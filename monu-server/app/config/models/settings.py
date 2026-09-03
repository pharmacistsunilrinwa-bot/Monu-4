from dataclasses import dataclass, field
import os


@dataclass
class Settings:
    app_name: str = field(
        default_factory=lambda: os.getenv(
            "MONU_APP_NAME",
            "MONU Server",
        )
    )

    environment: str = field(
        default_factory=lambda: os.getenv(
            "MONU_ENV",
            "development",
        )
    )

    debug: bool = field(
        default_factory=lambda: os.getenv(
            "MONU_DEBUG",
            "false",
        ).lower() == "true"
    )

    host: str = field(
        default_factory=lambda: os.getenv(
            "MONU_HOST",
            "127.0.0.1",
        )
    )

    port: int = field(
        default_factory=lambda: int(
            os.getenv(
                "MONU_PORT",
                "8000",
            )
        )
    )

    version: str = field(
        default_factory=lambda: os.getenv(
            "MONU_VERSION",
            "1.0.0",
        )
    )
