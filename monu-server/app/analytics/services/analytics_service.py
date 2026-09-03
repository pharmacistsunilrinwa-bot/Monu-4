from app.analytics.models.business_metrics import (
    BusinessMetrics,
)


class AnalyticsService:
    def analyze(
        self,
        total_revenue: float,
        total_clients: int,
        total_projects: int,
    ) -> BusinessMetrics:
        revenue_per_client = (
            total_revenue / total_clients
            if total_clients > 0
            else 0.0
        )

        revenue_per_project = (
            total_revenue / total_projects
            if total_projects > 0
            else 0.0
        )

        return BusinessMetrics(
            total_revenue=total_revenue,
            total_clients=total_clients,
            total_projects=total_projects,
            average_revenue_per_client=(
                revenue_per_client
            ),
            average_revenue_per_project=(
                revenue_per_project
            ),
        )

    def health(
        self,
        metrics: BusinessMetrics,
    ) -> str:
        if metrics.total_revenue <= 0:
            return "starting"

        if (
            metrics.average_revenue_per_project
            >= 50000
        ):
            return "strong"

        return "growing"
