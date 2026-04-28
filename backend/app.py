"""
Doris Showcase - FastAPI entrypoint
Start: uvicorn backend.app:app --host 0.0.0.0 --port 27713
"""
import logging
from contextlib import asynccontextmanager

from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from backend.settings import settings
from backend.doris.connect import get_pool, close_pool
from backend.api.routes import router
from backend.middleware.request_logger import RequestLoggerMiddleware
from backend.telemetry.collector import ensure_tables, start_writer, stop_writer

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    if settings.DB_WARMUP_ON_START:
        try:
            await get_pool()
            logger.info("✅ Doris 连接池就绪")
        except Exception as e:
            logger.warning(f"⚠️ Doris 连接失败: {e}")
    else:
        logger.info("ℹ️ 跳过启动预热，Doris 连接池改为按需初始化")

    if settings.TELEMETRY_ENABLED:
        try:
            await ensure_tables()
            start_writer()
            logger.info("✅ Telemetry writer 已启动，sys_logs/sys_spans 已就绪")
        except Exception as e:
            logger.warning(f"⚠️ Telemetry 初始化失败: {e}")
    else:
        logger.info("ℹ️ Telemetry writer 已关闭")
    yield
    if settings.TELEMETRY_ENABLED:
        stop_writer()
    await close_pool()


app = FastAPI(
    title="Doris Showcase",
    description="Scenario showcase platform for Apache Doris, SelectDB and VeloDB",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(RequestLoggerMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Path(settings.UPLOAD_DIR).mkdir(parents=True, exist_ok=True)
app.mount("/api/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")
app.include_router(router, prefix="/api")


@app.get("/")
async def root():
    return {"message": "Doris Showcase API is running", "docs": "/docs"}
