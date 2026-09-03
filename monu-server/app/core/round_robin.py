from collections import defaultdict


class RoundRobinSelector:
    def __init__(self) -> None:
        self._positions: dict[str, int] = defaultdict(int)

    def select(
        self,
        provider: str,
        candidates: list[str],
    ) -> str | None:
        if not candidates:
            return None

        position = self._positions[provider] % len(candidates)
        selected = candidates[position]

        self._positions[provider] = (position + 1) % len(candidates)

        return selected
