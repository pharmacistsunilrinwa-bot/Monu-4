from dataclasses import dataclass, field


@dataclass
class Goal:
    title: str
    target: float
    current: float = 0.0
    unit: str = "value"
    priority: int = 5
    status: str = "active"
    goal_id: int = field(default=0)
