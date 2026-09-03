from app.actions.models.action import Action
from app.approvals.models.approval import Approval
from app.approvals.stores.approval_store import (
    ApprovalStore,
)


class ApprovalService:
    def __init__(
        self,
        store: ApprovalStore | None = None,
        approval_priority: int = 8,
    ) -> None:
        self._store = store or ApprovalStore()
        self._approval_priority = approval_priority

    def request(
        self,
        action: Action,
    ) -> Approval:
        required = (
            action.priority
            >= self._approval_priority
        )

        status = (
            "pending"
            if required
            else "approved"
        )

        approval = Approval(
            action_id=action.action_id,
            required=required,
            status=status,
        )

        return self._store.add(approval)

    def approve(
        self,
        approval: Approval,
    ) -> Approval:
        approval.status = "approved"
        return approval

    def reject(
        self,
        approval: Approval,
    ) -> Approval:
        approval.status = "rejected"
        return approval

    def can_execute(
        self,
        action: Action,
    ) -> bool:
        approval = self._store.get_by_action(
            action.action_id
        )

        if approval is None:
            return False

        return approval.status == "approved"
