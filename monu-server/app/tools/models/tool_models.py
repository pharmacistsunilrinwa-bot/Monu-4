from dataclasses import dataclass, field
from typing import Any


@dataclass
class ToolRequest:
    tool_name: str
    arguments: dict[str, Any] = field(
        default_factory=dict
    )


@dataclass
class ToolResponse:
    success: bool
    tool_name: str
    result: Any = None
    error: str | None = None
