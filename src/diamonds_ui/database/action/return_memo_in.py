import psycopg
from datetime import date
from diamonds_ui.database.action.transfer import Transfer, get_transfers_to


class ReturnMemoIn(Transfer):
    orig_transfer_id: int
    return_memo_in_num: str | None
    back_date: date

def get_returns_memo_in(
        db: psycopg.Connection,
        lot_id: int
):
    return get_transfers_to(db, "return_memo_in", lot_id,
        ["orig_transfer_id", "return_memo_in_num", "back_date"])

