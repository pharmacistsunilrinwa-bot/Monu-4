from typing import Any

from app.agents import (
    AgentRegistry,
    AgentService,
)
from app.employees.models import (
    EmployeeProfile,
)
from app.employees.services.employee_factory import (
    EmployeeFactory,
)


class EmployeeService:
    def __init__(
        self,
        factory: EmployeeFactory,
        registry: AgentRegistry,
    ) -> None:
        self.factory = factory
        self.registry = registry
        self.agent_service = AgentService(
            registry
        )

    async def hire(
        self,
        profile: EmployeeProfile,
    ) -> None:
        employee = self.factory.create(
            profile
        )

        await self.registry.register(
            employee
        )

    async def assign(
        self,
        task: str,
        capability: str,
        context: dict[str, Any] | None = None,
    ):
        return await self.agent_service.execute(
            task=task,
            capability=capability,
            context=context,
        )
