from typing import Any

from app.ai import AIService
from app.contracts.agent import Agent


class AIAgent(Agent):
    name = "ai_agent"

    def __init__(
        self,
        ai_service: AIService,
        agent_name: str = "ai_agent",
        capabilities: list[str] | None = None,
        system_prompt: str | None = None,
    ) -> None:
        self.ai_service = ai_service
        self.name = agent_name
        self._capabilities = capabilities or [
            "general",
        ]
        self.system_prompt = system_prompt or (
            "You are MONU, an intelligent "
            "AI employee assistant."
        )

    async def capabilities(self) -> list[str]:
        return list(
            self._capabilities
        )

    async def execute(
        self,
        task: str,
        context: dict[str, Any] | None = None,
    ) -> Any:
        context = context or {}

        context_text = ""

        if context:
            context_text = (
                "\n\nContext:\n"
                f"{context}"
            )

        response = await self.ai_service.generate(
            prompt=(
                f"{task}"
                f"{context_text}"
            ),
            system_prompt=self.system_prompt,
        )

        if not response.success:
            raise RuntimeError(
                response.error
                or "AI generation failed"
            )

        return {
            "content": response.content,
            "provider": response.provider,
            "model": response.model,
            "agent": self.name,
        }
