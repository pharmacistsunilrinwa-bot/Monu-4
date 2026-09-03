from app.analytics import AnalyticsService
from app.decisions import DecisionService
from app.goals import GoalService
from app.strategy import StrategyService


def test_decision_system() -> None:
    analytics = AnalyticsService()

    metrics = analytics.analyze(
        total_revenue=100000,
        total_clients=2,
        total_projects=2,
    )

    strategy_service = StrategyService()

    strategy = strategy_service.recommend(
        metrics
    )

    goals = GoalService()

    revenue_goal = goals.create(
        title="Monthly Revenue",
        target=500000,
        unit="INR",
        priority=10,
    )

    goals.update(
        revenue_goal,
        100000,
    )

    decisions = DecisionService()

    decision = decisions.decide(
        metrics=metrics,
        strategy=strategy,
        goals=goals.all(),
    )

    assert decision.status == "recommended"

    assert decision.priority == 10

    assert decision.confidence > 0

    assert (
        decision.title
        == "Accelerate Goal Progress"
    )
