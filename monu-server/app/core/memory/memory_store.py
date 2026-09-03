from typing import Any


class MemoryStore:
    """
    Initial in-memory memory foundation for MONU.

    Later this can be replaced by Redis, PostgreSQL,
    vector database, or another persistent storage layer.
    """

    def __init__(self) -> None:
        self.short_term: list[dict[str, Any]] = []
        self.task_history: dict[str, dict[str, Any]] = {}
        self.project_memory: dict[str, Any] = {}
        self.failure_memory: list[dict[str, Any]] = []
        self.decision_history: list[dict[str, Any]] = []

    def remember_short_term(
        self,
        content: str,
        metadata: dict[str, Any] | None = None,
    ) -> None:
        self.short_term.append(
            {
                "content": content,
                "metadata": metadata or {},
            }
        )

        if len(self.short_term) > 100:
            self.short_term.pop(0)

    def remember_task(
        self,
        task_id: str,
        data: dict[str, Any],
    ) -> None:
        self.task_history[task_id] = data

    def remember_failure(
        self,
        data: dict[str, Any],
    ) -> None:
        self.failure_memory.append(data)

        if len(self.failure_memory) > 100:
            self.failure_memory.pop(0)

    def remember_decision(
        self,
        data: dict[str, Any],
    ) -> None:
        self.decision_history.append(data)

        if len(self.decision_history) > 100:
            self.decision_history.pop(0)

    def get_recent_context(
        self,
        limit: int = 10,
    ) -> list[dict[str, Any]]:
        return self.short_term[-limit:]

    def get_task(
        self,
        task_id: str,
    ) -> dict[str, Any] | None:
        return self.task_history.get(task_id)
