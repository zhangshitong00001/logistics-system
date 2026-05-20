from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import get_settings
from app.core.database import engine, Base
from app.models import *  # noqa: F401, F403 — ensure all models loaded

from app.api import auth
from app.api import consolidation
from app.api import sorting
from app.api import files
from app.api import transport
from app.api import customs
from app.api import warehouse
from app.api import delivery
from app.api import sign
from app.api import tracking
from app.api import reconciliation
from app.api import settlement
from app.api import payment
from app.api import alert
from app.api import analytics
from app.api import permission
from app.api import billing

settings = get_settings()


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        docs_url="/api/docs",
        redoc_url="/api/redoc",
    )

    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Register routers
    app.include_router(auth.router)
    app.include_router(consolidation.router)
    app.include_router(sorting.router)
    app.include_router(files.router)
    app.include_router(transport.router)
    app.include_router(customs.router)
    app.include_router(warehouse.router)
    app.include_router(delivery.router)
    app.include_router(sign.router)
    app.include_router(tracking.router)
    app.include_router(reconciliation.router)
    app.include_router(settlement.router)
    app.include_router(payment.router)
    app.include_router(alert.router)
    app.include_router(analytics.router)
    app.include_router(permission.router)
    app.include_router(billing.router)

    @app.get("/api/health")
    def health():
        return {"status": "ok", "app": settings.APP_NAME, "version": settings.APP_VERSION}

    return app


app = create_app()


@app.on_event("startup")
def on_startup():
    """Create all tables on startup"""
    Base.metadata.create_all(bind=engine)
