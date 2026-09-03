from app.actions import ActionService
from app.decisions import Decision


def test_action_system() -> None:
    decision = Decision(
        title="Acquire Clients",
        action="Launch client acquisition campaign",
        reason="Business needs more clients",
        priority=10,
        confidence=0.95,
    )

    actions = ActionService()

    action = actions.create_from_decision(
        decision
    )

    assert action.status == "planned"
    assert action.priority == 10
    assert action.source == "decision"

    assert action in actions.pending()

    actions.start(action)

    assert action.status == "running"

    actions.complete(action)

    assert action.status == "completed"

    assert len(actions.all()) == 1
