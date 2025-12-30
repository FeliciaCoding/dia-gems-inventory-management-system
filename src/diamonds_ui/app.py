import streamlit as st

from diamonds_ui.auth import logout, user

#
# Pages configuration
#
items = [
    st.Page("pages/inventory/inventory_white_diamonds.py", title = "White Diamonds", icon = ":material/store:"),
    st.Page("pages/inventory/inventory_colored_diamonds.py", title="Colored Diamonds", icon=":material/store:"),
    st.Page("pages/inventory/inventory_colored_gemstones.py", title="Colored Gemstones", icon=":material/store:"),
    st.Page("pages/inventory/inventory_jewelries.py", title="Jewelries", icon=":material/store:"),
]


purchases = st.Page(
    "pages/purchases.py", title="Purchases", icon=":material/store:"
)

sales = st.Page(
    "pages/sales.py", title="Sales", icon=":material/store:"
)

transfers = [
    st.Page("pages/transfers/transfers_to_office.py", title="To office", icon=":material/store:"),
    st.Page("pages/transfers/transfers_to_lab.py", title="To lab", icon=":material/store:"),
    st.Page("pages/transfers/transfers_to_factory.py", title="To factory", icon=":material/store:"),
    st.Page("pages/transfers/memos_in.py", title="Memo in", icon=":material/store:"),
    st.Page("pages/transfers/memos_out.py", title="Memo out", icon=":material/store:")
]

returns = [
    st.Page("pages/returns/return_from_lab.py", title="From labs", icon=":material/store:"),
    st.Page("pages/returns/return_from_factory.py", title="From factories", icon=":material/store:"),
    st.Page("pages/returns/return_memo_in.py", title="From memos in", icon=":material/store:"),
    st.Page("pages/returns/return_memo_out.py", title="From memos out", icon=":material/store:"),
]


chief_dict = {}
admin_dict = {}
sales_dict = {}
accountant_dict = {}
unlogged_dict = {}

if user.is_logged:
    logged_dict = {
        "Account": [
            st.Page("pages/account/profile.py", title=f"Profile ({user.get().first_name} {user.get().last_name})",
                    icon=":material/account_circle:"),
            st.Page(logout, title="Log out", icon=":material/logout:"),
            st.Page("pages/about.py", title="About", icon=":material/store:")
        ]
    }

    if user.get().role == 'Chief':
        # full control
        chief_dict = {
            "": [purchases, sales],
            "Inventory": items,
            "Transfers": transfers,
            "Returns": returns,
            **logged_dict
        }

    elif user.get().role == 'Admin':
        # all the inventory and all the transfers and returns
        admin_dict = {
            "Inventory": items,
            "Transfers": transfers,
            "Returns": returns,
            **logged_dict
        }

    elif user.get().role == 'Sales':
        # all the inventory and all the sales
        sales_dict = {
            "": [sales],
            "Inventory": items,
            **logged_dict
        }

    else: #'Accountant'
        # all the purchases and all the sales
        accountant_dict = {
            "": [purchases, sales],
            **logged_dict
        }

else:
    # When not logged in, present a login page.
    unlogged_dict = {
        "": [
            st.Page("pages/account/login.py", title="Log in", icon=":material/login:"),
            st.Page("pages/about.py", title="About", icon=":material/store:")
        ]
    }

#
# Display available pages in sidebar (depending on current user)
#
page_dict = {
    **chief_dict,
    **admin_dict,
    **sales_dict,
    **accountant_dict,
    **unlogged_dict,
}
pg = st.navigation(page_dict)
pg.run()

