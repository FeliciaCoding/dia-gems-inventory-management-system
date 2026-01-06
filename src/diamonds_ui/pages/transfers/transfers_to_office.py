"""
This page allows to do
- transfer to different office within the enterprise
"""


import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import Action, get_action
from diamonds_ui.database.action.transfer_to_office import (
    TransferToOffice, get_transfers_between_offices
)
from diamonds_ui.database.counterpart import Counterpart, get_counterparts
from diamonds_ui.database.item.item import (
    Item, PricedItem, get_items_for_action
)
from streamlit_utils.query_param import query_param


def render_transfer_details(t: TransferToOffice, a: Action, items: list[Item]):
    with st.container(border=True):
        st.markdown(f"### Details for: {t.action_id}")

        st.markdown(f"#### {a.action_category.capitalize()}")

        col1, col2 = st.columns(2)
        col1.markdown(f"**From:** {a.from_counterpart_name}")
        col2.markdown(f"**By:** {a.to_counterpart_name}")
        col1.markdown(f"**Transfer number**: {t.transfer_num}")
        col2.markdown(f"**Ship date**: {t.ship_date}")

        st.markdown("#### Items:")

        for item in items:
            with st.container(border=True):
                col1, col2 = st.columns(2)
                col1.markdown(f"{item.item_type.capitalize()}: **{item.stock_name}**")
                col1.caption(f"Lot #{item.lot_id}")
                col2.write(f"Purchased: {item.purchase_date.date()}")
                col2.write(f"From: {item.supplier_name}")


@st.dialog("New transfer")
def new_transfer_to_office():
    st.write(f"Adding new purchase")


def select_transfer(
    transfers: list[TransferToOffice],
    id: int | None = None,
):
    if id is None:
        index = None
    else:
        index = [a.action_id for a in transfers].index(id)

    return st.selectbox(
        "Current transfer",
        transfers,
        key="transfer_selection",
        index=index,
        format_func=lambda a: f"Transfer: (#{a.action_id}) from {a.from_counterpart_name} to {a.to_counterpart_name}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Transfers between offices")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("lot_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                t = select_transfer(
                    get_transfers_between_offices(db), qp.get())
                if t is not None:
                    qp.set(t.action_id)

                if st.button("Make new transfer"):
                    new_transfer_to_office()

        if t is None:
            st.info("Please select transfer to inspect it")
        else:
            action = get_action(db, t.action_id)
            items = get_items_for_action(db, action.action_id)
            render_transfer_details(t, action, items)

