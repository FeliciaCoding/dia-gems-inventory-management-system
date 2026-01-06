import psycopg
from datetime import date
from decimal import Decimal
from diamonds_ui.database.action.transfer import Transfer, get_transfers_to


class ReturnFromFactory(Transfer):
    orig_transfer_id: int
    back_from_fac_num: str | None
    back_date: date
    after_weight_ct: Decimal | None
    after_shape: str | None
    after_length: Decimal | None
    after_width: Decimal | None
    after_depth: Decimal | None
    weight_loss_ct: Decimal | None
    note: str | None


def get_returns_from_factory(
        db: psycopg.Connection,
        lot_id: int
):
    return get_transfers_to(db, "back_from_factory", lot_id,
        [
            "orig_transfer_id", "back_from_fac_num", "back_date",
            "after_weight_ct", "after_shape", "after_length",
            "after_width", "after_depth", "weight_loss_ct",
            "note"
        ])

