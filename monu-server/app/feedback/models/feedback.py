from dataclasses import dataclass


@dataclass
class Feedback:
    execution_id: str
    success: bool
    score: float
    notes: str = ""
