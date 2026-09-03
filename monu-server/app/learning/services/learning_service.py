from app.feedback import FeedbackService
from app.learning.models.learning_insight import (
    LearningInsight,
)


class LearningService:
    def analyze(
        self,
        feedback: FeedbackService,
    ) -> LearningInsight:
        total_feedback = len(feedback.all())

        average_score = round(feedback.average_score(), 2)

        success_rate = feedback.success_rate()

        if total_feedback == 0:
            recommendation = (
                "Collect more execution feedback"
            )
        elif success_rate < 0.5:
            recommendation = (
                "Review failed execution patterns"
            )
        elif average_score < 0.7:
            recommendation = (
                "Optimize execution quality"
            )
        else:
            recommendation = (
                "Scale successful execution patterns"
            )

        return LearningInsight(
            total_feedback=total_feedback,
            average_score=average_score,
            success_rate=success_rate,
            recommendation=recommendation,
        )
