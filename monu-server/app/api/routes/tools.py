from fastapi import APIRouter, Request

from app.api.models import ToolExecuteRequest

router = APIRouter(
    prefix="/tools",
    tags=["tools"],
)


@router.post("/{tool_name}")
async def execute_tool(
    tool_name: str,
    payload: ToolExecuteRequest,
    request: Request,
) -> dict:
    container = request.app.state.container

    response = await container.tool_service.execute(
        tool_name=tool_name,
        arguments=payload.arguments,
    )

    return {
        "success": response.success,
        "tool_name": response.tool_name,
        "result": response.result,
        "error": response.error,
    }
