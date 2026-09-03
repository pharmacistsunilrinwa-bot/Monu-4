from dataclasses import dataclass, field
from uuid import uuid4


@dataclass
class Project:
    title: str
    description: str
    client: str

    project_id: str = field(
        default_factory=lambda: str(uuid4())
    )

    status: str = "created"
    progress: int = 0

    tasks: list[str] = field(
        default_factory=list
    )

    deliverables: list[str] = field(
        default_factory=list
    )
