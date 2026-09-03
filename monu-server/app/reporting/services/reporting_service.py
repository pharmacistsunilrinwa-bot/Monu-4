from typing import Any

from app.reporting.engines.notification_engine import (
    NotificationEngine,
)
from app.reporting.engines.report_engine import (
    ReportEngine,
)
from app.reporting.models.reporting import (
    Notification,
    Report,
)
from app.reporting.stores.notification_store import (
    NotificationStore,
)
from app.reporting.stores.report_store import ReportStore


class ReportingService:
    def __init__(self) -> None:
        self.report_store = ReportStore()
        self.notification_store = NotificationStore()

        self.reports = ReportEngine(
            self.report_store
        )

        self.notifications = NotificationEngine(
            self.notification_store
        )

    def create_report(
        self,
        title: str,
        status: str,
        summary: str,
        data: dict[str, Any] | None = None,
    ) -> Report:
        return self.reports.create(
            title=title,
            status=status,
            summary=summary,
            data=data,
        )

    def notify(
        self,
        title: str,
        message: str,
        level: str = "info",
    ) -> Notification:
        return self.notifications.create(
            title=title,
            message=message,
            level=level,
        )

    def report_completion(
        self,
        task_title: str,
        result: Any,
    ) -> Report:
        report = self.create_report(
            title=f"Task Completed: {task_title}",
            status="completed",
            summary="Autonomous task completed successfully.",
            data={
                "result": result,
            },
        )

        self.notify(
            title="Task Completed",
            message=(
                f"{task_title} completed successfully."
            ),
            level="success",
        )

        return report

    def deliver_notifications(
        self,
    ) -> list[Notification]:
        return self.notifications.deliver_pending()
