from typing import Any

from app.providers.registry.provider_registry import ProviderRegistry
from app.schemas.provider import ProviderStatus


class ProviderHealthManager:
    def __init__(
        self,
        registry: ProviderRegistry,
    ) -> None:
        self.registry = registry

    async def check_provider(
        self,
        name: str,
    ) -> dict[str, Any]:
        provider = self.registry.get(name)

        if provider is None:
            return {
                "provider": name,
                "healthy": False,
                "reason": "provider_not_registered",
            }

        try:
            result = await provider.health_check()
            healthy = bool(result.get("healthy", True))

            self.registry.set_status(
                name,
                (
                    ProviderStatus.AVAILABLE
                    if healthy
                    else ProviderStatus.DEGRADED
                ),
            )

            return {
                "provider": name,
                "healthy": healthy,
                "details": result,
            }

        except Exception as error:
            self.registry.set_status(
                name,
                ProviderStatus.UNAVAILABLE,
            )

            return {
                "provider": name,
                "healthy": False,
                "reason": str(error),
            }

    async def check_all(self) -> list[dict[str, Any]]:
        results: list[dict[str, Any]] = []

        for record in self.registry.list():
            result = await self.check_provider(
                record.name
            )
            results.append(result)

        return results
