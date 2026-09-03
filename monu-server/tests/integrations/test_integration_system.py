from app.integrations import IntegrationService


def test_integration_system() -> None:
    integrations = IntegrationService()

    result = integrations.run_pipeline(
        opportunity_title="AI Automation",
        client_name="MONU Client",
        project_value=100000,
    )

    assert result.status == "completed"

    assert len(result.stages) == 7

    assert (
        result.data["project_value"]
        == 100000
    )

    assert (
        "revenue_recorded"
        in result.stages
    )
