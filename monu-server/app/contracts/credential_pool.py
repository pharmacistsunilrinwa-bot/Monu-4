from abc import ABC, abstractmethod
from typing import Any


class CredentialPool(ABC):
    @abstractmethod
    async def providers(self) -> list[str]:
        raise NotImplementedError

    @abstractmethod
    async def credentials(self, provider: str) -> list[dict[str, Any]]:
        raise NotImplementedError

    @abstractmethod
    async def select(self, provider: str) -> dict[str, Any] | None:
        raise NotImplementedError

    @abstractmethod
    async def mark_success(
        self,
        provider: str,
        credential_id: str,
    ) -> None:
        raise NotImplementedError

    @abstractmethod
    async def mark_failure(
        self,
        provider: str,
        credential_id: str,
        reason: str,
    ) -> None:
        raise NotImplementedError
