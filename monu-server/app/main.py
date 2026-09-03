from typing import Any

from fastapi import FastAPI
from pydantic import BaseModel

from app import MonuSystem
from app.core.services.monu_service import MonuService
from app.core.services.connection_service import ConnectionService


monu = MonuSystem()
monu_service = MonuService()
connection_service = ConnectionService(monu)


app = FastAPI(
    title="MONU Server",
    description="MONU Autonomous AI Assistant Employee System",
    version="2.0.0",
)


class MonuConnection(BaseModel):
    client_name: str | None = None


class MonuCommand(BaseModel):
    content: str
    metadata: dict[str, Any] = {}


@app.get("/")
def root() -> dict[str, object]:
    return {
        "name": "MONU Server",
        "status": "running",
        "services": monu.service_count(),
    }


@app.get("/health")
def health() -> dict[str, object]:
    status = monu.health()

    return {
        "healthy": status.healthy,
        "readiness": status.readiness,
        "total_components": status.total_components,
        "active_components": status.active_components,
    }


@app.get("/services")
def services() -> dict[str, object]:
    return {
        "count": monu.service_count(),
        "services": list(monu.services().keys()),
    }




@app.post("/connect")
async def connect(
    request: MonuConnection,
) -> dict[str, Any]:
    return connection_service.connect(
        client_name=request.client_name,
    )


@app.post("/command")
async def command(
    request: MonuCommand,
) -> dict[str, Any]:
    context = await monu_service.handle(
        content=request.content,
        metadata=request.metadata,
    )

    return {
        "task_id": context.task_id,
        "content": context.content,
        "intent": context.intent,
        "task_type": context.task_type.value,
        "state": context.state.value,
        "plan": context.plan,
        "route": context.route,
        "result": (
            context.result.output
            if context.result is not None
            else None
        ),
        "message": (
            context.result.message
            if context.result is not None
            else None
        ),
        "error": context.error,
        "metadata": context.metadata,
    }
