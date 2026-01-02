import psycopg
from diamonds_ui.database.action.transfer import Transfer, get_transfers_to


class TransferToOffice(Transfer):
    pass


def get_transfers_to_office(
        db: psycopg.Connection,
        lot_id: int
):
    return get_transfers_to(db, "transfer_to_office",
                            lot_id, [])
