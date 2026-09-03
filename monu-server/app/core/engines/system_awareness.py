from pathlib import Path
from typing import Any


class SystemAwarenessEngine:
    """
    Inspects the MONU project structure and builds
    a capability map from discovered project modules.
    """

    CAPABILITY_DIRECTORIES = {
        "actions": "Action Operations",
        "agents": "AI Agents",
        "ai": "AI Integration",
        "analytics": "Analytics",
        "approvals": "Approval Management",
        "autonomy": "Autonomous Operations",
        "clients": "Client Management",
        "core": "Core Intelligence",
        "decisions": "Decision Management",
        "employees": "AI Employee Workforce",
        "execution": "Execution System",
        "feedback": "Feedback System",
        "goals": "Goal Management",
        "income": "Income Operations",
        "integrations": "External Integrations",
        "knowledge": "Knowledge System",
        "learning": "Learning System",
        "leads": "Lead Management",
        "media": "Media Operations",
        "memory": "Memory System",
        "monitoring": "Monitoring",
        "notifications": "Notifications",
        "persistence": "Persistent Storage",
        "projects": "Project Management",
        "proposals": "Proposal Management",
        "providers": "AI Providers",
        "reporting": "Reporting",
        "research": "Research Operations",
        "resilience": "Recovery and Resilience",
        "revenue": "Revenue Operations",
        "security": "Security",
        "strategy": "Strategy",
        "system_health": "System Health",
        "tools": "Tool System",
        "workflows": "Workflow Management",
    }

    def __init__(
        self,
        project_root: str | Path | None = None,
    ) -> None:
        if project_root is None:
            project_root = Path.cwd()

        self.project_root = Path(project_root).resolve()

    def inspect(self) -> dict[str, Any]:
        app_directory = self.project_root / "app"

        if not app_directory.exists():
            return {
                "success": False,
                "error": "Application directory not found",
                "project_root": str(self.project_root),
            }

        directories = []
        capabilities = []
        python_files = []

        for item in sorted(app_directory.iterdir()):
            if item.is_dir():
                directories.append(item.name)

                capability = self.CAPABILITY_DIRECTORIES.get(
                    item.name
                )

                if capability is not None:
                    capabilities.append(
                        {
                            "module": item.name,
                            "capability": capability,
                            "status": "discovered",
                        }
                    )

        for file_path in app_directory.rglob("*.py"):
            if "__pycache__" not in file_path.parts:
                python_files.append(
                    str(
                        file_path.relative_to(
                            self.project_root
                        )
                    )
                )

        return {
            "success": True,
            "project_root": str(self.project_root),
            "application_directory": str(app_directory),
            "directory_count": len(directories),
            "python_file_count": len(python_files),
            "directories": directories,
            "capabilities": capabilities,
            "capability_count": len(capabilities),
        }

    def capability_summary(self) -> dict[str, Any]:
        inspection = self.inspect()

        if not inspection.get("success"):
            return inspection

        return {
            "success": True,
            "system": "MONU",
            "status": "system_inspected",
            "capability_count": inspection[
                "capability_count"
            ],
            "capabilities": inspection[
                "capabilities"
            ],
            "project_root": inspection[
                "project_root"
            ],
        }
