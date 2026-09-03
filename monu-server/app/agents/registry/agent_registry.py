import builtins

from app.contracts.agent import Agent


class AgentRegistry:
    def __init__(self) -> None:
        self._agents: dict[str, Agent] = {}
        self._capabilities: dict[
            str,
            builtins.list[str],
        ] = {}

    async def register(
        self,
        agent: Agent,
    ) -> None:
        name = agent.name.strip().lower()

        if not name:
            raise ValueError(
                "Agent name cannot be empty"
            )

        capabilities = await agent.capabilities()

        self._agents[name] = agent
        self._capabilities[name] = [
            capability.strip().lower()
            for capability in capabilities
        ]

    def unregister(
        self,
        name: str,
    ) -> None:
        normalized = name.strip().lower()

        self._agents.pop(
            normalized,
            None,
        )

        self._capabilities.pop(
            normalized,
            None,
        )

    def get(
        self,
        name: str,
    ) -> Agent | None:
        return self._agents.get(
            name.strip().lower()
        )

    def list(self) -> builtins.list[Agent]:
        return builtins.list(
            self._agents.values()
        )

    def find_by_capability(
        self,
        capability: str,
    ) -> builtins.list[Agent]:
        normalized = capability.strip().lower()

        matches: builtins.list[Agent] = []

        for name, capabilities in (
            self._capabilities.items()
        ):
            if normalized in capabilities:
                agent = self._agents.get(name)

                if agent is not None:
                    matches.append(agent)

        return matches
