from decimal import Decimal
from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg.rows import class_row


class Purchase(BaseModel):
    action_id: int
    from_counterpart_name: str
    to_counterpart_name: str
    terms: str
    remarks: str
    price: Decimal
    currency_code: str
    created_at: datetime
    updated_at: datetime
    transfer_num: str
    ship_date: date


def get_purchase(
        db: psycopg.Connection,
        lot_id: int
):
    with db.cursor(row_factory=class_row(Purchase)) as cur:
        return cur.execute(
            """
            SELECT a.action_id,
                c1.name AS from_counterpart_name,
                c2.name AS to_counterpart_name,
                terms,
                remarks,
                (ai.unit_price * ai.quantity) AS price,
                currency_code,
                a.created_at,
                a.updated_at,
                purchase_num AS transfer_num,
                purchase_date AS ship_date
            FROM diamonds_are_forever.action_item ai
                INNER JOIN diamonds_are_forever.action a
                ON ai.action_id = a.action_id
                INNER JOIN diamonds_are_forever.purchase p
                ON p.action_id = a.action_id
                INNER JOIN diamonds_are_forever.counterpart c1
                ON a.from_counterpart_id = c1.counterpart_id
                INNER JOIN diamonds_are_forever.counterpart c2
                ON a.to_counterpart_id = c2.counterpart_id
            WHERE ai.lot_id = %s
            """,
            (lot_id,),
        ).fetchone()

