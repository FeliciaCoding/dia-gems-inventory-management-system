"""
This page represents the inventory.
Also, this page is the main page.
Its content could be different depending on who looks at it.
"""
import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.item.colored_diamond import (
    ColoredDiamond,
    get_colored_diamonds
)
from diamonds_ui.database.item.item import Item, get_item
from diamonds_ui.database.action.action import Action, get_actions
from streamlit_utils.query_param import query_param


def render_colored_diamond_details(d: ColoredDiamond, i: Item, actions: list[Action]):
    with st.container(border=True):
        st.markdown(f"### Details for: {d.lot_id}")

        st.markdown(f"**Stock name:** {i.stock_name}")
        st.write(f"**Purchased from:** {i.supplier_name} **on** {i.purchase_date.date()}")
        st.write(f"**Availability:** {'yes' if i.is_available else 'no'}")

        st.markdown(f"**Weight:** {d.weight_ct} ct")
        st.markdown(f"**Shape:** {d.shape}")
        st.markdown(f"**Length:** {d.length}")
        st.markdown(f"**Width:** {d.width}")
        st.markdown(f"**Depth:** {d.depth}")

        st.markdown(f"**Fancy intensity:** {d.fancy_intensity}")
        st.markdown(f"**Fancy overtone:** {d.fancy_overtone}")
        st.markdown(f"**Fancy color:** {d.fancy_color}")

        st.markdown(f"**Certificate:** {d.certificate_num}")

        st.markdown("### Status")

        for a in actions:
            with st.container(border=True):
                st.markdown(f"#### {a.action_category.capitalize()}")
                col1, col2 = st.columns(2)
                col1.write(f"From: {a.from_counterpart_name}")
                col1.write(f"By: {a.to_counterpart_name}")
                col2.write(f"Price: {a.price} {a.currency_code}")
                col2.write(f"Registered: {a.created_at.date()}")


def select_colored_diamond(
    diamonds: list[ColoredDiamond],
    cd_id: int | None = None,
):
    if cd_id is None:
        index = None
    else:
        index = [d.lot_id for d in diamonds].index(cd_id)

    return st.selectbox(
        "Current colored diamond",
        diamonds,
        key="colored_diamond_selection",  # required for sync with query parameter (otherwise needs a rerun)
        index=index,
        format_func=lambda wd: f"colored diamond: (#{wd.lot_id}) {wd.weight_ct} ct, {wd.shape}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Colored Diamond Details")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("lot_id", int) as qp:
            diamond = select_colored_diamond(
                get_colored_diamonds(db), qp.get())
            if diamond is not None:
                qp.set(diamond.lot_id)

        if diamond is None:
            st.info("Please select colored diamond to inspect its details")
        else:
            general_item = get_item(db, diamond.lot_id)
            actions = get_actions(db, diamond.lot_id)
            render_colored_diamond_details(diamond, general_item, actions)

