from app.monitoring.models.monitoring import Metric
from app.monitoring.stores.metric_store import MetricStore


class MetricsEngine:
    def __init__(
        self,
        store: MetricStore,
    ) -> None:
        self.store = store

    def record(
        self,
        name: str,
        value: float,
        tags: dict[str, str] | None = None,
    ) -> Metric:
        metric = Metric(
            name=name,
            value=float(value),
            tags=tags or {},
        )

        return self.store.set(metric)

    def increment(
        self,
        name: str,
        amount: float = 1.0,
    ) -> Metric:
        existing = self.store.get(name)

        value = amount

        if existing is not None:
            value = existing.value + amount

        return self.record(
            name=name,
            value=value,
        )
