from typing import Any

from app.persistence.stores.json_store import JSONStore


class Repository:
    def __init__(
        self,
        store: JSONStore,
        collection: str,
    ) -> None:
        self.store = store
        self.collection = collection

    def _load_collection(self) -> dict[str, Any]:
        database = self.store.load()

        return database.get(
            self.collection,
            {},
        )

    def _save_collection(
        self,
        collection_data: dict[str, Any],
    ) -> None:
        database = self.store.load()

        database[self.collection] = collection_data

        self.store.save(database)

    def set(
        self,
        record_id: str,
        data: dict[str, Any],
    ) -> None:
        collection = self._load_collection()

        collection[record_id] = data

        self._save_collection(collection)

    def get(
        self,
        record_id: str,
    ) -> dict[str, Any] | None:
        collection = self._load_collection()

        return collection.get(record_id)

    def list_all(self) -> dict[str, dict[str, Any]]:
        return self._load_collection()

    def delete(
        self,
        record_id: str,
    ) -> None:
        collection = self._load_collection()

        collection.pop(
            record_id,
            None,
        )

        self._save_collection(collection)
