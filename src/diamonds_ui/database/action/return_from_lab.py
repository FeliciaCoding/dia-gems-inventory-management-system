import psycopg
from datetime import date, datetime
from decimal import Decimal
from pydantic import BaseModel
from psycopg import sql
from psycopg.rows import class_row
from diamonds_ui.database.counterpart import Counterpart
from diamonds_ui.database.item.item import Item, PricedItem
from diamonds_ui.database.employee import Employee
from diamonds_ui.database.action.transfer_to_office import PriceWithCurrency
from diamonds_ui.database.action.transfer_to_lab import TransferToLab
from diamonds_ui.database.action.action import (
    Action, get_action
)


class ReturnFromLab(BaseModel):
    action_id: int
    orig_transfer_id: int
    back_from_lab_num: str
    back_date: date
    new_certificate_num: str


def get_returns_from_labs(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE")
):
    with db.cursor(row_factory=class_row(ReturnFromLab)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                orig_transfer_id,
                back_from_lab_num,
                back_date,
                new_certificate_num
            FROM diamonds_are_forever.back_from_lab
            WHERE {condition}
            """
        ).format(
            condition=condition
        )
        return cur.execute(q).fetchall()


def get_pending_items_for_lab(
        db: psycopg.Connection,
        transfer: TransferToLab
):
    with db.cursor(row_factory=class_row(PricedItem)) as cur:
        q = sql.SQL(
            """
            SELECT DISTINCT ON (i.lot_id)
                i.lot_id, 
                i.stock_name, 
                i.purchase_date, 
                s.name AS supplier_name,
                i.origin, 
                ro.name AS responsible_office,
                i.item_type,
                i.is_available,
                i.created_at,
                i.updated_at,
                ai.price,
                ai.currency_code
            FROM (
                WITH all_items AS (
                    SELECT ai.lot_id
                    FROM diamonds_are_forever.transfer_to_lab ttl
                        INNER JOIN diamonds_are_forever.action_item ai
                        ON ttl.action_id = ai.action_id
                    WHERE ttl.action_id = {transfer_id}
                ),
                returned_items AS (
                    SELECT ai.lot_id
                    FROM diamonds_are_forever.back_from_lab bfl
                        INNER JOIN diamonds_are_forever.action_item ai
                        ON bfl.action_id = ai.action_id
                    WHERE bfl.orig_transfer_id = {transfer_id}               
                )
                SELECT lot_id FROM all_items
                EXCEPT
                SELECT lot_id FROM returned_items
            ) pending_item
                INNER JOIN diamonds_are_forever.item i
                ON pending_item.lot_id = i.lot_id
                INNER JOIN diamonds_are_forever.counterpart s
                ON i.supplier_id = s.counterpart_id
                INNER JOIN diamonds_are_forever.counterpart ro
                ON i.responsible_office_id = ro.counterpart_id
                INNER JOIN diamonds_are_forever.action_item ai
                ON i.lot_id = ai.lot_id
                INNER JOIN diamonds_are_forever.action a
                ON ai.action_id = a.action_id
            ORDER BY i.lot_id, a.updated_at DESC
            """
        ).format(
            transfer_id=transfer.action_id
        )
        return cur.execute(q).fetchall()


def make_new_return_from_lab(
    db: psycopg.Connection,
    *,
    orig_transfer: TransferToLab,
    terms: str | None,
    remarks: str | None,
    employee: Employee,
    transfer_num: str,
    back_date: date,
    item_to_return: Item,
    certificate_num: str,
    issue_date: datetime,
    weight_ct: Decimal,
    width: Decimal,
    length: Decimal,
    depth: Decimal,
    shape: str,
    clarity: str | None,
    gem_type: str,
    gem_color: str | None,
    treatment: str | None
):
    # use original action to find office and lab
    orig_action = get_action(db, orig_transfer.action_id)

    # create new action
    action = db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.action (
        from_counterpart_id,
        to_counterpart_id,
        terms,
        remarks,
        action_category
    ) VALUES
    ({from_counterpart_id}, {to_counterpart_id}, {terms}, {remarks}, 'return from lab')
    RETURNING action_id
    """).format(
        from_counterpart_id=orig_action.from_counterpart_id,
        to_counterpart_id=orig_action.to_counterpart_id,
        terms=terms,
        remarks=remarks,
    )).fetchone()

    if not action:
        return None, "Return from lab: could not create a new action"

    # reflect action creation in action_update_log
    db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.action_update_log (
        action_id,
        employee_id,
        update_type
    ) VALUES
    ({action_id}, {employee_id}, 'Insert')
    """).format(
        action_id=action[0],
        employee_id=employee.employee_id,
    ))

    # create action_item link for every item in items_to_send
    db.execute(sql.SQL(
        """
        INSERT INTO diamonds_are_forever.action_item (
            action_id,
            lot_id,
            price,
            currency_code
        ) VALUES
        ({action_id}, {lot_id}, {price}, {currency_code})
        """).format(
        action_id=action[0],
        lot_id=item_to_return.lot_id,
        price=item_to_return.price,
        currency_code=item_to_return.currency_code,
    ))

    # create new certificate
    certificate = db.execute(sql.SQL(
    """
     INSERT INTO diamonds_are_forever.certificate(
        lot_id, 
        lab_id, 
        certificate_num, 
        issue_date, 
        shape, 
        weight_ct, 
        length, 
        width, 
        depth, 
        clarity, 
        color, 
        treatment, 
        gem_type
    ) VALUES
    ({item_id}, {lab_id}, {cert_num}, {issue_date}, {shape}, 
     {weight_ct}, {length}, {width}, {depth}, 
     {diamond_clarity}, {gem_color}, {gem_treatment}, {gem_type})
    RETURNING certificate_num
    """).format(
        item_id=item_to_return.lot_id,
        lab_id=orig_action.to_counterpart_id,
        cert_num=certificate_num,
        issue_date=issue_date,
        shape=shape,
        weight_ct=weight_ct,
        length=length,
        width=width,
        depth=depth,
        diamond_clarity=clarity,
        gem_color=gem_color,
        gem_treatment=treatment,
        gem_type=gem_type
    )).fetchone()

    if not certificate:
        return None, "Return from lab: cannot create certificate"

    # create new return from lab
    transfer = db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.back_from_lab (
        action_id,
        orig_transfer_id,
        back_from_lab_num,
        back_date,
        new_certificate_num
    ) VALUES
    ({action_id}, {orig_transfer_id}, {transfer_num}, {back_date}, {new_cert_num})
    RETURNING action_id
    """).format(
        action_id=action[0],
        orig_transfer_id=orig_transfer.action_id,
        transfer_num=transfer_num,
        back_date=back_date,
        new_cert_num=certificate[0]
    )).fetchone()

    if not transfer:
        return None, "Return from lab: cannot create a new transfer to lab"

    return action[0], None

