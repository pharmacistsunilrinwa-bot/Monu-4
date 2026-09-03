from app.knowledge.engines.confidence import ConfidenceEngine


def test_confidence_calculation() -> None:
    engine = ConfidenceEngine()

    result = engine.calculate(
        [0.8, 0.9, 1.0]
    )

    assert result == 0.9


def test_empty_confidence() -> None:
    engine = ConfidenceEngine()

    assert engine.calculate([]) == 0.0
