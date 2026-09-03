from dataclasses import dataclass
import os


def get_env_bool(name: str, default: bool = False) -> bool:
    value = os.getenv(name, str(default)).strip().lower()
    return value in {"1", "true", "yes", "on"}


@dataclass(frozen=True)
class Settings:
    app_name: str
    version: str
    environment: str
    debug: bool
    log_level: str
    host: str
    port: int
    enable_memory: bool
    enable_providers: bool
    enable_tools: bool
    enable_agents: bool
    config_path: str

    @classmethod
    def from_environment(cls) -> "Settings":
        return cls(
            app_name=os.getenv("MONU_APP_NAME", "MONU Server"),
            version=os.getenv("MONU_VERSION", "0.1.0"),
            environment=os.getenv("MONU_ENV", "development"),
            debug=get_env_bool("MONU_DEBUG", False),
            log_level=os.getenv("MONU_LOG_LEVEL", "INFO").upper(),
            host=os.getenv("MONU_HOST", "0.0.0.0"),
            port=int(os.getenv("MONU_PORT", "8000")),
            enable_memory=get_env_bool("MONU_ENABLE_MEMORY", True),
            enable_providers=get_env_bool("MONU_ENABLE_PROVIDERS", True),
            enable_tools=get_env_bool("MONU_ENABLE_TOOLS", True),
            enable_agents=get_env_bool("MONU_ENABLE_AGENTS", True),
            config_path=os.getenv("MONU_CONFIG_PATH", "configs"),
        )


settings = Settings.from_environment()
