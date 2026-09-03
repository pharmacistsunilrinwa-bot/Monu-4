from app.analytics.models.business_metrics import (
    BusinessMetrics,
)
from app.decisions.models.decision import Decision
from app.goals.models.goal import Goal
from app.strategy.models.strategy_recommendation import (
    StrategyRecommendation,
)


class DecisionService:
    def decide(
        self,
        metrics: BusinessMetrics,
        strategy: StrategyRecommendation,
        goals: list[Goal],
    ) -> Decision:
        active_goals = [
            goal
            for goal in goals
            if goal.status == "active"
        ]

        if active_goals:
            highest_priority_goal = max(
                active_goals,
                key=lambda goal: goal.priority,
            )

            if highest_priority_goal.current < (
                highest_priority_goal.target * 0.5
            ):
                return Decision(
                    title=(
                        "Accelerate Goal Progress"
                    ),
                    action=(
                        f"Prioritize actions for "
                        f"{highest_priority_goal.title}"
                    ),
                    reason=(
                        "High priority goal is "
                        "below 50 percent progress."
                    ),
                    priority=10,
                    confidence=0.9,
                )

        if metrics.total_clients == 0:
            return Decision(
                title="Acquire Clients",
                action=(
                    "Launch client acquisition "
                    "campaign"
                ),
                reason=(
                    "Business currently has "
                    "no clients."
                ),
                priority=10,
                confidence=0.95,
            )

        return Decision(
            title=strategy.title,
            action=strategy.expected_impact,
            reason=strategy.reason,
            priority=strategy.priority,
            confidence=0.85,
        )
