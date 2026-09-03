from pathlib import Path
from typing import Any


class FileTool:
    """
    MONU's basic file inspection tool.

    Allows controlled reading and inspection of files.
    """

    def read_file(
        self,
        path: str,
    ) -> dict[str, Any]:
        target = Path(path)

        if not target.exists():
            return {
                "success": False,
                "error": "File does not exist",
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

            return {
                "success": True,
                "path": str(target),
                "content": content,
                "size": target.stat().st_size,
            }

        except Exception as exc:
            return {
                "success": False,
                "error": str(exc),
                "path": str(target),
            }

    def list_directory(
        self,
        path: str,
        recursive: bool = False,
    ) -> dict[str, Any]:
        target = Path(path)

        if not target.exists():
            return {
                "success": False,
                "error": "Directory does not exist",
                "path": str(target),
            }

        if not target.is_dir():
            return {
                "success": False,
                "error": "Path is not a directory",
                "path": str(target),
            }

        try:
            if recursive:
                items = [
                    str(item)
                    for item in target.rglob("*")
                ]
            else:
                items = [
                    str(item)
                    for item in target.iterdir()
                ]

            return {
                "success": True,
                "path": str(target),
                "items": items,
                "count": len(items),
            }

        except Exception as exc:
            return {
                "success": False,
                "error": str(exc),
                "path": str(target),
            }
