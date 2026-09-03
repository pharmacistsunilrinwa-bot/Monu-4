from collections.abc import Callable
from typing import TypeVar


T = TypeVar("T")


class CircuitBreaker:
    def __init__(
        self,
        failure_threshold: int = 3,
    ) -> None:
        self.failure_threshold = failure_threshold
        self.failure_count = 0
        self.is_open = False

    def execute(
        self,
        operation: Callable[[], T],
    ) -> T:
        if self.is_open:
            raise RuntimeError(
                "Circuit breaker is open"
            )

        try:
            result = operation()

            self.failure_count = 0

            return result

        except Exception:
            self.failure_count += 1

            if (
                self.failure_count
                >= self.failure_threshold
            ):
                self.is_open = True

            raise

    def reset(self) -> None:
        self.failure_count = 0
        self.is_open = False
