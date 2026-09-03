from app.media.models.media import (
    MediaRequest,
    MediaResult,
)
from app.media.providers.base import MediaProvider


class MockMediaProvider(MediaProvider):
    name = "mock-media"

    async def process(
        self,
        request: MediaRequest,
    ) -> MediaResult:
        return MediaResult(
            success=True,
            operation=request.operation,
            output=(
                f"mock://media/"
                f"{request.operation}/"
                f"{request.request_id}"
            ),
            provider=self.name,
            metadata={
                "source": request.source,
                "prompt": request.prompt,
                "options": request.options,
            },
        )
