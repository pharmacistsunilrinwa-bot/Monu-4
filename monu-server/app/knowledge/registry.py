import builtins

from app.schemas.knowledge import KnowledgeSource


class KnowledgeRegistry:
    def __init__(self) -> None:
        self._sources: dict[str, KnowledgeSource] = {}

    def register(
        self,
        source: KnowledgeSource,
    ) -> None:
        source_id = source.source_id.strip()

        if not source_id:
            raise ValueError(
                "Knowledge source_id cannot be empty"
            )

        self._sources[source_id] = source

    def unregister(
        self,
        source_id: str,
    ) -> None:
        self._sources.pop(
            source_id.strip(),
            None,
        )

    def get(
        self,
        source_id: str,
    ) -> KnowledgeSource | None:
        return self._sources.get(
            source_id.strip()
        )

    def list(
        self,
    ) -> builtins.list[KnowledgeSource]:
        return builtins.list(
            self._sources.values()
        )

    def find_by_type(
        self,
        source_type: str,
    ) -> builtins.list[KnowledgeSource]:
        normalized = source_type.strip().lower()

        return [
            source
            for source in self._sources.values()
            if source.source_type.value == normalized
        ]
