from decimal import Decimal
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class ColoredGemStone(BaseModel):
    lot_id: int
    weight_ct: Decimal
    shape: str
    length: Decimal
    width: Decimal
    depth: Decimal
    gem_type: str
    gem_color: str
    treatment: str
    certificate_num: str


def get_colored_gemstones(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    order: sql.SQL = sql.SQL("c.updated_at DESC"),
    **other_params,
):
    with db.cursor(row_factory=class_row(ColoredGemStone)) as cur:
        q = sql.SQL(
            """
            SELECT 
                cgs.lot_id,
                ls.weight_ct,
                ls.shape,
                ls.length,
                ls.width,
                ls.depth,
                cgs.gem_type,
                cgs.gem_color,
                cgs.treatment,
                c.certificate_num
            FROM colored_gem_stone cgs
                INNER JOIN loose_stone ls
                ON cgs.lot_id = ls.lot_id
                INNER JOIN certificate c
                ON cgs.lot_id = c.lot_id
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        cur.execute("SET search_path TO diamonds_are_forever")
        return cur.execute(q, other_params).fetchall()

