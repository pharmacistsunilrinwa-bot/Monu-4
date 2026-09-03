import asyncio

from app.ai import (
    AIProviderRegistry,
    AIService,
)


def test_missing_provider() -> None:
    async def run() -> None:
        registry = AIProviderRegistry()

        service = AIService(
            registry
        )

        response = await service.generate(
            prompt="Hello",
            provider_name="missing-provider",
        )

        assert response.success is False
        assert response.error is not None

    asyncio.run(run())
