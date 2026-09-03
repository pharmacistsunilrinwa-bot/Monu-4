from app.income import IncomeService
from app.proposals import ProposalService


def test_proposal_system() -> None:
    income = IncomeService()

    opportunity = income.add_opportunity(
        title="AI Media Agency",
        description=(
            "Provide AI video and image "
            "services to clients"
        ),
        category="media",
        estimated_value=50000,
        confidence=0.9,
        priority=9,
    )

    proposals = ProposalService()

    proposal = proposals.create(
        opportunity
    )

    assert proposal.status == "draft"

    assert proposal.opportunity == (
        "AI Media Agency"
    )

    assert len(proposal.steps) == 5

    approved = proposals.approve(
        proposal
    )

    assert approved.status == "approved"

    assert len(
        proposals.list_all()
    ) == 1
