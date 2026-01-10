from decimal import Decimal
from datetime import date, datetime
from pydantic import BaseModel
import psycopg
from psycopg.rows import class_row


class Sale(BaseModel):
    action_id: int
    sale_num: str | None
    sale_date: date | None
    payment_method: str | None
    payment_status: str | None


