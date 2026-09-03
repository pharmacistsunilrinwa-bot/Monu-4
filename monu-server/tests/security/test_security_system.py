from app.security import (
    APIKeyManager,
    AuthService,
    Identity,
    PermissionEngine,
    SecurityService,
)


def test_security_system() -> None:
    key_manager = APIKeyManager()

    auth_service = AuthService(
        key_manager
    )

    permission_engine = PermissionEngine()

    security = SecurityService(
        auth_service,
        permission_engine,
    )

    admin = Identity(
        identity_id="admin-1",
        role="admin",
    )

    user = Identity(
        identity_id="user-1",
        role="user",
    )

    admin_key = auth_service.register(admin)
    user_key = auth_service.register(user)

    admin_result = security.authorize(
        admin_key,
        "delete",
    )

    assert admin_result.allowed is True

    user_read = security.authorize(
        user_key,
        "read",
    )

    assert user_read.allowed is True

    user_write = security.authorize(
        user_key,
        "write",
    )

    assert user_write.allowed is False

    invalid = security.authorize(
        "invalid-key",
        "read",
    )

    assert invalid.allowed is False
