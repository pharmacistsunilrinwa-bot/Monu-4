from enum import StrEnum


class TaskType(StrEnum):
    CONVERSATION = "conversation"
    QUESTION = "question"
    RESEARCH = "research"
    CODING = "coding"
    FILE_OPERATION = "file_operation"
    PROJECT_OPERATION = "project_operation"
    AUTOMATION = "automation"
    MEDIA_GENERATION = "media_generation"
    SYSTEM_OPERATION = "system_operation"
    SCHEDULED_TASK = "scheduled_task"
    ECONOMIC_ANALYSIS = "economic_analysis"
    EMERGENCY_OPERATION = "emergency_operation"
