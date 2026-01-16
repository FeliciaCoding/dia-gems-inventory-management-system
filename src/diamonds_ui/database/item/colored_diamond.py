from decimal import Decimal
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class ColoredDiamond(BaseModel):
    lot_id: int
    weight_ct: Decimal
    shape: str
    length: Decimal
    width: Decimal
    depth: Decimal
    fancy_intensity: str
    fancy_overtone: str
    fancy_color: str
    clarity: str
    certificate_num: str | None = None


def get_colored_diamonds(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    order: sql.SQL = sql.SQL("c.updated_at DESC"),
    **other_params,
):
    with db.cursor(row_factory=class_row(ColoredDiamond)) as cur:
        q = sql.SQL(
            """
            SELECT
                cd.lot_id, 
                ls.weight_ct,
                ls.shape,
                ls.length,
                ls.width,
                ls.depth,
                cd.fancy_intensity, 
                cd.fancy_overtone, 
                cd.fancy_color,
                cd.clarity, 
                c.certificate_num
            FROM item i
            JOIN colored_diamond cd ON i.lot_id = cd.lot_id
            JOIN loose_stone ls ON i.lot_id = ls.lot_id
            LEFT JOIN certificate c ON i.lot_id = c.lot_id
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        cur.execute("SET search_path TO diamonds_are_forever")
        return cur.execute(q, other_params).fetchall()

