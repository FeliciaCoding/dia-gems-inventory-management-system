"""
This page reflects sales done
during some period of time (typically a month)
Besides it allows to register a new sale
"""

import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import Action, get_action
from diamonds_ui.database.action.sale import Sale, get_sales
from diamonds_ui.database.counterpart import Counterpart, get_counterparts
from diamonds_ui.database.item.item import (
    Item, PricedItem, get_items_for_action
)
from streamlit_utils.query_param import query_param


def render_sale_details(s: Sale, a: Action, items: list[PricedItem]):
    with st.container(border=True):
        st.markdown(f"### Details for: {s.action_id}")

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


@st.dialog("New sale")
def new_sale():
    if st.button("Submit"):
        pass


def select_sale(
    sales: list[Sale],
    id: int | None = None,
):
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
        with query_param("lot_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                s = select_sale(
                    get_sales(db), qp.get())
                if s is not None:
                    qp.set(s.action_id)

                if st.button("Add sale"):
                    new_sale()

        if s is None:
            st.info("Please select sale to inspect it")
        else:
            action = get_action(db, s.action_id)
            items = get_items_for_action(db, action.action_id)
            render_sale_details(s, action, items)

