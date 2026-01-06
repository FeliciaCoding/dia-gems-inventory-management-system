from decimal import Decimal
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Jewelry(BaseModel):
    lot_id: int
    jewelry_type: str
    gross_weight_gr: Decimal
    metal_type: str
    metal_weight_gr: Decimal
    total_center_stone_qty: int
    total_center_stone_weight_ct: Decimal
    centered_stone_type: str
    total_side_stone_qty: int
    total_side_stone_weight_ct: Decimal
    side_stone_type: str


def get_jewelries(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    **other_params,
):
    with db.cursor(row_factory=class_row(Jewelry)) as cur:
        q = sql.SQL(
            """
            SELECT 
                lot_id,
                jewelry_type,
                gross_weight_gr,
                metal_type,
                metal_weight_gr,
                total_center_stone_qty,
                total_center_stone_weight_ct,
                centered_stone_type,
                total_side_stone_qty,
                total_side_stone_weight_ct,
                side_stone_type
            FROM jewelry j
            WHERE {condition}
            """
        ).format(
            condition=condition,
        )
        cur.execute("SET search_path TO diamonds_are_forever")
        return cur.execute(q, other_params).fetchall()

