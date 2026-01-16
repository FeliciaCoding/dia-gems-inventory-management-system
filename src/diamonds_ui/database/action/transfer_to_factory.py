import psycopg
from datetime import date
from pydantic import BaseModel
from psycopg import sql
from psycopg.rows import class_row
from diamonds_ui.database.counterpart import Counterpart
from diamonds_ui.database.item.item import Item
from diamonds_ui.database.employee import Employee
from diamonds_ui.database.action.transfer_to_office import PriceWithCurrency


class TransferToFactory(BaseModel):
    action_id: int
    transfer_num: str
    ship_date: date
    processing_type: str


def get_transfers_to_factories(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE")
):
    with db.cursor(row_factory=class_row(TransferToFactory)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                transfer_num,
                ship_date,
                processing_type
            FROM diamonds_are_forever.transfer_to_factory
            WHERE {condition}
            """
        ).format(
            condition=condition
        )
        return cur.execute(q).fetchall()


def make_new_transfer_to_factory(
        db: psycopg.Connection,
        from_counterpart: Counterpart,
        to_counterpart: Counterpart,
        terms: str,
        remarks: str,
        transfer_num: str,
        ship_date: date,
        items_to_send: list[Item],
        employee: Employee,
        processing_type: str
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
    ({from_office_id}, {to_office_id}, {terms}, {remarks}, 'transfer to factory')
    RETURNING action_id
    """).format(
        from_office_id=from_counterpart.counterpart_id,
        to_office_id=to_counterpart.counterpart_id,
        terms=terms,
        remarks=remarks,
    )).fetchone()

    if not action:
        return None, "Transfer to factory: could not create a new action"

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
    INSERT INTO diamonds_are_forever.transfer_to_factory (
        action_id,
        transfer_num,
        ship_date,
        processing_type
    ) VALUES
    ({action_id}, {transfer_num}, {ship_date}, {processing_type})
    RETURNING action_id
    """).format(
        action_id=action[0],
        transfer_num=transfer_num,
        ship_date=ship_date,
        processing_type=processing_type,
    )).fetchone()

    if not transfer:
        return None, "Transfer to factory: could not create a new transfer to lab"

    return action[0], None


def get_transfers_to_factory_from_empl_office(
        db: psycopg.Connection,
        empl: Employee
):
    with db.cursor(row_factory=class_row(TransferToFactory)) as cur:
        q = sql.SQL(
            """
            SELECT
                ttf.action_id,
                ttf.transfer_num,
                ttf.ship_date,
                ttf.processing_type
            FROM diamonds_are_forever.transfer_to_factory ttf
                INNER JOIN diamonds_are_forever.action a
                ON ttf.action_id = a.action_id
            WHERE a.from_counterpart_id={office_id}
            """
        ).format(
            office_id=empl.office_id
        )
        return cur.execute(q).fetchall()

