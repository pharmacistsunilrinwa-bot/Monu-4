from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any


@dataclass
class IncomeOpportunity:
    title: str
    description: str
    category: str
    estimated_value: float = 0.0
    confidence: float = 0.0
    priority: int = 0
    data: dict[str, Any] = field(
        default_factory=dict
    )
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )
