"""
This page represents the inventory.
Also, this page is the main page.
Its content could be different depending on who looks at it.
"""

import streamlit as st
from psycopg import sql
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.components.pagination import pagination_element
from diamonds_ui.database.item.white_diamond import WhiteDiamond, white_diamonds_cursor, get_white_diamond
from diamonds_ui.database.action.purchase import Purchase, get_purchase
from diamonds_ui.database.action.sale import Sale, get_sale
from diamonds_ui.database.action.memo_in import MemoIn, get_memo_in
from diamonds_ui.database.action.memo_out import MemoOut, get_memos_out
from diamonds_ui.database.action.transfer_to_lab import TransferToLab, get_transfers_to_lab
from diamonds_ui.database.action.transfer_to_factory import TransferToFactory, get_transfers_to_factory
from diamonds_ui.database.action.transfer_to_office import TransferToOffice, get_transfers_to_office
from diamonds_ui.database.action.return_from_lab import ReturnFromLab, get_returns_from_lab
from diamonds_ui.database.action.return_from_factory import ReturnFromFactory, get_returns_from_factory
from diamonds_ui.database.action.return_memo_in import ReturnMemoIn, get_returns_memo_in
from diamonds_ui.database.action.return_memo_out import ReturnMemoOut, get_returns_memo_out


def render_white_diamond_details(
        d: WhiteDiamond,
        actions: list
):
    with st.container(border=True):
        st.markdown(f"### Details for: {d.stock_name}")
        st.caption(f"Lot id: #{d.lot_id}")

        st.markdown(f"**Current location:** {d.physical_location}")
        st.markdown(f"**Weight:** {d.weight_ct} ct")
        st.markdown(f"**Shape:** {d.shape}")
        st.markdown(f"**White scale:** {d.white_scale}")
        st.markdown(f"**Certificate:** {d.certificate_num}")

        st.markdown("### Status")

        actions.sort(key=lambda item: item.created_at)

        for a in actions:
            with st.container(border=True):
                info: dict[str, str] = dict()

                match a:
                    case MemoIn():
                        st.markdown("#### Memo In:")
                        if a.expected_return_date is not None:
                            info["Expected return date"] = a.expected_return_date
                    case MemoOut():
                        st.markdown("#### Memo Out:")
                        if a.expected_return_date is not None:
                            info["Expected return date"] = a.expected_return_date
                    case Purchase():
                        st.markdown("#### Purchase:")
                    case Sale():
                        st.markdown("#### Sale:")
                    case TransferToLab():
                        st.markdown("#### Transfer to lab:")
                        info["Lab purpose"] = a.lab_purpose
                    case TransferToFactory():
                        st.markdown("#### Transfer to factory:")
                        info["Processing type"] = a.processing_type
                    case TransferToOffice():
                        st.markdown("#### Transfer to office:")
                    case ReturnMemoIn():
                        st.markdown("#### Return memo-in:")
                    case ReturnMemoOut():
                        st.markdown("#### Return memo-out:")
                    case ReturnFromLab():
                        st.markdown("#### Return from lab:")
                    case ReturnFromFactory():
                        st.markdown("#### Return from factory:")
                    case _:
                        continue

                st.markdown(f"**From:** {a.from_counterpart_name}. **To:** {a.to_counterpart_name}")
                st.markdown(f"**Price:** {a.price} {a.currency_code}")
                st.markdown(f"**Ship date:** {a.ship_date}")
                st.markdown(f"**Transfer number:** {a.transfer_num}")

                for label, val in info.items():
                    st.markdown(f"**{label}:** {val}")

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

            render_white_diamond_details(
                wd,
                [get_purchase(db, wd.lot_id)] +
                [get_memo_in(db, wd.lot_id)] +
                get_transfers_to_lab(db, wd.lot_id) +
                get_transfers_to_factory(db, wd.lot_id) +
                get_transfers_to_office(db, wd.lot_id) +
                get_returns_memo_in(db, wd.lot_id) +
                [get_sale(db, wd.lot_id)] +
                get_memos_out(db, wd.lot_id) +
                get_returns_memo_out(db, wd.lot_id) +
                get_returns_from_lab(db, wd.lot_id) +
                get_returns_from_factory(db, wd.lot_id)
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




