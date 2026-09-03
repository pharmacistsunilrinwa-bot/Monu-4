from dataclasses import dataclass, field
from datetime import datetime, timezone


@dataclass
class Proposal:
    title: str
    opportunity: str
    summary: str
    estimated_value: float = 0.0
    status: str = "draft"
    steps: list[str] = field(
        default_factory=list
    )
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )
