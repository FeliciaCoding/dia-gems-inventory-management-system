import psycopg
from diamonds_ui.database.action.transfer import Transfer, get_transfers_to


class TransferToLab(Transfer):
    lab_purpose: str


def get_transfers_to_lab(
        db: psycopg.Connection,
        lot_id: int
):
    return get_transfers_to(db, "transfer_to_lab",
                            lot_id, ["lab_purpose"])

