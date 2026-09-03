from typing import Any

from app.agents.executors.agent_executor import (
    AgentExecutor,
)
from app.agents.models.agent import (
    AgentRequest,
    AgentResponse,
)
from app.agents.registry.agent_registry import (
    AgentRegistry,
)
from app.agents.services.agent_selector import (
    AgentSelector,
)


class AgentService:
    def __init__(
        self,
        registry: AgentRegistry,
    ) -> None:
        self.registry = registry
        self.selector = AgentSelector(
            registry
        )
        self.executor = AgentExecutor()

    async def execute(
        self,
        task: str,
        capability: str,
        context: dict[str, Any] | None = None,
    ) -> AgentResponse:
        agent = self.selector.select(
            capability
        )

        if agent is None:
            return AgentResponse(
                success=False,
                agent_name="none",
                error=(
                    "No agent found for capability: "
                    f"{capability}"
                ),
            )

        request = AgentRequest(
            task=task,
            capability=capability,
            context=context or {},
        )

        return await self.executor.execute(
            agent,
            request,
        )
