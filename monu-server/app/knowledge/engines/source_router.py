from app.knowledge.registry import KnowledgeRegistry
from app.schemas.knowledge import KnowledgeSource


class SourceRouter:
    def __init__(
        self,
        registry: KnowledgeRegistry,
    ) -> None:
        self.registry = registry

    def select_sources(
        self,
        source_type: str | None = None,
    ) -> list[KnowledgeSource]:
        if source_type is None:
            return self.registry.list()

        return self.registry.find_by_type(
            source_type
        )
