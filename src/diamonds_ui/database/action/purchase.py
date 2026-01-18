from decimal import Decimal
from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row


class Purchase(BaseModel):
    action_id: int
    purchase_num: str
    purchase_date: date

#
def create_purchase_white_diamonds(
        db: psycopg.Connection,
        employee_id: int,
        stock_name: str,
        purchase_date: date,
        purchase_num: str,
        origin: str,
        supplier_id: int,
        office_id: int,
        price: Decimal,
        currency: str,
        weight_ct: Decimal,
        shape: str,
        length: Decimal,
        width: Decimal,
        depth: Decimal,
        white_scale: str,
        clarity: str,
        certificate_num: str | None = None,
        cert_lab_id: int | None = None,
        cert_issue_date: date | None = None
) -> int :
    with db.cursor() as cur:
        cur.execute("SET search_path TO diamonds_are_forever")

        # add into action
        # execute(sql_query, parameter) method: https://www.psycopg.org/psycopg3/docs/api/cursors.html#psycopg.Cursor.execute
        # Parameters: https://www.psycopg.org/psycopg3/docs/basic/params.html
        cur.execute("""
        INSERT INTO action(from_counterpart_id, to_counterpart_id, action_category) 
        values(%s, %s, 'purchase')
        returning action_id
        """, (supplier_id, office_id)) # should return {int}
        action_id = cur.fetchone()[0]

        # add into item
        cur.execute("""
        insert into item(stock_name, purchase_date, supplier_id, origin, responsible_office_id, item_type)
        values(%s, %s, %s, %s, %s, 'white diamond')
        returning lot_id
        """, (stock_name, purchase_date, supplier_id, origin, office_id))
        lot_id = cur.fetchone()[0]

        # add cert
        if certificate_num is not None:
            cur.execute("""
                INSERT INTO certificate (
                    certificate_num, lot_id, lab_id, issue_date,
                    shape, weight_ct, length, width, depth,
                    clarity, gem_type)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                certificate_num, lot_id, cert_lab_id, cert_issue_date,
                shape, weight_ct, length, width, depth,
                clarity, 'Diamond'
            ))

        # add into loose stone
        cur.execute("""
            INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth)
            VALUES (%s, %s, %s::shape, %s, %s, %s)
        """, (lot_id, weight_ct, shape, length, width, depth))

        # add white diamond
        cur.execute("""
            INSERT INTO white_diamond (lot_id, white_scale, clarity)
            VALUES (%s, %s::white_scale, %s::clarity)
        """, (lot_id, white_scale, clarity))

        # add action_item
        cur.execute("""
            INSERT INTO action_item (action_id, lot_id, price, currency_code)
            VALUES (%s, %s, %s, %s::code)
        """, (action_id, lot_id, price, currency))

        # add purcahse
        cur.execute("""
            INSERT INTO purchase (action_id, purchase_num, purchase_date)
            VALUES (%s, %s, %s)
        """, (action_id, purchase_num, purchase_date))

        # add log
        cur.execute("""
             INSERT INTO action_update_log (action_id, employee_id, update_type)
             VALUES (%s, %s, 'Insert')
         """, (action_id, employee_id))

        # commit and return
        db.commit()
        return lot_id


def create_purchase_colored_diamonds(
    db: psycopg.Connection,
    employee_id: int,
    stock_name: str,
    purchase_date: date,
    purchase_num: str,
    origin: str,
    supplier_id: int,
    office_id: int,
    price: Decimal,
    currency: str,
    weight_ct: Decimal,
    shape: str,
    length: Decimal,
    width: Decimal,
    depth: Decimal,
    fancy_color: str,
    fancy_intensity: str,
    fancy_overtone: str | None,
    clarity: str,
    certificate_num: str | None = None,
    cert_lab_id: int | None = None,
    cert_issue_date: date | None = None,
) -> int:
    with db.cursor() as cur:
        cur.execute("SET search_path TO diamonds_are_forever")

        # action
        cur.execute("""
            INSERT INTO action (from_counterpart_id, to_counterpart_id, action_category)
            VALUES (%s, %s, 'purchase')
            RETURNING action_id
        """, (supplier_id, office_id))
        action_id = cur.fetchone()[0]

        # item
        cur.execute("""
            INSERT INTO item (stock_name, purchase_date, supplier_id, origin,
                              responsible_office_id, item_type)
            VALUES (%s, %s, %s, %s, %s, 'colored diamond')
            RETURNING lot_id
        """, (stock_name, purchase_date, supplier_id, origin, office_id))
        lot_id = cur.fetchone()[0]

        # loose stone
        cur.execute("""
            INSERT INTO loose_stone (lot_id, weight_ct, shape, length, width, depth)
            VALUES (%s, %s, %s::shape, %s, %s, %s)
        """, (lot_id, weight_ct, shape, length, width, depth))

        # colored diamond
        cur.execute("""
            INSERT INTO colored_diamond
                (lot_id, gem_type, fancy_color, fancy_intensity, fancy_overtone, clarity)
            VALUES (%s, 'Diamond', %s, %s, %s, %s::clarity)
        """, (lot_id, fancy_color, fancy_intensity, fancy_overtone, clarity))

        # action_item
        cur.execute("""
            INSERT INTO action_item (action_id, lot_id, price, currency_code)
            VALUES (%s, %s, %s, %s::code)
        """, (action_id, lot_id, price, currency))

        # purchase
        cur.execute("""
            INSERT INTO purchase (action_id, purchase_num, purchase_date)
            VALUES (%s, %s, %s)
        """, (action_id, purchase_num, purchase_date))

        if certificate_num is not None:
            cur.execute("""
                INSERT INTO certificate (
                    certificate_num, lot_id, lab_id, issue_date,
                    shape, weight_ct, length, width, depth,
                    clarity, color, gem_type)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                certificate_num, lot_id, cert_lab_id, cert_issue_date,
                shape, weight_ct, length, width, depth,
                clarity, fancy_color, 'Diamond'
            ))

        # log
        cur.execute("""
            INSERT INTO action_update_log (action_id, employee_id, update_type)
            VALUES (%s, %s, 'Insert')
        """, (action_id, employee_id))

        db.commit()
        return lot_id


def get_purchases(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE"),
        **other_params,
):
    with db.cursor(row_factory=class_row(Purchase)) as cur:
        q = sql.SQL(
            """
            SELECT p.action_id,
                   purchase_num,
                   purchase_date
            FROM purchase p
            WHERE {condition}
            """
        ).format(
            condition=condition,
        )
        cur.execute("SET search_path TO diamonds_are_forever")
        return cur.execute(q, other_params).fetchall()
