from abc import ABC, abstractmethod
from typing import Any


class Agent(ABC):
    name: str = "unknown"

    @abstractmethod
    async def capabilities(self) -> list[str]:
        raise NotImplementedError

    @abstractmethod
    async def execute(
        self,
        task: str,
        context: dict[str, Any] | None = None,
    ) -> Any:
        raise NotImplementedError
