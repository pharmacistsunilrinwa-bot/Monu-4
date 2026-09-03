from datetime import datetime, timezone
from typing import Any


class TaskManager:
    """
    Tracks MONU task lifecycle.
    """

    def __init__(self) -> None:
        self.tasks: dict[str, dict[str, Any]] = {}

    def create(
        self,
        task_id: str,
        content: str,
    ) -> dict[str, Any]:
        task = {
            "task_id": task_id,
            "content": content,
            "state": "CREATED",
            "created_at": datetime.now(
                timezone.utc
            ).isoformat(),
            "history": [],
        }

        self.tasks[task_id] = task

        return task

    def update_state(
        self,
        task_id: str,
        state: str,
    ) -> None:
        task = self.tasks.get(task_id)

        if task is None:
            return

        task["state"] = state

        task["history"].append(
            {
                "state": state,
                "timestamp": datetime.now(
                    timezone.utc
                ).isoformat(),
            }
        )

    def get(
        self,
        task_id: str,
    ) -> dict[str, Any] | None:
        return self.tasks.get(task_id)

    def all_tasks(
        self,
    ) -> list[dict[str, Any]]:
        return list(self.tasks.values())
