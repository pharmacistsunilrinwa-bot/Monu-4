from app.knowledge.engines.confidence import (
    ConfidenceEngine,
)
from app.knowledge.engines.source_router import (
    SourceRouter,
)
from app.knowledge.models.research import (
    ResearchResult,
)


class ResearchManager:
    def __init__(
        self,
        source_router: SourceRouter,
        confidence_engine: ConfidenceEngine,
    ) -> None:
        self.source_router = source_router
        self.confidence_engine = confidence_engine

    def prepare_research(
        self,
        query: str,
        source_type: str | None = None,
    ) -> ResearchResult:
        sources = self.source_router.select_sources(
            source_type
        )

        reliabilities = [
            source.reliability
            for source in sources
        ]

        confidence = (
            self.confidence_engine.calculate(
                reliabilities
            )
        )

        findings = [
            {
                "source_id": source.source_id,
                "source_name": source.name,
                "source_type": source.source_type.value,
                "reliability": source.reliability,
            }
            for source in sources
        ]

        return ResearchResult(
            query=query,
            findings=findings,
            confidence=confidence,
            verified=False,
        )
