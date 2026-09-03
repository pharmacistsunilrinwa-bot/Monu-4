from dataclasses import dataclass, field
from enum import StrEnum


class ProviderStatus(StrEnum):
    AVAILABLE = "available"
    UNAVAILABLE = "unavailable"
    DEGRADED = "degraded"
    DISABLED = "disabled"


@dataclass
class ProviderRecord:
    name: str
    capabilities: list[str] = field(default_factory=list)
    status: ProviderStatus = ProviderStatus.AVAILABLE
