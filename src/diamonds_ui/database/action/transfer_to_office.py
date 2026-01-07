from typing import NamedTuple

import psycopg
from datetime import date
from decimal import Decimal
from pydantic import BaseModel
from psycopg import sql
from psycopg.rows import class_row
from diamonds_ui.database.counterpart import Counterpart
from diamonds_ui.database.item.item import Item
from diamonds_ui.database.employee import Employee


class TransferToOffice(BaseModel):
    action_id: int
    transfer_num: str
    ship_date: date


class PriceInCurrency(NamedTuple):
    price: Decimal
    currency_code: str


def get_transfers_between_offices(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE"),
        **other_params
):
    with db.cursor(row_factory=class_row(TransferToOffice)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                transfer_num,
                ship_date
            FROM diamonds_are_forever.transfer_to_office
            WHERE {condition}
            """
        ).format(
            condition=condition
        )
        return cur.execute(q).fetchall()


def make_new_transfer_to_office(
        db: psycopg.Connection,
        from_counterpart: Counterpart,
        to_counterpart: Counterpart,
        terms: str,
        remarks: str,
        prices: dict[str, PriceInCurrency],
        transfer_num: str,
        ship_date: date,
        items_to_send: list[Item],
        employee: Employee
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
    ({from_office_id}, {to_office_id}, {terms}, {remarks}, 'transfer to office')
    RETURNING action_id
    """).format(
        from_office_id=from_counterpart.counterpart_id,
        to_office_id=to_counterpart.counterpart_id,
        terms=terms,
        remarks=remarks,
    )).fetchone()

    if not action:
        return None, "Transfer to office: could not create a new action"

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
                quantity, 
                unit_price, 
                currency_code
            ) VALUES
            ({action_id}, {lot_id}, 1, {price}, {currency_code})
            """).format(
            action_id=action[0],
            lot_id=item.lot_id,
            price=prices[item.stock_name].price,
            currency_code=prices[item.stock_name].currency_code,
        ))

    # create new transfer to office
    transfer = db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.transfer_to_office (
        action_id, 
        transfer_num, 
        ship_date 
    ) VALUES
    ({action_id}, {transfer_num}, {ship_date})
    RETURNING action_id
    """).format(
        action_id=action[0],
        transfer_num=transfer_num,
        ship_date=ship_date,
    )).fetchone()

    if not transfer:
        return None, "Transfer to office: could not create a new transfer to office"

    return action[0], None

