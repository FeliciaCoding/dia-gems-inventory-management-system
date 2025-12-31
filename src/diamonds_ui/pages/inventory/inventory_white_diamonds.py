"""
This page represents the inventory.
Also, this page is the main page.
Its content could be different depending on who looks at it.
"""

import streamlit as st
from psycopg import sql

from diamonds_ui.auth import user
from diamonds_ui.components.pagination import pagination_element
from diamonds_ui.database.item.white_diamond import WhiteDiamond, white_diamonds_cursor, get_white_diamond
from streamlit_utils import db


def render_white_diamond_details(d: WhiteDiamond):
    with st.container(border=True):
        st.markdown(f"### Details for: {d.stock_name}")
        st.caption(f"Lot id: #{d.lot_id}")

        st.write(f"💎 Weight: {d.weight_ct} ct")
        st.write(f"Shape: {d.shape}")
        st.write(f"White scale: {d.white_scale}")
        st.write(f"📜 Certificate: {d.certificate_num}")

    if st.button("← Back to list"):
        st.session_state.selected_lot_id = None
        st.rerun()


def render_white_diamond_card(d: WhiteDiamond):
    """Render a single White Diamond card.
    """
    with st.container(border=True):
        col1, col2, col3 = st.columns(3)

        col1.markdown(f"**{d.stock_name}**")
        col1.caption(f"Lot #{d.lot_id}")

        col2.write(f"💎 {d.weight_ct} ct · {d.shape}")
        col2.write(f"White scale: {d.white_scale}")

        col3.write(f"📜 {d.certificate_num}")

        if col3.button("Details", key=f"item_details_{d.lot_id}"):
            st.session_state.selected_lot_id = d.lot_id
            st.rerun()


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("White Diamonds")
    st.subheader("All the white diamonds registered in the system")

    _SELECTED_LOT_ID_KEY = "selected_lot_id"
    if _SELECTED_LOT_ID_KEY not in st.session_state:
        st.session_state[_SELECTED_LOT_ID_KEY] = None

    conn = db.connection()
    with conn.connect() as db:
        if st.session_state[_SELECTED_LOT_ID_KEY] is not None:
            render_white_diamond_details(get_white_diamond(db,
               st.session_state[_SELECTED_LOT_ID_KEY]))
        else:
            with white_diamonds_cursor(
                db,
                condition=sql.SQL("is_available = TRUE"),
            ) as cur:
                if cur.rowcount == 0:
                    st.info("No results")
                else:
                    # Build the pagination UI from the total number of rows; this returns
                    # the chosen per_page and offset values that we use with the cursor.
                    per_page, offset = pagination_element(cur.rowcount)

                    # Move the cursor to the requested offset and fetch the desired page.
                    cur.scroll(offset)
                    diamonds = cur.fetchmany(per_page)
                    for d in diamonds:
                        render_white_diamond_card(d)




