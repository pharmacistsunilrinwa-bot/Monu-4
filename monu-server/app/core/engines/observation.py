from typing import Any

from app.core.models.result import ExecutionResult


class ObservationEngine:
    """
    MONU observes the actual result of execution
    instead of blindly assuming success.
    """

    def observe(
        self,
        result: ExecutionResult,
    ) -> dict[str, Any]:
        return {
            "success": result.success,
            "message": result.message,
            "has_output": result.output is not None,
            "output_type": (
                type(result.output).__name__
                if result.output is not None
                else None
            ),
        }
