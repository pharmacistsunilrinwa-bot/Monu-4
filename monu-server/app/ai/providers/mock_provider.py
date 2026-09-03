from app.ai.models import (
    AIRequest,
    AIResponse,
)
from app.ai.providers.base import AIProvider


class MockAIProvider(AIProvider):
    name = "mock"

    async def generate(
        self,
        request: AIRequest,
    ) -> AIResponse:
        content = (
            "MONU AI Response: "
            f"{request.prompt}"
        )

        return AIResponse(
            content=content,
            provider=self.name,
            model="mock-model",
            success=True,
            metadata={
                "temperature": request.temperature,
            },
        )
