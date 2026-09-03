from app.feedback import FeedbackService
from app.learning import LearningService


def test_learning_system() -> None:
    feedback = FeedbackService()

    feedback.record(
        execution_id="execution-001",
        success=True,
        score=0.9,
    )

    feedback.record(
        execution_id="execution-002",
        success=True,
        score=0.8,
    )

    learning = LearningService()

    insight = learning.analyze(
        feedback
    )

    assert insight.total_feedback == 2
    assert insight.success_rate == 1.0
    assert insight.average_score == 0.85

    assert (
        insight.recommendation
        == "Scale successful execution patterns"
    )
