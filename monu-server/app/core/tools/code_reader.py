from pathlib import Path
from typing import Any


class CodeReader:
    """
    MONU's codebase inspection capability.

    MONU can inspect:
    - Python files
    - API source files
    - Server source files
    - Project directory structures
    """

    CODE_SUFFIXES = {
        ".py",
        ".js",
        ".ts",
        ".tsx",
        ".jsx",
        ".json",
        ".yaml",
        ".yml",
        ".toml",
        ".md",
        ".txt",
        ".html",
        ".css",
        ".sql",
        ".sh",
    }

    def read_code(
        self,
        path: str,
    ) -> dict[str, Any]:
        target = Path(path)

        if not target.exists():
            return {
                "success": False,
                "error": "Code file does not exist",
                "path": str(target),
            }

        if not target.is_file():
            return {
                "success": False,
                "error": "Path is not a file",
                "path": str(target),
            }

        try:
            content = target.read_text(
                encoding="utf-8",
                errors="replace",
            )

            lines = content.splitlines()

            return {
                "success": True,
                "path": str(target),
                "content": content,
                "line_count": len(lines),
                "size": target.stat().st_size,
                "suffix": target.suffix,
            }

        except Exception as exc:
            return {
                "success": False,
                "error": str(exc),
                "path": str(target),
            }

    def inspect_project(
        self,
        root: str,
    ) -> dict[str, Any]:
        base = Path(root)

        if not base.exists():
            return {
                "success": False,
                "error": "Project path does not exist",
            }

        files: list[dict[str, Any]] = []

        try:
            for item in base.rglob("*"):
                if item.is_file():
                    files.append(
                        {
                            "path": str(item),
                            "suffix": item.suffix,
                            "is_code": (
                                item.suffix
                                in self.CODE_SUFFIXES
                            ),
                            "size": item.stat().st_size,
                        }
                    )

            return {
                "success": True,
                "root": str(base),
                "files": files,
                "file_count": len(files),
            }

        except Exception as exc:
            return {
                "success": False,
                "error": str(exc),
            }
