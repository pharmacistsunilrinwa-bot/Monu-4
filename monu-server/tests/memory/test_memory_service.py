from app.memory import MemoryService


def test_memory_service() -> None:
    service = MemoryService()

    service.remember(
        "MONU supports provider routing",
        importance=0.8,
    )

    service.remember(
        "MONU has a knowledge system",
        importance=0.9,
    )

    results = service.recall(
        "knowledge system"
    )

    assert len(results) >= 1
