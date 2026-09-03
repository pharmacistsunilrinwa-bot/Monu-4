from dataclasses import dataclass, field
from uuid import uuid4


@dataclass
class Client:
    name: str
    contact: str
    client_id: str = field(
        default_factory=lambda: str(uuid4())
    )
    status: str = "active"
    projects: list[str] = field(
        default_factory=list
    )
    total_value: float = 0.0
