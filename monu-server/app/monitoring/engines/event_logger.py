from typing import Any

from app.monitoring.models.monitoring import SystemEvent
from app.monitoring.stores.event_store import EventStore


class EventLogger:
    def __init__(
        self,
        store: EventStore,
    ) -> None:
        self.store = store

    def log(
        self,
        name: str,
        level: str = "info",
        data: dict[str, Any] | None = None,
    ) -> SystemEvent:
        event = SystemEvent(
            name=name,
            level=level,
            data=data or {},
        )

        return self.store.add(event)
