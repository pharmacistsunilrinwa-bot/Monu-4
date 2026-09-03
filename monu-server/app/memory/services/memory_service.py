from typing import Any

from app.memory.engines.context_retriever import (
    ContextRetriever,
)
from app.memory.engines.memory_ranker import (
    MemoryRanker,
)
from app.memory.models.memory import MemoryItem
from app.memory.stores.memory_store import (
    MemoryStore,
)


class MemoryService:
    def __init__(self) -> None:
        self.store = MemoryStore()
        self.ranker = MemoryRanker()
        self.retriever = ContextRetriever(
            store=self.store,
            ranker=self.ranker,
        )

    def remember(
        self,
        content: str,
        importance: float = 0.5,
        metadata: dict[str, Any] | None = None,
    ) -> MemoryItem:
        item = MemoryItem(
            content=content,
            importance=max(
                0.0,
                min(1.0, importance),
            ),
            metadata=metadata or {},
        )

        return self.store.add(item)

    def recall(
        self,
        query: str,
        limit: int = 5,
    ) -> list[MemoryItem]:
        return self.retriever.retrieve(
            query=query,
            limit=limit,
        )

    def forget(
        self,
        memory_id: str,
    ) -> None:
        self.store.remove(memory_id)

    def clear(self) -> None:
        self.store.clear()
