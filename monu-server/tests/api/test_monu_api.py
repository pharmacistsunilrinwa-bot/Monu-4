from fastapi.testclient import TestClient

from app.main import app


def test_root() -> None:
    client = TestClient(app)

    response = client.get("/")

    assert response.status_code == 200

    data = response.json()

    assert data["name"] == "MONU Server"
    assert data["status"] == "running"
    assert data["services"] > 0


def test_health() -> None:
    client = TestClient(app)

    response = client.get("/health")

    assert response.status_code == 200

    data = response.json()

    assert data["healthy"] is True
    assert data["readiness"] == "ready"


def test_services() -> None:
    client = TestClient(app)

    response = client.get("/services")

    assert response.status_code == 200

    data = response.json()

    assert data["count"] > 0
    assert "research" in data["services"]
    assert "income" in data["services"]
    assert "projects" in data["services"]
    assert "execution" in data["services"]
