from app.agents.models.agent import (
    AgentRequest,
    AgentResponse,
)
from app.contracts.agent import Agent


class AgentExecutor:
    async def execute(
        self,
        agent: Agent,
        request: AgentRequest,
    ) -> AgentResponse:
        try:
            result = await agent.execute(
                task=request.task,
                context=request.context,
            )

            return AgentResponse(
                success=True,
                agent_name=agent.name,
                result=result,
            )

        except Exception as error:
            return AgentResponse(
                success=False,
                agent_name=agent.name,
                error=str(error),
            )
