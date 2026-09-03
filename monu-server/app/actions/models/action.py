from dataclasses import dataclass, field


@dataclass
class Action:
    title: str
    description: str
    priority: int
    source: str = "decision"
    status: str = "planned"
    action_id: int = field(default=0)
