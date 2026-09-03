from typing import Any

from app.core.engines import (
    ActionParser,
    CapabilityRouter,
    ContextEngine,
    Executor,
    IntentEngine,
    Planner,
    Verifier,
)
from app.core.models import TaskContext, TaskRequest
from app.schemas.task_states import TaskState


class MonuOrchestrator:
    """
    Central MONU execution pipeline.

    Understand
        ->
    Build Context
        ->
    Plan
        ->
    Select Capability
        ->
    Execute
        ->
    Verify
    """

    def __init__(self) -> None:
        self.intent_engine = IntentEngine()
        self.context_engine = ContextEngine()
        self.planner = Planner()
        self.router = CapabilityRouter()
        self.executor = Executor()
        self.verifier = Verifier()
        self.action_parser = ActionParser()

    async def process(
        self,
        content: str,
        metadata: dict[str, Any] | None = None,
    ) -> TaskContext:

        metadata = dict(metadata or {})

        parsed_action = self.action_parser.parse(
            content
        )

        if (
            parsed_action.get("action")
            and not metadata.get("action")
        ):
            metadata.update(
                {
                    key: value
                    for key, value
                    in parsed_action.items()
                    if value is not None
                }
            )

        task_type = self.intent_engine.classify(
            content
        )

        task = TaskRequest(
            content=content,
            task_type=task_type,
            metadata=metadata,
        )

        context = TaskContext(
            task_id=task.task_id,
            content=task.content,
            task_type=task.task_type,
            metadata=task.metadata,
        )

        context.state = TaskState.UNDERSTANDING

        built_context = self.context_engine.build(
            content=context.content,
            metadata=context.metadata,
        )

        context.intent = (
            self.intent_engine.detect_intent(
                context.content
            )
        )

        context.metadata[
            "runtime_context"
        ] = built_context

        context.state = TaskState.PLANNING

        context.plan = self.planner.create_plan(
            context.task_type,
            context.content,
        )

        context.state = TaskState.EXECUTING

        context.route = self.router.route(
            context.task_type
        )

        result = await self.executor.execute(
            route=context.route,
            content=context.content,
            plan=context.plan,
            action=context.metadata.get("action"),
            path=context.metadata.get("path"),
        )

        context.result = result

        context.state = TaskState.VERIFYING

        if self.verifier.verify(result):
            context.state = TaskState.COMPLETED
        else:
            context.state = TaskState.FAILED
            context.error = result.message

        return context
