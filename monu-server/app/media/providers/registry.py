from app.media.providers.base import MediaProvider


class MediaProviderRegistry:
    def __init__(self) -> None:
        self._providers: dict[
            str,
            MediaProvider,
        ] = {}

    def register(
        self,
        provider: MediaProvider,
    ) -> None:
        self._providers[
            provider.name
        ] = provider

    def get(
        self,
        name: str,
    ) -> MediaProvider | None:
        return self._providers.get(name)

    def list_all(
        self,
    ) -> list[str]:
        return list(
            self._providers.keys()
        )
