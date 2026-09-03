from abc import ABC, abstractmethod

from app.ai.models import (
    AIRequest,
    AIResponse,
)


class AIProvider(ABC):
    name: str

    @abstractmethod
    async def generate(
        self,
        request: AIRequest,
    ) -> AIResponse:
        raise NotImplementedError
