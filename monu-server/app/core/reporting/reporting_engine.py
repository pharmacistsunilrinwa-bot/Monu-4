from typing import Any


class ReportingEngine:
    """
    Converts task execution into an owner-readable report.
    """

    def create_report(
        self,
        task_id: str,
        content: str,
        state: str,
        result: Any,
        error: str | None = None,
    ) -> dict[str, Any]:
        return {
            "task_id": task_id,
            "task": content,
            "status": state,
            "result": (
                result.output
                if result is not None
                else None
            ),
            "message": (
                result.message
                if result is not None
                else None
            ),
            "error": error,
            "owner_action_required": (
                state == "WAITING_APPROVAL"
            ),
        }
