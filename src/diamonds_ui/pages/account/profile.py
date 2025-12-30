import streamlit as st

from diamonds_ui.auth import user

employee = user.get()

# If the user is not logged in, show an error.
if employee is None:
    st.error("Somehow you have accessed this page while not being logged !!!")
else:
    # Use a horizontal container for the title and badge.
    with st.container(horizontal=True, vertical_alignment="center"):
        st.title("Profile")
        st.badge(f"Employee ID: {employee.employee_id}")

    # Show the user's name and email.
    st.html(
        f"""
        <table>
            <tr>
                <td>Name:</td>
                <td>{employee.first_name} {employee.last_name}</td>
            </tr>
            <tr>
                <td>Email:</td>
                <td>{employee.email}</td>
            </tr>
            <tr>
                <td>Office:</td>
                <td>{employee.counterpart}</td>
            </tr>
            <tr>
                <td>Role:</td>
                <td>{employee.role}</td>
            </tr>
        </table>
        """
    )

