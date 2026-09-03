import time
from collections.abc import Callable
from typing import TypeVar

from app.resilience.models.policy import RetryPolicy


T = TypeVar("T")


class RetryEngine:
    def execute(
        self,
        operation: Callable[[], T],
        policy: RetryPolicy,
    ) -> T:
        last_error: Exception | None = None

        for attempt in range(
            policy.max_attempts
        ):
            try:
                return operation()

            except Exception as error:
                last_error = error

                if (
                    attempt
                    < policy.max_attempts - 1
                    and policy.delay_seconds > 0
                ):
                    time.sleep(
                        policy.delay_seconds
                    )

        assert last_error is not None

        raise last_error
