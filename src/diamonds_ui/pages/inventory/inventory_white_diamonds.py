"""
This page represents the inventory.
Also, this page is the main page.
Its content could be different depending on who looks at it.
"""

import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.item.white_diamond import WhiteDiamond, get_white_diamonds
from diamonds_ui.database.action.action import Action, get_actions
from streamlit_utils.query_param import query_param


def render_white_diamond_details(d: WhiteDiamond, actions: list[Action]):
    with st.container(border=True):
        st.markdown(f"### Details for: {d.lot_id}")
        st.markdown(f"**Weight:** {d.weight_ct} ct")
        st.markdown(f"**Shape:** {d.shape}")
        st.markdown(f"**White scale:** {d.white_scale}")
        st.markdown(f"**Certificate:** {d.certificate_num}")

        st.markdown("### Status")

        for a in actions:
            with st.container(border=True):
                col1, col2, col3 = st.columns(3)
                col1.markdown(f"**{a.action_category.capitalize()}**")
                col1.write(f"action id: #{a.action_id}")
                col2.write(f"From: {a.from_counterpart_name}")
                col2.write(f"From: {a.to_counterpart_name}")
                col3.write(f"Price: {a.price} {a.currency_code}")
                col3.write(f"Registered: {a.created_at.date()}")


def select_white_diamond(
    diamonds: list[WhiteDiamond],
    wd_id: int | None = None,
):
    if wd_id is None:
        index = None
    else:
        index = [d.lot_id for d in diamonds].index(wd_id)

    diamond = st.selectbox(
        "Current white diamond",
        diamonds,
        key="white_diamond_selection",  # required for sync with query parameter (otherwise needs a rerun)
        index=index,
        format_func=lambda wd: f"white diamond: (#{wd.lot_id}) {wd.weight_ct} ct, {wd.shape}",
    )
    return diamond

if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("White Diamond Details")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("lot_id", int) as qp:
            white_diamond = select_white_diamond(get_white_diamonds(db), qp.get())
            if white_diamond is not None:
                qp.set(white_diamond.lot_id)

        if white_diamond is None:
            st.info("Please select white diamond to inspect its details")
        else:
            actions = get_actions(db, white_diamond.lot_id)
            render_white_diamond_details(white_diamond, actions)



