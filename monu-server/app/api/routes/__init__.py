from app.api.routes.health import router as health_router
from app.api.routes.memory import router as memory_router
from app.api.routes.research import router as research_router
from app.api.routes.tools import router as tools_router

__all__ = [
    "health_router",
    "memory_router",
    "research_router",
    "tools_router",
]
