from collections.abc import Callable
from typing import Any

from app.autonomy.engines.task_executor import (
    TaskExecutor,
)
from app.autonomy.engines.task_scheduler import (
    TaskScheduler,
)
from app.autonomy.models.report import (
    TaskReport,
)
from app.autonomy.models.task import (
    AutonomousTask,
)
from app.autonomy.stores.task_store import (
    TaskStore,
)


class AutonomyService:
    def __init__(self) -> None:
        self.store = TaskStore()

        self.executor = TaskExecutor()

        self.scheduler = TaskScheduler(
            self.executor
        )

    def create_task(
        self,
        title: str,
        description: str = "",
    ) -> AutonomousTask:
        task = AutonomousTask(
            title=title,
            description=description,
        )

        return self.store.add(task)

    def submit(
        self,
        title: str,
        operation: Callable[[], Any],
        description: str = "",
    ) -> AutonomousTask:
        task = self.create_task(
            title=title,
            description=description,
        )

        self.scheduler.schedule(
            task,
            operation,
        )

        return task

    def get(
        self,
        task_id: str,
    ) -> AutonomousTask | None:
        return self.store.get(task_id)

    def list_tasks(
        self,
    ) -> list[AutonomousTask]:
        return self.store.list_all()

    def report(
        self,
        task_id: str,
    ) -> TaskReport | None:
        task = self.get(task_id)

        if task is None:
            return None

        summary = (
            f"Task '{task.title}' is "
            f"{task.status} "
            f"({task.progress}%)."
        )

        if task.error:
            summary += (
                f" Error: {task.error}"
            )

        return TaskReport(
            task_id=task.task_id,
            status=task.status,
            progress=task.progress,
            summary=summary,
        )
