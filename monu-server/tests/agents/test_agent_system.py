import asyncio

from app.agents import (
    AgentRegistry,
    AgentService,
)
from app.contracts.agent import Agent


class DemoResearchAgent(Agent):
    name = "research_agent"

    async def capabilities(self) -> list[str]:
        return [
            "research",
            "analysis",
        ]

    async def execute(
        self,
        task: str,
        context=None,
    ):
        return {
            "task": task,
            "status": "completed",
            "context": context or {},
        }


def test_agent_system() -> None:
    async def run() -> None:
        registry = AgentRegistry()
        agent = DemoResearchAgent()

        await registry.register(agent)

        service = AgentService(registry)

        response = await service.execute(
            task="Research secure AI architecture",
            capability="research",
        )

        assert response.success is True
        assert response.agent_name == (
            "research_agent"
        )

        assert response.result["status"] == (
            "completed"
        )

    asyncio.run(run())
