import os
import re
from collections import defaultdict


CREDENTIAL_PATTERN = re.compile(
    r"^(?P<provider>[A-Z0-9_]+)_(?P<kind>API_KEY|TOKEN)_(?P<index>[0-9]+)$"
)


def discover_credentials() -> dict[str, list[str]]:
    providers: dict[str, list[tuple[int, str]]] = defaultdict(list)

    for name in os.environ:
        match = CREDENTIAL_PATTERN.match(name)

        if not match:
            continue

        provider = match.group("provider")
        index = int(match.group("index"))

        value = os.getenv(name, "")

        if not value:
            continue

        providers[provider].append((index, name))

    discovered: dict[str, list[str]] = {}

    for provider, items in providers.items():
        items.sort(key=lambda item: item[0])
        discovered[provider] = [name for _, name in items]

    return discovered


def discover_provider_credentials(provider: str) -> list[str]:
    normalized = provider.strip().upper()
    credentials = discover_credentials()
    return credentials.get(normalized, [])
