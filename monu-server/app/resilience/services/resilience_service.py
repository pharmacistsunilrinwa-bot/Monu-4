from collections.abc import Callable
from typing import TypeVar

from app.resilience.engines.circuit_breaker import (
    CircuitBreaker,
)
from app.resilience.engines.retry_engine import RetryEngine
from app.resilience.models.policy import RetryPolicy


T = TypeVar("T")


class ResilienceService:
    def __init__(
        self,
        retry_engine: RetryEngine | None = None,
    ) -> None:
        self.retry_engine = (
            retry_engine or RetryEngine()
        )

    def retry(
        self,
        operation: Callable[[], T],
        policy: RetryPolicy | None = None,
    ) -> T:
        return self.retry_engine.execute(
            operation,
            policy or RetryPolicy(),
        )

    def circuit_breaker(
        self,
        failure_threshold: int = 3,
    ) -> CircuitBreaker:
        return CircuitBreaker(
            failure_threshold
        )
