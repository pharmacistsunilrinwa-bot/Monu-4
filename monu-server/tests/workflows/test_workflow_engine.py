import asyncio

from app.contracts.tool import Tool
from app.tools import (
    ToolRegistry,
    ToolService,
)
from app.workflows import (
    Workflow,
    WorkflowEngine,
    WorkflowStep,
)


class AddTool(Tool):
    name = "add"

    async def execute(
        self,
        arguments,
    ):
        return (
            arguments["a"]
            + arguments["b"]
        )


class MultiplyTool(Tool):
    name = "multiply"

    async def execute(
        self,
        arguments,
    ):
        return (
            arguments["a"]
            * arguments["b"]
        )


def test_workflow_engine() -> None:
    async def run() -> None:
        registry = ToolRegistry()

        registry.register(
            AddTool()
        )

        registry.register(
            MultiplyTool()
        )

        tool_service = ToolService(
            registry
        )

        engine = WorkflowEngine(
            tool_service
        )

        workflow = Workflow(
            workflow_id="math-workflow",
            steps=[
                WorkflowStep(
                    step_id="step-1",
                    tool_name="add",
                    arguments={
                        "a": 2,
                        "b": 3,
                    },
                ),
                WorkflowStep(
                    step_id="step-2",
                    tool_name="multiply",
                    arguments={
                        "a": 4,
                        "b": 5,
                    },
                ),
            ],
        )

        result = await engine.execute(
            workflow
        )

        assert result.success is True
        assert len(result.results) == 2
        assert result.results[0]["result"] == 5
        assert result.results[1]["result"] == 20

    asyncio.run(run())
