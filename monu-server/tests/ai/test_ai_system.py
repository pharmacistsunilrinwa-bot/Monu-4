import asyncio

from app.ai import (
    AIProviderRegistry,
    AIService,
    MockAIProvider,
)


def test_ai_system() -> None:
    async def run() -> None:
        registry = AIProviderRegistry()

        registry.register(
            MockAIProvider()
        )

        service = AIService(
            registry
        )

        response = await service.generate(
            prompt="Explain MONU architecture"
        )

        assert response.success is True
        assert response.provider == "mock"
        assert "MONU AI Response" in (
            response.content
        )

    asyncio.run(run())
