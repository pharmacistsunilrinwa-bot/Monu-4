from typing import Any


class PermissionEngine:
    """
    Basic authorization classification.

    Level 1:
        Safe / read-only actions

    Level 2:
        Controlled actions

    Level 3:
        Owner approval required
    """

    HIGH_RISK_KEYWORDS = (
        "delete",
        "remove",
        "destroy",
        "production deploy",
        "deploy production",
        "payment",
        "transfer money",
        "financial transaction",
        "credential",
        "secret",
        "permission change",
        "access change",
    )

    CONTROLLED_KEYWORDS = (
        "write",
        "modify",
        "edit",
        "create",
        "install",
        "run",
        "execute",
    )

    def check(
        self,
        content: str,
    ) -> dict[str, Any]:
        normalized = content.lower()

        if any(
            keyword in normalized
            for keyword in self.HIGH_RISK_KEYWORDS
        ):
            return {
                "level": 3,
                "approved": False,
                "requires_owner_approval": True,
                "reason": "High-risk action detected",
            }

        if any(
            keyword in normalized
            for keyword in self.CONTROLLED_KEYWORDS
        ):
            return {
                "level": 2,
                "approved": True,
                "requires_owner_approval": False,
                "reason": "Controlled action",
            }

        return {
            "level": 1,
            "approved": True,
            "requires_owner_approval": False,
            "reason": "Safe action",
        }
