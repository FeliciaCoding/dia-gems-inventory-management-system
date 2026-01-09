"""
This page allows to register a new item that
is either being purchased.
It should have a chart what we buy where.
And how it affects revenue.
It should highlight personal purchases.
"""

import streamlit as st
from streamlit_utils import db
from diamonds_ui.auth import user
from diamonds_ui.database.action.action import Action, get_action
from diamonds_ui.database.action.purchase import Purchase, get_purchases
from diamonds_ui.database.counterpart import Counterpart, get_counterparts
from diamonds_ui.database.item.item import (
    Item, PricedItem, get_items_for_action
)
from streamlit_utils.query_param import query_param


def render_purchase_details(p: Purchase, a: Action, items: list[PricedItem]):
    with st.container(border=True):
        st.markdown(f"### Details for: {p.action_id}")

        st.markdown(f"#### {a.action_category.capitalize()}")

        col1, col2 = st.columns(2)
        col1.markdown(f"**From:** {a.from_counterpart_name}")
        col2.markdown(f"**By:** {a.to_counterpart_name}")
        col1.markdown(f"**Purchase number**: {p.purchase_num}")
        col2.markdown(f"**Purchase date**: {p.purchase_date}")

        # TODO:
        # - Add all concerned items included in this purchase
        # - Compute price of this whole purchase
        st.markdown("#### Items:")

        for item in items:
            with st.container(border=True):
                col1, col2 = st.columns(2)
                col1.markdown(f"{item.item_type.capitalize()}: **{item.stock_name}**")
                col1.caption(f"Lot #{item.lot_id}")
                col2.write(f"Purchased: {item.purchase_date.date()}")
                col2.write(f"From: {item.supplier_name}")
                col2.write(f"Price: {item.price} {item.currency_code}")


@st.dialog("New purchase")
def new_purchase():
    st.write(f"Adding new purchase")
    stock_name = st.text_input("Stock name")
    purchase_date = st.date_input("Purchase date")
    purchase_num = st.text_input("Purchase number")
    origin = st.text_input("Origin")

    # selector for supplier
    supplier = st.selectbox(
        "Chosen supplier",
        get_counterparts(db),
        key="supplier_selection",
        index=None,
        format_func=lambda suppl: f"Supplier: (#{suppl.name}) {suppl.category}",
    )
    # selector for item type
    item_type = st.selectbox(
        "Item type",
        ['white diamond', 'colored diamond', 'colored gemstone', 'jewelry'],
        key="item_type_selection",  # required for sync with query parameter (otherwise needs a rerun)
        index=None
    )

    if item_type in ["white diamond", "colored diamond",
                    "colored gemstone"]:
        weight_ct = st.text_input("Weight in carats")
        shape = st.selectbox(
            "Loose stone shape",
            ['Brilliant Cut', 'Pear Shape', 'Radiant Cut',
             'Heart Shape', 'Emerald Cut', 'Baquette', 'Briolette', 'Kite',
             'Marquise', 'Oval', 'Princess', 'Trillion'],
            key="shape_selection",
            index=None
        )
        length = st.text_input("Length in mm")
        width = st.text_input("Width in mm")
        depth = st.text_input("Depth in mm")

    if item_type == "white diamond":
        white_scale = st.selectbox(
            "White scale of a diamond",
            ['D', 'E', 'F', 'G', 'H',
             'I', 'J', 'K', 'L', 'M',
             'N', 'O', 'P', 'Q', 'R',
             'S', 'T', 'U', 'V', 'W',
             'X', 'Y', 'Z'],
            key="white_scale_selection",
            index=None
        )
        clarity = st.selectbox(
            "Clarity of a diamond",
            ['I1', 'I2', 'VS', 'VS1', 'VS2', 'VVS',
             'VVS1', 'VVS2','FL', 'IF'],
            key="clarity_selection",
            index=None
        )
        if st.button("Submit"):
            # TODO:
            # 1) create new action (type=purchase)
            # 2) create new item/loose stone/white diamond
            # 3) make action_item link
            # 4) create new purchase
            # 5) switch page to purchase with newly created purchase
            # 6) reflect new action creation in action_update_log for current user
            pass

    elif item_type == "colored diamond":
        fancy_intensity = st.selectbox(
            "Fancy intensity of a colored diamond",
            ['Faint', 'Very Light', 'Light',
             'Fancy light', 'Fancy','Fansy Vivid',
             'Fancy intense', 'Fancy Deep', 'Fansy Dark'],
            key="fancy_intensity_selection",
            index=None
        )
        fancy_overtone = st.text_input(
            "Fancy overtone of a colored diamond")
        fancy_color = st.selectbox(
            "Fancy color of a colored diamond",
            ['Red', 'Orange', 'Yellow',
             'Green', 'Blue', 'Violet', 'Gray'],
            key="fancy_color_selection",
            index=None
        )
        clarity = st.selectbox(
            "Clarity of a diamond",
            ['I1', 'I2', 'VS', 'VS1', 'VS2', 'VVS',
             'VVS1', 'VVS2','FL', 'IF'],
            key="clarity_selection",
            index=None
        )
        if st.button("Submit"):
            # TODO:
            # 1) create new action (type=purchase)
            # 2) create new item/loose stone/colored diamond
            # 3) make action_item link
            # 4) create new purchase
            # 5) switch page to purchase with newly created purchase
            # 6) reflect new action creation in action_update_log for current user
            pass

    elif item_type == "colored gemstone":
        # gem_type selector
        gem_type = st.selectbox(
            "Type of a gemstone",
            ['Sapphire', 'Emerald', 'Ruby', 'Diamond'],
            key="gem_type_selection",
            index=None
        )
        # gem_color selector
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
            # TODO:
            # 1) create new action (type=purchase)
            # 2) create new item/loose stone/colored gemstone
            # 3) make action_item link
            # 4) create new purchase
            # 5) switch page to purchase with newly created purchase
            # 6) reflect new action creation in action_update_log for current user
            pass

    elif item_type == "jewelry":
        jewelry_type = st.selectbox(
            "Type of a jewelry",
            ['Earrings', 'Necklace', 'Ring',
             'Brooch', 'Bracelet'],
            key="jewelry_type_selection",
            index=None
        )
        gross_weight_gr = st.number_input(
            "Whole weight of a jewelry in g",
            min_value=0
        )
        metal_type = st.selectbox(
            "Type of metal",
            ['PT900', 'PT950', '18k white gold',
             '14k white gold', '18k white/yellow gold',
             '18k rose gold', '18k white gold + PT'],
            key="metal_type_selection",
            index=None
        )
        metal_weight_gr = st.number_input(
            "Weight of the metal in g",
            min_value=0.0
        )
        centered_stone_type = st.text_input("Type of the center stones")
        total_center_stone_qty = st.number_input(
            "Total quantity of center stones",
            min_value=0
        )
        total_center_stone_weight_ct = st.number_input(
            "Total weight of the center stones in carats",
            min_value=0.0
        )
        side_stone_type = st.text_input("Type of the side stones")
        total_side_stone_qty = st.number_input(
            "Total quantity of side stones",
            min_value=0
        )
        total_side_stone_weight_ct = st.number_input(
            "Total weight of the side stones in carats",
            min_value=0.0
        )
        if st.button("Submit"):
            # TODO:
            # 1) create new action (type=purchase)
            # 2) create new item/jewelry
            # 3) make action_item link
            # 4) create new purchase
            # 5) switch page to purchase with newly created purchase
            # 6) reflect new action creation in action_update_log for current user
            pass


def select_purchase(
    purchases: list[Purchase],
    id: int | None = None,
):
    if id is None:
        index = None
    else:
        index = [a.action_id for a in purchases].index(id)

    return st.selectbox(
        "Current purchase",
        purchases,
        key="purchase_selection",  # required for sync with query parameter (otherwise needs a rerun)
        index=index,
        format_func=lambda a: f"Purchase: (#{a.action_id}) {a.purchase_num}",
    )


if user.get() is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    st.header("Purchase")

    conn = db.connection()
    with conn.connect() as db:
        with query_param("lot_id", int) as qp:
            with st.container(horizontal=True, vertical_alignment="bottom"):
                p = select_purchase(
                    get_purchases(db), qp.get())
                if p is not None:
                    qp.set(p.action_id)

                if st.button("Add purchase"):
                    new_purchase()

        if p is None:
            st.info("Please select purchase to inspect it")
        else:
            action = get_action(db, p.action_id)
            items = get_items_for_action(db, action.action_id)
            render_purchase_details(p, action, items)

