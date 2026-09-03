from app.monitoring import MonitoringService


def test_monitoring_system() -> None:
    monitoring = MonitoringService()

    event = monitoring.log_event(
        name="system.started",
        level="info",
        data={
            "service": "MONU",
        },
    )

    assert event.name == "system.started"

    metric = monitoring.record_metric(
        name="requests.total",
        value=10,
    )

    assert metric.value == 10

    updated = monitoring.increment_metric(
        name="requests.total",
        amount=5,
    )

    assert updated.value == 15

    monitoring.register_health_check(
        "memory",
        lambda: True,
    )

    monitoring.register_health_check(
        "database",
        lambda: True,
    )

    results = monitoring.check_health()

    assert len(results) == 2
    assert all(
        result.healthy
        for result in results
    )
