from app.revenue.models.revenue_record import (
    RevenueRecord,
)


class RevenueStore:
    def __init__(self) -> None:
        self._records: list[
            RevenueRecord
        ] = []

    def add(
        self,
        record: RevenueRecord,
    ) -> RevenueRecord:
        self._records.append(record)

        return record

    def all(self) -> list[RevenueRecord]:
        return list(self._records)
