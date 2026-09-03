from app.goals.models.goal import Goal


class GoalStore:
    def __init__(self) -> None:
        self._goals: list[Goal] = []
        self._next_id = 1

    def add(
        self,
        goal: Goal,
    ) -> Goal:
        goal.goal_id = self._next_id
        self._next_id += 1

        self._goals.append(goal)

        return goal

    def all(self) -> list[Goal]:
        return list(self._goals)

    def get(
        self,
        goal_id: int,
    ) -> Goal | None:
        for goal in self._goals:
            if goal.goal_id == goal_id:
                return goal

        return None
