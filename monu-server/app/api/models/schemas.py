from typing import Any

from pydantic import BaseModel, Field


class MemoryCreateRequest(BaseModel):
    content: str = Field(min_length=1)
    importance: float = Field(
        default=0.5,
        ge=0.0,
        le=1.0,
    )
    metadata: dict[str, Any] = Field(
        default_factory=dict
    )


class MemoryRecallRequest(BaseModel):
    query: str = Field(min_length=1)
    limit: int = Field(
        default=5,
        ge=1,
        le=100,
    )


class ResearchRequest(BaseModel):
    query: str = Field(min_length=1)
    source_type: str | None = None


class ToolExecuteRequest(BaseModel):
    arguments: dict[str, Any] = Field(
        default_factory=dict
    )
