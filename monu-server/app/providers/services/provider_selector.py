from app.contracts.provider import Provider
from app.providers.registry.provider_registry import ProviderRegistry


class ProviderSelector:
    def __init__(
        self,
        registry: ProviderRegistry,
    ) -> None:
        self.registry = registry

    def select(
        self,
        capability: str,
    ) -> Provider | None:
        candidates = self.registry.find_by_capability(
            capability
        )

        if not candidates:
            return None

        return candidates[0]
