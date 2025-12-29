"""Main Streamlit app entry point for the Pagila UI example.

This module wires up the app pages and navigation. It demonstrates:
- Defining pages (static file pages or callables).
- Showing different sidebar entries depending on whether a user is logged in.
- Using a small shared UI section (logo) shown on every page.
- Running the selected page using the streamlit navigation helper.

Notes for students:
- st.Page(...) constructs a page object: it can take a string path to a page module
  (which Streamlit will load) or a callable (for simple actions like logging out).
- We inspect user.is_logged to decide which account-related pages to show.
- pg.run() triggers the currently selected page to execute.
"""

import streamlit as st

#
# Pages configuration
#
# Define top-level pages (these refer to other python files under pages/)
home = st.Page(
    "pages/inventory.py", title="Stones and Jewelries", icon=":material/store:", default=True
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
    "Inventory": [home],
}
# Create the navigation component from the dictionary above.
pg = st.navigation(page_dict)

# Run current page (based on url or user selection)
pg.run()

