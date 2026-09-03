from app.monitoring.models.monitoring import (
    SystemEvent,
)


class EventStore:
    def __init__(self) -> None:
        self._events: list[SystemEvent] = []

    def add(
        self,
        event: SystemEvent,
    ) -> SystemEvent:
        self._events.append(event)
        return event

    def list_all(self) -> list[SystemEvent]:
        return list(self._events)

    def clear(self) -> None:
        self._events.clear()
