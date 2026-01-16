"""
This page allows to do
- transfer to laboratory
"""

import streamlit as st
from psycopg import sql
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import Action, get_action
from diamonds_ui.database.action.transfer_to_lab import (
    TransferToLab, get_transfers_to_labs, make_new_transfer_to_lab
)
from diamonds_ui.database.counterpart import Counterpart, get_counterparts
from diamonds_ui.database.item.item import (
    Item, PricedItem,
    get_items_for_action, get_items_stored_in_office
)
from streamlit_utils.query_param import query_param


def render_transfer_details(t: TransferToLab, a: Action, items: list[Item]):
    with st.container(border=True):
        st.markdown(f"### Details for: #{t.action_id}")

        st.markdown(f"#### {a.action_category.capitalize()}")

        col1, col2 = st.columns(2)
        col1.markdown(f"**From:** {a.from_counterpart_name}")
        col2.markdown(f"**To:** {a.to_counterpart_name}")
        col1.markdown(f"**Transfer number**: {t.transfer_num}")
        col2.markdown(f"**Ship date**: {t.ship_date}")

        # Transfer To Lab stuff
        col2.markdown(f"**Lab purpose**: {t.lab_purpose}")

        st.markdown("#### Items:")

        for item in items:
            with st.container(border=True):
                col1, col2 = st.columns(2)
                col1.markdown(f"{item.item_type.capitalize()}: **{item.stock_name}**")
                col1.caption(f"Lot #{item.lot_id}")
                col2.write(f"Origin: {item.origin}")


@st.dialog("New transfer to lab")
def new_transfer_to_office(db):
    transfer_num = st.text_input("Transfer number")
    ship_date = st.date_input("Shipment date")

    # TODO:
    # change this selector to user.get().office like to factory
    src_office = st.selectbox(
        "Sender",
        get_counterparts(db, sql.SQL("category = 'Office'")),
        key="src_office_selection",
        index=None,
        format_func=lambda office: f"From office: {office.country} {office.city} {office.postal_code}",
    )
    dest_lab = st.selectbox(
        "Recipient",
        get_counterparts(db, sql.SQL("category = 'Lab' AND is_active")),
        key="dest_lab_selection",
        index=None,
        format_func=lambda lab: f"To lab: {lab.type_name} {lab.country} {lab.city}",
    )
    lab_purpose = st.selectbox(
        "Purpose",
        ['Certify', 'Re-certify'],
        key="lab_purpose_selection",
        index=None
    )

    if src_office is not None:
        # TODO:
        # ensure that only STONES can be selected
        # in our constraints we forbid to send jewerly
        items_to_send = st.multiselect(
            "What items you would like to send?",
            get_items_stored_in_office(db, src_office.counterpart_id),
            format_func=lambda item: f"{item.item_type.capitalize()}: {item.stock_name}, supplier: {item.supplier_name}",
            default=None
        )

        terms = st.text_input("Terms")
        remarks = st.text_input("Remarks")

        if len(items_to_send) > 0:
            st.write("Prices of chosen items: ")
            st.table([
                {"item": item.stock_name, "price": item.price, "currency": item.currency_code}
                for item in items_to_send
            ], border="horizontal")

            if st.button("Submit"):
                # create new action
                # create new transfer to office
                # create action_item link for every item in items_to_send
                action_id, err = make_new_transfer_to_lab(
                    db,
                    src_office,
                    dest_lab,
                    terms,
                    remarks,
                    transfer_num,
                    ship_date,
                    items_to_send,
                    user.get(),
                    lab_purpose
                )

                if err is None:
                    db.commit()
                    st.toast("New transfer to lab has been registered!",
                             icon="✅")

                    st.switch_page(
                    "pages/transfers/transfers_to_lab.py",
                        query_params=dict(action_id=action_id),
                    )
                else:
                    st.error(err)


def select_transfer(
    transfers: list[TransferToLab],
    transfer_id: int | None = None,
):
    if transfer_id is None:
        index = None
    else:
        index = [a.action_id for a in transfers].index(transfer_id)

    return st.selectbox(
        "Current transfer",
        transfers,
        key="transfer_to_lab_selection",
        index=index,
        format_func=lambda t: f"Transfer: (#{t.action_id}) number: {t.transfer_num}, date: {t.ship_date}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Transfers to lab")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("action_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                t = select_transfer(
                    get_transfers_to_labs(db), qp.get())
                if t is not None:
                    qp.set(t.action_id)

                if st.button("Make new transfer"):
                    new_transfer_to_office(db)

        if t is None:
            st.info("Please select transfer to inspect it")
        else:
            action = get_action(db, t.action_id)
            items = get_items_for_action(db, action.action_id)
            render_transfer_details(t, action, items)
