"""Small pagination UI helper for the Streamlit Pagila example.

This module exposes pagination_element(), a compact UI component that shows
"from-to of total" information and provides controls to change the current
page offset and the number of items per page.

Concepts for students:
- Streamlit's st.container groups widgets visually; st.empty creates a placeholder
  that can be filled later; st.popover shows additional controls when opened.
- st.session_state is a per-user, per-tab dictionary used to persist values
  across reruns (the widgets value are stored there).
- The function returns (per_page, offset) so calling code can use those values
  for SQL queries or slicing lists.
"""

import streamlit as st


def pagination_element(total: int, per_page_default=10):
    """Render pagination controls and return the chosen page size and offset.

    Args:
        total: total number of items available.
        per_page_default: initial value for "items per page".

    Returns:
        A tuple (per_page, offset) containing the current values chosen by the user.

    Behavior notes:
    - A small popover contains inputs for "Per page" and "Offset".
    - Offset is stored in st.session_state under the key "page_offset" so it can be read
      or modified by other code.
    - The function also renders previous/next buttons that update session_state.
    """
    with st.container(
        horizontal=True, horizontal_alignment="right", vertical_alignment="center"
    ):
        # Create placeholder widgets we will populate. Using st.empty lets us
        # control layout order and update individual parts independently.
        pagination = st.empty()
        prev_page_btn = st.empty()
        next_page_btn = st.empty()

        # Put additional controls (per-page and offset) inside a popover so the
        # main UI stays compact but the values are still editable.
        with st.popover("⋮"):
            per_page = st.number_input(
                "Per page", value=per_page_default, min_value=1, width=150
            )
            offset = st.number_input(
                "Offset",
                key="page_offset",  # stored in session_state
                value=0,
                min_value=0,
                max_value=max(total - 1, 0),
                step=per_page,
                width=150,
            )

        # Compute human-friendly range (1-based) for display.
        from_item = offset + 1
        to_item = min(offset + per_page, total)
        pagination.write(f"{from_item}-{to_item} of {total}")

        # Callback to go to previous page: update the session_state value.
        def prev_page():
            st.session_state.page_offset = max(
                st.session_state.page_offset - per_page, 0
            )

        # Disable previous button when already at the beginning.
        prev_page_btn.button(
            ":material/arrow_back_ios:",
            disabled=offset <= 0,
            on_click=prev_page,
            shortcut="Left",
        )

        # Callback to go to next page: advance offset but don't go past last item.
        def next_page():
            st.session_state.page_offset = min(
                st.session_state.page_offset + per_page, total - 1
            )

        # Disable next button when we're showing the last page.
        next_page_btn.button(
            ":material/arrow_forward_ios:",
            disabled=offset + per_page >= total,
            on_click=next_page,
            shortcut="Right",
        )

    # Return the current per-page and offset values so callers can use them.
    return per_page, offset
