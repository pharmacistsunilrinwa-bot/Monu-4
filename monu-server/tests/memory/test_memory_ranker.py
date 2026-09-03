from app.memory.engines import MemoryRanker
from app.memory.models import MemoryItem


def test_memory_relevance() -> None:
    ranker = MemoryRanker()

    memory = MemoryItem(
        content="MONU uses modular AI architecture",
        importance=0.8,
    )

    score = ranker.score(
        "MONU modular architecture",
        memory,
    )

    assert score > 0.5
