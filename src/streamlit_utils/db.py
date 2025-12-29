"""Lightweight psycopg3 connection helper for Streamlit apps.

This module provides a custom Streamlit connection class that wraps a
psycopg_pool.ConnectionPool. We intentionally avoid Streamlit's higher-level
SQLAlchemy connection helper to keep direct control over the database driver
(psycopg3) and to demonstrate explicit connection/transaction handling.

Key points for students:
- Use st.connection("postgresql", type=StreamlitPsycopgConnection) to obtain an
  instance (see the connection() helper at the bottom).
- connect() is a context manager that yields a live psycopg.Connection from the pool.
- Errors are surfaced to the Streamlit app via st.error for a friendly UI message.
"""

from contextlib import contextmanager
from typing import Any, Generator, NamedTuple

import psycopg
import streamlit as st
from psycopg.rows import namedtuple_row
from psycopg_pool import ConnectionPool
from streamlit.connections import BaseConnection


class StreamlitPsycopgConnection(BaseConnection[ConnectionPool]):
    """Streamlit connection class using a psycopg3 connection pool.

    This class gives direct control of the psycopg driver (row factory, explicit
    pool usage, error handling) rather than relying on SQLAlchemy wrappers.
    """

    def _connect(self, **kwargs) -> ConnectionPool:
        """Create a ConnectionPool instance.

        Builds a conninfo string from secrets and kwargs. Only well-known
        libpq parameters are included (host, port, dbname, user, password, passfile).

        The pool is configured to return rows as named tuples via row_factory,
        making it easy to access columns by attribute (row.column_name).
        """
        # Use secrets provided via Streamlit if caller didn't supply them.
        params = {**self._secrets, **kwargs}
        # Build conninfo string (driver expects space-separated key=value pairs).
        conninfo = " ".join(
            f"{k}={v}"
            for k, v in params.items()
            if k in ["host", "port", "dbname", "user", "password", "passfile"]
        )
        return ConnectionPool(
            conninfo,
            kwargs=dict(row_factory=namedtuple_row),
        )

    @contextmanager
    def connect(self) -> Generator[psycopg.Connection[NamedTuple], Any, Any]:
        """Context manager that yields a live psycopg.Connection from the pool.

        Usage:
        ```
        with conn_obj.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(...)
        ```

        The context manager handles putting the connection back into the pool and
        rolls back the transaction on psycopg.Error to keep the pool clean.
        Errors are reported to the UI via st.error.
        """
        conn = None
        try:
            conn = self._instance.getconn()
            yield conn
        except psycopg.Error as e:
            # Present a friendly error in Streamlit; rollback to avoid leaving a bad transaction.
            st.error(f"Database connection error: {e}")
            if conn:
                conn.rollback()
        finally:
            # Always return the connection to the pool if we acquired one.
            if conn:
                self._instance.putconn(conn)


def connection() -> StreamlitPsycopgConnection:
    """Helper to obtain a Streamlit-registered postgresql connection instance.

    This is a tiny convenience wrapper so calling code can do:
        conn = connection()
        with conn.connect() as db_conn:
            ...

    Streamlit's st.connection system is used to create/manage the connection
    object according to the app's configuration/secrets.
    """
    return st.connection("postgresql", type=StreamlitPsycopgConnection)
