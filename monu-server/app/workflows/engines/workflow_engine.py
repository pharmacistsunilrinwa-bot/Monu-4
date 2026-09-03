from app.tools.services import ToolService
from app.workflows.models import (
    Workflow,
    WorkflowResult,
)


class WorkflowEngine:
    def __init__(
        self,
        tool_service: ToolService,
    ) -> None:
        self.tool_service = tool_service

    async def execute(
        self,
        workflow: Workflow,
    ) -> WorkflowResult:
        results = []

        for step in workflow.steps:
            response = await self.tool_service.execute(
                tool_name=step.tool_name,
                arguments=step.arguments,
            )

            results.append(
                {
                    "step_id": step.step_id,
                    "success": response.success,
                    "result": response.result,
                    "error": response.error,
                }
            )

            if not response.success:
                return WorkflowResult(
                    workflow_id=workflow.workflow_id,
                    success=False,
                    results=results,
                    error=response.error,
                )

        return WorkflowResult(
            workflow_id=workflow.workflow_id,
            success=True,
            results=results,
        )
