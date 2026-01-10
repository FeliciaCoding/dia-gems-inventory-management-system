import psycopg
from datetime import date
from pydantic import BaseModel
from psycopg import sql
from psycopg.rows import class_row
from diamonds_ui.database.counterpart import Counterpart
from diamonds_ui.database.item.item import Item
from diamonds_ui.database.employee import Employee
from diamonds_ui.database.action.transfer_to_office import PriceWithCurrency

class TransferToLab(BaseModel):
    action_id: int
    transfer_num: str
    ship_date: date
    lab_purpose: str


def get_transfers_to_labs(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE")
):
    with db.cursor(row_factory=class_row(TransferToLab)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                transfer_num,
                ship_date,
                lab_purpose
            FROM diamonds_are_forever.transfer_to_lab
            WHERE {condition}
            """
        ).format(
            condition=condition
        )
        return cur.execute(q).fetchall()


def make_new_transfer_to_lab(
        db: psycopg.Connection,
        from_counterpart: Counterpart,
        to_counterpart: Counterpart,
        terms: str,
        remarks: str,
        transfer_num: str,
        ship_date: date,
        items_to_send: list[Item],
        employee: Employee,
        lab_purpose: str
) -> tuple[int | None, str | None]:
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
    ({from_office_id}, {to_office_id}, {terms}, {remarks}, 'transfer to lab')
    RETURNING action_id
    """).format(
        from_office_id=from_counterpart.counterpart_id,
        to_office_id=to_counterpart.counterpart_id,
        terms=terms,
        remarks=remarks,
    )).fetchone()

    if not action:
        return None, "Transfer to lab: could not create a new action"

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
    for item in items_to_send:
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
            lot_id=item.lot_id,
            price=item.price,
            currency_code=item.currency_code,
        ))

    # create new transfer to office
    transfer = db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.transfer_to_lab (
        action_id,
        transfer_num,
        ship_date,
        lab_purpose
    ) VALUES
    ({action_id}, {transfer_num}, {ship_date}, {lab_purpose})
    RETURNING action_id
    """).format(
        action_id=action[0],
        transfer_num=transfer_num,
        ship_date=ship_date,
        lab_purpose=lab_purpose,
    )).fetchone()

    if not transfer:
        return None, "Transfer to lab: could not create a new transfer to lab"

    return action[0], None


def get_transfers_to_labs_where_empl_works(db: psycopg.Connection, empl: Employee):
    with db.cursor(row_factory=class_row(TransferToLab)) as cur:
        q = sql.SQL(
            """
            SELECT 
                ttl.action_id,
                ttl.transfer_num,
                ttl.ship_date,
                ttl.lab_purpose
            FROM diamonds_are_forever.transfer_to_lab ttl
                INNER JOIN diamonds_are_forever.action a
                ON ttl.action_id = a.action_id
            WHERE a.from_counterpart_id={office_id}
            """
        ).format(
            office_id=empl.office_id
        )
        return cur.execute(q).fetchall()


