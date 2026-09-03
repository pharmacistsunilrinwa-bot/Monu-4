from app.notifications import (
    NotificationService,
)


def test_notification_system() -> None:
    notifications = NotificationService()

    completed = notifications.notify(
        title="Task Completed",
        message=(
            "Income research task "
            "has completed successfully"
        ),
    )

    alert = notifications.notify(
        title="High Value Opportunity",
        message=(
            "MONU discovered a high value "
            "income opportunity"
        ),
        level="warning",
    )

    assert len(
        notifications.unread()
    ) == 2

    important = notifications.important()

    assert len(important) == 1
    assert important[0] == alert

    notifications.mark_read(completed)

    assert completed.read is True

    assert len(
        notifications.unread()
    ) == 1
