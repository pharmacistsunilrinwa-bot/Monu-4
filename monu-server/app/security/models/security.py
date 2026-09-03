from dataclasses import dataclass, field


@dataclass
class Identity:
    identity_id: str
    role: str = "user"
    permissions: set[str] = field(
        default_factory=set
    )


@dataclass
class AccessResult:
    allowed: bool
    identity_id: str
    permission: str
    reason: str = ""
