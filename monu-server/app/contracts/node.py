from abc import ABC, abstractmethod
from typing import Any


class ExecutionNode(ABC):
    node_id: str

    @abstractmethod
    async def health_check(self) -> dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    async def capabilities(self) -> list[str]:
        raise NotImplementedError

    @abstractmethod
    async def execute(self, task: dict[str, Any]) -> dict[str, Any]:
        raise NotImplementedError
