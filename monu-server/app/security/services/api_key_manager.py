import secrets


class APIKeyManager:
    def __init__(self) -> None:
        self._keys: dict[str, str] = {}

    def create(
        self,
        identity_id: str,
    ) -> str:
        key = secrets.token_urlsafe(32)

        self._keys[key] = identity_id

        return key

    def validate(
        self,
        key: str,
    ) -> str | None:
        return self._keys.get(key)

    def revoke(
        self,
        key: str,
    ) -> None:
        self._keys.pop(key, None)
