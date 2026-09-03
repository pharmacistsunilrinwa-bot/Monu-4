from dataclasses import dataclass, field
from typing import Any


@dataclass
class WorkflowStep:
    step_id: str
    tool_name: str
    arguments: dict[str, Any] = field(
        default_factory=dict
    )


@dataclass
class Workflow:
    workflow_id: str
    steps: list[WorkflowStep] = field(
        default_factory=list
    )


@dataclass
class WorkflowResult:
    workflow_id: str
    success: bool
    results: list[Any] = field(
        default_factory=list
    )
    error: str | None = None
