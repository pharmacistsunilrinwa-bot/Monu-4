from app.schemas.task_types import TaskType


class Planner:
    def create_plan(self, task_type: TaskType, content: str) -> list[str]:
        base_plan = [
            "understand_request",
            "select_capability",
        ]

        task_specific_steps: dict[TaskType, list[str]] = {
            TaskType.RESEARCH: [
                "collect_sources",
                "analyze_information",
                "verify_information",
            ],
            TaskType.CODING: [
                "inspect_code_context",
                "design_solution",
                "generate_change",
                "verify_change",
            ],
            TaskType.FILE_OPERATION: [
                "validate_file_operation",
                "execute_file_operation",
            ],
            TaskType.SYSTEM_OPERATION: [
                "validate_system_operation",
                "check_authorization",
                "execute_operation",
            ],
            TaskType.AUTOMATION: [
                "define_automation",
                "validate_schedule",
            ],
        }

        plan = list(base_plan)
        plan.extend(task_specific_steps.get(task_type, ["execute_request"]))
        plan.append("verify_result")

        return plan
