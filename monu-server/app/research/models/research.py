from dataclasses import dataclass, field
from datetime import datetime, timezone


@dataclass
class ResearchFinding:
    title: str
    summary: str
    source: str = ""
    relevance: float = 0.0
    metadata: dict[str, str] = field(
        default_factory=dict
    )
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )


@dataclass
class ResearchReport:
    query: str
    findings: list[ResearchFinding] = field(
        default_factory=list
    )
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )
