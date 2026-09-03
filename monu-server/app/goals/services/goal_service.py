from app.goals.models.goal import Goal
from app.goals.stores.goal_store import GoalStore


class GoalService:
    def __init__(
        self,
        store: GoalStore | None = None,
    ) -> None:
        self._store = store or GoalStore()

    def create(
        self,
        title: str,
        target: float,
        unit: str = "value",
        priority: int = 5,
    ) -> Goal:
        goal = Goal(
            title=title,
            target=target,
            unit=unit,
            priority=priority,
        )

        return self._store.add(goal)

    def update(
        self,
        goal: Goal,
        current: float,
    ) -> Goal:
        goal.current = current

        if goal.current >= goal.target:
            goal.status = "completed"

        return goal

    def progress(
        self,
        goal: Goal,
    ) -> float:
        if goal.target <= 0:
            return 0.0

        return min(
            100.0,
            (goal.current / goal.target) * 100,
        )

    def active_goals(self) -> list[Goal]:
        return [
            goal
            for goal in self._store.all()
            if goal.status == "active"
        ]

    def all(self) -> list[Goal]:
        return self._store.all()
