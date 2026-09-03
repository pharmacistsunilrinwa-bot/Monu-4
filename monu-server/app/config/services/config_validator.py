from app.config.models.settings import Settings


class ConfigValidator:
    VALID_ENVIRONMENTS = {
        "development",
        "testing",
        "production",
    }

    def validate(
        self,
        settings: Settings,
    ) -> None:
        if not settings.app_name.strip():
            raise ValueError(
                "Application name cannot be empty"
            )

        if (
            settings.environment
            not in self.VALID_ENVIRONMENTS
        ):
            raise ValueError(
                "Invalid environment: "
                f"{settings.environment}"
            )

        if not (
            1 <= settings.port <= 65535
        ):
            raise ValueError(
                "Port must be between "
                "1 and 65535"
            )
