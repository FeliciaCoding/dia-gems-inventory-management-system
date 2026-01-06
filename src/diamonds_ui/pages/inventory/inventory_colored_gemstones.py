"""
This page represents the inventory.
Also, this page is the main page.
Its content could be different depending on who looks at it.
"""

import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.item.colored_gemstone import (
    ColoredGemStone,
    get_colored_gemstones
)
from diamonds_ui.database.item.item import Item, get_item
from diamonds_ui.database.action.action import Action, get_actions
from streamlit_utils.query_param import query_param


def render_colored_gemstone_details(s: ColoredGemStone, i: Item, actions: list[Action]):
    with st.container(border=True):
        st.markdown(f"### Details for: {s.lot_id}")

        st.markdown(f"**Stock name:** {i.stock_name}")
        st.write(f"**Purchased from:** {i.supplier_name} **on** {i.purchase_date.date()}")
        st.write(f"**Availability:** {'yes' if i.is_available else 'no'}")

        st.markdown(f"**Weight:** {s.weight_ct} ct")
        st.markdown(f"**Shape:** {s.shape}")
        st.markdown(f"**Length:** {s.length} mm")
        st.markdown(f"**Width:** {s.width} mm")
        st.markdown(f"**Depth:** {s.depth} mm")

        st.markdown(f"**Gem type:** {s.gem_type}")
        st.markdown(f"**Gem color:** {s.gem_color}")
        st.markdown(f"**Treatment:** {s.treatment}")

        st.markdown(f"**Certificate:** {s.certificate_num}")

        st.markdown("### Status")

        for a in actions:
            with st.container(border=True):
                st.markdown(f"#### {a.action_category.capitalize()}")
                col1, col2 = st.columns(2)
                col1.write(f"From: {a.from_counterpart_name}")
                col1.write(f"By: {a.to_counterpart_name}")
                col2.write(f"Price: {a.price} {a.currency_code}")
                col2.write(f"Registered: {a.created_at.date()}")


def select_colored_gemstone(
    diamonds: list[ColoredGemStone],
    cd_id: int | None = None,
):
    if cd_id is None:
        index = None
    else:
        index = [d.lot_id for d in diamonds].index(cd_id)

    return st.selectbox(
        "Current colored gemstone",
        diamonds,
        key="colored_gemstone_selection",  # required for sync with query parameter (otherwise needs a rerun)
        index=index,
        format_func=lambda wd: f"colored gemstone: (#{wd.lot_id}) {wd.weight_ct} ct, {wd.shape}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Colored Gemstone Details")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("lot_id", int) as qp:
            gemstone = select_colored_gemstone(
                get_colored_gemstones(db), qp.get())
            if gemstone is not None:
                qp.set(gemstone.lot_id)

        if gemstone is None:
            st.info("Please select colored gemstone to inspect its details")
        else:
            general_item = get_item(db, gemstone.lot_id)
            actions = get_actions(db, gemstone.lot_id)
            render_colored_gemstone_details(gemstone, general_item, actions)

