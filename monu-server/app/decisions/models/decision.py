from dataclasses import dataclass


@dataclass
class Decision:
    title: str
    action: str
    reason: str
    priority: int
    confidence: float
    status: str = "recommended"
