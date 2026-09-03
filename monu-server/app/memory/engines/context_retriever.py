from app.memory.engines.memory_ranker import (
    MemoryRanker,
)
from app.memory.models.memory import MemoryItem
from app.memory.stores.memory_store import (
    MemoryStore,
)


class ContextRetriever:
    def __init__(
        self,
        store: MemoryStore,
        ranker: MemoryRanker,
    ) -> None:
        self.store = store
        self.ranker = ranker

    def retrieve(
        self,
        query: str,
        limit: int = 5,
    ) -> list[MemoryItem]:
        scored: list[
            tuple[float, MemoryItem]
        ] = []

        for memory in self.store.list_all():
            score = self.ranker.score(
                query,
                memory,
            )

            scored.append(
                (score, memory)
            )

        scored.sort(
            key=lambda item: item[0],
            reverse=True,
        )

        return [
            memory
            for score, memory in scored[:limit]
            if score > 0
        ]
