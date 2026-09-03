from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any


@dataclass
class PersistentRecord:
    record_id: str
    collection: str
    data: dict[str, Any]
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )
