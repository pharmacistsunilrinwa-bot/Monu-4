from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any


@dataclass
class SystemEvent:
    name: str
    level: str = "info"
    data: dict[str, Any] = field(
        default_factory=dict
    )
    created_at: datetime = field(
        default_factory=lambda: datetime.now(
            timezone.utc
        )
    )


@dataclass
class Metric:
    name: str
    value: float
    tags: dict[str, str] = field(
        default_factory=dict
    )


@dataclass
class ComponentHealth:
    name: str
    healthy: bool
    details: str = ""
