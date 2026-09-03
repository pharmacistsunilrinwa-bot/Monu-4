from app.workflows.engines import WorkflowEngine
from app.workflows.models import (
    Workflow,
    WorkflowResult,
)


class WorkflowService:
    def __init__(
        self,
        engine: WorkflowEngine,
    ) -> None:
        self.engine = engine

    async def execute(
        self,
        workflow: Workflow,
    ) -> WorkflowResult:
        return await self.engine.execute(
            workflow
        )
