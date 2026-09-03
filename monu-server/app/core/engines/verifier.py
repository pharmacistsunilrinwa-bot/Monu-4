from app.core.models.result import ExecutionResult


class Verifier:
    def verify(self, result: ExecutionResult) -> bool:
        if not result.success:
            return False

        if result.output is None:
            return False

        return True
