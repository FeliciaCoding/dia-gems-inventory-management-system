from decimal import Decimal
from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg.rows import class_row


class Action(BaseModel):
    action_id: int
    from_counterpart_name: str | None
    to_counterpart_name: str | None
    terms: str | None
    remarks: str | None
    action_category: str | None
    price: Decimal
    currency_code: str
    created_at: datetime
    updated_at: datetime


def get_actions(
        db: psycopg.Connection,
        lot_id: int
):
    with db.cursor(row_factory=class_row(Action)) as cur:
        return cur.execute(
            """
            SELECT a.action_id,
                c1.name AS from_counterpart_name,
                c2.name AS to_counterpart_name,
                terms,
                remarks,
                action_category,
                (ai.unit_price * ai.quantity) AS price,
                currency_code,
                a.created_at,
                a.updated_at
            FROM diamonds_are_forever.action_item ai
                INNER JOIN diamonds_are_forever.action a
                ON ai.action_id = a.action_id
                INNER JOIN diamonds_are_forever.counterpart c1
                ON a.from_counterpart_id = c1.counterpart_id
                INNER JOIN diamonds_are_forever.counterpart c2
                ON a.to_counterpart_id = c2.counterpart_id
            WHERE ai.lot_id = %s
            """,
            (lot_id,),
        ).fetchall()


def get_action(
        db: psycopg.Connection,
        action_id: int
):
    with db.cursor(row_factory=class_row(Action)) as cur:
        return cur.execute(
            """
            SELECT a.action_id,
                   c1.name                       AS from_counterpart_name,
                   c2.name                       AS to_counterpart_name,
                   terms,
                   remarks,
                   action_category,
                   (ai.unit_price * ai.quantity) AS price,
                   currency_code,
                   a.created_at,
                   a.updated_at
            FROM diamonds_are_forever.action a
                INNER JOIN diamonds_are_forever.counterpart c1
                ON a.from_counterpart_id = c1.counterpart_id
                INNER JOIN diamonds_are_forever.counterpart c2
                ON a.to_counterpart_id = c2.counterpart_id
            WHERE a.action_id = %s
            """,
            (action_id,)
        ).fetchone()

