import streamlit as st

#
# Pages configuration
#
# Define top-level pages (these refer to other python files under pages/)
white_diamonds = st.Page(
    "pages/inventory_white_diamonds.py", title="White Diamonds", icon=":material/store:", default=True
)

colored_diamonds = st.Page(
    "pages/inventory_colored_diamonds.py", title="Colored Diamonds", icon=":material/store:"
)

colored_gemstones = st.Page(
    "pages/inventory_colored_gemstones.py", title="Colored Gemstones", icon=":material/store:"
)

jewelries = st.Page(
    "pages/inventory_jewelries.py", title="Jewelries", icon=":material/store:"
)

item_details = st.Page(
    "pages/item_details.py", title="Item Details", icon=":material/store:"
)

purchases = st.Page(
    "pages/purchases.py", title="Purchases", icon=":material/store:"
)

sales = st.Page(
    "pages/sales.py", title="Sales", icon=":material/store:"
)

transfers = st.Page(
    "pages/transfers.py", title="Transfers", icon=":material/store:"
)

returns = st.Page(
    "pages/returns.py", title="Returns", icon=":material/store:"
)


#
# Shared content (shown on all pages)
#
# Place a large logo in the app header; these are static asset paths.
# st.logo(
#     "assets/images/horizontal_logo.svg",
#     icon_image="assets/images/icon_logo.svg",
#     size="large",
# )


#
# Display available pages in sidebar (depending on current user)
#
# Build a simple mapping of section headers to page lists for the navigation helper.
page_dict = {
    "Inventory": [white_diamonds, colored_diamonds, colored_gemstones, jewelries],
    "Purchases": [purchases],
    "Transfers": [transfers],
    "Sales": [sales],
    "Returns": [returns],
}
# Create the navigation component from the dictionary above.
pg = st.navigation(page_dict)

# Run current page (based on url or user selection)
pg.run()

