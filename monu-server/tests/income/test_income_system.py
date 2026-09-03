from app.income import IncomeService


def test_income_system() -> None:
    income = IncomeService()

    first = income.add_opportunity(
        title="AI Automation Agency",
        description=(
            "Provide AI automation services "
            "to businesses"
        ),
        category="services",
        estimated_value=80000,
        confidence=0.9,
        priority=9,
    )

    second = income.add_opportunity(
        title="Content Generation",
        description=(
            "Generate media and content "
            "for clients"
        ),
        category="media",
        estimated_value=30000,
        confidence=0.7,
        priority=7,
    )

    assert income.score(first) > 0

    recommendations = (
        income.recommendations()
    )

    assert len(recommendations) == 2

    assert (
        recommendations[0].title
        == "AI Automation Agency"
    )

    assert second in recommendations
