from app.revenue.models.revenue_record import (
    RevenueRecord,
)
from app.revenue.stores.revenue_store import (
    RevenueStore,
)


class RevenueService:
    def __init__(
        self,
        store: RevenueStore | None = None,
    ) -> None:
        self.store = (
            store
            if store is not None
            else RevenueStore()
        )

    def record(
        self,
        source: str,
        amount: float,
        category: str,
    ) -> RevenueRecord:
        revenue = RevenueRecord(
            source=source,
            amount=amount,
            category=category,
        )

        return self.store.add(revenue)

    def total(self) -> float:
        return sum(
            record.amount
            for record in self.store.all()
        )

    def by_category(
        self,
        category: str,
    ) -> float:
        return sum(
            record.amount
            for record in self.store.all()
            if record.category == category
        )

    def top_sources(self) -> list[
        RevenueRecord
    ]:
        return sorted(
            self.store.all(),
            key=lambda record: record.amount,
            reverse=True,
        )
