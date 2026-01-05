from datetime import datetime
from pydantic import BaseModel
from contextlib import contextmanager
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Item(BaseModel):
    lot_id: int
    stock_name: str
    purchase_date: datetime
    supplier_name: str
    origin: str
    responsible_office: str
    item_type: str
    is_available: bool
    created_at: datetime
    updated_at: datetime


@contextmanager
def items_cursor(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    order: sql.SQL = sql.SQL("i.updated_at DESC"),
    **other_params,
):
    """Yield a cursor that returns WhiteDiamonds objects
    """
    with db.cursor(row_factory=class_row(Item)) as cur:
        q = sql.SQL(
            """
            SELECT 
                lot_id, 
                stock_name, 
                purchase_date, 
                s.name AS supplier_name,
                origin, 
                ro.name AS responsible_office,
                item_type,
                is_available,
                i.created_at,
                i.updated_at
            FROM diamonds_are_forever.item i
                INNER JOIN diamonds_are_forever.counterpart s
                ON i.supplier_id = s.counterpart_id
                INNER JOIN diamonds_are_forever.counterpart ro
                ON i.responsible_office_id = ro.counterpart_id
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        yield cur.execute(q, other_params)

