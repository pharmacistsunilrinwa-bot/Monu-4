from dataclasses import dataclass, field
from typing import Any


@dataclass
class ResearchResult:
    query: str
    findings: list[dict[str, Any]] = field(
        default_factory=list
    )
    confidence: float = 0.0
    verified: bool = False
