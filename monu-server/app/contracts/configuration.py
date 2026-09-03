from abc import ABC, abstractmethod
from typing import Any


class ConfigurationProvider(ABC):
    @abstractmethod
    async def get(self, key: str, default: Any = None) -> Any:
        raise NotImplementedError

    @abstractmethod
    async def set(self, key: str, value: Any) -> None:
        raise NotImplementedError

    @abstractmethod
    async def health_check(self) -> dict[str, Any]:
        raise NotImplementedError
