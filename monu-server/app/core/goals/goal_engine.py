from uuid import uuid4
from typing import Any


class GoalEngine:
    """
    Converts large owner goals into manageable objectives.
    """

    def create_goal(
        self,
        content: str,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        return {
            "goal_id": str(uuid4()),
            "content": content,
            "metadata": metadata or {},
            "status": "CREATED",
            "objectives": [],
        }

    def decompose(
        self,
        goal: dict[str, Any],
    ) -> list[dict[str, Any]]:
        content = goal["content"]

        objectives = [
            {
                "name": "understand_requirements",
                "status": "PENDING",
            },
            {
                "name": "create_plan",
                "status": "PENDING",
            },
            {
                "name": "execute_work",
                "status": "PENDING",
            },
            {
                "name": "verify_result",
                "status": "PENDING",
            },
        ]

        goal["objectives"] = objectives
        goal["status"] = "PLANNED"

        return objectives
