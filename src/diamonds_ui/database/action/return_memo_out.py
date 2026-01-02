import psycopg
from datetime import date
from diamonds_ui.database.action.transfer import Transfer, get_transfers_to


class ReturnMemoOut(Transfer):
    orig_transfer_id: int
    return_memo_out_num: str | None
    back_date: date

def get_returns_memo_out(
        db: psycopg.Connection,
        lot_id: int
):
    return get_transfers_to(db, "return_memo_out", lot_id,
        ["orig_transfer_id", "return_memo_out_num", "back_date"])

