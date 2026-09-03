from app.clients.models.client import Client


class ClientStore:
    def __init__(self) -> None:
        self._clients: dict[str, Client] = {}

    def add(
        self,
        client: Client,
    ) -> Client:
        self._clients[
            client.client_id
        ] = client

        return client

    def get(
        self,
        client_id: str,
    ) -> Client | None:
        return self._clients.get(
            client_id
        )

    def all(self) -> list[Client]:
        return list(
            self._clients.values()
        )
