from app.memory.models import MemoryItem
from app.memory.stores import MemoryStore


def test_memory_store() -> None:
    store = MemoryStore()

    item = MemoryItem(
        content="MONU is a modular AI system"
    )

    store.add(item)

    assert store.get(item.memory_id) is item
    assert len(store.list_all()) == 1

    store.remove(item.memory_id)

    assert store.get(item.memory_id) is None
