"""
This page allows to do
- return from factories
"""
import streamlit as st
from decimal import Decimal
from streamlit_utils import db
from streamlit_utils.query_param import query_param
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import (
    Action, get_action
)
from diamonds_ui.database.action.return_from_factory import (
    ReturnFromFactory,
    get_returns_from_factories,
    get_pending_items_for_factory,
    make_new_return_from_factory
)
from diamonds_ui.database.action.transfer_to_factory import (
    get_transfers_to_factory_from_empl_office
)
from diamonds_ui.database.counterpart import (
    Counterpart,
    get_counterparts
)
from diamonds_ui.database.item.loose_stone import (
    LooseStone,
    get_loose_stone
)
from diamonds_ui.database.item.item import (
    Item,
    PricedItem,
    get_items_for_action,
    get_items_stored_in_office
)


def render_return_details(
    t: ReturnFromFactory,
    a: Action,
    item: Item
):
    """
    Render detailed information about a return from factory,
    including action metadata, concerned item, and measurements
    before and after processing.
    """
    with st.container(border=True):
        st.markdown(f"### Details for: #{t.action_id}")

        st.markdown(f"#### {a.action_category.capitalize()}")

        col1, col2 = st.columns(2)
        col1.markdown(f"**From:** {a.from_counterpart_name}")
        col2.markdown(f"**To:** {a.to_counterpart_name}")
        col1.markdown(f"**Transfer number**: {t.back_from_fac_num}")
        col2.markdown(f"**Received on**: {t.back_date}")

        with st.container():
            st.markdown("#### Concerned item")
            col1, col2 = st.columns(2)
            col1.markdown(f"**Stock name:** {item.stock_name}")
            col1.markdown(f"**Type:** {item.item_type}")
            col2.markdown(f"**Responsible office:** {item.responsible_office}")

        with st.container():
            st.markdown("#### Measurements:")
            col1, col2 = st.columns(2, border=True)
            col1.markdown("**Before:**")
            col2.markdown("**After:**")

            col1.markdown(f"**Weight (carat):** {t.before_weight_ct}")
            col1.markdown(f"**Shape:** {t.before_shape}")
            col1.markdown(f"**Length:** {t.before_length}")
            col1.markdown(f"**Width:** {t.before_width}")
            col1.markdown(f"**Depth:** {t.before_depth}")

            col2.markdown(f"**Weight (carat):** {t.after_weight_ct}")
            col2.markdown(f"**Shape:** {t.after_shape}")
            col2.markdown(f"**Length:** {t.after_length}")
            col2.markdown(f"**Width:** {t.after_width}")
            col2.markdown(f"**Depth:** {t.after_depth}")


@st.dialog("New return from factory")
def new_return_from_factory(db):
    """
    Dialog for registering a new return from factory.
    Allows selecting the original transfer, choosing a pending item,
    entering updated measurements, and submitting the return action.
    """
    orig_transfer = st.selectbox(
        "Original transfer",
        get_transfers_to_factory_from_empl_office(
            db, user.get()),
        key="orig_transfer_selection",
        index=None,
        format_func=lambda transfer:
            f"Transfer: {transfer.transfer_num} {transfer.ship_date} {transfer.processing_type}",
    )

    if orig_transfer is not None:
        pending_items = get_pending_items_for_factory(
            db,
            orig_transfer
        )
        if len(pending_items) == 0:
            st.write("All items have been returned")
        else:
            st.markdown("#### Generic transfer information")

            transfer_num = st.text_input("Transfer number")
            back_date = st.datetime_input("Received on date")
            terms = st.text_input("Terms")
            remarks = st.text_input("Remarks")

            item_to_return = st.selectbox(
                "What item you would like to return?",
                pending_items,
                format_func=lambda item: f"{item.item_type.capitalize()}: {item.stock_name}, supplier: {item.supplier_name}",
                index=None
            )

            if item_to_return is not None:
                st.markdown("#### Enter its new measurements")

                # Extract info to prefill the fields below
                stone = get_loose_stone(db, item_to_return.lot_id)

                weight_ct = st.number_input("Weight in carats",
                    value=float(stone.weight_ct), min_value=0.0, max_value=100.0)
                length = st.number_input("Length in mm",
                    value=float(stone.length), min_value=0.0, max_value=10.0)
                width = st.number_input("Width in mm",
                    value=float(stone.width), min_value=0.0, max_value=10.0)
                depth = st.number_input("Depth in mm",
                    value=float(stone.depth), min_value=0.0, max_value=10.0)

                shape_vals = ['Brilliant Cut', 'Pear Shape', 'Radiant Cut',
                     'Heart Shape', 'Emerald Cut', 'Baquette', 'Briolette', 'Kite',
                     'Marquise', 'Oval', 'Princess', 'Trillion']
                shape = st.selectbox(
                    "Shape",
                    shape_vals,
                    key="shape_selection",
                    index=shape_vals.index(stone.shape)
                )

                note = st.text_input("Additional details")

                if st.button("Submit"):
                    action_id, err = make_new_return_from_factory(
                        db,
                        orig_transfer=orig_transfer,
                        terms=terms,
                        remarks=remarks,
                        employee=user.get(),
                        transfer_num=transfer_num,
                        back_date=back_date,
                        item_to_return=item_to_return,
                        weight_ct=weight_ct,
                        width=width,
                        length=length,
                        depth=depth,
                        shape=shape,
                        note=note
                    )

                    if err is None:
                        db.commit()
                        with query_param("action_id", int) as qp:
                            qp.set(action_id)
                        st.rerun()
                    else:
                        st.error(err)


def select_transfer(
    transfers: list[ReturnFromFactory],
    transfer_id: int | None = None,
):
    """
    Display a selectbox for factory returns and return
    the selected transfer (optionally preselected by action_id).
    """
    if transfer_id is None:
        index = None
    else:
        index = [a.action_id for a in transfers].index(transfer_id)

    return st.selectbox(
        "Current transfer",
        transfers,
        key="transfer_selection",
        index=index,
        format_func=lambda t: f"Transfer: (#{t.action_id}) number: {t.back_from_fac_num}, date: {t.back_date}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Returns from factories")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("action_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                t = select_transfer(
                    get_returns_from_factories(db), qp.get())
                if t is not None:
                    qp.set(t.action_id)

                if st.button("Register new return"):
                    new_return_from_factory(db)

        if t is None:
            st.info("Please select transfer to inspect it")
        else:
            action = get_action(db, t.action_id)
            items = get_items_for_action(db, action.action_id)
            render_return_details(t, action, items[0])

