from dataclasses import dataclass


@dataclass
class SystemStatus:
    healthy: bool
    total_components: int
    active_components: int
    readiness: str
