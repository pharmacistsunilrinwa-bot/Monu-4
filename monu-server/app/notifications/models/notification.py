from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any


@dataclass
class Notification:
    title: str
    message: str
    level: str = "info"
    read: bool = False
    data: dict[str, Any] = field(
        default_factory=dict
    )
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )
