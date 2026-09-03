from typing import Any

from app.tools.executors import ToolExecutor
from app.tools.models import (
    ToolRequest,
    ToolResponse,
)
from app.tools.registry import ToolRegistry


class ToolService:
    def __init__(
        self,
        registry: ToolRegistry,
    ) -> None:
        self.registry = registry
        self.executor = ToolExecutor()

    async def execute(
        self,
        tool_name: str,
        arguments: dict[str, Any] | None = None,
    ) -> ToolResponse:
        tool = self.registry.get(tool_name)

        if tool is None:
            return ToolResponse(
                success=False,
                tool_name=tool_name,
                error=(
                    f"Tool not found: {tool_name}"
                ),
            )

        request = ToolRequest(
            tool_name=tool_name,
            arguments=arguments or {},
        )

        return await self.executor.execute(
            tool,
            request,
        )
