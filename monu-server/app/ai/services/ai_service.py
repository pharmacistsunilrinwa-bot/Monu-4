from app.ai.models import (
    AIRequest,
    AIResponse,
)
from app.ai.providers import (
    AIProviderRegistry,
)


class AIService:
    def __init__(
        self,
        registry: AIProviderRegistry,
        default_provider: str = "mock",
    ) -> None:
        self.registry = registry
        self.default_provider = default_provider

    async def generate(
        self,
        prompt: str,
        provider_name: str | None = None,
        system_prompt: str | None = None,
        temperature: float = 0.7,
        max_tokens: int | None = None,
    ) -> AIResponse:
        selected_provider = (
            provider_name
            or self.default_provider
        )

        provider = self.registry.get(
            selected_provider
        )

        if provider is None:
            return AIResponse(
                content="",
                provider=selected_provider,
                model="unknown",
                success=False,
                error=(
                    "AI provider not found: "
                    f"{selected_provider}"
                ),
            )

        request = AIRequest(
            prompt=prompt,
            system_prompt=system_prompt,
            temperature=temperature,
            max_tokens=max_tokens,
        )

        try:
            return await provider.generate(
                request
            )

        except Exception as error:
            return AIResponse(
                content="",
                provider=selected_provider,
                model="unknown",
                success=False,
                error=str(error),
            )
