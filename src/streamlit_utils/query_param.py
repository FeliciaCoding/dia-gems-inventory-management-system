"""Helpers to read, validate, and update Streamlit URL query parameters.

This module provides a small context-manager API around Streamlit's
st.query_params so page code can:
- read a parameter from the URL,
- convert/validate it to a Python type (e.g., int),
- optionally request an update that will be written back to the URL.

Why this is useful for students:
- Streamlit exposes URL query parameters as strings (or lists of strings).
  Converting them safely and keeping a consistent pattern for updating the URL
  makes code easier to reason about and test.
- Using a context manager lets callers read the parsed value and decide to
  update the parameter; the writing back happens automatically on exit.
"""

from contextlib import contextmanager
from dataclasses import dataclass
from typing import Callable, Literal
import streamlit as st


@dataclass
class Mutator[T]:
    """Tiny mutable container used by query_param to communicate a value back.

    Purpose:
    - Context managers cannot directly rebind locals in the caller, so Mutator
      is returned to allow the caller to inspect the parsed value and schedule
      a new value to be written when the context exits.

    Methods:
    - get(default): return the parsed value or the provided default.
    - set(value): schedule `value` to be written back into st.query_params on exit.
    """

    value: T | None
    new_value: T | None = None

    def get(self, default: T | None = None) -> T | None:
        if self.value is None:
            return default
        return self.value

    def set(self, value: T | None):
        # Caller sets this to schedule an update to st.query_params on exit.
        self.new_value = value


@contextmanager
def query_param[T](
    key: str,
    mapper: Callable[[str], T | None],
    if_not_set: Literal["remove", "keep"] = "remove",
):
    """Context manager to read, validate, and optionally update a Streamlit URL query parameter.

    Example:
    ```
    with query_param("store_id", int) as qp:
        store_id = qp.get()            # e.g. 5 or None
        # ... use store_id ...
        qp.set(7)                      # request updating the URL to ?store_id=7
    ```

    Behavior:
    - Reads the raw parameter from st.query_params (strings).
    - Attempts to map/validate it using `mapper`; failures are treated as absent.
    - Yields a Mutator holding the parsed value. Call mutator.set(new) to request a change.
    - On exit:
        - If mutator.new_value is not None: st.query_params[key] is set to that value.
        - If mutator.new_value is None: behavior depends on if_not_set:
            - "remove" (default): the parameter is removed from the URL.
            - "keep": the existing parameter is preserved if the caller didn't call set().

    Notes:
    - Mapper should accept the raw query param (string) and return the desired value
      or raise/return None on failure.
    - Writing to st.query_params updates the browser URL on the next rerun.
    """
    # Read raw parameter(s) from Streamlit's query params.
    value = st.query_params.get(key)
    if value is not None:
        try:
            # Attempt to map/validate the raw value to the desired type.
            value = mapper(value)
        except:
            # On parse/validation error, treat as no value.
            value = None

    # Decide default "new_value" behavior when the caller doesn't call mutator.set().
    match if_not_set:
        case "keep":
            new_value = value
        case "remove" | _:
            new_value = None
    mutator = Mutator(value, new_value)

    yield mutator

    # Persist the requested change back into the query params.
    if mutator.new_value is None:
        # Remove the parameter if the caller didn't request a value (or opted to remove).
        st.query_params.pop(key, None)
    else:
        # Set the new value (Streamlit will stringify when showing in the URL).
        st.query_params[key] = mutator.new_value
