"""
This page represents the inventory.
Also, this page is the main page.
Its content could be different depending on who looks at it.
"""

import streamlit as st
from psycopg import sql

from diamonds_ui.components.pagination import pagination_element
from diamonds_ui.database.item.jewelry import Jewelry, jewelries_cursor
from streamlit_utils import db
# from streamlit_utils.query_param import query_param

st.header("Jewelries")
st.subheader("All the jewelries registered in the system")

conn = db.connection()
with conn.connect() as db:

    def render_jewelry(j: Jewelry):
        with st.container(border=True):
            st.html(
                f"""
                Jewelry: <strong>{j.stock_name} - {j.origin}</strong> <small>({j.purchase_date})</small>
                """
            )

    # Use the white_diamonds context manager to stream results from the DB.
    # The cursor supports .scroll() and .fetchmany() so we can implement pagination.
    with jewelries_cursor(
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
            for d in cur.fetchmany(per_page):
                render_jewelry(d)

