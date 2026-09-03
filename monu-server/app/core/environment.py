from enum import StrEnum


class Environment(StrEnum):
    DEVELOPMENT = "development"
    TESTING = "testing"
    STAGING = "staging"
    PRODUCTION = "production"


def normalize_environment(value: str) -> Environment:
    normalized = value.strip().lower()

    try:
        return Environment(normalized)
    except ValueError as error:
        allowed = ", ".join(item.value for item in Environment)
        raise ValueError(
            f"Invalid MONU environment: {value}. Allowed values: {allowed}"
        ) from error
