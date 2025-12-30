from pydantic import BaseModel
from contextlib import contextmanager
import psycopg
from psycopg.rows import class_row


class Employee(BaseModel):
    employee_id: int
    first_name: str
    last_name: str
    email: str
    role: str
    is_active: bool
    counterpart: str


def get_employee(
        db: psycopg.Connection,
        email: str
):
    with db.cursor(row_factory=class_row(Employee)) as cur:
        return cur.execute(
            """
            SELECT employee_id,
                   first_name,
                   last_name,
                   e.email,
                   role,
                   e.is_active,
                   c.name AS counterpart
            FROM diamonds_are_forever.employee e
                     INNER JOIN diamonds_are_forever.counterpart c
                     ON e.counterpart_id = c.counterpart_id
            WHERE e.email = %s
            """,
            (email,),
        ).fetchone()

