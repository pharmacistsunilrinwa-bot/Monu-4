from dataclasses import dataclass, field
from typing import Any


@dataclass
class Execution:
    action_id: str
    status: str = "pending"
    result: Any = None
    error: str | None = None
    steps: list[str] = field(
        default_factory=list
    )
