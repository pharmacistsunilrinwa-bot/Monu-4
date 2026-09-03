from app.knowledge.registry import KnowledgeRegistry
from app.schemas.knowledge import (
    KnowledgeSource,
    KnowledgeSourceType,
)


def test_knowledge_registry() -> None:
    registry = KnowledgeRegistry()

    source = KnowledgeSource(
        source_id="demo-web",
        source_type=KnowledgeSourceType.WEB,
        name="Demo Web Source",
        reliability=0.9,
    )

    registry.register(source)

    assert registry.get("demo-web") is source
    assert len(registry.find_by_type("web")) == 1
