from app.memory.models.memory import MemoryItem


class MemoryStore:
    def __init__(self) -> None:
        self._items: dict[str, MemoryItem] = {}

    def add(
        self,
        item: MemoryItem,
    ) -> MemoryItem:
        self._items[item.memory_id] = item
        return item

    def get(
        self,
        memory_id: str,
    ) -> MemoryItem | None:
        return self._items.get(memory_id)

    def remove(
        self,
        memory_id: str,
    ) -> None:
        self._items.pop(memory_id, None)

    def list_all(self) -> list[MemoryItem]:
        return list(self._items.values())

    def clear(self) -> None:
        self._items.clear()
