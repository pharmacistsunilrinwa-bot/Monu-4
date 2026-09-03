from app.notifications.models.notification import (
    Notification,
)


class NotificationStore:
    def __init__(self) -> None:
        self._items: list[
            Notification
        ] = []

    def add(
        self,
        notification: Notification,
    ) -> Notification:
        self._items.append(notification)
        return notification

    def list_all(
        self,
    ) -> list[Notification]:
        return list(self._items)

    def unread(
        self,
    ) -> list[Notification]:
        return [
            item
            for item in self._items
            if not item.read
        ]

    def mark_read(
        self,
        notification: Notification,
    ) -> Notification:
        notification.read = True
        return notification
