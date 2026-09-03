from app.research import (
    ResearchFinding,
    ResearchService,
)


def test_research_system() -> None:
    research = ResearchService()

    report = research.research(
        query="AI business opportunities",
        findings=[
            ResearchFinding(
                title="AI Automation",
                summary=(
                    "Businesses need workflow "
                    "automation"
                ),
                source="market",
                relevance=0.9,
            ),
            ResearchFinding(
                title="AI Content",
                summary=(
                    "Creators need AI media "
                    "services"
                ),
                source="market",
                relevance=0.7,
            ),
        ],
    )

    assert report.query == (
        "AI business opportunities"
    )

    assert len(report.findings) == 2

    assert (
        report.findings[0].title
        == "AI Automation"
    )

    top = research.top_findings()

    assert len(top) == 2

    assert research.latest() == report
