import asyncio
import logging
import json
import re as _re
import time as _time
import uuid as _uuid
from contextlib import asynccontextmanager
from typing import Dict, List, Optional

import aiomysql
import httpx

from backend.settings import settings
from backend.telemetry.collector import emit_span, get_trace_id, get_trace_start

logger = logging.getLogger(__name__)

_pool: Optional[aiomysql.Pool] = None


async def get_pool() -> aiomysql.Pool:
    global _pool
    if _pool is None or _pool.closed:
        _pool = await aiomysql.create_pool(
            host=settings.DORIS_HOST, port=settings.DORIS_PORT,
            user=settings.DORIS_USER, password=settings.DORIS_PASSWORD,
            db=settings.DORIS_DATABASE
        )
    return _pool


async def close_pool():
    global _pool
    if _pool and not _pool.closed:
        _pool.close()
        await _pool.wait_closed()


@asynccontextmanager
async def get_conn():
    pool = await get_pool()
    async with pool.acquire() as conn:
        ai_resource = settings.DORIS_AI_RESOURCE.strip()
        if ai_resource:
            if not _re.fullmatch(r"[A-Za-z0-9_\\-]+", ai_resource):
                raise ValueError("DORIS_AI_RESOURCE contains invalid characters")
            async with conn.cursor() as cur:
                await cur.execute(f"SET default_ai_resource = '{ai_resource}'")
        yield conn


# ── DB span 采集 ─────────────────────────────────────────────────
def _sql_op(sql: str) -> str:
    return sql.strip().split()[0].upper()[:16] if sql.strip() else 'UNKNOWN'

def _sql_table(sql: str) -> str:
    m = _re.search(r'(?:FROM|INTO|UPDATE|TABLE)\s+(\w+)', sql.upper())
    return m.group(1).lower() if m else ''

def _record_db(sql, duration_ms, offset_ms, error=''):
    trace_id = get_trace_id()
    if not trace_id:
        return
    span_id = _uuid.uuid4().hex[:16]
    op = f"{_sql_op(sql)} {_sql_table(sql)}".strip()
    status = 'ERROR' if error else 'OK'
    emit_span(trace_id, span_id, "", "Doris", op, offset_ms, duration_ms, status, sql[:500])


# ── 通用查询 ─────────────────────────────────────────────────────
async def execute_query(sql: str, args: tuple = None) -> List[Dict]:
    req_start = get_trace_start()
    t0 = _time.time()
    offset_ms = (t0 - req_start) * 1000 if req_start else 0
    try:
        async with get_conn() as conn:
            async with conn.cursor(aiomysql.DictCursor) as cur:
                await cur.execute(sql, args)
                rows = await cur.fetchall()
                result = [dict(r) for r in rows]
        dur = (_time.time() - t0) * 1000
        _record_db(sql[:300], dur, offset_ms)
        return result
    except Exception as e:
        dur = (_time.time() - t0) * 1000
        _record_db(sql[:300], dur, offset_ms, str(e)[:200])
        logger.warning(f"execute_query: {e}")
        return []


async def execute_one(sql: str, args: tuple = None) -> Optional[Dict]:
    rows = await execute_query(sql, args)
    return rows[0] if rows else None


async def execute_write(sql: str, args: tuple = None) -> int:
    req_start = get_trace_start()
    t0 = _time.time()
    offset_ms = (t0 - req_start) * 1000 if req_start else 0
    try:
        async with get_conn() as conn:
            async with conn.cursor() as cur:
                await cur.execute(sql, args)
                rc = cur.rowcount
        dur = (_time.time() - t0) * 1000
        _record_db(sql[:300], dur, offset_ms)
        return rc
    except Exception as e:
        dur = (_time.time() - t0) * 1000
        _record_db(sql[:300], dur, offset_ms, str(e)[:200])
        logger.warning(f"execute_write: {e}")
        return 0


async def execute_many(sql: str, args_list: List[tuple]) -> int:
    if not args_list:
        return 0
    try:
        async with get_conn() as conn:
            async with conn.cursor() as cur:
                await cur.executemany(sql, args_list)
                return cur.rowcount
    except Exception as e:
        logger.warning(f"execute_many: {e}")
        return 0


async def stream_load_json(table: str, rows: List[Dict], columns: List[str]) -> int:
    if not rows:
        return 0
    if not _re.fullmatch(r"[A-Za-z0-9_]+", table):
        raise ValueError("invalid Doris table name")

    label = f"telemetry_{table}_{int(_time.time() * 1000)}_{_uuid.uuid4().hex[:8]}"
    url = (
        f"http://{settings.DORIS_STREAM_LOAD_HOST}:{settings.DORIS_STREAM_LOAD_PORT}"
        f"/api/{settings.DORIS_DATABASE}/{table}/_stream_load"
    )
    headers = {
        "label": label,
        "format": "json",
        "read_json_by_line": "true",
        "columns": ",".join(columns),
        "strict_mode": "false",
        "Expect": "100-continue",
    }
    data = "\n".join(
        json.dumps({col: row.get(col) for col in columns}, ensure_ascii=False, separators=(",", ":"))
        for row in rows
    )
    async def _do_load() -> dict:
        auth = (settings.DORIS_USER, settings.DORIS_PASSWORD)
        async with httpx.AsyncClient(follow_redirects=False, timeout=15, trust_env=False) as client:
            resp = await client.put(url, content=data.encode("utf-8"), headers=headers, auth=auth)
            # Doris FE → BE 重定向时 httpx 会丢弃 Authorization，手动跟随并带上鉴权
            if resp.is_redirect:
                location = resp.headers.get("location", "")
                resp = await client.put(location, content=data.encode("utf-8"), headers=headers, auth=auth)
        resp.raise_for_status()
        return resp.json()

    for attempt in range(2):
        try:
            result = await _do_load()
            status = str(result.get("Status", "")).lower()
            if status not in {"success", "publish timeout"}:
                msg = result.get("Message") or str(result)
                # 新建表 metadata 尚未传播到 BE，等 2 秒重试一次
                if "NOT_FOUND" in msg and attempt == 0:
                    await asyncio.sleep(2)
                    continue
                raise RuntimeError(msg)
            return int(result.get("NumberLoadedRows") or len(rows))
        except Exception as e:
            if attempt == 0 and "NOT_FOUND" in str(e):
                await asyncio.sleep(2)
                continue
            logger.warning(f"stream_load_json {table}: {e}")
            return 0
    return 0


async def ping() -> bool:
    try:
        return bool(await execute_query("SELECT 1 AS ok"))
    except Exception:
        return False


async def get_doris_version() -> str:
    try:
        row = await execute_one("SELECT VERSION() AS v")
        return row.get("v", "unknown") if row else "unknown"
    except Exception:
        return "unknown"
