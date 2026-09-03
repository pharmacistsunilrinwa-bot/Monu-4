from app.config.models.features import FeatureFlags
from app.config.models.settings import Settings
from app.config.services.config_validator import (
    ConfigValidator,
)


class ConfigService:
    def __init__(
        self,
        settings: Settings | None = None,
        features: FeatureFlags | None = None,
    ) -> None:
        self.settings = settings or Settings()
        self.features = features or FeatureFlags()

        self.validator = ConfigValidator()

        self.validator.validate(
            self.settings
        )

    def get_settings(
        self,
    ) -> Settings:
        return self.settings

    def is_feature_enabled(
        self,
        name: str,
    ) -> bool:
        return self.features.enabled(name)

    def set_feature(
        self,
        name: str,
        enabled: bool,
    ) -> None:
        self.features.set(
            name,
            enabled,
        )
