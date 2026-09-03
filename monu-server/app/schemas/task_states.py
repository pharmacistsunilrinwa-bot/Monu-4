from enum import StrEnum


class TaskState(StrEnum):
    RECEIVED = "received"
    UNDERSTANDING = "understanding"
    PLANNING = "planning"
    SEARCHING = "searching"
    READING = "reading"
    EXECUTING = "executing"
    WAITING = "waiting"
    VERIFYING = "verifying"
    COMPLETED = "completed"
    FAILED = "failed"
    RECOVERING = "recovering"
    PAUSED = "paused"
    CANCELLED = "cancelled"
