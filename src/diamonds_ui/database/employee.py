from pydantic import BaseModel
from contextlib import contextmanager
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Employee(BaseModel):
    employee_id: int
    first_name: str
    last_name: str
    email: str
    role: str
    is_active: bool
    counterpart: str


@contextmanager
def employee_cursor(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    order: sql.SQL = sql.SQL("updated_at DESC"),
    **other_params,
):
    with db.cursor(row_factory=class_row(Employee)) as cur:
        q = sql.SQL(
            """
            SELECT employee_id, first_name, last_name, 
                   email, role, is_active, c.name
            FROM diamonds_are_forever.employee e
                INNER JOIN diamonds_are_forever.counterpart c
                ON e.counterpart_id = c.counterpart_id
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        yield cur.execute(q, other_params)



