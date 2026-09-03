from app.config import (
    ConfigService,
    FeatureFlags,
    Settings,
)


def test_config_system() -> None:
    settings = Settings(
        app_name="MONU Test",
        environment="testing",
        debug=True,
        host="127.0.0.1",
        port=9000,
        version="1.0.0-test",
    )

    features = FeatureFlags()

    service = ConfigService(
        settings=settings,
        features=features,
    )

    loaded = service.get_settings()

    assert loaded.app_name == "MONU Test"
    assert loaded.environment == "testing"
    assert loaded.debug is True
    assert loaded.port == 9000

    assert (
        service.is_feature_enabled(
            "memory_v2"
        )
        is False
    )

    service.set_feature(
        "memory_v2",
        True,
    )

    assert (
        service.is_feature_enabled(
            "memory_v2"
        )
        is True
    )
