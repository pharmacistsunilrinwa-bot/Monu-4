from typing import Any

from app.schemas.task_states import TaskState


class RecoveryManager:
    """
    Controlled failure recovery.

    MONU should diagnose and retry a limited number
    of times instead of entering an infinite loop.
    """

    def __init__(
        self,
        max_retries: int = 2,
    ) -> None:
        self.max_retries = max_retries

    def should_recover(
        self,
        state: TaskState,
        retry_count: int = 0,
    ) -> bool:
        return (
            state == TaskState.FAILED
            and retry_count < self.max_retries
        )

    def recovery_state(self) -> TaskState:
        return TaskState.RECOVERING

    def diagnose(
        self,
        error: str | None,
    ) -> dict[str, Any]:
        return {
            "diagnosis_started": True,
            "error": error or "Unknown failure",
            "recommended_action": "retry_or_replan",
        }
