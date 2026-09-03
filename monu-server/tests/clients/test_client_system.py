from app.clients import ClientService


def test_client_system() -> None:
    clients = ClientService()

    client = clients.create(
        name="MONU Business Client",
        contact="client@example.com",
    )

    assert client.status == "active"

    clients.add_project(
        client,
        project_title="AI Video Campaign",
        value=50000,
    )

    clients.add_project(
        client,
        project_title="AI Automation",
        value=75000,
    )

    assert len(client.projects) == 2

    assert client.total_value == 125000

    active = clients.active_clients()

    assert client in active

    clients.deactivate(client)

    assert client.status == "inactive"
