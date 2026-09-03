from typing import Any


class ContextEngine:
    def build(
        self,
        content: str,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        return {
            "content": content,
            "metadata": metadata or {},
            "content_length": len(content),
        }
