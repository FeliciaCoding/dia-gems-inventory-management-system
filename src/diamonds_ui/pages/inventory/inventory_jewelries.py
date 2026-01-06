"""
This page represents the inventory.
Also, this page is the main page.
Its content could be different depending on who looks at it.
"""

import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.item.jewelry import (
    Jewelry,
    get_jewelries
)
from diamonds_ui.database.item.item import Item, get_item
from diamonds_ui.database.action.action import Action, get_actions
from streamlit_utils.query_param import query_param


def render_jewelry_details(j: Jewelry, i: Item, actions: list[Action]):
    with st.container(border=True):
        st.markdown(f"### Details for: {j.lot_id}")

        st.markdown(f"**Stock name:** {i.stock_name}")
        st.write(f"**Purchased from:** {i.supplier_name} **on** {i.purchase_date.date()}")
        st.write(f"**Availability:** {'yes' if i.is_available else 'no'}")

        st.markdown(f"**Jewelry type:** {j.jewelry_type}")
        st.markdown(f"**Gross weight:** {j.gross_weight_gr} g")
        st.markdown(f"**Metal type:** {j.metal_type}")
        st.markdown(f"**Metal weight:** {j.metal_weight_gr} g")
        st.markdown(f"**Total center stones quantity:** {j.total_center_stone_qty}")
        st.markdown(f"**Total center stones weight:** {j.total_center_stone_weight_ct} ct")
        st.markdown(f"**Center stones' type:** {j.centered_stone_type}")
        st.markdown(f"**Total side stones quantity:** {j.total_side_stone_qty}")
        st.markdown(f"**Total side stones weight:** {j.total_side_stone_weight_ct} ct")
        st.markdown(f"**Side stones' type:** {j.side_stone_type}")

        st.markdown("### Status")

        for a in actions:
            with st.container(border=True):
                st.markdown(f"#### {a.action_category.capitalize()}")
                col1, col2 = st.columns(2)
                col1.write(f"From: {a.from_counterpart_name}")
                col1.write(f"By: {a.to_counterpart_name}")
                col2.write(f"Price: {a.price} {a.currency_code}")
                col2.write(f"Registered: {a.created_at.date()}")


def select_jewelry(
    diamonds: list[Jewelry],
    cd_id: int | None = None,
):
    if cd_id is None:
        index = None
    else:
        index = [d.lot_id for d in diamonds].index(cd_id)

    return st.selectbox(
        "Current jewelry",
        diamonds,
        key="jewelry_selection",  # required for sync with query parameter (otherwise needs a rerun)
        index=index,
        format_func=lambda wd: f"jewelry: (#{wd.lot_id}) {wd.jewelry_type}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Jewelry Details")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("lot_id", int) as qp:
            jewelry = select_jewelry(
                get_jewelries(db), qp.get())
            if jewelry is not None:
                qp.set(jewelry.lot_id)

        if jewelry is None:
            st.info("Please select jewelry to inspect its details")
        else:
            general_item = get_item(db, jewelry.lot_id)
            actions = get_actions(db, jewelry.lot_id)
            render_jewelry_details(jewelry, general_item, actions)






