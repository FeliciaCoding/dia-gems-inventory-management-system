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
from diamonds_ui.database.action.purchase import Purchase, get_purchase
from diamonds_ui.database.action.memo_in import MemoIn, get_memo_in
from diamonds_ui.database.action.transfer_to_lab import TransferToLab, get_transfers_to_lab
from diamonds_ui.database.action.transfer_to_factory import TransferToFactory, get_transfers_to_factory
from diamonds_ui.database.action.transfer_to_office import TransferToOffice, get_transfers_to_office
from streamlit_utils import db


def render_white_diamond_details(
        d: WhiteDiamond,
        incoming: Purchase | MemoIn,
        transfers: list[TransferToLab | TransferToFactory | TransferToOffice]
):
    with st.container(border=True):
        st.markdown(f"### Details for: {d.stock_name}")
        st.caption(f"Lot id: #{d.lot_id}")

        st.markdown(f"**Current location:** {d.physical_location}")
        st.markdown(f"**Weight:** {d.weight_ct} ct")
        st.markdown(f"**Shape:** {d.shape}")
        st.markdown(f"**White scale:** {d.white_scale}")
        st.markdown(f"**Certificate:** {d.certificate_num}")

        st.markdown(f"#### Status")

        match incoming:
            case Purchase():
                with st.container(border=True):
                    st.markdown(f"#### Purchase:")
                    st.markdown(f"**From:** {incoming.from_counterpart_name}. **To:** {incoming.to_counterpart_name}")
                    st.markdown(f"**Price:** {incoming.price} {incoming.currency_code}")
                    st.markdown(f"**Purchase date:** {incoming.purchase_date}")
            case MemoIn():
                st.markdown(f"#### Memo In:")
                st.markdown(f"**From:** {incoming.from_counterpart_name}. **To:** {incoming.to_counterpart_name}")
                st.markdown(f"**Price:** {incoming.price} {incoming.currency_code}")
                st.markdown(f"**Memo in number:** {incoming.memo_in_num}")
                st.markdown(f"**Ship date:** {incoming.ship_date}")
                if incoming.expected_return_date is not None:
                    st.markdown(f"**Expected return date:** {incoming.expected_return_date}")

        transfers.sort(key=lambda item: item.updated_at)
        for t in transfers:
            match t:
                case TransferToLab():
                    st.markdown(f"#### Transfer to lab:")
                    st.markdown(f"**From:** {t.from_counterpart_name}. **To:** {t.to_counterpart_name}")
                    st.markdown(f"**Transfer number:** {t.transfer_num}")
                    st.markdown(f"**Ship date:** {t.ship_date}")
                    st.markdown(f"**Lab purpose:** {t.lab_purpose}")
                case TransferToFactory():
                    st.markdown(f"#### Transfer to factory:")
                    st.markdown(f"**From:** {t.from_counterpart_name}. **To:** {t.to_counterpart_name}")
                    st.markdown(f"**Transfer number:** {t.transfer_num}")
                    st.markdown(f"**Ship date:** {t.ship_date}")
                    st.markdown(f"**Processing type:** {t.processing_type}")
                case TransferToOffice():
                    st.markdown(f"#### Transfer to office:")
                    st.markdown(f"**From:** {t.from_counterpart_name}. **To:** {t.to_counterpart_name}")
                    st.markdown(f"**Transfer number:** {t.transfer_num}")
                    st.markdown(f"**Ship date:** {t.ship_date}")

    if st.button("Back to list"):
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
            wd = get_white_diamond(db, st.session_state[_SELECTED_LOT_ID_KEY])
            purchase = get_purchase(db, wd.lot_id)
            transfers_to_lab = get_transfers_to_lab(db, wd.lot_id)
            transfers_to_factory = get_transfers_to_factory(db, wd.lot_id)
            transfers_to_office = []

            render_white_diamond_details(
                wd,
                purchase,
                transfers_to_lab + transfers_to_factory + transfers_to_office
            )
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




