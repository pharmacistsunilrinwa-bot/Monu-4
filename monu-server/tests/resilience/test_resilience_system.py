import pytest

from app.resilience import (
    CircuitBreaker,
    ResilienceService,
    RetryPolicy,
)


def test_retry_success() -> None:
    service = ResilienceService()

    attempts = {"count": 0}

    def operation() -> str:
        attempts["count"] += 1

        if attempts["count"] < 3:
            raise ValueError("Temporary failure")

        return "success"

    result = service.retry(
        operation,
        RetryPolicy(
            max_attempts=3,
        ),
    )

    assert result == "success"
    assert attempts["count"] == 3


def test_circuit_breaker() -> None:
    breaker = CircuitBreaker(
        failure_threshold=2
    )

    def failure() -> None:
        raise ValueError("Failure")

    with pytest.raises(ValueError):
        breaker.execute(failure)

    with pytest.raises(ValueError):
        breaker.execute(failure)

    with pytest.raises(RuntimeError):
        breaker.execute(failure)

    assert breaker.is_open is True
