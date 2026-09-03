from app.core.engines.planner import Planner
from app.schemas.task_types import TaskType


def test_research_plan() -> None:
    planner = Planner()
    plan = planner.create_plan(
        TaskType.RESEARCH,
        "Research artificial intelligence",
    )

    assert "understand_request" in plan
    assert "collect_sources" in plan
    assert "verify_result" in plan
