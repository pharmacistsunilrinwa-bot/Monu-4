from app.notifications.models.notification import (
    Notification,
)


class AlertEngine:
    IMPORTANT_LEVELS = {
        "warning",
        "error",
        "critical",
    }

    def is_important(
        self,
        notification: Notification,
    ) -> bool:
        return (
            notification.level
            in self.IMPORTANT_LEVELS
        )
