from typing import Callable

from app.monitoring.models.monitoring import (
    ComponentHealth,
)


class HealthEngine:
    def __init__(self) -> None:
        self._checks: dict[
            str,
            Callable[[], bool],
        ] = {}

    def register(
        self,
        name: str,
        check: Callable[[], bool],
    ) -> None:
        self._checks[name] = check

    def check_all(
        self,
    ) -> list[ComponentHealth]:
        results: list[ComponentHealth] = []

        for name, check in self._checks.items():
            try:
                healthy = bool(check())

                results.append(
                    ComponentHealth(
                        name=name,
                        healthy=healthy,
                        details=(
                            "healthy"
                            if healthy
                            else "unhealthy"
                        ),
                    )
                )

            except Exception as error:
                results.append(
                    ComponentHealth(
                        name=name,
                        healthy=False,
                        details=str(error),
                    )
                )

        return results
