from typing import Any


class ConflictDetector:
    def detect(
        self,
        findings: list[dict[str, Any]],
    ) -> list[dict[str, Any]]:
        conflicts: list[dict[str, Any]] = []
        seen: dict[str, Any] = {}

        for finding in findings:
            claim = str(
                finding.get("claim", "")
            ).strip()

            if not claim:
                continue

            value = finding.get("value")

            if claim in seen and seen[claim] != value:
                conflicts.append(
                    {
                        "claim": claim,
                        "existing_value": seen[claim],
                        "conflicting_value": value,
                    }
                )
            else:
                seen[claim] = value

        return conflicts
