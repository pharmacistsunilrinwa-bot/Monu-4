from app.security.models.security import Identity
from app.security.services.api_key_manager import (
    APIKeyManager,
)


class AuthService:
    def __init__(
        self,
        key_manager: APIKeyManager,
    ) -> None:
        self.key_manager = key_manager
        self._identities: dict[str, Identity] = {}

    def register(
        self,
        identity: Identity,
    ) -> str:
        self._identities[
            identity.identity_id
        ] = identity

        return self.key_manager.create(
            identity.identity_id
        )

    def authenticate(
        self,
        api_key: str,
    ) -> Identity | None:
        identity_id = self.key_manager.validate(
            api_key
        )

        if identity_id is None:
            return None

        return self._identities.get(
            identity_id
        )
