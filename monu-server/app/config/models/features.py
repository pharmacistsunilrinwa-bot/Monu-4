from dataclasses import dataclass, field


@dataclass
class FeatureFlags:
    flags: dict[str, bool] = field(
        default_factory=dict
    )

    def enabled(
        self,
        name: str,
    ) -> bool:
        return self.flags.get(
            name,
            False,
        )

    def set(
        self,
        name: str,
        enabled: bool,
    ) -> None:
        self.flags[name] = enabled
