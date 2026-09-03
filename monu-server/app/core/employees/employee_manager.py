from typing import Any

from app.schemas.task_types import TaskType


class EmployeeManager:
    """
    Selects the most appropriate AI Employee
    for a task.
    """

    EMPLOYEE_MAP: dict[TaskType, str] = {
        TaskType.RESEARCH: "research_employee",
        TaskType.CODING: "software_employee",
        TaskType.FILE_OPERATION: "software_employee",
        TaskType.PROJECT_OPERATION: "project_employee",
        TaskType.AUTOMATION: "automation_employee",
        TaskType.MEDIA_GENERATION: "media_employee",
        TaskType.SYSTEM_OPERATION: "system_employee",
        TaskType.ECONOMIC_ANALYSIS: "data_employee",
    }

    def select_employee(
        self,
        task_type: TaskType,
    ) -> str:
        return self.EMPLOYEE_MAP.get(
            task_type,
            "general_employee",
        )

    def delegate(
        self,
        task_type: TaskType,
        content: str,
    ) -> dict[str, Any]:
        employee = self.select_employee(task_type)

        return {
            "employee": employee,
            "task_type": task_type.value,
            "content": content,
            "assigned": True,
        }
