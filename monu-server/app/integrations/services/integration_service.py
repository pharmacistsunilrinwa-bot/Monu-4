from app.integrations.models.integration_result import (
    IntegrationResult,
)


class IntegrationService:
    def run_pipeline(
        self,
        opportunity_title: str,
        client_name: str,
        project_value: float,
    ) -> IntegrationResult:
        stages = [
            "opportunity_received",
            "proposal_created",
            "lead_created",
            "project_created",
            "client_registered",
            "revenue_recorded",
            "analytics_updated",
        ]

        return IntegrationResult(
            status="completed",
            stages=stages,
            data={
                "opportunity_title": (
                    opportunity_title
                ),
                "client_name": client_name,
                "project_value": project_value,
            },
        )
