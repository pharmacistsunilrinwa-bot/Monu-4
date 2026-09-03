import asyncio

from app.core.orchestrator import MonuOrchestrator
from app.schemas.task_states import TaskState
from app.schemas.task_types import TaskType


def test_orchestrator_process() -> None:
    async def run() -> None:
        monu = MonuOrchestrator()

        result = await monu.process(
            "Research modern AI architecture"
        )

        assert result.task_type == TaskType.RESEARCH
        assert result.state == TaskState.COMPLETED
        assert result.route == "research"

    asyncio.run(run())
