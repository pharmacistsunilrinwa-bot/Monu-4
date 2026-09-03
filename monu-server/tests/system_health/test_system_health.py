from app.system_health import (
    SystemHealthService,
)


def test_system_health() -> None:
    health = SystemHealthService()

    status = health.check(
        {
            "core": True,
            "ai": True,
            "memory": True,
            "agents": True,
            "research": True,
            "income": True,
            "projects": True,
            "revenue": True,
            "decisions": True,
            "execution": True,
        }
    )

    assert status.healthy is True

    assert status.readiness == "ready"

    assert status.total_components == 10

    assert status.active_components == 10
