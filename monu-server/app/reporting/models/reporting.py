from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any
from uuid import uuid4


@dataclass
class Report:
    report_id: str = field(
        default_factory=lambda: str(uuid4())
    )
    title: str = ""
    status: str = "info"
    summary: str = ""
    data: dict[str, Any] = field(
        default_factory=dict
    )
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )


@dataclass
class Notification:
    notification_id: str = field(
        default_factory=lambda: str(uuid4())
    )
    title: str = ""
    message: str = ""
    level: str = "info"
    delivered: bool = False
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )
