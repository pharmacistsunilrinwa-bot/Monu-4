from dataclasses import dataclass


@dataclass
class LearningInsight:
    total_feedback: int
    average_score: float
    success_rate: float
    recommendation: str
