from dataclasses import dataclass


@dataclass
class StrategyRecommendation:
    title: str
    reason: str
    priority: int
    expected_impact: str
