from dataclasses import dataclass, field
from typing import Any


@dataclass
class ExecutionResult:
    success: bool
    output: Any = None
    message: str = ""
    metadata: dict[str, Any] = field(default_factory=dict)
