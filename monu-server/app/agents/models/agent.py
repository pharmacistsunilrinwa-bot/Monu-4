from dataclasses import dataclass, field
from typing import Any


@dataclass
class AgentRequest:
    task: str
    capability: str
    context: dict[str, Any] = field(
        default_factory=dict
    )


@dataclass
class AgentResponse:
    success: bool
    agent_name: str
    result: Any = None
    error: str | None = None
