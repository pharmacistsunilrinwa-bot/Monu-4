import asyncio

from app.contracts.provider import Provider
from app.providers.registry import ProviderRegistry


class DemoProvider(Provider):
    name = "demo"

    async def health_check(self):
        return {
            "healthy": True,
        }

    async def capabilities(self):
        return [
            "reasoning",
            "text",
        ]

    async def execute(self, request):
        return {
            "success": True,
            "request": request,
        }


def test_provider_registry() -> None:
    async def run() -> None:
        registry = ProviderRegistry()
        provider = DemoProvider()

        capabilities = await provider.capabilities()

        registry.register(
            provider,
            capabilities,
        )

        assert registry.get("demo") is provider
        assert len(registry.list()) == 1
        assert len(
            registry.find_by_capability("reasoning")
        ) == 1

    asyncio.run(run())
