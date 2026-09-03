from abc import ABC, abstractmethod

from app.media.models.media import (
    MediaRequest,
    MediaResult,
)


class MediaProvider(ABC):
    name: str

    @abstractmethod
    async def process(
        self,
        request: MediaRequest,
    ) -> MediaResult:
        raise NotImplementedError
