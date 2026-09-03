from fastapi.testclient import TestClient

from app.api.main import create_app


def test_memory_api() -> None:
    client = TestClient(create_app())

    create_response = client.post(
        "/memory",
        json={
            "content": "MONU API memory test",
            "importance": 0.9,
        },
    )

    assert create_response.status_code == 200

    memory = create_response.json()

    assert memory["content"] == (
        "MONU API memory test"
    )

    recall_response = client.post(
        "/memory/recall",
        json={
            "query": "MONU API memory",
            "limit": 5,
        },
    )

    assert recall_response.status_code == 200

    data = recall_response.json()

    assert data["count"] >= 1
