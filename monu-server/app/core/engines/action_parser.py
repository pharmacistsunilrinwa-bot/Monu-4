import re
from typing import Any


class ActionParser:
    """
    Converts natural-language requests into executable MONU actions.
    """

    FILE_PATTERN = re.compile(
        r'(?<!\S)(?:~?/)?(?:[\w.-]+/)*[\w.-]+\.(?:py|js|ts|json|yaml|yml|md|txt)(?!\S)'
    )

    DIRECTORY_PATTERN = re.compile(
        r'(?<!\S)(?:~?/)?(?:[\w.-]+/)+[\w.-]+/?(?!\S)'
    )

    def parse(
        self,
        content: str,
    ) -> dict[str, Any]:
        normalized = content.lower().strip()
        path = self._extract_path(content)

        if any(
            phrase in normalized
            for phrase in (
                "read code",
                "read the code",
                "read source code",
                "inspect code",
            )
        ):
            return {
                "action": "read_code",
                "path": path,
            }

        if any(
            phrase in normalized
            for phrase in (
                "inspect project",
                "project inspect",
                "project structure",
                "scan project",
                "analyze project",
            )
        ):
            return {
                "action": "inspect_project",
                "path": path,
            }

        if any(
            phrase in normalized
            for phrase in (
                "what can you do",
                "show capabilities",
                "system capabilities",
                "inspect yourself",
                "system status",
                "show system information",
                "show your features",
            )
        ):
            return {
                "action": "system_awareness",
                "path": path,
            }

        if any(
            phrase in normalized
            for phrase in (
                "read file",
                "file read",
                "inspect file",
            )
        ):
            return {
                "action": "read_file",
                "path": path,
            }

        if any(
            phrase in normalized
            for phrase in (
                "list directory",
                "show directory",
                "list folder",
                "show folder",
                "inspect directory",
            )
        ):
            return {
                "action": "list_directory",
                "path": path,
            }

        return {
            "action": None,
            "path": path,
        }

    def _extract_path(
        self,
        content: str,
    ) -> str | None:
        file_matches = self.FILE_PATTERN.findall(content)

        if file_matches:
            return file_matches[-1].rstrip("/")

        directory_matches = self.DIRECTORY_PATTERN.findall(content)

        if directory_matches:
            return directory_matches[-1].rstrip("/")

        return None
