import builtins

from app.contracts.tool import Tool


class ToolRegistry:
    def __init__(self) -> None:
        self._tools: dict[str, Tool] = {}

    def register(
        self,
        tool: Tool,
    ) -> None:
        name = tool.name.strip().lower()

        if not name:
            raise ValueError(
                "Tool name cannot be empty"
            )

        self._tools[name] = tool

    def unregister(
        self,
        name: str,
    ) -> None:
        self._tools.pop(
            name.strip().lower(),
            None,
        )

    def get(
        self,
        name: str,
    ) -> Tool | None:
        return self._tools.get(
            name.strip().lower()
        )

    def list(
        self,
    ) -> builtins.list[Tool]:
        return builtins.list(
            self._tools.values()
        )
