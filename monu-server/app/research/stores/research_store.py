from app.research.models.research import (
    ResearchReport,
)


class ResearchStore:
    def __init__(self) -> None:
        self._reports: list[
            ResearchReport
        ] = []

    def add(
        self,
        report: ResearchReport,
    ) -> ResearchReport:
        self._reports.append(report)
        return report

    def list_all(
        self,
    ) -> list[ResearchReport]:
        return list(self._reports)

    def latest(
        self,
    ) -> ResearchReport | None:
        if not self._reports:
            return None

        return self._reports[-1]
