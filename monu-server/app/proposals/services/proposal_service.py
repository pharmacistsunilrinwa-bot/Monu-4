from app.income.models.opportunity import (
    IncomeOpportunity,
)
from app.proposals.engines.proposal_engine import (
    ProposalEngine,
)
from app.proposals.models.proposal import Proposal
from app.proposals.stores.proposal_store import (
    ProposalStore,
)


class ProposalService:
    def __init__(self) -> None:
        self.store = ProposalStore()
        self.engine = ProposalEngine()

    def create(
        self,
        opportunity: IncomeOpportunity,
    ) -> Proposal:
        proposal = self.engine.create(
            opportunity
        )

        return self.store.add(proposal)

    def approve(
        self,
        proposal: Proposal,
    ) -> Proposal:
        return self.engine.approve(
            proposal
        )

    def list_all(
        self,
    ) -> list[Proposal]:
        return self.store.list_all()
