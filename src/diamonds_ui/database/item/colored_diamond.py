from decimal import Decimal
from datetime import datetime
from pydantic import BaseModel
from contextlib import contextmanager
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class ColoredDiamond(BaseModel):
    lot_id: int
    stock_name: str
    purchase_date: datetime
    supplier_name: str
    origin: str
    responsible_office: str
    physical_location: str
    is_available: bool
    weight_ct: Decimal
    shape: str
    fancy_intensity: str
    fancy_overtone: str
    fancy_color: str
    clarity: str
    certificate_num: str


@contextmanager
def colored_diamonds_cursor(
    db: psycopg.Connection,
    condition: sql.SQL = sql.SQL("TRUE"),
    order: sql.SQL = sql.SQL("updated_at DESC"),
    **other_params,
):
    with db.cursor(row_factory=class_row(ColoredDiamond)) as cur:
        q = sql.SQL(
            """
            SELECT lot_id, stock_name, purchase_date, supplier_name,
                origin, responsible_office, physical_location,
                is_available, weight_ct, shape,
                fancy_intensity, fancy_overtone, fancy_color,
                clarity, certificate_num
            FROM diamonds_are_forever.complete_inventory_colored_diamonds
            WHERE {condition}
            ORDER BY {order}
            """
        ).format(
            condition=condition,
            order=order,
        )
        yield cur.execute(q, other_params)

