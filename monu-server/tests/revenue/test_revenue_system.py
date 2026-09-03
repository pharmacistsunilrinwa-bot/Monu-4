from app.revenue import RevenueService


def test_revenue_system() -> None:
    revenue = RevenueService()

    first = revenue.record(
        source="AI Video Project",
        amount=50000,
        category="media",
    )

    second = revenue.record(
        source="Automation Project",
        amount=75000,
        category="automation",
    )

    third = revenue.record(
        source="Image Generation",
        amount=25000,
        category="media",
    )

    assert revenue.total() == 150000

    assert (
        revenue.by_category("media")
        == 75000
    )

    top = revenue.top_sources()

    assert top[0] == second
    assert first in top
    assert third in top
