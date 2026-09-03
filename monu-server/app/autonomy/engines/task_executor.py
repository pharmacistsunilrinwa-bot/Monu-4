import asyncio
from collections.abc import Callable
from typing import Any

from app.autonomy.models.task import (
    AutonomousTask,
)


class TaskExecutor:
    async def execute(
        self,
        task: AutonomousTask,
        operation: Callable[[], Any],
    ) -> AutonomousTask:
        task.update(
            status="running",
            progress=10,
        )

        try:
            result = operation()

            if asyncio.iscoroutine(result):
                result = await result

            task.update(
                status="completed",
                progress=100,
                result=result,
            )

        except Exception as exc:
            task.update(
                status="failed",
                progress=100,
                error=str(exc),
            )

        return task
