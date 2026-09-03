from app.income.models.opportunity import (
    IncomeOpportunity,
)
from app.proposals.models.proposal import Proposal


class ProposalEngine:
    def create(
        self,
        opportunity: IncomeOpportunity,
    ) -> Proposal:
        return Proposal(
            title=(
                f"Proposal: "
                f"{opportunity.title}"
            ),
            opportunity=opportunity.title,
            summary=opportunity.description,
            estimated_value=(
                opportunity.estimated_value
            ),
            steps=[
                "Analyze target market",
                "Define service offering",
                "Prepare pricing strategy",
                "Create client proposal",
                "Wait for owner approval",
            ],
        )

    def approve(
        self,
        proposal: Proposal,
    ) -> Proposal:
        proposal.status = "approved"
        return proposal
