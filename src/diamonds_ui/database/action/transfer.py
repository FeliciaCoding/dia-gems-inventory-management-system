from decimal import Decimal
from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Transfer(BaseModel):
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


def get_transfers_to(
        db: psycopg.Connection,
        table_name: str,
        lot_id: int,
        additional_cols: list[str]
):
    with db.cursor(row_factory=class_row(Transfer)) as cur:
        q = sql.SQL(
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
                transfer_num,
                {additional_columns}
            FROM action_item ai
                INNER JOIN action a
                ON ai.action_id = a.action_id
                INNER JOIN {table_name} t
                ON t.action_id = a.action_id
                INNER JOIN counterpart c1
                ON a.from_counterpart_id = c1.counterpart_id
                INNER JOIN counterpart c2
                ON a.to_counterpart_id = c2.counterpart_id
            WHERE ai.lot_id = {item_id}
            """
        ).format(
            # NOTE:
            # Basically we do hack with `["ship_date"] + additional_cols`
            # to avoid problems with a trailing comma in FROM
            additional_columns=sql.SQL(', ').join(map(
                lambda item: sql.Identifier(item),
                ["ship_date"] + additional_cols)),
            table_name=sql.Identifier(table_name),
            item_id=lot_id,
        )
        cur.execute("SET search_path TO diamonds_are_forever")
        return cur.execute(q).fetchall()



