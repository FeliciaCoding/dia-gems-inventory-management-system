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
    type: str


@contextmanager
def counterpart_cursor(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    order: sql.SQL = sql.SQL("updated_at DESC"),
    **other_params,
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
                cat.type_name
            FROM diamonds_are_forever.counterpart c
                INNER JOIN diamonds_are_forever.counterpart_account_type cat
                ON c.counterpart_id = cat.counterpart_id
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        yield cur.execute(q, other_params)


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
                cat.type_name AS type
            FROM diamonds_are_forever.counterpart c
                INNER JOIN diamonds_are_forever.counterpart_account_type cat
                ON c.counterpart_id = cat.counterpart_id
            WHERE {condition}
            """
        ).format(
            condition=condition,
        )
        return cur.execute(q).fetchall()


