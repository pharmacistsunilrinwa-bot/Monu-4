import pytest

from app.config import (
    ConfigService,
    Settings,
)


def test_invalid_environment() -> None:
    settings = Settings(
        environment="invalid"
    )

    with pytest.raises(ValueError):
        ConfigService(
            settings=settings
        )


def test_invalid_port() -> None:
    settings = Settings(
        port=70000
    )

    with pytest.raises(ValueError):
        ConfigService(
            settings=settings
        )


def test_valid_production_config() -> None:
    settings = Settings(
        app_name="MONU",
        environment="production",
        port=8000,
    )

    service = ConfigService(
        settings=settings
    )

    assert (
        service.get_settings().environment
        == "production"
    )
