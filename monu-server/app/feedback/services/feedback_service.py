from app.feedback.models.feedback import Feedback


class FeedbackService:
    def __init__(self) -> None:
        self._feedback: list[Feedback] = []

    def record(
        self,
        execution_id: str,
        success: bool,
        score: float,
        notes: str = "",
    ) -> Feedback:
        feedback = Feedback(
            execution_id=execution_id,
            success=success,
            score=score,
            notes=notes,
        )

        self._feedback.append(feedback)

        return feedback

    def all(self) -> list[Feedback]:
        return list(self._feedback)

    def average_score(self) -> float:
        if not self._feedback:
            return 0.0

        return sum(
            item.score
            for item in self._feedback
        ) / len(self._feedback)

    def success_rate(self) -> float:
        if not self._feedback:
            return 0.0

        successful = sum(
            1
            for item in self._feedback
            if item.success
        )

        return successful / len(
            self._feedback
        )
