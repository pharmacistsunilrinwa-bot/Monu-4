from abc import ABC, abstractmethod
from typing import Any


class Provider(ABC):
    name: str

    @abstractmethod
    async def health_check(self) -> dict[str, Any]:
        raise NotImplementedError

    @abstractmethod
    async def capabilities(self) -> list[str]:
        raise NotImplementedError

    @abstractmethod
    async def execute(self, request: dict[str, Any]) -> dict[str, Any]:
        raise NotImplementedError
