import streamlit as st

from diamonds_ui.auth import logout, user


#
# Pages configuration
#
# Define top-level pages (these refer to other python files under pages/)
white_diamonds = st.Page(
    "pages/inventory_white_diamonds.py", title="White Diamonds", icon=":material/store:"
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

about = st.Page(
    "pages/about.py", title="About", icon=":material/store:"
)



if user.is_logged:
    # A logout page can be a callable; clicking it runs the logout function.
    logout_page = st.Page(logout, title="Log out", icon=":material/logout:")
    # # Show the user's name in the profile title by reading the stored user object.
    profile = st.Page(
        "pages/profile.py",
        title=f"Profile ({user.get().first_name} {user.get().last_name})",
        icon=":material/account_circle:",
    )
else:
    # When not logged in, present a login page.
    login_page = st.Page(
        "pages/login.py", title="Log in", icon=":material/login:"
    )


#
# Display available pages in sidebar (depending on current user)
#
# Build a simple mapping of section headers to page lists for the navigation helper.
page_dict = {
    "Inventory": [] if not user.is_logged else [white_diamonds, colored_diamonds, colored_gemstones, jewelries],
    "Purchases": [purchases],
    "Transfers": [transfers],
    "Sales": [sales],
    "Returns": [returns],
    "Account": [login_page, about] if not user.is_logged else [profile, about, logout_page],
}
# Create the navigation component from the dictionary above.
pg = st.navigation(page_dict)

# Run current page (based on url or user selection)
pg.run()

