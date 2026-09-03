from typing import Any

from app.media.models.media import (
    MediaRequest,
    MediaResult,
)
from app.media.providers.registry import (
    MediaProviderRegistry,
)


class MediaService:
    def __init__(
        self,
        registry: MediaProviderRegistry,
        default_provider: str = "mock-media",
    ) -> None:
        self.registry = registry
        self.default_provider = default_provider

    async def process(
        self,
        operation: str,
        source: str,
        prompt: str = "",
        options: dict[str, Any] | None = None,
        provider: str | None = None,
    ) -> MediaResult:
        provider_name = (
            provider or self.default_provider
        )

        media_provider = self.registry.get(
            provider_name
        )

        if media_provider is None:
            return MediaResult(
                success=False,
                operation=operation,
                error=(
                    f"Media provider not found: "
                    f"{provider_name}"
                ),
            )

        request = MediaRequest(
            operation=operation,
            source=source,
            prompt=prompt,
            options=options or {},
        )

        return await media_provider.process(
            request
        )

    async def photo_to_video(
        self,
        source: str,
        prompt: str = "",
    ) -> MediaResult:
        return await self.process(
            operation="photo_to_video",
            source=source,
            prompt=prompt,
        )

    async def video_to_photo(
        self,
        source: str,
    ) -> MediaResult:
        return await self.process(
            operation="video_to_photo",
            source=source,
        )

    async def photo_to_cartoon(
        self,
        source: str,
        prompt: str = "",
    ) -> MediaResult:
        return await self.process(
            operation="photo_to_cartoon",
            source=source,
            prompt=prompt,
        )

    async def video_to_cartoon(
        self,
        source: str,
        prompt: str = "",
    ) -> MediaResult:
        return await self.process(
            operation="video_to_cartoon",
            source=source,
            prompt=prompt,
        )

    async def generate_video(
        self,
        prompt: str,
    ) -> MediaResult:
        return await self.process(
            operation="text_to_video",
            source="",
            prompt=prompt,
        )
