from dataclasses import dataclass, field
from typing import Any
from uuid import uuid4


@dataclass
class MediaRequest:
    operation: str
    source: str
    prompt: str = ""
    options: dict[str, Any] = field(
        default_factory=dict
    )
    request_id: str = field(
        default_factory=lambda: str(uuid4())
    )


@dataclass
class MediaResult:
    success: bool
    operation: str
    output: str = ""
    provider: str = ""
    error: str = ""
    metadata: dict[str, Any] = field(
        default_factory=dict
    )
