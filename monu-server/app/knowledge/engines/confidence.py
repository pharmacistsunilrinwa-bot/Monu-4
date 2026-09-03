class ConfidenceEngine:
    def calculate(
        self,
        source_reliabilities: list[float],
    ) -> float:
        if not source_reliabilities:
            return 0.0

        normalized = [
            max(0.0, min(1.0, value))
            for value in source_reliabilities
        ]

        return sum(normalized) / len(normalized)
