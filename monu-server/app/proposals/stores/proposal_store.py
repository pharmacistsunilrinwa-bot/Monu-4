from app.proposals.models.proposal import Proposal


class ProposalStore:
    def __init__(self) -> None:
        self._proposals: list[Proposal] = []

    def add(
        self,
        proposal: Proposal,
    ) -> Proposal:
        self._proposals.append(proposal)
        return proposal

    def list_all(
        self,
    ) -> list[Proposal]:
        return list(self._proposals)
