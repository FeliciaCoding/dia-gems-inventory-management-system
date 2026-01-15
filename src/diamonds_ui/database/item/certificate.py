from decimal import Decimal
from datetime import datetime
from pydantic import BaseModel
from contextlib import contextmanager
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Certificate(BaseModel):
    lot_id: int
    stock_name: str
    lab_id: int
    lab_name: str
    certificate_num: str
    issue_date: datetime
    shape: str
    weight_ct: Decimal
    length: Decimal
    width: Decimal
    depth: Decimal
    clarity: str | None
    color: str | None
    treatment: str | None
    gem_type: str
    is_valid: bool


@contextmanager
def certificates_cursor(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    order: sql.SQL = sql.SQL("updated_at DESC"),
    **other_params,
):
    with db.cursor(row_factory=class_row(Certificate)) as cur:
        q = sql.SQL(
            """
            SELECT 
                c.lot_id, 
                i.stock_name,
                c.lab_id, 
                l.name AS lab_name, 
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
                gem_type,
                is_valid
            FROM diamonds_are_forever.certificate c
                INNER JOIN diamonds_are_forever.counterpart l
                ON c.lab_id = l.counterpart_id
                INNER JOIN diamonds_are_forever.item i
                ON c.lot_id = i.lot_id
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        yield cur.execute(q, other_params)


def get_certificate(
    db: psycopg.Connection,
    certificate_num: str
):
    with db.cursor(row_factory=class_row(Certificate)) as cur:
        return cur.execute(
            """
            SELECT 
                c.lot_id, 
                i.stock_name,
                c.lab_id, 
                l.name AS lab_name, 
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
                gem_type,
                is_valid
            FROM diamonds_are_forever.certificate c
                INNER JOIN diamonds_are_forever.counterpart l
                ON c.lab_id = l.counterpart_id
                INNER JOIN diamonds_are_forever.item i
                ON c.lot_id = i.lot_id
            WHERE c.certificate_num = %s
            """,
            (certificate_num,)
        ).fetchone()

