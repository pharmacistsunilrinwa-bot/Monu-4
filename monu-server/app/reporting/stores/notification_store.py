from app.reporting.models.reporting import Notification


class NotificationStore:
    def __init__(self) -> None:
        self._notifications: list[
            Notification
        ] = []

    def add(
        self,
        notification: Notification,
    ) -> Notification:
        self._notifications.append(
            notification
        )
        return notification

    def list_all(
        self,
    ) -> list[Notification]:
        return list(self._notifications)

    def pending(
        self,
    ) -> list[Notification]:
        return [
            notification
            for notification in self._notifications
            if not notification.delivered
        ]
