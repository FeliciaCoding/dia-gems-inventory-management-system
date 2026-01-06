from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class TransferToOffice(BaseModel):
    action_id: int
    transfer_num: str
    ship_date: date


def get_transfers_between_offices(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE"),
        **other_params,
):
    with db.cursor(row_factory=class_row(TransferToOffice)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                transfer_num,
                ship_date
            FROM diamonds_are_forever.transfer_to_office
            WHERE {condition}
            """
        ).format(
            condition=condition
        )
        return cur.execute(q).fetchall()

