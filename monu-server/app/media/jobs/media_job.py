from dataclasses import dataclass, field
from typing import Any
from uuid import uuid4


@dataclass
class MediaJob:
    operation: str
    source: str
    prompt: str = ""

    job_id: str = field(
        default_factory=lambda: str(uuid4())
    )

    status: str = "pending"

    result: Any = None

    error: str = ""

    progress: int = 0
