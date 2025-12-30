import streamlit as st

from diamonds_ui.auth import user

# Create a form so the input and submit are treated as one action.
with st.form("login_form"):
    # Simple text input for the user's email address.
    email = st.text_input(label="Email", autocomplete="email")

    # The form submit button; the form only submits when this button is pressed.
    submit = st.form_submit_button(label="Log In")

# Handle the form submission outside the "with" block.
if submit:
    # Attempt to log in; the helper returns None when successful, or an error message.
    error = user.login(email)
    if error is None:
        # On success, redirect the user to the stores inventory page.
        st.switch_page("pages/inventory_white_diamonds.py")
    else:
        # Show the error to the user (e.g., "Incorrect email.").
        st.error(error)

