import asyncio

from app.agents import AgentRegistry
from app.ai import (
    AIProviderRegistry,
    AIService,
    MockAIProvider,
)
from app.employees import (
    EmployeeFactory,
    EmployeeProfile,
    EmployeeService,
)


def test_employee_system() -> None:
    async def run() -> None:
        providers = AIProviderRegistry()

        providers.register(
            MockAIProvider()
        )

        ai_service = AIService(
            providers
        )

        registry = AgentRegistry()

        factory = EmployeeFactory(
            ai_service
        )

        employees = EmployeeService(
            factory=factory,
            registry=registry,
        )

        profile = EmployeeProfile(
            name="income_researcher",
            role="business researcher",
            capabilities=[
                "research",
                "business",
            ],
            system_prompt=(
                "You are MONU's business "
                "research employee."
            ),
        )

        await employees.hire(
            profile
        )

        response = await employees.assign(
            task=(
                "Find possible online business "
                "opportunities"
            ),
            capability="business",
        )

        assert response.success is True
        assert response.agent_name == (
            "income_researcher"
        )

        assert "MONU AI Response" in (
            response.result["content"]
        )

    asyncio.run(run())
