from fastapi import APIRouter, Request

from app.api.models import (
    MemoryCreateRequest,
    MemoryRecallRequest,
)

router = APIRouter(
    prefix="/memory",
    tags=["memory"],
)


@router.post("")
async def remember(
    payload: MemoryCreateRequest,
    request: Request,
) -> dict:
    container = request.app.state.container

    item = container.memory_service.remember(
        content=payload.content,
        importance=payload.importance,
        metadata=payload.metadata,
    )

    return {
        "memory_id": item.memory_id,
        "content": item.content,
        "importance": item.importance,
    }


@router.post("/recall")
async def recall(
    payload: MemoryRecallRequest,
    request: Request,
) -> dict:
    container = request.app.state.container

    results = container.memory_service.recall(
        query=payload.query,
        limit=payload.limit,
    )

    return {
        "count": len(results),
        "memories": [
            {
                "memory_id": item.memory_id,
                "content": item.content,
                "importance": item.importance,
            }
            for item in results
        ],
    }


@router.delete("/{memory_id}")
async def forget(
    memory_id: str,
    request: Request,
) -> dict:
    container = request.app.state.container

    container.memory_service.forget(memory_id)

    return {
        "deleted": memory_id,
    }
