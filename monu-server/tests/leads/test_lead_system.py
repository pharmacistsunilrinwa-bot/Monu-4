from app.leads import LeadService


def test_lead_system() -> None:
    leads = LeadService()

    lead = leads.create(
        name="AI Media Client",
        contact="client@example.com",
        source="research",
        interest="AI video generation",
    )

    assert lead.status == "new"

    score = leads.score(lead)

    assert score == 100.0

    qualified = leads.qualify(lead)

    assert qualified.status == "qualified"

    converted = leads.convert(lead)

    assert converted.status == "converted"

    assert len(
        leads.list_leads()
    ) == 1
