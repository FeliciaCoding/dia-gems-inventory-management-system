from decimal import Decimal
from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Purchase(BaseModel):
    action_id: int
    purchase_num: str
    purchase_date: date

#
def create_purchase_white_diamonds(
        db: psycopg.Connection,
        employee_id: int,
        stock_name: str,
        purchase_date: date,
        purchase_num: str,
        origin: str,
        supplier_id: int,
        office_id: int,
        price: Decimal,
        currency: str,
        weight_ct: Decimal,
        shape: str,
        length: Decimal,
        width: Decimal,
        depth: Decimal,
        white_scale: str,
        clarity: str
 # return lot id for new stone
) -> int :
    with db.cursor() as cur:
        cur.execute("SET search_path TO diamonds_are_forever")
        # add into action
        # add into item
        # add into loose stone
        # add white diamond
        # add action_item
        # add purcahse
        # add log

        # commit and return


def get_purchases(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE"),
        **other_params,
):
    with db.cursor(row_factory=class_row(Purchase)) as cur:
        q = sql.SQL(
            """
            SELECT p.action_id,
                   purchase_num,
                   purchase_date
            FROM purchase p
            WHERE {condition}
            """
        ).format(
            condition=condition,
        )
        cur.execute("SET search_path TO diamonds_are_forever")
        return cur.execute(q, other_params).fetchall()
