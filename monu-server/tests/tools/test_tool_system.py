import asyncio

from app.contracts.tool import Tool
from app.tools import (
    ToolRegistry,
    ToolService,
)


class EchoTool(Tool):
    name = "echo"

    async def execute(
        self,
        arguments,
    ):
        return {
            "echo": arguments.get("message"),
        }


def test_tool_system() -> None:
    async def run() -> None:
        registry = ToolRegistry()
        registry.register(
            EchoTool()
        )

        service = ToolService(
            registry
        )

        response = await service.execute(
            "echo",
            {
                "message": "hello MONU",
            },
        )

        assert response.success is True
        assert response.result["echo"] == (
            "hello MONU"
        )

    asyncio.run(run())
