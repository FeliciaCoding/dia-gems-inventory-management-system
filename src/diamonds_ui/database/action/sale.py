from decimal import Decimal
from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg import sql
from psycopg.rows import class_row
from diamonds_ui.database.counterpart import Counterpart
from diamonds_ui.database.item.item import Item
from diamonds_ui.database.employee import Employee
from diamonds_ui.database.action.transfer_to_office import PriceWithCurrency


class Sale(BaseModel):
    action_id: int
    sale_num: str | None
    sale_date: date | None
    payment_method: str | None
    payment_status: str | None


def get_sales(
        db: psycopg.Connection,
        condition: sql.SQL = sql.SQL("TRUE"),
        **other_params,
):
    with db.cursor(row_factory=class_row(Sale)) as cur:
        q = sql.SQL(
            """
            SELECT 
                action_id,
                sale_num,
                sale_date,
                payment_method,
                payment_status
            FROM diamonds_are_forever.sale s
            WHERE {condition}
            """
        ).format(
            condition=condition,
        )
        return cur.execute(q, other_params).fetchall()


def make_new_sale(
        db: psycopg.Connection,
        office: Counterpart,
        client: Counterpart,
        terms: str,
        remarks: str,
        sale_num: str,
        sale_date: date,
        items_to_sell: list[Item],
        employee: Employee,
        payment_method: str,
        payment_status: str,
        prices: dict[str, PriceWithCurrency]
) -> tuple[int | None, str | None]:
    # create new action
    action = db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.action (
        from_counterpart_id,
        to_counterpart_id,
        terms,
        remarks,
        action_category
    ) VALUES
    ({from_counterpart_id}, {to_counterpart_id}, {terms}, {remarks}, 'sale')
    RETURNING action_id
    """).format(
        from_counterpart_id=office.counterpart_id,
        to_counterpart_id=client.counterpart_id,
        terms=terms,
        remarks=remarks,
    )).fetchone()

    if not action:
        return None, "Sale: could not create a new action"

    # reflect action creation in action_update_log
    db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.action_update_log (
        action_id,
        employee_id,
        update_type
    ) VALUES
    ({action_id}, {employee_id}, 'Insert')
    """).format(
        action_id=action[0],
        employee_id=employee.employee_id,
    ))

    # create action_item link for every item in items_to_send
    for item in items_to_sell:
        db.execute(sql.SQL(
            """
            INSERT INTO diamonds_are_forever.action_item (
                action_id,
                lot_id,
                price,
                currency_code
            ) VALUES
            ({action_id}, {lot_id}, {price}, {currency_code})
            """
        ).format(
            action_id=action[0],
            lot_id=item.lot_id,
            price=prices[item.stock_name].price,
            currency_code=prices[item.stock_name].currency_code,
        ))

    # create new transfer to office
    transfer = db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.sale (
        action_id,
        sale_num,
        sale_date,
        payment_method,
        payment_status
    ) VALUES
    ({action_id}, {sale_num}, {sale_date}, {payment_method}, {payment_status})
    RETURNING action_id
    """).format(
        action_id=action[0],
        sale_num=sale_num,
        sale_date=sale_date,
        payment_method=payment_method,
        payment_status=payment_status
    )).fetchone()

    if not transfer:
        return None, "Sale: could not create a new sale"

    return action[0], None


def update_sale(
        db: psycopg.Connection,
        action_id: int,
        terms: str,
        remarks: str,
        sale_num: str,
        sale_date: date,
        employee: Employee,
        payment_method: str,
        payment_status: str
):
    # create new action
    db.execute(sql.SQL(
    """
    UPDATE diamonds_are_forever.action 
    SET (terms, remarks) = ({terms}, {remarks})
    WHERE action_id = {action_id}
    """).format(
        terms=terms,
        remarks=remarks,
        action_id=action_id
    ))

    # reflect action creation in action_update_log
    db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.action_update_log (
        action_id,
        employee_id,
        update_type
    ) VALUES
    ({action_id}, {employee_id}, 'Update')
    """).format(
        action_id=action_id,
        employee_id=employee.employee_id
    ))

    db.execute(sql.SQL(
    """
    UPDATE diamonds_are_forever.sale 
    SET (
        sale_num,
        sale_date,
        payment_method,
        payment_status
    ) = (
        {sale_num},
        {sale_date},
        {payment_method},
        {payment_status}   
    )
    WHERE action_id = {action_id}
    """).format(
        action_id=action_id,
        sale_num=sale_num,
        sale_date=sale_date,
        payment_method=payment_method,
        payment_status=payment_status
    ))
    db.commit()


def delete_sale(
        db: psycopg.Connection,
        action_id: int,
        employee_id: int,
        concerned_items: list[Item]
):
    db.execute(sql.SQL(
    """
    INSERT INTO diamonds_are_forever.action_update_log (
        action_id,
        employee_id,
        update_type
    ) VALUES
    ({action_id}, {employee_id}, 'Delete')
    """).format(
        action_id=action_id,
        employee_id=employee_id
    ))

    db.execute(
        """
        DELETE FROM diamonds_are_forever.sale
        WHERE action_id = %s 
        """,
        (action_id,)
    )
    db.execute(
        """
        DELETE FROM diamonds_are_forever.action_item
        WHERE action_id = %s 
        """,
        (action_id,)
    )
    db.execute(
        """
        DELETE FROM diamonds_are_forever.action
        WHERE action_id = %s 
        """,
        (action_id,)
    )

    for item in concerned_items:
        db.execute(
            """
            UPDATE diamonds_are_forever.item
            SET is_available = TRUE
            WHERE lot_id = %s 
            """,
            (item.lot_id,)
        )
    db.commit()

