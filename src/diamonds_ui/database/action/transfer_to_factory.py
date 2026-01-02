import psycopg
from diamonds_ui.database.action.transfer import Transfer, get_transfers_to


class TransferToFactory(Transfer):
    processing_type: str


def get_transfers_to_factory(
        db: psycopg.Connection,
        lot_id: int
):
    return get_transfers_to(db, "transfer_to_factory",
                            lot_id, ["processing_type"])
