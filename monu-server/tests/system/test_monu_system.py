from app import MonuSystem


def test_monu_system() -> None:
    monu = MonuSystem()

    services = monu.services()

    assert monu.service_count() == len(
        services
    )

    assert "research" in services
    assert "income" in services
    assert "projects" in services
    assert "revenue" in services
    assert "analytics" in services
    assert "decisions" in services
    assert "execution" in services

    health = monu.health()

    assert health.healthy is True
    assert health.readiness == "ready"

    assert (
        health.total_components
        == monu.service_count()
    )
