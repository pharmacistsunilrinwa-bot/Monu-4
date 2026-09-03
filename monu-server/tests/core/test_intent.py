from app.core.engines.intent import IntentEngine
from app.schemas.task_types import TaskType


def test_research_detection() -> None:
    engine = IntentEngine()
    result = engine.classify("Research the latest technology")
    assert result == TaskType.RESEARCH


def test_coding_detection() -> None:
    engine = IntentEngine()
    result = engine.classify("Debug this Python code")
    assert result == TaskType.CODING


def test_empty_input() -> None:
    engine = IntentEngine()
    result = engine.classify("")
    assert result == TaskType.CONVERSATION
