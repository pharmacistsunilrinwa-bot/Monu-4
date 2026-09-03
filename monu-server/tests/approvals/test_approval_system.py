from app.actions import ActionService
from app.approvals import ApprovalService
from app.decisions import Decision


def test_approval_system() -> None:
    decision = Decision(
        title="Launch Campaign",
        action="Launch acquisition campaign",
        reason="Revenue growth needed",
        priority=10,
        confidence=0.9,
    )

    actions = ActionService()

    action = actions.create_from_decision(
        decision
    )

    approvals = ApprovalService()

    approval = approvals.request(action)

    assert approval.required is True
    assert approval.status == "pending"

    assert approvals.can_execute(action) is False

    approvals.approve(approval)

    assert approval.status == "approved"

    assert approvals.can_execute(action) is True
