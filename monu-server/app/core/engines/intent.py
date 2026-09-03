from app.schemas.task_types import TaskType


class IntentEngine:
    KEYWORDS: dict[TaskType, tuple[str, ...]] = {
        TaskType.RESEARCH: (
            "research",
            "search",
            "find",
            "analyze",
            "investigate",
        ),
        TaskType.CODING: (
            "code",
            "python",
            "program",
            "bug",
            "debug",
            "function",
        ),
        TaskType.FILE_OPERATION: (
            "file",
            "folder",
            "directory",
            "read",
            "write",
        ),
        TaskType.AUTOMATION: (
            "automate",
            "automation",
            "schedule",
            "repeat",
        ),
        TaskType.MEDIA_GENERATION: (
            "image",
            "video",
            "audio",
            "generate media",
        ),
        TaskType.SYSTEM_OPERATION: (
            "system",
            "server",
            "service",
            "process",
        ),
        TaskType.QUESTION: (
            "what",
            "why",
            "when",
            "where",
            "how",
        ),
    }

    def classify(self, content: str) -> TaskType:
        normalized = content.lower().strip()

        if not normalized:
            return TaskType.CONVERSATION

        for task_type, keywords in self.KEYWORDS.items():
            if any(keyword in normalized for keyword in keywords):
                return task_type

        return TaskType.CONVERSATION

    def detect_intent(self, content: str) -> str:
        task_type = self.classify(content)
        return task_type.value
