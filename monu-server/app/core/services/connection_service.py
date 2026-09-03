from datetime import datetime, timezone
from typing import Any

from app.monu import MonuSystem


class ConnectionService:
    """
    Provides an immediate server connection response
    independent from MONU command execution.
    """

    def __init__(
        self,
        monu_system: MonuSystem,
    ) -> None:
        self.monu_system = monu_system

    def connect(
        self,
        client_name: str | None = None,
    ) -> dict[str, Any]:
        timestamp = datetime.now(
            timezone.utc
        ).isoformat()

        greeting_name = (
            client_name.strip()
            if client_name and client_name.strip()
            else "Friend"
        )

        health_report = self._build_health_report()

        return {
            "connected": True,
            "message": (
                f"Hello, {greeting_name}. "
                "MONU server is connected and ready."
            ),
            "system": "MONU",
            "connection_time": timestamp,
            "health_report": health_report,
        }

    def _build_health_report(
        self,
    ) -> dict[str, Any]:
        services = self.monu_system.services()

        components = {
            name: service is not None
            for name, service in services.items()
        }

        healthy_components = sum(
            1
            for status in components.values()
            if status
        )

        total_components = len(components)

        system_health = self.monu_system.health()

        return {
            "server": {
                "status": "running",
                "reachable": True,
            },
            "api": {
                "status": "available",
            },
            "system_health": {
                "healthy": system_health.healthy,
                "readiness": system_health.readiness,
                "total_components": (
                    system_health.total_components
                ),
                "active_components": (
                    system_health.active_components
                ),
            },
            "services": {
                "total": total_components,
                "active": healthy_components,
                "inactive": (
                    total_components
                    - healthy_components
                ),
                "components": components,
            },
        }
