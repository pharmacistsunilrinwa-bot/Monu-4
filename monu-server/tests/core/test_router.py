from app.core.engines.router import CapabilityRouter
from app.schemas.task_types import TaskType


def test_research_route() -> None:
    router = CapabilityRouter()
    assert router.route(TaskType.RESEARCH) == "research"


def test_coding_route() -> None:
    router = CapabilityRouter()
    assert router.route(TaskType.CODING) == "coding"
