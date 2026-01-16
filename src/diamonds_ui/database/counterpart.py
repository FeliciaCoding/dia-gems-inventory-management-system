from datetime import datetime
from pydantic import BaseModel
from contextlib import contextmanager
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Counterpart(BaseModel):
    counterpart_id: int
    name: str
    phone_number: str | None
    city: str | None
    postal_code: str | None
    country: str | None
    email: str | None
    is_active: bool
    type_name: str
    category: str


def get_counterparts(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE")
):
    with db.cursor(row_factory=class_row(Counterpart)) as cur:
        q = sql.SQL(
            """
            SELECT 
                c.counterpart_id, 
                name, 
                phone_number,
                city, 
                postal_code, 
                country, 
                email, 
                is_active,
                cat.type_name,
                atype.category
            FROM diamonds_are_forever.counterpart c
                INNER JOIN diamonds_are_forever.counterpart_account_type cat
                ON c.counterpart_id = cat.counterpart_id
                INNER JOIN diamonds_are_forever.account_type atype
                ON cat.type_name = atype.type_name
            WHERE {condition}
            """
        ).format(
            condition=condition,
        )
        return cur.execute(q).fetchall()


def get_counterpart(
    db: psycopg.Connection,
    id: int
):
    with db.cursor(row_factory=class_row(Counterpart)) as cur:
        return cur.execute(
            """
            SELECT 
                c.counterpart_id, 
                name, 
                phone_number,
                city, 
                postal_code, 
                country, 
                email, 
                is_active,
                cat.type_name,
                atype.category
            FROM diamonds_are_forever.counterpart c
                INNER JOIN diamonds_are_forever.counterpart_account_type cat
                ON c.counterpart_id = cat.counterpart_id
                INNER JOIN diamonds_are_forever.account_type atype
                ON cat.type_name = atype.type_name
            WHERE c.counterpart_id = %s
            """,
            (id,)
        ).fetchone()

