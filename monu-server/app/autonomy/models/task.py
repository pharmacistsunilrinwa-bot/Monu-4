from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any
from uuid import uuid4


@dataclass
class AutonomousTask:
    title: str
    description: str = ""
    task_id: str = field(
        default_factory=lambda: str(uuid4())
    )
    status: str = "pending"
    progress: int = 0
    result: Any = None
    error: str | None = None
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )
    updated_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )

    def update(
        self,
        *,
        status: str | None = None,
        progress: int | None = None,
        result: Any = None,
        error: str | None = None,
    ) -> None:
        if status is not None:
            self.status = status

        if progress is not None:
            self.progress = max(
                0,
                min(100, progress),
            )

        if result is not None:
            self.result = result

        if error is not None:
            self.error = error

        self.updated_at = datetime.now(
            timezone.utc
        )
