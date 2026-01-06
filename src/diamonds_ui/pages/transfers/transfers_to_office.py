"""
This page allows to do
- transfer to different office within the enterprise
"""


import streamlit as st
from psycopg import sql
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import Action, get_action
from diamonds_ui.database.action.transfer_to_office import (
    TransferToOffice, get_transfers_between_offices,
    make_new_transfer_to_office, PriceInCurrency
)
from diamonds_ui.database.counterpart import Counterpart, get_counterparts
from diamonds_ui.database.item.item import (
    Item, PricedItem,
    get_items_for_action, get_items_stored_in_office
)
from streamlit_utils.query_param import query_param


def render_transfer_details(t: TransferToOffice, a: Action, items: list[Item]):
    with st.container(border=True):
        st.markdown(f"### Details for: {t.action_id}")

        st.markdown(f"#### {a.action_category.capitalize()}")

        col1, col2 = st.columns(2)
        col1.markdown(f"**From:** {a.from_counterpart_name}")
        col2.markdown(f"**By:** {a.to_counterpart_name}")
        col1.markdown(f"**Transfer number**: {t.transfer_num}")
        col2.markdown(f"**Ship date**: {t.ship_date}")

        st.markdown("#### Items:")

        for item in items:
            with st.container(border=True):
                col1, col2 = st.columns(2)
                col1.markdown(f"{item.item_type.capitalize()}: **{item.stock_name}**")
                col1.caption(f"Lot #{item.lot_id}")
                col2.write(f"Purchased: {item.purchase_date.date()}")
                col2.write(f"From: {item.supplier_name}")


@st.dialog("New transfer between offices")
def new_transfer_to_office(db):
    transfer_num = st.text_input("Transfer number")
    ship_date = st.date_input("Shipment date")

    src_office = st.selectbox(
        "Sender",
        get_counterparts(db, sql.SQL("category = 'Office'")),
        key="src_office_selection",
        index=None,
        format_func=lambda office: f"From office: {office.country} {office.city} {office.postal_code}",
    )

    if src_office is not None:
        dest_office = st.selectbox(
            "Recipient",
            get_counterparts(db,
                 sql.SQL("category = 'Office' AND c.counterpart_id != {src}").format(
                     src=src_office.counterpart_id)),
            key="dest_office_selection",
            index=None,
            format_func=lambda office: f"To office: {office.country} {office.city} {office.postal_code}",
        )

        # select items that store in src office
        items_to_send = st.multiselect(
            "What items you would like to send?",
            get_items_stored_in_office(db, src_office.counterpart_id),
            format_func=lambda item: f"{item.item_type.capitalize()}: {item.stock_name}, supplier: {item.supplier_name}",
            default=None
        )

        terms = st.text_input("Terms")
        remarks = st.text_input("Remarks")

        if len(items_to_send) > 0:
            st.write("Prices (editable) of chosen items: ")
            edited_items = st.data_editor([
                {"item": item.stock_name, "price": item.price, "currency": item.currency_code}
                for item in items_to_send
            ], disabled=["item", "currency"])

            if st.button("Submit"):
                # create new action
                # create new transfer to office
                # create action_item link for every item in items_to_send
                make_new_transfer_to_office(db,
                    src_office,
                    dest_office,
                    terms,
                    remarks,
                    {item["item"]: PriceInCurrency(item["price"], item["currency"])
                     for item in edited_items},
                    transfer_num,
                    ship_date,
                    items_to_send,
                    user.get())


def select_transfer(
    transfers: list[TransferToOffice],
    id: int | None = None,
):
    if id is None:
        index = None
    else:
        index = [a.action_id for a in transfers].index(id)

    return st.selectbox(
        "Current transfer",
        transfers,
        key="transfer_selection",
        index=index,
        format_func=lambda a: f"Transfer: (#{a.action_id}) from {a.from_counterpart_name} to {a.to_counterpart_name}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Transfers between offices")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("lot_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                t = select_transfer(
                    get_transfers_between_offices(db), qp.get())
                if t is not None:
                    qp.set(t.action_id)

                if st.button("Make new transfer"):
                    new_transfer_to_office(db)

        if t is None:
            st.info("Please select transfer to inspect it")
        else:
            action = get_action(db, t.action_id)
            items = get_items_for_action(db, action.action_id)
            render_transfer_details(t, action, items)

