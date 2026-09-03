from app.contracts.tool import Tool
from app.tools.models import (
    ToolRequest,
    ToolResponse,
)


class ToolExecutor:
    async def execute(
        self,
        tool: Tool,
        request: ToolRequest,
    ) -> ToolResponse:
        try:
            result = await tool.execute(
                request.arguments
            )

            return ToolResponse(
                success=True,
                tool_name=tool.name,
                result=result,
            )

        except Exception as error:
            return ToolResponse(
                success=False,
                tool_name=tool.name,
                error=str(error),
            )
