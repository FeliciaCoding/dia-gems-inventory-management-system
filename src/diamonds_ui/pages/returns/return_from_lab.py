"""
This page is the multi-stage form that
allows to register returns:
- return memo-in
- return memo-out,
- return from lab
- return from factory
"""

import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import (
    Action, get_action
)
from diamonds_ui.database.action.transfer_to_lab import (
    TransferToLab,
    get_transfers_to_labs_where_empl_works
)
from diamonds_ui.database.action.return_from_lab import (
    ReturnFromLab, get_pending_items_for_lab,
    get_returns_from_labs, make_new_return_from_lab
)
from diamonds_ui.database.counterpart import Counterpart, get_counterparts
from diamonds_ui.database.item.item import (
    Item, PricedItem,
    get_items_for_action, get_items_stored_in_office
)
from diamonds_ui.database.item.certificate import (
    Certificate, get_certificate
)
from streamlit_utils.query_param import query_param


def render_return_details(
    t: ReturnFromLab,
    a: Action,
    item: Item,
    cert: Certificate
):
    with st.container(border=True):
        st.markdown(f"### Details for: #{t.action_id}")

        st.markdown(f"#### {a.action_category.capitalize()}")

        col1, col2 = st.columns(2)
        col1.markdown(f"**From:** {a.from_counterpart_name}")
        col2.markdown(f"**To:** {a.to_counterpart_name}")
        col1.markdown(f"**Transfer number**: {t.back_from_lab_num}")
        col2.markdown(f"**Received on**: {t.back_date}")

        # Return From Lab stuff
        # - certification
        # - what item it concerns
        with st.container(border=True):
            st.markdown("#### Concerned item")
            col1, col2 = st.columns(2)
            col1.markdown(f"**Stock name:** {item.stock_name}")
            col1.markdown(f"**Type:** {item.item_type}")
            col2.markdown(f"**Responsible office:** {item.responsible_office}")

        with st.container(border=True):
            st.markdown("#### Certificate")
            col1, col2 = st.columns(2)
            col1.markdown(f"**Certificate num:** {cert.certificate_num}")
            col2.markdown(f"**Issued by:** {cert.lab_name}")
            col2.markdown(f"**Issued on:** {cert.issue_date.date()}")

            # TODO:
            # add button that would lead to detailed certificate view
            # (like the one for purchases for example)
            # in this view user can look at the desired certificate
            # in more details, or it would be cool to have search there
            # among all the certificates for a some specific item


@st.dialog("New return from lab")
def new_return_from_lab(db):
    # list of transfers to lab done by office where user works
    orig_transfer = st.selectbox(
        "Sender",
        get_transfers_to_labs_where_empl_works(db, user.get()),
        key="orig_transfer_office_selection",
        index=None,
        format_func=lambda transfer:
            f"Transfer: {transfer.transfer_num} {transfer.ship_date} {transfer.lab_purpose}",
    )

    if orig_transfer is not None:
        pending_items = get_pending_items_for_lab(db,
            orig_transfer)
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
                st.markdown("#### Enter its new certification details")

                cert_num = st.text_input("Certificate number")
                issue_date = st.date_input("Issue date")

                weight_ct = st.number_input("Weight in carats", 0.0, 100.0)
                length = st.number_input("Length in mm", 0.0, 10.0)
                width = st.number_input("Width in mm", 0.0, 10.0)
                depth = st.number_input("Depth in mm", 0.0, 10.0)

                shape = st.selectbox(
                    "Shape",
                    ['Brilliant Cut', 'Pear Shape', 'Radiant Cut',
                     'Heart Shape', 'Emerald Cut', 'Baquette', 'Briolette', 'Kite',
                     'Marquise', 'Oval', 'Princess', 'Trillion'],
                    key="shape_selection",
                    index=None
                )
                gem_type = st.selectbox(
                    "Type of a gemstone",
                    ['Sapphire', 'Emerald', 'Ruby', 'Diamond'],
                    key="gem_type_selection",
                    index=None
                )

                clarity = None
                gem_color = None
                treatment = None
                if gem_type == "Diamond":
                    clarity = st.selectbox(
                        "Clarity of a diamond",
                        ['I1', 'I2', 'VS', 'VS1', 'VS2', 'VVS',
                         'VVS1', 'VVS2', 'FL', 'IF'],
                        key="clarity_selection",
                        index=None
                    )
                elif gem_type is not None:
                    gem_color = st.selectbox(
                        "Color of a gemstone",
                        ['Red', 'Blue', 'Green',
                         'Pigeon blood', 'Royal Blue'],
                        key="gem_color_selection",
                        index=None
                    )
                    # treatment selector
                    treatment = st.selectbox(
                        "Treatment of a gemstone",
                        ['No heat', 'heated', 'No oil',
                         'Minor Oil', 'Oiled'],
                        key="treatment_selection",
                        index=None
                    )

                if st.button("Submit"):
                    action_id, err = make_new_return_from_lab(
                        db,
                        orig_transfer=orig_transfer,
                        terms=terms,
                        remarks=remarks,
                        employee=user.get(),
                        transfer_num=transfer_num,
                        back_date=back_date,
                        item_to_return=item_to_return,
                        certificate_num=cert_num,
                        issue_date=issue_date,
                        weight_ct=weight_ct,
                        width=width,
                        length=length,
                        depth=depth,
                        shape=shape,
                        clarity=clarity,
                        gem_type=gem_type,
                        gem_color=gem_color,
                        treatment=treatment
                    )

                    if err is None:
                        db.commit()
                        st.toast("New return from lab has been registered!",
                            icon="✅")
                        st.switch_page(
                        "pages/returns/return_from_lab.py",
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
        key="transfer_selection",
        index=index,
        format_func=lambda t: f"Transfer: (#{t.action_id}) number: {t.back_from_lab_num}, date: {t.back_date}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Returns from labs")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("action_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                t = select_transfer(
                    get_returns_from_labs(db), qp.get())
                if t is not None:
                    qp.set(t.action_id)

                if st.button("Register new return"):
                    new_return_from_lab(db)

        if t is None:
            st.info("Please select transfer to inspect it")
        else:
            action = get_action(db, t.action_id)
            items = get_items_for_action(db, action.action_id)
            cert = get_certificate(db, t.new_certificate_id)
            render_return_details(t, action, items[0], cert)


