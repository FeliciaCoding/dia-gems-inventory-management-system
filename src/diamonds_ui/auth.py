import streamlit as st

from diamonds_ui.database.employee import Employee, get_employee
from streamlit_utils import db


class _User[T]:
    """Small helper to manage current user in streamlit.session_state.

    Usage example (simplified):
        err = user.login("student@example.com")
        if err is None:
            # logged in, user.get() returns the DB row/object
            current = user.get()
        else:
            st.error(err)

    The class intentionally keeps logic minimal: check, set, remove, and fetch.
    """

    _PREFIX = "USER_"

    # session key used to store the full user object returned by the DB.
    user_key = f"{_PREFIX}-user"

    @property
    def is_logged(self) -> bool:
        """Return True if a user object is present in st.session_state.

        This is a lightweight check used by UI code to determine whether the
        app should show login controls or user-specific pages.
        """
        return self.user_key in st.session_state

    def login(self, email: str):
        """Attempt to log in a user by email.

        Queries the database for a user with the provided email. If found,
        the returned user object is stored in st.session_state under
        self.user_key so the rest of the app can access it.

        Args:
            email: the email address to look up in the user table.

        Returns:
            None when login succeeds, or a short error message string when it fails.
        """
        error = None
        # Use the project's db helper to get a short-lived connection.
        with db.connection().connect() as conn:
            employee: T = get_employee(conn, email)

            if employee is None:
                error = "Incorrect email."

            if error is None:
                # Store the DB row/object for the rest of the Streamlit session.
                st.session_state[self.user_key] = employee

        return error

    def logout(self):
        """Remove the current user from session_state.

        After this call the app should treat the user as logged out. Calling
        this when no user is stored will raise a KeyError, so callers usually
        check is_logged first.
        """
        del st.session_state[self.user_key]

    def get(self) -> T | None:
        """Return the current logged-in user object or None.

        The returned value is whatever the DB driver produced (e.g., a Row or
        mapping) when login stored it.
        """
        if self.is_logged:
            return st.session_state[self.user_key]
        else:
            return None


user = _User[Employee]()


def logout():
    """Convenience function to log out and immediately refresh the Streamlit UI.

    Calling st.rerun() forces the script to re-run, so UI elements can update
    to reflect that no user is logged in.
    """
    user.logout()
    st.rerun()
