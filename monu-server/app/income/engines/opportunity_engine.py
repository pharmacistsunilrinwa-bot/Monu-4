from app.income.models.opportunity import (
    IncomeOpportunity,
)


class OpportunityEngine:
    def score(
        self,
        opportunity: IncomeOpportunity,
    ) -> float:
        value_score = min(
            opportunity.estimated_value / 100000,
            1.0,
        )

        confidence_score = min(
            max(opportunity.confidence, 0.0),
            1.0,
        )

        priority_score = min(
            max(opportunity.priority / 10, 0.0),
            1.0,
        )

        return round(
            (
                value_score * 0.4
                + confidence_score * 0.4
                + priority_score * 0.2
            ),
            3,
        )

    def rank(
        self,
        opportunities: list[
            IncomeOpportunity
        ],
    ) -> list[IncomeOpportunity]:
        return sorted(
            opportunities,
            key=self.score,
            reverse=True,
        )
