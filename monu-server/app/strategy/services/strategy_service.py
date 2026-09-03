from app.analytics.models.business_metrics import (
    BusinessMetrics,
)
from app.strategy.models.strategy_recommendation import (
    StrategyRecommendation,
)


class StrategyService:
    def recommend(
        self,
        metrics: BusinessMetrics,
    ) -> StrategyRecommendation:
        if metrics.total_clients == 0:
            return StrategyRecommendation(
                title="Acquire First Clients",
                reason=(
                    "Business has no active "
                    "clients yet."
                ),
                priority=10,
                expected_impact=(
                    "Create initial revenue "
                    "pipeline"
                ),
            )

        if (
            metrics.average_revenue_per_project
            < 50000
        ):
            return StrategyRecommendation(
                title="Increase Project Value",
                reason=(
                    "Average project revenue "
                    "is below target."
                ),
                priority=9,
                expected_impact=(
                    "Increase revenue per "
                    "client"
                ),
            )

        return StrategyRecommendation(
            title="Scale High Value Services",
            reason=(
                "Projects are generating "
                "strong revenue."
            ),
            priority=10,
            expected_impact=(
                "Increase profitable "
                "business growth"
            ),
        )
