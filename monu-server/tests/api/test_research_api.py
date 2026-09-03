from fastapi.testclient import TestClient

from app.api.main import create_app


def test_research_api() -> None:
    client = TestClient(create_app())

    response = client.post(
        "/research",
        json={
            "query": "Secure AI architecture",
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert data["query"] == (
        "Secure AI architecture"
    )
    assert "findings" in data
    assert "confidence" in data
