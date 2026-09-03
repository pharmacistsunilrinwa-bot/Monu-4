from app.knowledge import (
    ConfidenceEngine,
    KnowledgeRegistry,
    ResearchManager,
    SourceRouter,
)
from app.memory import MemoryService
from app.providers import ProviderRegistry
from app.tools import ToolRegistry, ToolService


class ApplicationContainer:
    def __init__(self) -> None:
        self.provider_registry = ProviderRegistry()

        self.knowledge_registry = KnowledgeRegistry()
        self.source_router = SourceRouter(
            self.knowledge_registry
        )
        self.confidence_engine = ConfidenceEngine()
        self.research_manager = ResearchManager(
            source_router=self.source_router,
            confidence_engine=self.confidence_engine,
        )

        self.memory_service = MemoryService()

        self.tool_registry = ToolRegistry()
        self.tool_service = ToolService(
            self.tool_registry
        )
