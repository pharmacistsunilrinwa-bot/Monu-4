from dataclasses import dataclass
from enum import StrEnum


class CredentialStatus(StrEnum):
    AVAILABLE = "available"
    HEALTHY = "healthy"
    RATE_LIMITED = "rate_limited"
    QUOTA_EXHAUSTED = "quota_exhausted"
    TEMPORARILY_FAILED = "temporarily_failed"
    EXPIRED = "expired"
    INVALID = "invalid"
    DISABLED = "disabled"


@dataclass
class CredentialRecord:
    provider: str
    credential_id: str
    environment_variable: str
    status: CredentialStatus = CredentialStatus.AVAILABLE
    failure_count: int = 0
    last_used_at: str | None = None
    last_success_at: str | None = None
