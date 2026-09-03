from pathlib import Path
from typing import Any

from app.persistence.stores.json_store import JSONStore
from app.persistence.stores.repository import Repository


class PersistenceService:
    def __init__(
        self,
        database_path: str | Path = "data/monu.json",
    ) -> None:
        self.store = JSONStore(
            database_path
        )

    def repository(
        self,
        collection: str,
    ) -> Repository:
        return Repository(
            store=self.store,
            collection=collection,
        )

    def save(
        self,
        collection: str,
        record_id: str,
        data: dict[str, Any],
    ) -> None:
        self.repository(
            collection
        ).set(
            record_id,
            data,
        )

    def load(
        self,
        collection: str,
        record_id: str,
    ) -> dict[str, Any] | None:
        return self.repository(
            collection
        ).get(
            record_id
        )
