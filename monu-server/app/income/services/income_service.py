from app.income.engines.opportunity_engine import (
    OpportunityEngine,
)
from app.income.models.opportunity import (
    IncomeOpportunity,
)
from app.income.stores.opportunity_store import (
    OpportunityStore,
)


class IncomeService:
    def __init__(self) -> None:
        self.store = OpportunityStore()
        self.engine = OpportunityEngine()

    def add_opportunity(
        self,
        title: str,
        description: str,
        category: str,
        estimated_value: float = 0.0,
        confidence: float = 0.0,
        priority: int = 0,
    ) -> IncomeOpportunity:
        opportunity = IncomeOpportunity(
            title=title,
            description=description,
            category=category,
            estimated_value=estimated_value,
            confidence=confidence,
            priority=priority,
        )

        return self.store.add(
            opportunity
        )

    def recommendations(
        self,
    ) -> list[IncomeOpportunity]:
        return self.engine.rank(
            self.store.list_all()
        )

    def score(
        self,
        opportunity: IncomeOpportunity,
    ) -> float:
        return self.engine.score(
            opportunity
        )
