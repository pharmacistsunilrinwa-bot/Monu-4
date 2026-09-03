from dataclasses import dataclass
from datetime import datetime, timezone


@dataclass
class TaskReport:
    task_id: str
    status: str
    progress: int
    summary: str
    created_at: datetime = datetime.now(
        timezone.utc
    )
