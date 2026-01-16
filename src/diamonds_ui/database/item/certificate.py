from decimal import Decimal
from datetime import datetime
from pydantic import BaseModel
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


def get_certificates(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("c.is_valid")
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
            ORDER BY c.created_at DESC
            """
        ).format(
            condition=condition
        )
        return cur.execute(q).fetchall()


def get_certificate(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("c.is_valid")

):
    with db.cursor(row_factory=class_row(Certificate)) as cur:
        return cur.execute(sql.SQL(
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
            """
        ).format(condition=condition)).fetchone()

