from datetime import datetime, timezone
from typing import Any


class AuditLogger:
    """
    Records important MONU lifecycle events.
    """

    def __init__(self) -> None:
        self.events: list[dict[str, Any]] = []

    def log(
        self,
        event: str,
        task_id: str | None = None,
        details: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        record = {
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat(),
            "event": event,
            "task_id": task_id,
            "details": details or {},
        }

        self.events.append(record)

        return record

    def history(
        self,
        task_id: str | None = None,
    ) -> list[dict[str, Any]]:
        if task_id is None:
            return list(self.events)

        return [
            event
            for event in self.events
            if event["task_id"] == task_id
        ]
