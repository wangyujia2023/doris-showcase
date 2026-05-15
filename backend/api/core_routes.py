import asyncio
import os
import re
from pathlib import Path
from urllib.parse import urlparse

import aiomysql
import httpx
from fastapi import APIRouter, Query, HTTPException
from fastapi.responses import StreamingResponse
from functools import lru_cache
from pydantic import BaseModel
from typing import List, Optional, Dict

from backend.service.user_service import UserService, SegmentService
from backend.service.behavior_service import BehaviorService
from backend.service.dashboard_service import DashboardService
from backend.service.management_dashboard import ManagementDashboard
from backend.service.tag_analysis_service import TagAnalysisService
from backend.service.report_service import ReportService
from backend.service.metrics_service import MetricsService
from backend.service.observe_service import ObserveService
from backend.doris.connect import close_pool, ping, get_doris_version

router = APIRouter()

PROJECT_ROOT = Path(__file__).resolve().parents[2]
ENV_FILE = PROJECT_ROOT / ".env"
SAFE_ENV_KEYS = {
    "BACKEND_HOST",
    "BACKEND_PORT",
    "BACKEND_PROXY_HOST",
    "FRONTEND_HOST",
    "FRONTEND_PORT",
    "DORIS_HOST",
    "DORIS_PORT",
    "DORIS_HTTP_PORT",
    "DORIS_STREAM_LOAD_HOST",
    "DORIS_STREAM_LOAD_PORT",
    "DORIS_USER",
    "DORIS_PASSWORD",
    "DORIS_DATABASE",
    "DORIS_AI_RESOURCE",
    "DORIS_AI_PROVIDER",
    "DORIS_AI_MODEL",
    "DORIS_AI_ENDPOINT",
    "DORIS_AI_API_KEY",
    "LINEAGE_DATABASE",
    "UPLOAD_DIR",
    "LOG_DIR",
    "OPENMETADATA_BASE_URL",
    "OPENMETADATA_JWT_TOKEN",
    "INIT_DATABASE_ON_DEPLOY",
    "DROP_DATABASES",
}


class InitConfigPayload(BaseModel):
    backend_host: str = "0.0.0.0"
    backend_port: int = 27713
    backend_proxy_host: str = "127.0.0.1"
    frontend_host: str = "0.0.0.0"
    frontend_port: int = 5173
    doris_host: str
    doris_port: int
    doris_http_port: int = 18030
    doris_user: str = "root"
    doris_password: str = ""
    doris_database: str = "doris_showcase"
    doris_ai_resource: str = ""
    doris_ai_provider: str = ""
    doris_ai_model: str = ""
    doris_ai_endpoint: str = ""
    doris_ai_api_key: str = ""
    lineage_database: str = ""
    upload_dir: str = "./uploads"
    log_dir: str = "./logs"
    openmetadata_base_url: str = ""
    openmetadata_jwt_token: str = ""
    init_database_on_deploy: bool = False
    drop_databases: bool = False


class InitRunPayload(BaseModel):
    mode: str = "all"


def _read_env_lines() -> list[str]:
    if not ENV_FILE.exists():
        example = PROJECT_ROOT / ".env.example"
        if example.exists():
            return example.read_text(encoding="utf-8").splitlines()
        return []
    return ENV_FILE.read_text(encoding="utf-8").splitlines()


def _read_env_map() -> Dict[str, str]:
    data: Dict[str, str] = {}
    for line in _read_env_lines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip().strip('"').strip("'")
    return data


def _write_env_values(values: Dict[str, str]) -> None:
    existing = _read_env_lines()
    used = set()
    lines = []
    for line in existing:
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in line:
            lines.append(line)
            continue
        key = line.split("=", 1)[0].strip()
        if key in SAFE_ENV_KEYS and key in values:
            lines.append(f"{key}={values[key]}")
            used.add(key)
        else:
            lines.append(line)
    for key, value in values.items():
        if key not in used:
            lines.append(f"{key}={value}")
    ENV_FILE.write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")


def _bool_env(value: bool) -> str:
    return "true" if value else "false"


def _validate_identifier(value: str, label: str) -> None:
    if not re.fullmatch(r"[A-Za-z0-9_]+", value):
        raise HTTPException(status_code=400, detail=f"Invalid {label}")


def _apply_runtime_settings(payload: InitConfigPayload) -> None:
    from backend.settings import settings
    env_map = _read_env_map()
    doris_password = payload.doris_password if payload.doris_password else env_map.get("DORIS_PASSWORD", "")
    openmetadata_token = payload.openmetadata_jwt_token if payload.openmetadata_jwt_token else env_map.get("OPENMETADATA_JWT_TOKEN", "")
    ai_api_key = payload.doris_ai_api_key if payload.doris_ai_api_key else env_map.get("DORIS_AI_API_KEY", "")

    settings.BACKEND_HOST = payload.backend_host
    settings.BACKEND_PORT = payload.backend_port
    settings.FRONTEND_HOST = payload.frontend_host
    settings.FRONTEND_PORT = payload.frontend_port
    settings.DORIS_HOST = payload.doris_host
    settings.DORIS_PORT = payload.doris_port
    settings.DORIS_HTTP_PORT = payload.doris_http_port
    settings.DORIS_STREAM_LOAD_HOST = payload.doris_host
    settings.DORIS_STREAM_LOAD_PORT = payload.doris_http_port
    settings.DORIS_USER = payload.doris_user
    settings.DORIS_PASSWORD = doris_password
    settings.DORIS_DATABASE = payload.doris_database
    settings.DORIS_AI_RESOURCE = payload.doris_ai_resource
    settings.LINEAGE_DATABASE = payload.doris_database
    settings.RETAIL_LINEAGE_DB = payload.doris_database
    settings.UPLOAD_DIR = str(Path(payload.upload_dir) if Path(payload.upload_dir).is_absolute() else PROJECT_ROOT / payload.upload_dir)
    settings.OPENMETADATA_BASE_URL = payload.openmetadata_base_url
    settings.OPENMETADATA_JWT_TOKEN = openmetadata_token
    os.environ.update({
        "BACKEND_HOST": payload.backend_host,
        "BACKEND_PORT": str(payload.backend_port),
        "BACKEND_PROXY_HOST": payload.backend_proxy_host,
        "FRONTEND_HOST": payload.frontend_host,
        "FRONTEND_PORT": str(payload.frontend_port),
        "DORIS_HOST": payload.doris_host,
        "DORIS_PORT": str(payload.doris_port),
        "DORIS_HTTP_PORT": str(payload.doris_http_port),
        "DORIS_STREAM_LOAD_HOST": payload.doris_host,
        "DORIS_STREAM_LOAD_PORT": str(payload.doris_http_port),
        "DORIS_USER": payload.doris_user,
        "DORIS_PASSWORD": doris_password,
        "DORIS_DATABASE": payload.doris_database,
        "DORIS_AI_RESOURCE": payload.doris_ai_resource,
        "DORIS_AI_PROVIDER": payload.doris_ai_provider,
        "DORIS_AI_MODEL": payload.doris_ai_model,
        "DORIS_AI_ENDPOINT": payload.doris_ai_endpoint,
        "DORIS_AI_API_KEY": ai_api_key,
        "LINEAGE_DATABASE": payload.doris_database,
        "UPLOAD_DIR": payload.upload_dir,
        "LOG_DIR": payload.log_dir,
        "OPENMETADATA_BASE_URL": payload.openmetadata_base_url,
        "OPENMETADATA_JWT_TOKEN": openmetadata_token,
        "INIT_DATABASE_ON_DEPLOY": _bool_env(payload.init_database_on_deploy),
        "DROP_DATABASES": _bool_env(payload.drop_databases),
    })


async def _test_doris_server(payload: InitConfigPayload) -> Dict[str, str]:
    env_map = _read_env_map()
    password = payload.doris_password if payload.doris_password else env_map.get("DORIS_PASSWORD", "")
    ai_resource = payload.doris_ai_resource.strip()
    try:
        conn = await aiomysql.connect(
            host=payload.doris_host,
            port=payload.doris_port,
            user=payload.doris_user,
            password=password,
            connect_timeout=10,
        )
        try:
            async with conn.cursor() as cur:
                await cur.execute("SELECT 1")
                if ai_resource:
                    if not re.fullmatch(r"[A-Za-z0-9_\\-]+", ai_resource):
                        raise ValueError("DORIS_AI_RESOURCE contains invalid characters")
                    await cur.execute(f"SET default_ai_resource = '{ai_resource}'")
            return {"status": "ok", "ai_resource": ai_resource, "default_ai_resource_set": bool(ai_resource)}
        finally:
            conn.close()
    except Exception as e:
        message = str(e)
        if isinstance(e, httpx.HTTPStatusError):
            message = e.response.text[:1000] or message
        return {"status": "error", "message": message}


def _extract_llm_text(data: Dict) -> str:
    if isinstance(data.get("text"), str):
        return data["text"]
    choices = data.get("choices") or []
    if choices:
        msg = choices[0].get("message") or {}
        if isinstance(msg.get("content"), str):
            return msg["content"]
        if isinstance(choices[0].get("text"), str):
            return choices[0]["text"]
    candidates = data.get("candidates") or []
    if candidates:
        parts = ((candidates[0].get("content") or {}).get("parts") or [])
        if parts and isinstance(parts[0].get("text"), str):
            return parts[0]["text"]
    output = data.get("output") or []
    if output:
        content = output[0].get("content") or []
        if content and isinstance(content[0].get("text"), str):
            return content[0]["text"]
    return str(data)[:1000]


async def _test_llm(payload: InitConfigPayload) -> Dict[str, str]:
    env_map = _read_env_map()
    endpoint = payload.doris_ai_endpoint.strip()
    api_key = payload.doris_ai_api_key or env_map.get("DORIS_AI_API_KEY", "")
    provider = payload.doris_ai_provider.strip().lower()
    model = payload.doris_ai_model.strip()
    if not endpoint or not api_key:
        raise HTTPException(status_code=400, detail="LLM endpoint and API key are required")

    headers = {"Content-Type": "application/json"}
    body: Dict = {}
    if provider == "gemini" or "generativelanguage.googleapis.com" in endpoint:
        url = endpoint
        if "key=" not in url:
            sep = "&" if "?" in url else "?"
            url = f"{url}{sep}key={api_key}"
        body = {"contents": [{"parts": [{"text": "who are you"}]}]}
    else:
        url = _normalize_chat_endpoint(endpoint)
        headers["Authorization"] = f"Bearer {api_key}"
        body = {
            "model": model,
            "messages": [{"role": "user", "content": "who are you"}],
            "temperature": 0,
            "max_tokens": 128,
        }
        if not model:
            body.pop("model")

    try:
        async with httpx.AsyncClient(timeout=30, trust_env=False) as client:
            resp = await client.post(url, headers=headers, json=body)
        resp.raise_for_status()
        data = resp.json()
        answer = _extract_llm_text(data).strip()
        return {"status": "ok", "answer": answer or "LLM connection succeeded"}
    except Exception as e:
        return {"status": "error", "message": str(e)}


def _normalize_chat_endpoint(endpoint: str) -> str:
    parsed = urlparse(endpoint)
    path = parsed.path.rstrip("/")
    if path.endswith("/chat/completions") or path.endswith("/responses"):
        return endpoint
    return endpoint.rstrip("/") + "/chat/completions"


@lru_cache
def get_user_svc() -> UserService:
    return UserService()


@lru_cache
def get_seg_svc() -> SegmentService:
    return SegmentService()


@lru_cache
def get_beh_svc() -> BehaviorService:
    return BehaviorService()


@lru_cache
def get_dash_svc() -> DashboardService:
    return DashboardService()


@lru_cache
def get_mgmt_svc() -> ManagementDashboard:
    return ManagementDashboard()


@lru_cache
def get_tag_svc() -> TagAnalysisService:
    return TagAnalysisService()


@lru_cache
def get_rpt_svc() -> ReportService:
    return ReportService()


@lru_cache
def get_met_svc() -> MetricsService:
    return MetricsService()


@lru_cache
def get_obs_svc() -> ObserveService:
    return ObserveService()


@router.get("/user/wide")
async def query_user_wide(
    user_name: Optional[str] = None,
    id_card: Optional[str] = None,
    phone: Optional[str] = None,
    asset_level: Optional[str] = None,
    active_level: Optional[str] = None,
    lifecycle_stage: Optional[str] = None,
    preferred_channel: Optional[str] = None,
    age_min: Optional[int] = None,
    age_max: Optional[int] = None,
    aum_min: Optional[float] = None,
    aum_max: Optional[float] = None,
    anomaly_flag: Optional[int] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=200),
):
    return await get_user_svc().query_wide(
        user_name, id_card, phone, asset_level, active_level,
        lifecycle_stage, preferred_channel, age_min, age_max,
        aum_min, aum_max, anomaly_flag, page, page_size,
    )


@router.get("/user/{user_id}")
async def get_user_detail(user_id: int):
    data = await get_user_svc().get_user_detail(user_id)
    if not data:
        raise HTTPException(status_code=404, detail="用户不存在")
    return data


class SegmentRule(BaseModel):
    tag_name: str
    tag_values: List[str]
    op: str = "OR"
    exclude: bool = False


class CreateSegmentReq(BaseModel):
    segment_name: str
    description: str = ""
    rules: List[SegmentRule]
    created_by: str = "system"


class CountSegmentReq(BaseModel):
    rules: List[SegmentRule]


@router.post("/segment/count")
async def count_segment(req: CountSegmentReq):
    rules = [r.model_dump() for r in req.rules]
    return await get_seg_svc().count_segment(rules)


@router.post("/segment/create")
async def create_segment(req: CreateSegmentReq):
    rules = [r.model_dump() for r in req.rules]
    return await get_seg_svc().create_segment(req.segment_name, rules, req.description, req.created_by)


@router.get("/segment/list")
async def list_segments():
    return await get_seg_svc().list_segments()


@router.delete("/segment/{segment_id}")
async def delete_segment(segment_id: int):
    ok = await get_seg_svc().delete_segment(segment_id)
    return {"success": ok}


@router.get("/segment/{segment_id}/users")
async def segment_users(
    segment_id: int,
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
):
    return await get_seg_svc().get_segment_users(segment_id, page, size)


@router.get("/segment/{segment_id}/stats")
async def segment_stats(segment_id: int):
    return await get_seg_svc().get_segment_stats(segment_id)


class FunnelReq(BaseModel):
    steps: Optional[List[str]] = None
    window_seconds: int = 86400
    channel: Optional[str] = None
    segment_id: Optional[int] = None


class RetentionReq(BaseModel):
    cohort_event: str = "REGISTER"
    return_event: str = "LOGIN"
    retention_days: Optional[List[int]] = None


@router.post("/behavior/funnel")
async def funnel_analysis(req: FunnelReq):
    return await get_beh_svc().funnel_analysis(req.steps, req.window_seconds, req.channel, req.segment_id)


@router.post("/behavior/retention")
async def retention_analysis(req: RetentionReq):
    return await get_beh_svc().retention_analysis(req.cohort_event, req.return_event, req.retention_days)


@router.get("/behavior/transaction")
async def transaction_analysis(channel: Optional[str] = None):
    return await get_beh_svc().transaction_analysis(channel=channel)


@router.get("/behavior/rfm")
async def rfm_analysis():
    return await get_beh_svc().rfm_analysis()


@router.get("/dashboard")
async def dashboard():
    return await get_dash_svc().get_overview()


@router.get("/management")
async def management_dashboard():
    return await get_mgmt_svc().get_overview()


@router.get("/tag-analysis/overview")
async def tag_overview():
    return await get_tag_svc().overview()


@router.get("/tag-analysis/users")
async def tag_users(tag_name: Optional[str] = None, is_risk: Optional[int] = None):
    return await get_tag_svc().tag_user_list(tag_name, is_risk)


@router.get("/tag-analysis/risk")
async def tag_risk():
    return await get_tag_svc().risk_tag_analysis()


@router.get("/tag-analysis/cross")
async def tag_cross():
    return await get_tag_svc().tag_asset_cross()


@router.get("/tag-analysis/cooccurrence")
async def tag_cooccurrence():
    return await get_tag_svc().tag_cooccurrence()


@router.post("/tag-analysis/run-classify")
async def run_classify():
    return await get_tag_svc().run_classify()


@router.get("/system/health")
async def health():
    ok = await ping()
    version = await get_doris_version() if ok else "N/A"
    return {"status": "ok" if ok else "error", "doris_version": version}


@router.get("/system/config")
async def get_config():
    from backend.settings import settings
    return {
        "backend_host": settings.BACKEND_HOST,
        "doris_host": settings.DORIS_HOST,
        "doris_port": settings.DORIS_PORT,
        "doris_http_port": settings.DORIS_HTTP_PORT,
        "doris_stream_load_host": settings.DORIS_STREAM_LOAD_HOST,
        "doris_stream_load_port": settings.DORIS_STREAM_LOAD_PORT,
        "doris_user": settings.DORIS_USER,
        "doris_database": settings.DORIS_DATABASE,
        "lineage_database": settings.DORIS_DATABASE,
        "backend_port": settings.BACKEND_PORT,
        "backend_proxy_host": os.getenv("BACKEND_PROXY_HOST", "127.0.0.1"),
        "frontend_host": settings.FRONTEND_HOST,
        "frontend_port": settings.FRONTEND_PORT,
        "hasp_enabled": settings.DORIS_HASP_ENABLED,
        "ai_resource_configured": bool(settings.DORIS_AI_RESOURCE),
        "ai_resource": settings.DORIS_AI_RESOURCE or "",
        "ai_provider": os.getenv("DORIS_AI_PROVIDER", ""),
        "ai_model": os.getenv("DORIS_AI_MODEL", ""),
        "ai_endpoint": os.getenv("DORIS_AI_ENDPOINT", ""),
        "openmetadata_configured": bool(settings.OPENMETADATA_BASE_URL and settings.OPENMETADATA_JWT_TOKEN),
        "openmetadata_base_url": settings.OPENMETADATA_BASE_URL,
        "upload_dir": settings.UPLOAD_DIR,
        "log_dir": os.getenv("LOG_DIR", "./logs"),
        "init_database_on_deploy": os.getenv("INIT_DATABASE_ON_DEPLOY", "false").lower() == "true",
        "drop_databases": os.getenv("DROP_DATABASES", "false").lower() == "true",
    }


@router.post("/system/init/config")
async def save_init_config(payload: InitConfigPayload):
    _validate_identifier(payload.doris_database, "Doris database")
    if payload.doris_ai_resource and not re.fullmatch(r"[A-Za-z0-9_\\-]+", payload.doris_ai_resource):
        raise HTTPException(status_code=400, detail="Invalid AI resource")

    env_map = _read_env_map()
    ai_api_key = payload.doris_ai_api_key or env_map.get("DORIS_AI_API_KEY", "")
    values = {
        "BACKEND_HOST": payload.backend_host,
        "BACKEND_PORT": str(payload.backend_port),
        "BACKEND_PROXY_HOST": payload.backend_proxy_host,
        "FRONTEND_HOST": payload.frontend_host,
        "FRONTEND_PORT": str(payload.frontend_port),
        "DORIS_HOST": payload.doris_host,
        "DORIS_PORT": str(payload.doris_port),
        "DORIS_HTTP_PORT": str(payload.doris_http_port),
        "DORIS_STREAM_LOAD_HOST": payload.doris_host,
        "DORIS_STREAM_LOAD_PORT": str(payload.doris_http_port),
        "DORIS_USER": payload.doris_user,
        "DORIS_PASSWORD": payload.doris_password or env_map.get("DORIS_PASSWORD", ""),
        "DORIS_DATABASE": payload.doris_database,
        "DORIS_AI_RESOURCE": payload.doris_ai_resource,
        "DORIS_AI_PROVIDER": payload.doris_ai_provider,
        "DORIS_AI_MODEL": payload.doris_ai_model,
        "DORIS_AI_ENDPOINT": payload.doris_ai_endpoint,
        "DORIS_AI_API_KEY": ai_api_key,
        "LINEAGE_DATABASE": payload.doris_database,
        "UPLOAD_DIR": payload.upload_dir,
        "LOG_DIR": payload.log_dir,
        "OPENMETADATA_BASE_URL": payload.openmetadata_base_url,
        "OPENMETADATA_JWT_TOKEN": payload.openmetadata_jwt_token or env_map.get("OPENMETADATA_JWT_TOKEN", ""),
        "INIT_DATABASE_ON_DEPLOY": _bool_env(payload.init_database_on_deploy),
        "DROP_DATABASES": _bool_env(payload.drop_databases),
    }
    _write_env_values(values)
    _apply_runtime_settings(payload)
    await close_pool()
    return {"ok": True, "env_file": str(ENV_FILE)}


@router.post("/system/init/test")
async def test_init_config(payload: InitConfigPayload):
    _apply_runtime_settings(payload)
    await close_pool()
    return await _test_doris_server(payload)


@router.post("/system/init/llm-test")
async def test_init_llm(payload: InitConfigPayload):
    return await _test_llm(payload)


@router.post("/system/init/database")
async def run_database_init(payload: InitRunPayload):
    if payload.mode not in {"all", "core", "lineage", "regdb", "wide", "validate"}:
        raise HTTPException(status_code=400, detail="Invalid init mode")
    proc = await asyncio.create_subprocess_exec(
        "sh", "scripts/init_database.sh", payload.mode,
        cwd=str(PROJECT_ROOT),
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.STDOUT,
    )
    out, _ = await proc.communicate()
    output = out.decode("utf-8", errors="replace")
    if proc.returncode != 0:
        raise HTTPException(status_code=500, detail=output[-4000:])
    return {"ok": True, "mode": payload.mode, "output": output[-8000:]}


@router.post("/system/init/database/stream")
async def run_database_init_stream(payload: InitRunPayload):
    if payload.mode not in {"all", "core", "lineage", "regdb", "wide", "validate"}:
        raise HTTPException(status_code=400, detail="Invalid init mode")

    async def generate():
        proc = await asyncio.create_subprocess_exec(
            "sh", "scripts/init_database.sh", payload.mode,
            cwd=str(PROJECT_ROOT),
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.STDOUT,
        )
        async for line in proc.stdout:
            yield line.decode("utf-8", errors="replace")
        await proc.wait()
        if proc.returncode != 0:
            yield f"\n❌ Exit {proc.returncode}\n"
        else:
            yield "\n✅ Done\n"

    return StreamingResponse(generate(), media_type="text/plain; charset=utf-8")


@router.get("/report/overview")
async def report_overview():
    return await get_rpt_svc().business_overview()


@router.get("/report/transaction")
async def report_transaction():
    return await get_rpt_svc().transaction_report()


@router.get("/report/risk")
async def report_risk():
    return await get_rpt_svc().risk_report()


class MetricsQueryReq(BaseModel):
    dimensions: List[str] = []
    measures: List[str] = []
    limit: int = 100
    page: int = 1
    filters: List[Dict] = []
    sort_by: Optional[str] = None
    sort_dir: str = "DESC"
    top_n: Optional[int] = None
    calc_fields: List[Dict] = []
    time_range: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None


class MetricsCompareReq(BaseModel):
    dimensions: List[str] = []
    measures: List[str] = []
    compare_type: str = "mom"
    current_start: Optional[str] = None
    current_end: Optional[str] = None


class MetricsDrillReq(BaseModel):
    parent_dim: str
    parent_value: str
    child_dim: str
    measures: List[str] = []
    filters: List[Dict] = []


class SaveQueryReq(BaseModel):
    name: str
    config: Dict


@router.get("/metrics/definitions")
async def metrics_definitions():
    return await get_met_svc().get_definitions()


@router.get("/metrics/templates")
async def metrics_templates():
    return await get_met_svc().get_templates()


@router.post("/metrics/query")
async def metrics_query(req: MetricsQueryReq):
    return await get_met_svc().query(
        req.dimensions, req.measures, req.limit, req.page,
        req.filters, req.sort_by, req.sort_dir, req.top_n,
        req.calc_fields, req.time_range, req.start_date, req.end_date,
    )


@router.post("/metrics/compare")
async def metrics_compare(req: MetricsCompareReq):
    return await get_met_svc().compare(
        req.dimensions, req.measures, req.compare_type,
        req.current_start, req.current_end,
    )


@router.post("/metrics/drilldown")
async def metrics_drilldown(req: MetricsDrillReq):
    return await get_met_svc().drilldown(
        req.parent_dim, req.parent_value, req.child_dim, req.measures, req.filters,
    )


@router.post("/metrics/saved")
async def metrics_save(req: SaveQueryReq):
    return get_met_svc().save_query(req.name, req.config)


@router.get("/metrics/saved")
async def metrics_list_saved():
    return get_met_svc().list_saved()


@router.delete("/metrics/saved/{qid}")
async def metrics_delete_saved(qid: str):
    return {"success": get_met_svc().delete_saved(qid)}


@router.get("/metrics/history")
async def metrics_history(limit: int = Query(30, ge=1, le=100)):
    return get_met_svc().get_history(limit)


@router.get("/observe/logs")
async def observe_logs(
    path: Optional[str] = None,
    level: Optional[str] = None,
    service: Optional[str] = None,
    page: int = Query(1, ge=1),
    size: int = Query(100, ge=1, le=200),
):
    return await get_obs_svc().logs(path, level, service, page, size)


@router.get("/observe/stats")
async def observe_stats():
    return await get_obs_svc().stats()


@router.post("/observe/classify")
async def observe_classify():
    return await get_obs_svc().classify_logs()


@router.get("/trace/list")
async def trace_list(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
):
    return await get_obs_svc().traces(page, size)


@router.get("/trace/{trace_id}")
async def trace_detail(trace_id: str):
    return await get_obs_svc().trace_detail(trace_id)
