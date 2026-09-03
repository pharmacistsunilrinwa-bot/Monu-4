from fastapi import APIRouter, Request

from app.api.models import ResearchRequest

router = APIRouter(
    prefix="/research",
    tags=["research"],
)


@router.post("")
async def research(
    payload: ResearchRequest,
    request: Request,
) -> dict:
    container = request.app.state.container

    result = container.research_manager.prepare_research(
        query=payload.query,
        source_type=payload.source_type,
    )

    return {
        "query": result.query,
        "findings": result.findings,
        "confidence": result.confidence,
        "verified": result.verified,
    }
