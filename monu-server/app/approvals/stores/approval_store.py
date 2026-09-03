from app.approvals.models.approval import Approval


class ApprovalStore:
    def __init__(self) -> None:
        self._approvals: list[Approval] = []
        self._next_id = 1

    def add(
        self,
        approval: Approval,
    ) -> Approval:
        approval.approval_id = self._next_id
        self._next_id += 1

        self._approvals.append(approval)

        return approval

    def get_by_action(
        self,
        action_id: int,
    ) -> Approval | None:
        for approval in self._approvals:
            if approval.action_id == action_id:
                return approval

        return None

    def all(self) -> list[Approval]:
        return list(self._approvals)
