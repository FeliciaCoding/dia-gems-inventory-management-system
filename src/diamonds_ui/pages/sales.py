"""
This page reflects sales done
during some period of time (typically a month)
Besides it allows to register a new sale
"""

import streamlit as st
from psycopg import sql
from streamlit_utils import db
from streamlit_utils.query_param import query_param
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import Action, get_action
from diamonds_ui.database.action.sale import (
    Sale,
    get_sales,
    make_new_sale,
    update_sale,
    delete_sale
)
from diamonds_ui.database.counterpart import (
    Counterpart,
    get_counterparts,
    get_counterpart
)
from diamonds_ui.database.item.item import (
    Item,
    PricedItem,
    get_items_for_action,
    get_items_stored_in_office
)
from diamonds_ui.database.action.transfer_to_office import PriceWithCurrency
from diamonds_ui.database.item.certificate import get_certificate, Certificate


def render_sale_details(s: Sale, a: Action, items: list[PricedItem], db):
    """
    Render detailed information about a sale,
    including action metadata, payment details,
    and sold items. Also provides controls to
    refresh, edit, or delete the sale.
    """
    with st.container(border=True):
        with st.container(horizontal=True):
            st.markdown(f"### Details for: {s.action_id}")
            if st.button("", icon=":material/autorenew:"):
                st.rerun()
            if st.button("", icon=":material/delete:"):
                remove_sale(db, s, items)
            if st.button("", icon=":material/edit:"):
                edit_sale(db, s, a)

        st.markdown(f"#### {a.action_category.capitalize()}")

        col1, col2 = st.columns(2)
        col1.markdown(f"**From:** {a.from_counterpart_name}")
        col2.markdown(f"**To:** {a.to_counterpart_name}")
        col1.markdown(f"**Sale number**: {s.sale_num}")
        col2.markdown(f"**Sale date**: {s.sale_date}")
        col2.markdown(f"**Payment method**: {s.payment_method}")
        col2.markdown(f"**Payment status**: {s.payment_status}")

        st.markdown("#### Items:")
        for item in items:
            with st.container(border=True):
                col1, col2 = st.columns(2)
                col1.markdown(f"{item.item_type.capitalize()}: **{item.stock_name}**")
                col1.caption(f"Lot #{item.lot_id}")
                col2.write(f"Purchased: {item.purchase_date.date()}")
                col2.write(f"From: {item.supplier_name}")
                col2.write(f"Price: {item.price} {item.currency_code}")


@st.dialog("Deleting sale")
def remove_sale(db, s: Sale, items: list[Item]):
    """
    Confirmation dialog for deleting a sale.
    Removes the sale, related action records,
    and restores availability of concerned items.
    """
    st.markdown(f"## Are you sure you want to delete this sale (#{s.action_id}) ?")
    with st.container(horizontal=True, horizontal_alignment="center"):
        if st.button("Yes", width="stretch"):
            delete_sale(
                db,
                s.action_id,
                user.get().employee_id,
                items
            )
            with query_param("action_id", int) as qp:
                qp.set(None)
            st.rerun()
        if st.button("No", width="stretch"):
            st.rerun()


@st.dialog("Editing sale")
def edit_sale(db, s: Sale, a: Action):
    """
    Dialog for editing sale metadata such as
    sale number, date, payment method/status,
    terms, and remarks.
    """
    sale_num = st.text_input("Sale number *", value=s.sale_num)
    sale_date = st.date_input("Sale date *", value=s.sale_date)
    payment_method = st.text_input("Payment method *", value=s.payment_method)

    statuses =  ['Partial paid', 'Unpaid', 'Paid']
    payment_status = st.selectbox(
        "Payment status *",
        statuses,
        key="payment_status_reselection",
        index=statuses.index(s.payment_status)
    )
    terms = st.text_input("Terms", value=a.terms)
    remarks = st.text_input("Remarks", value=a.remarks)

    not_empty_num = sale_num is not None and len(sale_num) > 0
    not_empty_date = sale_date is not None
    not_empty_method = payment_method is not None and len(payment_method) > 0
    not_empty_status = payment_status is not None
    is_valid = (
        not_empty_num and
        not_empty_date and
        not_empty_method and
        not_empty_status
    )

    if is_valid:
        if st.button("Done"):
            update_sale(
                db,
                a.action_id,
                terms,
                remarks,
                sale_num,
                sale_date,
                user.get(),
                payment_method,
                payment_status
            )
            st.rerun()
    else:
        st.warning("Some of the required (*) fields are empty, please fill them first before going any further")


@st.dialog("New sale")
def new_sale(db):
    """
    Dialog for registering a new sale.
    Allows selecting a client, choosing items
    from the responsible office, validating
    certificates, editing prices, and submitting
    the sale with payment details.
    """
    office = get_counterpart(db, user.get().office_id)
    st.markdown(f"**Responsible office:** {office.name} ({office.country}, {office.city})")

    client = st.selectbox(
        "Recipient",
        get_counterparts(db, sql.SQL("category = 'Client' AND is_active")),
        key="client_selection",
        index=None,
        format_func=lambda c: f"To: {c.type_name} {c.country} {c.city}",
    )

    if office is not None:
        items_to_sell = st.multiselect(
            "What items you would like to sell?",
            get_items_stored_in_office(db, office.counterpart_id),
            format_func=lambda item: f"{item.item_type.capitalize()}: {item.stock_name}, supplier: {item.supplier_name}",
            default=None
        )

        if len(items_to_sell) > 0:
            items = list()
            no_cert_stones = list()
            for item in items_to_sell:
                c = get_certificate(
                    db,
                    sql.SQL("c.is_valid AND c.lot_id = {0}").format(item.lot_id)
                )
                if c is None and item.item_type != "jewelry":
                    cert_num = "no valid certificates"
                    no_cert_stones.append(item.stock_name)
                else:
                    cert_num = "not available for jewelry" if item.item_type == "jewelry" else c.certificate_num

                items.append({
                    "item": item.stock_name,
                    "price": item.price,
                    "currency": item.currency_code,
                    "certificate": cert_num
                })

            st.write("Prices (editable) of chosen items: ")
            edited_items = st.data_editor(
                items, disabled=["item", "currency", "certificate"])

            if len(no_cert_stones) > 0:
                st.error("You cannot sell uncertified stones: " + ", ".join(no_cert_stones))
            else:
                sale_num = st.text_input("Sale number")
                sale_date = st.date_input("Sale date")
                payment_method = st.text_input("Payment method")
                payment_status = st.selectbox(
                    "Payment status",
                    ['Partial paid', 'Unpaid', 'Paid'],
                    key="payment_status_selection",
                    index=None
                )
                terms = st.text_input("Terms")
                remarks = st.text_input("Remarks")

                if st.button("Submit"):
                    action_id, err = make_new_sale(
                        db,
                        office,
                        client,
                        terms,
                        remarks,
                        sale_num,
                        sale_date,
                        items_to_sell,
                        user.get(),
                        payment_method,
                        payment_status,
                        {item["item"]: PriceWithCurrency(item["price"], item["currency"])
                         for item in edited_items}
                    )
                    if err is None:
                        db.commit()
                        with query_param("action_id", int) as qp:
                            qp.set(action_id)
                        st.rerun()
                    else:
                        st.error(err)


def select_sale(
    sales: list[Sale],
    id: int | None = None,
):
    """
    Display a selectbox for sales and return
    the selected sale (optionally preselected
    by action_id).
    """
    if id is None:
        index = None
    else:
        index = [a.action_id for a in sales].index(id)

    return st.selectbox(
        "Current sale",
        sales,
        key="sale_selection",
        index=index,
        format_func=lambda a: f"Sale: (#{a.action_id}) {a.sale_num}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Sale")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("action_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                s = select_sale(
                    get_sales(db), qp.get())
                if s is not None:
                    qp.set(s.action_id)

                if st.button("Add sale"):
                    new_sale(db)

        if s is None:
            st.info("Please select sale to inspect it")
        else:
            action = get_action(db, s.action_id)
            items = get_items_for_action(db, action.action_id)
            render_sale_details(s, action, items, db)

