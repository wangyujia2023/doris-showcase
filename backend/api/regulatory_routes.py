"""银行监管报送一表通 - API 路由"""
from fastapi import APIRouter, Query
from functools import lru_cache
from backend.service.regulatory_service import (
    RegInitService, RegProcessService, RegQueryService,
)

router = APIRouter()

@lru_cache
def _init():   return RegInitService()
@lru_cache
def _proc():   return RegProcessService()
@lru_cache
def _query():  return RegQueryService()

# ── 初始化 & 数据 ──────────────────────────────────────────────
@router.post("/regulatory/init")
async def reg_init():
    return await _init().init_tables()

@router.post("/regulatory/seed")
async def reg_seed():
    return await _init().seed_data()

@router.post("/regulatory/process")
async def reg_process():
    return await _proc().process_all()

# ── 查询 ───────────────────────────────────────────────────────
@router.get("/regulatory/master")
async def reg_master():
    return await _query().get_master_list()

@router.get("/regulatory/overview")
async def reg_overview():
    return await _query().get_overview()

@router.get("/regulatory/submit-log")
async def reg_submit_log():
    return await _query().get_submit_log()

@router.get("/regulatory/qc")
async def reg_qc(period: str = Query("2024-03")):
    return await _query().get_qc_detail(period)

# ── 新增接口 ───────────────────────────────────────────────────
@router.get("/regulatory/nav")
async def reg_nav():
    """左侧导航 + 状态芯片"""
    return await _query().get_nav_status()

@router.get("/regulatory/report/{code}")
async def reg_report_data(code: str, period: str = Query("2024-03")):
    """按报表代码返回格式化表格行（G01/G03/G04A/G11）"""
    return await _query().get_report_data(code.upper(), period)

@router.get("/regulatory/indicators")
async def reg_indicators():
    """右侧监管核心指标"""
    return await _query().get_indicators()

@router.get("/regulatory/calendar")
async def reg_calendar():
    """本月报送日历"""
    return await _query().get_calendar()

@router.get("/regulatory/history")
async def reg_history():
    """最近报送记录"""
    return await _query().get_history()
