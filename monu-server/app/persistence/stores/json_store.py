import json
from pathlib import Path
from typing import Any


class JSONStore:
    def __init__(
        self,
        path: str | Path,
    ) -> None:
        self.path = Path(path)

        self.path.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        if not self.path.exists():
            self.path.write_text(
                "{}",
                encoding="utf-8",
            )

    def load(self) -> dict[str, Any]:
        content = self.path.read_text(
            encoding="utf-8",
        )

        if not content.strip():
            return {}

        return json.loads(content)

    def save(
        self,
        data: dict[str, Any],
    ) -> None:
        self.path.write_text(
            json.dumps(
                data,
                indent=2,
                default=str,
            ),
            encoding="utf-8",
        )
