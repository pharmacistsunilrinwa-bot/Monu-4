from dataclasses import dataclass, field
from uuid import uuid4


@dataclass
class RevenueRecord:
    source: str
    amount: float
    category: str
    record_id: str = field(
        default_factory=lambda: str(uuid4())
    )
