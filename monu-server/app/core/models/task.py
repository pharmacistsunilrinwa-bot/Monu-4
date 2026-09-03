from dataclasses import dataclass, field
from typing import Any
from uuid import uuid4

from app.schemas.task_states import TaskState
from app.schemas.task_types import TaskType


@dataclass
class TaskRequest:
    content: str
    task_type: TaskType
    task_id: str = field(default_factory=lambda: str(uuid4()))
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass
class TaskContext:
    task_id: str
    content: str
    task_type: TaskType
    state: TaskState = TaskState.RECEIVED
    intent: str | None = None
    plan: list[str] = field(default_factory=list)
    route: str | None = None
    result: Any = None
    error: str | None = None
    metadata: dict[str, Any] = field(default_factory=dict)
