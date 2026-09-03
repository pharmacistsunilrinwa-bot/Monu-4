from app.leads.models.lead import Lead


class LeadStore:
    def __init__(self) -> None:
        self._leads: dict[str, Lead] = {}

    def add(
        self,
        lead: Lead,
    ) -> Lead:
        self._leads[lead.lead_id] = lead
        return lead

    def get(
        self,
        lead_id: str,
    ) -> Lead | None:
        return self._leads.get(lead_id)

    def list_all(self) -> list[Lead]:
        return list(
            self._leads.values()
        )
