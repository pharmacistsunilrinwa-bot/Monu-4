from app.goals import GoalService


def test_goal_system() -> None:
    goals = GoalService()

    revenue_goal = goals.create(
        title="Monthly Revenue",
        target=500000,
        unit="INR",
        priority=10,
    )

    goals.update(
        revenue_goal,
        250000,
    )

    assert revenue_goal.status == "active"

    assert (
        goals.progress(revenue_goal)
        == 50.0
    )

    goals.update(
        revenue_goal,
        500000,
    )

    assert revenue_goal.status == "completed"

    client_goal = goals.create(
        title="Acquire Clients",
        target=10,
        unit="clients",
        priority=8,
    )

    assert client_goal in goals.active_goals()

    assert len(goals.all()) == 2
