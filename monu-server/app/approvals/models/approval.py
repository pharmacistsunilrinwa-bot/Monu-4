from dataclasses import dataclass, field


@dataclass
class Approval:
    action_id: int
    required: bool
    status: str = "pending"
    approval_id: int = field(default=0)
