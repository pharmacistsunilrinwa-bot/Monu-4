from app.reporting import ReportingService


def test_reporting_system() -> None:
    reporting = ReportingService()

    report = reporting.create_report(
        title="MONU Progress Report",
        status="running",
        summary="Background work is active.",
        data={
            "progress": 50,
        },
    )

    assert report.title == (
        "MONU Progress Report"
    )

    notification = reporting.notify(
        title="MONU Update",
        message="Task is running.",
    )

    assert notification.delivered is False

    completion = reporting.report_completion(
        task_title="Income Research",
        result={
            "opportunity": "AI automation",
        },
    )

    assert completion.status == "completed"

    delivered = (
        reporting.deliver_notifications()
    )

    assert len(delivered) == 2

    assert all(
        notification.delivered
        for notification in delivered
    )
