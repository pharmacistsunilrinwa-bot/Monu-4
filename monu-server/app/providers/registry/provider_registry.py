import builtins

from app.contracts.provider import Provider
from app.schemas.provider import ProviderRecord, ProviderStatus


class ProviderRegistry:
    def __init__(self) -> None:
        self._providers: dict[str, Provider] = {}
        self._records: dict[str, ProviderRecord] = {}

    def register(
        self,
        provider: Provider,
        capabilities: builtins.list[str],
    ) -> None:
        name = provider.name.strip().lower()

        if not name:
            raise ValueError("Provider name cannot be empty")

        self._providers[name] = provider
        self._records[name] = ProviderRecord(
            name=name,
            capabilities=builtins.list(capabilities),
            status=ProviderStatus.AVAILABLE,
        )

    def unregister(self, name: str) -> None:
        normalized = name.strip().lower()
        self._providers.pop(normalized, None)
        self._records.pop(normalized, None)

    def get(self, name: str) -> Provider | None:
        return self._providers.get(name.strip().lower())

    def list(self) -> builtins.list[ProviderRecord]:
        return builtins.list(self._records.values())

    def find_by_capability(
        self,
        capability: str,
    ) -> builtins.list[Provider]:
        normalized = capability.strip().lower()

        providers: builtins.list[Provider] = []

        for name, record in self._records.items():
            capabilities = [
                item.strip().lower()
                for item in record.capabilities
            ]

            if normalized in capabilities:
                provider = self._providers.get(name)

                if provider is not None:
                    providers.append(provider)

        return providers

    def set_status(
        self,
        name: str,
        status: ProviderStatus,
    ) -> None:
        normalized = name.strip().lower()
        record = self._records.get(normalized)

        if record is None:
            raise KeyError(
                f"Provider not registered: {name}"
            )

        record.status = status
