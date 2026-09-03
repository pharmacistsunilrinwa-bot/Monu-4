from pathlib import Path

from app.persistence import PersistenceService


def test_persistence_system(
    tmp_path: Path,
) -> None:
    database = tmp_path / "monu.json"

    service = PersistenceService(
        database
    )

    service.save(
        collection="memory",
        record_id="memory-1",
        data={
            "content": "MONU persistent memory",
            "importance": 1.0,
        },
    )

    record = service.load(
        collection="memory",
        record_id="memory-1",
    )

    assert record is not None
    assert record["content"] == (
        "MONU persistent memory"
    )

    repository = service.repository(
        "memory"
    )

    assert len(
        repository.list_all()
    ) == 1
