from typing import Any

from app.monitoring.engines.event_logger import EventLogger
from app.monitoring.engines.health_engine import HealthEngine
from app.monitoring.engines.metrics_engine import MetricsEngine
from app.monitoring.models.monitoring import (
    ComponentHealth,
    Metric,
    SystemEvent,
)
from app.monitoring.stores.event_store import EventStore
from app.monitoring.stores.metric_store import MetricStore


class MonitoringService:
    def __init__(self) -> None:
        self.event_store = EventStore()
        self.metric_store = MetricStore()

        self.logger = EventLogger(
            self.event_store
        )

        self.metrics = MetricsEngine(
            self.metric_store
        )

        self.health = HealthEngine()

    def log_event(
        self,
        name: str,
        level: str = "info",
        data: dict[str, Any] | None = None,
    ) -> SystemEvent:
        return self.logger.log(
            name=name,
            level=level,
            data=data,
        )

    def record_metric(
        self,
        name: str,
        value: float,
    ) -> Metric:
        return self.metrics.record(
            name=name,
            value=value,
        )

    def increment_metric(
        self,
        name: str,
        amount: float = 1.0,
    ) -> Metric:
        return self.metrics.increment(
            name=name,
            amount=amount,
        )

    def register_health_check(
        self,
        name: str,
        check,
    ) -> None:
        self.health.register(
            name,
            check,
        )

    def check_health(
        self,
    ) -> list[ComponentHealth]:
        return self.health.check_all()
