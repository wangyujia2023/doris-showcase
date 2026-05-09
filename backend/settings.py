"""Doris Showcase - 全局配置"""
from __future__ import annotations

import os
from pathlib import Path
from typing import List


def _load_dotenv_file(path: str = ".env") -> None:
    candidates = [
        Path(path),
        Path.cwd() / path,
        Path(__file__).resolve().parents[1] / path,
    ]
    env_path = next((p for p in candidates if p.exists()), None)
    if not env_path:
        return
    for line in env_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        os.environ.setdefault(key, value)


def _env_bool(key: str, default: str = "false") -> bool:
    return os.getenv(key, default).strip().lower() in {"1", "true", "yes", "on"}


def _env_int(key: str, default: str) -> int:
    try:
        return int(os.getenv(key, default))
    except (TypeError, ValueError):
        return int(default)


class Settings:
    """轻量配置对象，避免依赖 pydantic_settings。

    直接读取环境变量，属性固定存在，适合服务器部署时的稳定加载。
    """

    def __init__(self) -> None:
        _load_dotenv_file()

        # Doris 连接
        self.DORIS_HOST: str = os.getenv("DORIS_HOST", "10.26.20.3")
        self.DORIS_PORT: int = _env_int("DORIS_PORT", "19030")
        self.DORIS_HTTP_PORT: int = _env_int("DORIS_HTTP_PORT", "18030")
        self.DORIS_STREAM_LOAD_HOST: str = os.getenv("DORIS_STREAM_LOAD_HOST", self.DORIS_HOST)
        self.DORIS_STREAM_LOAD_PORT: int = _env_int("DORIS_STREAM_LOAD_PORT", "18041")
        self.DORIS_USER: str = os.getenv("DORIS_USER", "root")
        self.DORIS_PASSWORD: str = os.getenv("DORIS_PASSWORD", "")
        self.DORIS_DATABASE: str = os.getenv("DORIS_DATABASE", "doris_showcase")
        self.DORIS_AI_RESOURCE: str = os.getenv("DORIS_AI_RESOURCE", "")
        self.DB_WARMUP_ON_START: bool = _env_bool("DB_WARMUP_ON_START", "false")
        self.BACKEND_HOST: str = os.getenv("BACKEND_HOST", "0.0.0.0")
        self.BACKEND_PORT: int = _env_int("BACKEND_PORT", "27713")
        self.FRONTEND_HOST: str = os.getenv("FRONTEND_HOST", "0.0.0.0")
        self.FRONTEND_PORT: int = _env_int("FRONTEND_PORT", "5173")
        self.APP_ENV: str = os.getenv("APP_ENV", "dev")
        self.PROJECT_ROOT: str = os.getenv("PROJECT_ROOT", str(Path(__file__).resolve().parents[1]))
        upload_dir = Path(os.getenv("UPLOAD_DIR", str(Path(self.PROJECT_ROOT) / "uploads")))
        self.UPLOAD_DIR: str = str(upload_dir if upload_dir.is_absolute() else Path(self.PROJECT_ROOT) / upload_dir)

        # Doris 4.0 HASP 配置
        self.DORIS_HASP_ENABLED: bool = True

        # CORS / 运行开关
        self.CORS_ORIGINS: List[str] = [
            f"http://localhost:{self.FRONTEND_PORT}",
            "http://localhost:3000",
            f"http://127.0.0.1:{self.FRONTEND_PORT}",
        ]
        self.TELEMETRY_ENABLED: bool = _env_bool("TELEMETRY_ENABLED", "true")
        self.BEHAVIOR_SCAN_DAYS: int = _env_int("BEHAVIOR_SCAN_DAYS", "120")
        self.OPENMETADATA_BASE_URL: str = os.getenv("OPENMETADATA_BASE_URL", "http://10.26.20.3:8585/api")
        self.OPENMETADATA_JWT_TOKEN: str = os.getenv("OPENMETADATA_JWT_TOKEN", "")
        self.LINEAGE_DATABASE: str = os.getenv("LINEAGE_DATABASE", os.getenv("RETAIL_LINEAGE_DB", "lineage_showcase"))
        self.RETAIL_LINEAGE_DB: str = self.LINEAGE_DATABASE  # Backward compatible alias

        # 数据安全（脱敏）
        self.MASK_ID_CARD: bool = True
        self.MASK_PHONE: bool = True
        self.MASK_ACCOUNT: bool = True


settings = Settings()
