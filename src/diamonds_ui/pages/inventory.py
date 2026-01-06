import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.components.pagination import pagination_element
from diamonds_ui.database.item.item import Item, items_cursor


def render_item_card(i: Item):
    with st.container(border=True):
        col1, col2, col3 = st.columns(3)

        col1.markdown(f"{i.item_type.capitalize()}: **{i.stock_name}**")
        col1.caption(f"Lot #{i.lot_id}")

        col2.write(f"Purchased: {i.purchase_date.date()}")
        col2.write(f"From: {i.supplier_name}")

        col3.write(f"{'available' if i.is_available else 'not available'}")

        if col3.button("Details", key=f"item_details_{i.lot_id}"):
            if i.item_type == "white diamond":
                st.switch_page(
                    "pages/inventory/inventory_white_diamonds.py",
                    query_params=dict(lot_id=i.lot_id),
                )
            elif i.item_type == "colored diamond":
                st.switch_page(
                    "pages/inventory/inventory_colored_diamonds.py",
                    query_params=dict(lot_id=i.lot_id),
                )
            elif i.item_type == "colored gemstone":
                st.switch_page(
                    "pages/inventory/inventory_colored_gemstones.py",
                    query_params=dict(lot_id=i.lot_id),
                )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Inventory")
    st.subheader("All sorts of the registered items in the system")

    # _SELECTED_LOT_ID_KEY = "selected_lot_id"
    # if _SELECTED_LOT_ID_KEY not in st.session_state:
    #     st.session_state[_SELECTED_LOT_ID_KEY] = None

    conn = db.connection()
    with conn.connect() as db:
        with items_cursor(
            db
        ) as cur:
            if cur.rowcount == 0:
                st.info("No results")
            else:
                per_page, offset = pagination_element(cur.rowcount)
                cur.scroll(offset)
                for i in cur.fetchmany(per_page):
                    render_item_card(i)

