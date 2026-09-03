from app.execution.models.execution import (
    Execution,
)


class ExecutionService:
    def create(
        self,
        action_id: str,
    ) -> Execution:
        return Execution(
            action_id=action_id,
        )

    def start(
        self,
        execution: Execution,
    ) -> Execution:
        execution.status = "running"
        execution.steps.append(
            "execution_started"
        )
        return execution

    def complete(
        self,
        execution: Execution,
        result: object = None,
    ) -> Execution:
        execution.status = "completed"
        execution.result = result
        execution.steps.append(
            "execution_completed"
        )
        return execution

    def fail(
        self,
        execution: Execution,
        error: str,
    ) -> Execution:
        execution.status = "failed"
        execution.error = error
        execution.steps.append(
            "execution_failed"
        )
        return execution
