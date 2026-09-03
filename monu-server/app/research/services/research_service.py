from app.research.engines.discovery_engine import (
    DiscoveryEngine,
)
from app.research.models.research import (
    ResearchFinding,
    ResearchReport,
)
from app.research.stores.research_store import (
    ResearchStore,
)


class ResearchService:
    def __init__(self) -> None:
        self.store = ResearchStore()
        self.discovery = DiscoveryEngine()

    def research(
        self,
        query: str,
        findings: list[ResearchFinding],
    ) -> ResearchReport:
        report = self.discovery.create_report(
            query=query,
            findings=findings,
        )

        return self.store.add(report)

    def latest(
        self,
    ) -> ResearchReport | None:
        return self.store.latest()

    def top_findings(
        self,
        limit: int = 5,
    ) -> list[ResearchFinding]:
        report = self.latest()

        if report is None:
            return []

        return self.discovery.top_findings(
            report,
            limit,
        )
