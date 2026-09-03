from app.leads.models.lead import Lead
from app.leads.stores.lead_store import LeadStore


class LeadService:
    def __init__(
        self,
        store: LeadStore | None = None,
    ) -> None:
        self.store = store or LeadStore()

    def create(
        self,
        name: str,
        contact: str,
        source: str,
        interest: str,
    ) -> Lead:
        lead = Lead(
            name=name,
            contact=contact,
            source=source,
            interest=interest,
        )

        return self.store.add(lead)

    def score(
        self,
        lead: Lead,
    ) -> float:
        value = 0.0

        if lead.interest:
            value += 50.0

        if lead.contact:
            value += 30.0

        if lead.source:
            value += 20.0

        lead.score = value

        return value

    def qualify(
        self,
        lead: Lead,
    ) -> Lead:
        score = self.score(lead)

        if score >= 70:
            lead.status = "qualified"
        else:
            lead.status = "new"

        return lead

    def convert(
        self,
        lead: Lead,
    ) -> Lead:
        if lead.status != "qualified":
            raise ValueError(
                "Lead must be qualified "
                "before conversion"
            )

        lead.status = "converted"

        return lead

    def list_leads(self) -> list[Lead]:
        return self.store.list_all()
