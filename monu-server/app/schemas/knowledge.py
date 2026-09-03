from dataclasses import dataclass
from enum import StrEnum


class KnowledgeSourceType(StrEnum):
    WEB = "web"
    API = "api"
    DATABASE = "database"
    DOCUMENT = "document"
    MEMORY = "memory"


@dataclass
class KnowledgeSource:
    source_id: str
    source_type: KnowledgeSourceType
    name: str
    reliability: float = 0.5
