"""
This page is dedicated to the info about the platform
and its creators
"""

import streamlit as st

st.header("About")

with st.container(border=True):
    st.markdown("#### Diamonds")
    st.write("Developed system is a secure inventory management and traceability platform dedicated to diamonds, colored stones, and jewelry. ")
    st.write("It acts as a centralized and reliable source of information for identifying, tracking, and managing goods throughout their lifecycle.")

with st.container(border=True):
    st.markdown("#### Contributors")
    st.write("- Liao Pei-Wen")
    st.write("- Makovskyi Maksym")
    st.write("- Wu Guo Yu")
