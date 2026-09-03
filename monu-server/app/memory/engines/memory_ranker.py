from app.memory.models.memory import MemoryItem


class MemoryRanker:
    def score(
        self,
        query: str,
        memory: MemoryItem,
    ) -> float:
        query_words = set(
            query.lower().split()
        )

        memory_words = set(
            memory.content.lower().split()
        )

        if not query_words:
            return memory.importance

        overlap = len(
            query_words.intersection(
                memory_words
            )
        )

        relevance = overlap / len(query_words)

        return (
            relevance * 0.7
            + memory.importance * 0.3
        )
