from typing import Any

from app.core.orchestrator import MonuOrchestrator
from app.core.models.task import TaskContext


class MonuService:
    def __init__(self) -> None:
        self.orchestrator = MonuOrchestrator()

    async def handle(
        self,
        content: str,
        metadata: dict[str, Any] | None = None,
    ) -> TaskContext:
        return await self.orchestrator.process(
            content=content,
            metadata=metadata,
        )
