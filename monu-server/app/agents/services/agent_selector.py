from app.agents.registry.agent_registry import (
    AgentRegistry,
)
from app.contracts.agent import Agent


class AgentSelector:
    def __init__(
        self,
        registry: AgentRegistry,
    ) -> None:
        self.registry = registry

    def select(
        self,
        capability: str,
    ) -> Agent | None:
        candidates = (
            self.registry.find_by_capability(
                capability
            )
        )

        if not candidates:
            return None

        return candidates[0]
