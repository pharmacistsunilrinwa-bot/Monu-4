from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import Any
from uuid import uuid4


@dataclass
class MemoryItem:
    content: str
    memory_id: str = field(
        default_factory=lambda: str(uuid4())
    )
    metadata: dict[str, Any] = field(
        default_factory=dict
    )
    importance: float = 0.5
    created_at: datetime = field(
        default_factory=lambda: datetime.now(UTC)
    )
