from app.monitoring.models.monitoring import Metric


class MetricStore:
    def __init__(self) -> None:
        self._metrics: dict[str, Metric] = {}

    def set(
        self,
        metric: Metric,
    ) -> Metric:
        self._metrics[metric.name] = metric
        return metric

    def get(
        self,
        name: str,
    ) -> Metric | None:
        return self._metrics.get(name)

    def list_all(self) -> list[Metric]:
        return list(self._metrics.values())
