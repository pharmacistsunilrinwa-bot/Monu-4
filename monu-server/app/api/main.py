from fastapi import FastAPI

from app.api.routes import (
    health_router,
    memory_router,
    research_router,
    tools_router,
)
from app.infrastructure.container import (
    ApplicationContainer,
)


def create_app() -> FastAPI:
    app = FastAPI(
        title="MONU Server",
        version="0.9.0",
    )

    app.state.container = ApplicationContainer()

    app.include_router(health_router)
    app.include_router(memory_router)
    app.include_router(research_router)
    app.include_router(tools_router)

    return app


app = create_app()
