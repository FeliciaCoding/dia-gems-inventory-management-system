from decimal import Decimal
from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Sale(BaseModel):
    action_id: int
    sale_num: str | None
    sale_date: date | None
    payment_method: str | None
    payment_status: str | None


def get_sales(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE"),
        **other_params,
):
    with db.cursor(row_factory=class_row(Sale)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                sale_num,
                sale_date,
                payment_method,
                payment_status
            FROM diamonds_are_forever.sale s
            WHERE {condition}
            """
        ).format(
            condition=condition,
        )
        return cur.execute(q, other_params).fetchall()

