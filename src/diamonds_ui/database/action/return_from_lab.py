import psycopg
from datetime import date
from pydantic import BaseModel
from psycopg import sql
from psycopg.rows import class_row
from diamonds_ui.database.counterpart import Counterpart
from diamonds_ui.database.item.item import Item
from diamonds_ui.database.employee import Employee
from diamonds_ui.database.action.transfer_to_office import PriceWithCurrency
from diamonds_ui.database.action.transfer_to_lab import TransferToLab


class ReturnFromLab(BaseModel):
    action_id: int
    orig_transfer_id: int
    back_from_lab_num: str
    back_date: date
    new_certificate_id: int


def get_returns_from_labs(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE")
):
    with db.cursor(row_factory=class_row(ReturnFromLab)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                orig_transfer_id,
                back_from_lab_num,
                back_date,
                new_certificate_id
            FROM diamonds_are_forever.back_from_lab
            WHERE {condition}
            """
        ).format(
            condition=condition
        )
        return cur.execute(q).fetchall()


def get_pending_items_for_lab(
        db: psycopg.Connection,
        transfer: TransferToLab
):
    with db.cursor(row_factory=class_row(Item)) as cur:
        q = sql.SQL(
            """
            SELECT 
                i.lot_id, 
                i.stock_name, 
                i.purchase_date, 
                s.name AS supplier_name,
                i.origin, 
                ro.name AS responsible_office,
                i.item_type,
                i.is_available,
                i.created_at,
                i.updated_at
            FROM (
                WITH all_items AS (
                    SELECT ai.lot_id
                    FROM diamonds_are_forever.transfer_to_lab ttl
                        INNER JOIN diamonds_are_forever.action_item ai
                        ON ttl.action_id = ai.action_id
                    WHERE ttl.action_id = {transfer_id}
                ),
                returned_items AS (
                    SELECT ai.lot_id
                    FROM diamonds_are_forever.back_from_lab bfl
                        INNER JOIN diamonds_are_forever.action_item ai
                        ON bfl.action_id = ai.action_id
                    WHERE bfl.orig_transfer_id = {transfer_id}               
                )
                SELECT lot_id FROM all_items
                EXCEPT
                SELECT lot_id FROM returned_items
            ) pending_item
                INNER JOIN diamonds_are_forever.item i
                ON pending_item.lot_id = i.lot_id
                INNER JOIN diamonds_are_forever.counterpart s
                ON i.supplier_id = s.counterpart_id
                INNER JOIN diamonds_are_forever.counterpart ro
                ON i.responsible_office_id = ro.counterpart_id
            """
        ).format(
            transfer_id=transfer.action_id
        )
        return cur.execute(q).fetchall()


