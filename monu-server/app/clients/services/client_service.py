from app.clients.models.client import Client
from app.clients.stores.client_store import (
    ClientStore,
)


class ClientService:
    def __init__(
        self,
        store: ClientStore | None = None,
    ) -> None:
        self.store = (
            store
            if store is not None
            else ClientStore()
        )

    def create(
        self,
        name: str,
        contact: str,
    ) -> Client:
        client = Client(
            name=name,
            contact=contact,
        )

        return self.store.add(client)

    def add_project(
        self,
        client: Client,
        project_title: str,
        value: float = 0.0,
    ) -> Client:
        client.projects.append(
            project_title
        )

        client.total_value += value

        return client

    def deactivate(
        self,
        client: Client,
    ) -> Client:
        client.status = "inactive"

        return client

    def active_clients(self) -> list[Client]:
        return [
            client
            for client in self.store.all()
            if client.status == "active"
        ]
