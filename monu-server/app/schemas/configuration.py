from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class ConfigurationRecord:
    key: str
    value: Any
    source: str
    version: str | None = None
    sensitive: bool = False
