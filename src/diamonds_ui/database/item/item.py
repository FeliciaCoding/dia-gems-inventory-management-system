from datetime import datetime
from decimal import Decimal
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


class PricedItem(Item):
    price: Decimal
    currency_code: str


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


def get_item(
    db: psycopg.Connection,
    lot_id: int,
):
    with db.cursor(row_factory=class_row(Item)) as cur:
        return cur.execute(
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
            WHERE i.lot_id = %s
            """,
            (lot_id,),
        ).fetchone()


def get_items_for_action(
    db: psycopg.Connection,
    action_id: int,
):
    with db.cursor(row_factory=class_row(PricedItem)) as cur:
        return cur.execute(
            """
            SELECT 
                i.lot_id, 
                i.stock_name, 
                i.purchase_date, 
                s.name AS supplier_name,
                i.origin, 
                ro.name AS responsible_office,
                i.item_type,
                i.is_available,
                i.created_at,
                i.updated_at,
                ai.price,
                ai.currency_code
            FROM diamonds_are_forever.action_item ai
                INNER JOIN diamonds_are_forever.item i
                ON ai.lot_id = i.lot_id
                INNER JOIN diamonds_are_forever.counterpart s
                ON i.supplier_id = s.counterpart_id
                INNER JOIN diamonds_are_forever.counterpart ro
                ON i.responsible_office_id = ro.counterpart_id
            WHERE ai.action_id = %s
            """,
            (action_id,),
        ).fetchall()


def get_items_stored_in_office(
    db: psycopg.Connection,
    office_id: int,
):
    with db.cursor(row_factory=class_row(PricedItem)) as cur:
        return cur.execute(
            """
            SELECT DISTINCT ON (i.lot_id)
                i.lot_id,
                i.stock_name,
                i.purchase_date,
                s.name AS supplier_name,
                i.origin,
                ro.name AS responsible_office,
                i.item_type,
                i.is_available,
                i.created_at,
                i.updated_at,
                ai.price,
                ai.currency_code
            FROM diamonds_are_forever.action a
                INNER JOIN diamonds_are_forever.action_item ai
                ON a.action_id = ai.action_id
                INNER JOIN diamonds_are_forever.item i
                ON ai.lot_id = i.lot_id
                INNER JOIN diamonds_are_forever.counterpart s
                ON i.supplier_id = s.counterpart_id
                INNER JOIN diamonds_are_forever.counterpart ro
                ON i.responsible_office_id = ro.counterpart_id
            WHERE a.to_counterpart_id = %s
            ORDER BY i.lot_id, a.updated_at DESC
            """,
            (office_id,),
        ).fetchall()



