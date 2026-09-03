from app.research.models.research import (
    ResearchFinding,
    ResearchReport,
)


class DiscoveryEngine:
    def create_report(
        self,
        query: str,
        findings: list[ResearchFinding],
    ) -> ResearchReport:
        ranked = sorted(
            findings,
            key=lambda item: item.relevance,
            reverse=True,
        )

        return ResearchReport(
            query=query,
            findings=ranked,
        )

    def top_findings(
        self,
        report: ResearchReport,
        limit: int = 5,
    ) -> list[ResearchFinding]:
        return report.findings[:limit]
