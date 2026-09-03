from app.security.models.security import Identity


class PermissionEngine:
    ROLE_PERMISSIONS: dict[str, set[str]] = {
        "admin": {
            "*",
        },
        "developer": {
            "read",
            "write",
            "execute",
        },
        "user": {
            "read",
        },
    }

    def has_permission(
        self,
        identity: Identity,
        permission: str,
    ) -> bool:
        permissions = set(
            identity.permissions
        )

        permissions.update(
            self.ROLE_PERMISSIONS.get(
                identity.role,
                set(),
            )
        )

        return (
            "*" in permissions
            or permission in permissions
        )
