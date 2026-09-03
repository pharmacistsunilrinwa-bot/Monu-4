from app.feedback import FeedbackService


def test_feedback_system() -> None:
    feedback = FeedbackService()

    first = feedback.record(
        execution_id="execution-001",
        success=True,
        score=0.9,
        notes="Excellent execution",
    )

    second = feedback.record(
        execution_id="execution-002",
        success=False,
        score=0.4,
        notes="Needs improvement",
    )

    assert first.success is True
    assert second.success is False

    assert len(feedback.all()) == 2

    assert feedback.average_score() == 0.65

    assert feedback.success_rate() == 0.5
