from decimal import Decimal
from pydantic import BaseModel
import psycopg
from psycopg.rows import class_row


class LooseStone(BaseModel):
    lot_id: int
    weight_ct: Decimal
    shape: str
    length: Decimal
    width: Decimal
    depth: Decimal


def get_loose_stone(
    db: psycopg.Connection,
    item_id: int
):
    with db.cursor(row_factory=class_row(LooseStone)) as cur:
        return cur.execute(
            """
            SELECT 
                ls.lot_id, 
                ls.weight_ct,
                ls.shape,
                ls.length,
                ls.width,
                ls.depth
            FROM diamonds_are_forever.loose_stone ls
            WHERE ls.lot_id = %s
            """,
            (item_id,)
        ).fetchone()

