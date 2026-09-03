from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any
from uuid import uuid4


@dataclass
class Job:
    name: str
    job_id: str = field(
        default_factory=lambda: str(
            uuid4()
        )
    )
    status: str = "pending"
    result: Any = None
    error: str | None = None
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )
