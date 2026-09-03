from dataclasses import dataclass, field


@dataclass
class EmployeeProfile:
    name: str
    role: str
    capabilities: list[str] = field(
        default_factory=list
    )
    system_prompt: str = ""
