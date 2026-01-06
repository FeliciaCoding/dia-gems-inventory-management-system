"""
This page allows to register a new item that
is either being purchased.
It should have a chart what we buy where.
And how it affects revenue.
It should highlight personal purchases.
"""

import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import Action, get_action
from diamonds_ui.database.action.purchase import Purchase, get_purchases
from diamonds_ui.database.counterpart import Counterpart, get_counterparts
from diamonds_ui.database.item.item import Item
from streamlit_utils.query_param import query_param


def render_purchase_details(p: Purchase, a: Action):
    with st.container(border=True):
        st.markdown(f"### Details for: {p.lot_id}")

        st.markdown(f"#### {a.action_category.capitalize()}")
        col1, col2 = st.columns(2)
        col1.write(f"From: {a.from_counterpart_name}")
        col1.write(f"By: {a.to_counterpart_name}")
        col2.write(f"Price: {a.price} {a.currency_code}")
        col2.write(f"Registered: {a.created_at.date()}")

        st.write(f"Purchase number: {p.purchase_num}")
        st.write(f"Purchase date: {p.purchase_date}")


def select_supplier(suppliers: list[Counterpart]):
    return


@st.dialog("New purchase")
def new_purchase():
    st.write(f"Adding new purchase")
    stock_name = st.text_input("Stock name")
    purchase_date = st.text_input("Purchase date")
    origin = st.text_input("Origin")

    # selector for supplier
    supplier = st.selectbox(
        "Chosen supplier",
        get_counterparts(db),
        key="supplier_selection",
        index=None,
        format_func=lambda suppl: f"Supplier: (#{suppl.name}) {suppl.type}",
    )
    # selector for item type
    item_type = st.selectbox(
        "Item type",
        ['white diamond', 'colored diamond', 'colored gemstone', 'jewelry'],
        key="item_type_selection",  # required for sync with query parameter (otherwise needs a rerun)
        index=None
    )

    # TODO:
    # conditionally render necessary inputs
    # depending on item's type

    # if st.button("Submit"):
    #     st.session_state.vote = {"item": item, "reason": reason}
    #     st.rerun()


def select_purchase(
    purchases: list[Purchase],
    id: int | None = None,
):
    if id is None:
        index = None
    else:
        index = [a.action_id for a in purchases].index(id)

    return st.selectbox(
        "Current purchase",
        purchases,
        key="purchase_selection",  # required for sync with query parameter (otherwise needs a rerun)
        index=index,
        format_func=lambda a: f"Purchase: (#{a.action_id}) {a.purchase_num}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Purchase")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("lot_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                p = select_purchase(
                    get_purchases(db), qp.get())
                if p is not None:
                    qp.set(p.action_id)

                if st.button("Add purchase"):
                    new_purchase()


        if p is None:
            st.info("Please select purchase to inspect it")
        else:
            action = get_action(db, p.action_id)
            render_purchase_details(p, action)

