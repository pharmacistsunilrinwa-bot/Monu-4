from app.system_health.models.system_status import (
    SystemStatus,
)


class SystemHealthService:
    def check(
        self,
        components: dict[str, bool],
    ) -> SystemStatus:
        total = len(components)

        active = sum(
            1
            for value in components.values()
            if value
        )

        healthy = (
            total > 0
            and active == total
        )

        readiness = (
            "ready"
            if healthy
            else "degraded"
        )

        return SystemStatus(
            healthy=healthy,
            total_components=total,
            active_components=active,
            readiness=readiness,
        )
