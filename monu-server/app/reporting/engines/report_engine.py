from typing import Any

from app.reporting.models.reporting import Report
from app.reporting.stores.report_store import ReportStore


class ReportEngine:
    def __init__(
        self,
        store: ReportStore,
    ) -> None:
        self.store = store

    def create(
        self,
        title: str,
        status: str,
        summary: str,
        data: dict[str, Any] | None = None,
    ) -> Report:
        report = Report(
            title=title,
            status=status,
            summary=summary,
            data=data or {},
        )

        return self.store.add(report)
