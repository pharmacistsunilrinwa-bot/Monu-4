from abc import ABC, abstractmethod
from typing import Any


class MemoryStore(ABC):
    @abstractmethod
    async def store(self, record: dict[str, Any]) -> str:
        raise NotImplementedError

    @abstractmethod
    async def retrieve(
        self,
        query: str,
        limit: int = 10,
    ) -> list[dict[str, Any]]:
        raise NotImplementedError

    @abstractmethod
    async def delete(self, record_id: str) -> bool:
        raise NotImplementedError
