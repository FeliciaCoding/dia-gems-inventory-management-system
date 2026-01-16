from decimal import Decimal
from datetime import datetime
from pydantic import BaseModel
from contextlib import contextmanager
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class WhiteDiamond(BaseModel):
    lot_id: int
    weight_ct: Decimal
    shape: str
    length: Decimal
    width: Decimal
    depth: Decimal
    white_scale: str
    clarity: str
    certificate_num: str | None = None


def get_white_diamonds(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    order: sql.SQL = sql.SQL("i.updated_at DESC"),
    **other_params,
):
    with db.cursor(row_factory=class_row(WhiteDiamond)) as cur:
        q = sql.SQL(
            """
            SELECT 
                wd.lot_id, 
                ls.weight_ct,
                ls.shape,
                ls.length,
                ls.width,
                ls.depth,
                wd.white_scale,
                wd.clarity,
                c.certificate_num
            FROM item i
                INNER JOIN white_diamond wd 
                ON wd.lot_id = i.lot_id
                INNER JOIN loose_stone ls
                ON wd.lot_id = ls.lot_id
                LEFT JOIN certificate c
                ON wd.lot_id = c.lot_id
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        cur.execute("SET search_path TO diamonds_are_forever")
        return cur.execute(q, other_params).fetchall()

