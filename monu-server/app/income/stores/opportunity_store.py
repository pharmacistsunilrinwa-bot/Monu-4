from app.income.models.opportunity import (
    IncomeOpportunity,
)


class OpportunityStore:
    def __init__(self) -> None:
        self._items: list[
            IncomeOpportunity
        ] = []

    def add(
        self,
        opportunity: IncomeOpportunity,
    ) -> IncomeOpportunity:
        self._items.append(opportunity)
        return opportunity

    def list_all(
        self,
    ) -> list[IncomeOpportunity]:
        return list(self._items)

    def clear(self) -> None:
        self._items.clear()
