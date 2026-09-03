from app.reporting.models.reporting import Report


class ReportStore:
    def __init__(self) -> None:
        self._reports: list[Report] = []

    def add(
        self,
        report: Report,
    ) -> Report:
        self._reports.append(report)
        return report

    def get(
        self,
        report_id: str,
    ) -> Report | None:
        for report in self._reports:
            if report.report_id == report_id:
                return report
        return None

    def list_all(self) -> list[Report]:
        return list(self._reports)
