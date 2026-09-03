from typing import Any

from app.notifications.engines.alert_engine import (
    AlertEngine,
)
from app.notifications.models.notification import (
    Notification,
)
from app.notifications.stores.notification_store import (
    NotificationStore,
)


class NotificationService:
    def __init__(self) -> None:
        self.store = NotificationStore()
        self.alerts = AlertEngine()

    def notify(
        self,
        title: str,
        message: str,
        level: str = "info",
        data: dict[str, Any] | None = None,
    ) -> Notification:
        notification = Notification(
            title=title,
            message=message,
            level=level,
            data=data or {},
        )

        return self.store.add(
            notification
        )

    def unread(
        self,
    ) -> list[Notification]:
        return self.store.unread()

    def mark_read(
        self,
        notification: Notification,
    ) -> Notification:
        return self.store.mark_read(
            notification
        )

    def important(
        self,
    ) -> list[Notification]:
        return [
            item
            for item in self.store.list_all()
            if self.alerts.is_important(item)
        ]
