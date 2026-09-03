from app.analytics import AnalyticsService
from app.strategy import StrategyService


def test_strategy_system() -> None:
    analytics = AnalyticsService()

    metrics = analytics.analyze(
        total_revenue=300000,
        total_clients=3,
        total_projects=5,
    )

    strategy = StrategyService()

    recommendation = strategy.recommend(
        metrics
    )

    assert (
        recommendation.title
        == "Scale High Value Services"
    )

    assert recommendation.priority == 10
