from app.analytics import AnalyticsService


def test_analytics_system() -> None:
    analytics = AnalyticsService()

    metrics = analytics.analyze(
        total_revenue=300000,
        total_clients=3,
        total_projects=5,
    )

    assert metrics.total_revenue == 300000
    assert metrics.total_clients == 3
    assert metrics.total_projects == 5

    assert (
        metrics.average_revenue_per_client
        == 100000
    )

    assert (
        metrics.average_revenue_per_project
        == 60000
    )

    health = analytics.health(metrics)

    assert health == "strong"
