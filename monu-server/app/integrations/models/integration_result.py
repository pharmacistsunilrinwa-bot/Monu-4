from dataclasses import dataclass, field


@dataclass
class IntegrationResult:
    status: str
    stages: list[str] = field(
        default_factory=list
    )
    data: dict[str, object] = field(
        default_factory=dict
    )
