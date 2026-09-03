from app.reporting.models.reporting import (
    Notification,
)
from app.reporting.stores.notification_store import (
    NotificationStore,
)


class NotificationEngine:
    def __init__(
        self,
        store: NotificationStore,
    ) -> None:
        self.store = store

    def create(
        self,
        title: str,
        message: str,
        level: str = "info",
    ) -> Notification:
        notification = Notification(
            title=title,
            message=message,
            level=level,
        )

        return self.store.add(
            notification
        )

    def deliver_pending(
        self,
    ) -> list[Notification]:
        notifications = self.store.pending()

        for notification in notifications:
            notification.delivered = True

        return notifications
