from app.security.engines.permission_engine import (
    PermissionEngine,
)
from app.security.models.security import (
    AccessResult,
    Identity,
)
from app.security.services.auth_service import (
    AuthService,
)


class SecurityService:
    def __init__(
        self,
        auth_service: AuthService,
        permission_engine: PermissionEngine,
    ) -> None:
        self.auth_service = auth_service
        self.permission_engine = permission_engine

    def authorize(
        self,
        api_key: str,
        permission: str,
    ) -> AccessResult:
        identity = self.auth_service.authenticate(
            api_key
        )

        if identity is None:
            return AccessResult(
                allowed=False,
                identity_id="anonymous",
                permission=permission,
                reason="Invalid API key",
            )

        allowed = (
            self.permission_engine.has_permission(
                identity,
                permission,
            )
        )

        return AccessResult(
            allowed=allowed,
            identity_id=identity.identity_id,
            permission=permission,
            reason=(
                "Access granted"
                if allowed
                else "Permission denied"
            ),
        )
