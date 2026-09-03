import asyncio
from collections.abc import Callable
from typing import Any

from app.autonomy.engines.task_executor import (
    TaskExecutor,
)
from app.autonomy.models.task import (
    AutonomousTask,
)


class TaskScheduler:
    def __init__(
        self,
        executor: TaskExecutor,
    ) -> None:
        self.executor = executor
        self._background_tasks: set[
            asyncio.Task
        ] = set()

    def schedule(
        self,
        task: AutonomousTask,
        operation: Callable[[], Any],
    ) -> None:
        background_task = asyncio.create_task(
            self.executor.execute(
                task,
                operation,
            )
        )

        self._background_tasks.add(
            background_task
        )

        background_task.add_done_callback(
            self._background_tasks.discard
        )

    def active_count(self) -> int:
        return len(
            self._background_tasks
        )
