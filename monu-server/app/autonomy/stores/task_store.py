from app.autonomy.models.task import (
    AutonomousTask,
)


class TaskStore:
    def __init__(self) -> None:
        self._tasks: dict[
            str,
            AutonomousTask,
        ] = {}

    def add(
        self,
        task: AutonomousTask,
    ) -> AutonomousTask:
        self._tasks[task.task_id] = task
        return task

    def get(
        self,
        task_id: str,
    ) -> AutonomousTask | None:
        return self._tasks.get(task_id)

    def list_all(
        self,
    ) -> list[AutonomousTask]:
        return list(self._tasks.values())

    def list_by_status(
        self,
        status: str,
    ) -> list[AutonomousTask]:
        return [
            task
            for task in self._tasks.values()
            if task.status == status
        ]
