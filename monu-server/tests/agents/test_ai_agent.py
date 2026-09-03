import asyncio

from app.agents import AIAgent
from app.ai import (
    AIProviderRegistry,
    AIService,
    MockAIProvider,
)


def test_ai_agent() -> None:
    async def run() -> None:
        providers = AIProviderRegistry()

        providers.register(
            MockAIProvider()
        )

        ai_service = AIService(
            providers
        )

        agent = AIAgent(
            ai_service=ai_service,
            agent_name="research_employee",
            capabilities=[
                "research",
                "analysis",
            ],
        )

        result = await agent.execute(
            task="Analyze AI business opportunities",
            context={
                "goal": "income generation",
            },
        )

        assert result["agent"] == (
            "research_employee"
        )

        assert result["provider"] == "mock"

        assert "MONU AI Response" in (
            result["content"]
        )

    asyncio.run(run())
