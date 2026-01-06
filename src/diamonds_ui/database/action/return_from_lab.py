import psycopg
from datetime import date
from diamonds_ui.database.action.transfer import Transfer, get_transfers_to


class ReturnFromLab(Transfer):
    orig_transfer_id: int
    back_from_lab_num: str | None
    back_date: date


def get_returns_from_lab(
        db: psycopg.Connection,
        lot_id: int
):
    # TODO:
    # We are sending items to a lab for receiving new certificates (yes?)
    # Every return should be accompanied by a new certificate (yes?)
    # So, here we actually need to show/save num of previous certificate
    # and num of a new one, along with info about lab
    return get_transfers_to(db, "back_from_lab",
        lot_id, ["orig_transfer_id", "back_from_lab_num", "back_date"])

