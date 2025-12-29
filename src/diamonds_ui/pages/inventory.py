import streamlit as st
from psycopg import sql

from diamonds_ui.components.pagination import pagination_element
from diamonds_ui.database.white_diamond import WhiteDiamond, white_diamonds
from streamlit_utils import db
# from streamlit_utils.query_param import query_param

st.header("White Diamonds")
st.subheader("White Diamonds registered in the system")

conn = db.connection()
with conn.connect() as db:

    def render_white_diamond(wh: WhiteDiamond):
        """Render a single White Diamond card.
        """
        with st.container(border=True):
            st.html(
                f"""
                <strong>{wh.stock_name} - {wh.origin}</strong> <small>({wh.purchase_date})</small>
                <br>
                {wh.weight_ct}
                """
            )

    # Use the white_diamonds context manager to stream results from the DB.
    # The cursor supports .scroll() and .fetchmany() so we can implement pagination.
    with white_diamonds(
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
                render_white_diamond(d)

