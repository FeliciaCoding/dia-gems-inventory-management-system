import psycopg
from datetime import date
from decimal import Decimal
from pydantic import BaseModel
from psycopg import sql
from psycopg.rows import class_row
from diamonds_ui.database.counterpart import Counterpart
from diamonds_ui.database.item.item import Item, PricedItem
from diamonds_ui.database.employee import Employee
from diamonds_ui.database.action.transfer_to_office import PriceWithCurrency
from diamonds_ui.database.action.transfer_to_factory import TransferToFactory
from diamonds_ui.database.action.action import (
    Action,
    get_action
)


class ReturnFromFactory(BaseModel):
    """Represents an item returned from factory after processing (recutting/polishing)"""
    action_id: int
    orig_transfer_id: int
    back_from_fac_num: str
    back_date: date
    before_weight_ct: Decimal
    before_shape: str
    before_length: Decimal
    before_width: Decimal
    before_depth: Decimal
    after_weight_ct: Decimal
    after_shape: str
    after_length: Decimal
    after_width: Decimal
    after_depth: Decimal
    weight_loss_ct: Decimal
    note: str | None


def get_returns_from_factories(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE")
):
    """
    Retrieves all returns from factory with optional filtering.

    Returns complete before/after measurements for items that underwent factory processing.
    """
    with db.cursor(row_factory=class_row(ReturnFromFactory)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                orig_transfer_id,
                back_from_fac_num,
                back_date,
                before_weight_ct,
                before_shape,
                before_length,
                before_width,
                before_depth,
                after_weight_ct,
                after_shape,
                after_length,
                after_width,
                after_depth,
                weight_loss_ct,
                note
            FROM diamonds_are_forever.back_from_factory
            WHERE {condition}
            """
        ).format(
            condition=condition
        )
        return cur.execute(q).fetchall()


def get_pending_items_for_factory(
        db: psycopg.Connection,
        transfer: TransferToFactory
):
    """
    Finds items still at factory (not yet returned).

    Compares items sent to factory vs items returned to identify pending items.
    Returns items that are still being processed.
    """
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
                    FROM diamonds_are_forever.transfer_to_factory ttf
                        INNER JOIN diamonds_are_forever.action_item ai
                        ON ttf.action_id = ai.action_id
                    WHERE ttf.action_id = {transfer_id}
                ),
                returned_items AS (
                    SELECT ai.lot_id
                    FROM diamonds_are_forever.back_from_factory bff
                        INNER JOIN diamonds_are_forever.action_item ai
                        ON bff.action_id = ai.action_id
                    WHERE bff.orig_transfer_id = {transfer_id}
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
            ORDER BY i.lot_id, a.created_at DESC
            """
        ).format(
            transfer_id=transfer.action_id
        )
        return cur.execute(q).fetchall()


def make_new_return_from_factory(
    db: psycopg.Connection,
    *,
    orig_transfer: TransferToFactory,
    terms: str | None,
    remarks: str | None,
    employee: Employee,
    transfer_num: str,
    back_date: date,
    item_to_return: Item,
    weight_ct: Decimal,
    width: Decimal,
    length: Decimal,
    depth: Decimal,
    shape: str,
    note: str
):
    """
    Registers an item's return from factory after processing.

    Creates action, action_item, and back_from_factory records with new measurements.
    Logs the action and updates item status.
    Returns (action_id, error_message) tuple.
    """
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
    ({from_counterpart_id}, {to_counterpart_id}, {terms}, {remarks}, 'return from factory')
    RETURNING action_id
    """).format(
        from_counterpart_id=orig_action.to_counterpart_id,
        to_counterpart_id=orig_action.from_counterpart_id,
        terms=terms,
        remarks=remarks
    )).fetchone()

    if not action:
        return None, "Return from factory: could not create a new action"

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

    # create new return from factory
    transfer = db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.back_from_factory (
        action_id,
        orig_transfer_id,
        back_from_fac_num,
        back_date,
        after_weight_ct,
        after_shape,
        after_length,
        after_width,
        after_depth,
        note
    ) VALUES
    ({action_id}, {orig_transfer_id}, {transfer_num}, {back_date}, 
     {after_weight_ct}, {after_shape}, {after_length}, {after_width}, 
     {after_depth}, {note})
    RETURNING action_id
    """).format(
        action_id=action[0],
        orig_transfer_id=orig_transfer.action_id,
        transfer_num=transfer_num,
        back_date=back_date,
        after_weight_ct=weight_ct,
        after_shape=shape,
        after_length=length,
        after_width=width,
        after_depth=depth,
        note=note
    )).fetchone()

    if not transfer:
        return None, "Return from factory: cannot create a new return from factory"

    return action[0], None
