from app.execution import ExecutionService


def test_execution_system() -> None:
    executions = ExecutionService()

    execution = executions.create(
        action_id="action-001",
    )

    assert execution.status == "pending"

    executions.start(execution)

    assert execution.status == "running"

    executions.complete(
        execution,
        result={
            "message": "Action completed",
        },
    )

    assert execution.status == "completed"

    assert execution.result is not None
    assert len(execution.steps) == 2
