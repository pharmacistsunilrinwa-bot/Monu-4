from app.ai.providers.base import AIProvider


class AIProviderRegistry:
    def __init__(self) -> None:
        self._providers: dict[
            str,
            AIProvider,
        ] = {}

    def register(
        self,
        provider: AIProvider,
    ) -> None:
        name = provider.name.strip().lower()

        if not name:
            raise ValueError(
                "Provider name cannot be empty"
            )

        self._providers[name] = provider

    def unregister(
        self,
        name: str,
    ) -> None:
        self._providers.pop(
            name.strip().lower(),
            None,
        )

    def get(
        self,
        name: str,
    ) -> AIProvider | None:
        return self._providers.get(
            name.strip().lower()
        )

    def list(
        self,
    ) -> list[AIProvider]:
        return list(
            self._providers.values()
        )
