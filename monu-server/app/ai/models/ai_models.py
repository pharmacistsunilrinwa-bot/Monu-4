from dataclasses import dataclass, field
from typing import Any


@dataclass
class AIRequest:
    prompt: str
    system_prompt: str | None = None
    temperature: float = 0.7
    max_tokens: int | None = None
    metadata: dict[str, Any] = field(
        default_factory=dict
    )


@dataclass
class AIResponse:
    content: str
    provider: str
    model: str
    success: bool = True
    error: str | None = None
    metadata: dict[str, Any] = field(
        default_factory=dict
    )
