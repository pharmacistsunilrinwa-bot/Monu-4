from app.actions.models.action import Action
from app.actions.stores.action_store import ActionStore
from app.decisions.models.decision import Decision


class ActionService:
    def __init__(
        self,
        store: ActionStore | None = None,
    ) -> None:
        self._store = store or ActionStore()

    def create_from_decision(
        self,
        decision: Decision,
    ) -> Action:
        action = Action(
            title=decision.title,
            description=decision.action,
            priority=decision.priority,
            source="decision",
        )

        return self._store.add(action)

    def start(
        self,
        action: Action,
    ) -> Action:
        action.status = "running"
        return action

    def complete(
        self,
        action: Action,
    ) -> Action:
        action.status = "completed"
        return action

    def pending(self) -> list[Action]:
        return [
            action
            for action in self._store.all()
            if action.status == "planned"
        ]

    def all(self) -> list[Action]:
        return self._store.all()
