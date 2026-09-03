from abc import ABC, abstractmethod
from typing import Any


class Tool(ABC):
    name: str = ""

    @abstractmethod
    async def execute(
        self,
        arguments: dict[str, Any],
    ) -> Any:
        raise NotImplementedError

    async def health_check(self) -> dict[str, Any]:
        return {
            "healthy": True,
        }
