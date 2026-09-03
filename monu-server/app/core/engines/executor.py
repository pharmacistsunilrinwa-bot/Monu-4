from pathlib import Path

from app.core.engines.system_awareness import (
    SystemAwarenessEngine,
)
from app.core.models.result import ExecutionResult


class Executor:
    """
    Executes authorized local MONU operations.
    """

    def __init__(self) -> None:
        self.project_root = Path.cwd()
        self.system_awareness = SystemAwarenessEngine(
            project_root=self.project_root
        )

    async def execute(
        self,
        route: str,
        content: str,
        plan: list[str],
        action: str | None = None,
        path: str | None = None,
    ) -> ExecutionResult:

        if action == "system_awareness":
            result = self.system_awareness.capability_summary()

            return ExecutionResult(
                success=result.get("success", False),
                output=result,
                message="System awareness inspection completed",
            )

        if action in (
            "read_code",
            "read_file",
        ):
            return self._read_file(path)

        if action == "list_directory":
            return self._list_directory(path)

        if action == "inspect_project":
            return self._inspect_project(path)

        return ExecutionResult(
            success=True,
            output={
                "route": route,
                "content": content,
                "executed_plan": plan,
            },
            message="Core execution completed",
        )

    def _resolve_path(
        self,
        path: str | None,
    ) -> Path:
        if not path:
            return self.project_root

        candidate = Path(path).expanduser()

        if not candidate.is_absolute():
            candidate = (
                self.project_root / candidate
            )

        return candidate.resolve()

    def _read_file(
        self,
        path: str | None,
    ) -> ExecutionResult:
        if not path:
            return ExecutionResult(
                success=False,
                output=None,
                message="No file path provided",
            )

        target = self._resolve_path(path)

        if not target.exists():
            return ExecutionResult(
                success=False,
                output=None,
                message=f"File not found: {path}",
            )

        if not target.is_file():
            return ExecutionResult(
                success=False,
                output=None,
                message=f"Path is not a file: {path}",
            )

        try:
            content = target.read_text(
                encoding="utf-8"
            )

            return ExecutionResult(
                success=True,
                output={
                    "success": True,
                    "path": str(
                        target.relative_to(
                            self.project_root
                        )
                    ),
                    "content": content,
                    "line_count": len(
                        content.splitlines()
                    ),
                    "size": target.stat().st_size,
                    "suffix": target.suffix,
                },
                message="Code inspection completed",
            )

        except Exception as error:
            return ExecutionResult(
                success=False,
                output=None,
                message=str(error),
            )

    def _list_directory(
        self,
        path: str | None,
    ) -> ExecutionResult:
        target = self._resolve_path(path)

        if not target.exists():
            return ExecutionResult(
                success=False,
                output=None,
                message=f"Directory not found: {path}",
            )

        if not target.is_dir():
            return ExecutionResult(
                success=False,
                output=None,
                message=f"Path is not a directory: {path}",
            )

        items = []

        for item in sorted(target.iterdir()):
            items.append(
                {
                    "name": item.name,
                    "type": (
                        "directory"
                        if item.is_dir()
                        else "file"
                    ),
                }
            )

        return ExecutionResult(
            success=True,
            output={
                "success": True,
                "path": str(
                    target.relative_to(
                        self.project_root
                    )
                ),
                "items": items,
                "count": len(items),
            },
            message="Directory inspection completed",
        )

    def _inspect_project(
        self,
        path: str | None,
    ) -> ExecutionResult:
        target = self._resolve_path(path)

        if not target.exists():
            return ExecutionResult(
                success=False,
                output=None,
                message=f"Project path not found: {path}",
            )

        if not target.is_dir():
            return ExecutionResult(
                success=False,
                output=None,
                message=f"Project path is not a directory: {path}",
            )

        directories = []
        files = []

        for item in sorted(target.iterdir()):
            if item.is_dir():
                directories.append(item.name)
            else:
                files.append(item.name)

        try:
            relative_path = str(
                target.relative_to(
                    self.project_root
                )
            )
        except ValueError:
            relative_path = str(target)

        return ExecutionResult(
            success=True,
            output={
                "success": True,
                "path": relative_path,
                "directories": directories,
                "files": files,
                "directory_count": len(
                    directories
                ),
                "file_count": len(files),
            },
            message="Project inspection completed",
        )
