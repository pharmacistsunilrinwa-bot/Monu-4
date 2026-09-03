from app.schemas.task_types import TaskType


class CapabilityRouter:
    ROUTES: dict[TaskType, str] = {
        TaskType.CONVERSATION: "core",
        TaskType.QUESTION: "knowledge",
        TaskType.RESEARCH: "research",
        TaskType.CODING: "coding",
        TaskType.FILE_OPERATION: "tools",
        TaskType.PROJECT_OPERATION: "workflow",
        TaskType.AUTOMATION: "workflow",
        TaskType.MEDIA_GENERATION: "media",
        TaskType.SYSTEM_OPERATION: "system",
        TaskType.SCHEDULED_TASK: "scheduler",
        TaskType.ECONOMIC_ANALYSIS: "analysis",
        TaskType.EMERGENCY_OPERATION: "emergency",
    }

    def route(self, task_type: TaskType) -> str:
        return self.ROUTES.get(task_type, "core")
