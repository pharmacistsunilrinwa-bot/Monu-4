from dataclasses import dataclass, field
from uuid import uuid4


@dataclass
class Lead:
    name: str
    contact: str
    source: str
    interest: str

    lead_id: str = field(
        default_factory=lambda: str(uuid4())
    )

    status: str = "new"
    score: float = 0.0
    notes: list[str] = field(
        default_factory=list
    )
