from app.actions.models.action import Action


class ActionStore:
    def __init__(self) -> None:
        self._actions: list[Action] = []
        self._next_id = 1

    def add(
        self,
        action: Action,
    ) -> Action:
        action.action_id = self._next_id
        self._next_id += 1

        self._actions.append(action)

        return action

    def all(self) -> list[Action]:
        return list(self._actions)

    def get(
        self,
        action_id: int,
    ) -> Action | None:
        for action in self._actions:
            if action.action_id == action_id:
                return action

        return None
