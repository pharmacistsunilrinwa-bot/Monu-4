from app.agents import AIAgent
from app.ai import AIService
from app.employees.models import (
    EmployeeProfile,
)


class EmployeeFactory:
    def __init__(
        self,
        ai_service: AIService,
    ) -> None:
        self.ai_service = ai_service

    def create(
        self,
        profile: EmployeeProfile,
    ) -> AIAgent:
        return AIAgent(
            ai_service=self.ai_service,
            agent_name=profile.name,
            capabilities=profile.capabilities,
            system_prompt=profile.system_prompt,
        )
