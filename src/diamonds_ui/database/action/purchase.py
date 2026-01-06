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

