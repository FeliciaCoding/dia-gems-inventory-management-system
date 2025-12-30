from decimal import Decimal
from datetime import datetime
from pydantic import BaseModel
from contextlib import contextmanager
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Certificate(BaseModel):
    certificate_id: int
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
    clarity: str
    color: str
    treatment: str
    gem_type: str


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
            SELECT certificate_id, c.lot_id, stock_name,
                l.lab_id, lab_name, certificate_num,
                issue_date, shape, weight_ct,
                length, width, depth, clarity,
                color, treatment, gem_type
            FROM diamonds_are_forever.certificate c
                INNER JOIN lab l
                ON c.lab_id = l.lab_id
                INNER JOIN item i
                ON c.lot_id = i.lot_id
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        yield cur.execute(q, other_params)

