"""London Underground (TfL) operations - API routes"""
from fastapi import APIRouter, Query
from functools import lru_cache

from backend.service.bjmetro_service import (
    BJMetroOverviewService, BJMetroFlowService,
    BJMetroTrainService, BJMetroEquipmentService, BJMetroRevenueService,
)

router = APIRouter()


@lru_cache
def _overview(): return BJMetroOverviewService()
@lru_cache
def _flow():     return BJMetroFlowService()
@lru_cache
def _train():    return BJMetroTrainService()
@lru_cache
def _equip():    return BJMetroEquipmentService()
@lru_cache
def _revenue():  return BJMetroRevenueService()


# ── 运营总览 ────────────────────────────────────────────────────────
@router.get("/bjmetro/overview/kpi")
async def overview_kpi():
    return await _overview().today_kpi()

@router.get("/bjmetro/overview/flow-trend")
async def overview_flow_trend():
    return await _overview().flow_trend_today()

@router.get("/bjmetro/overview/line-ranking")
async def overview_line_ranking():
    return await _overview().line_flow_ranking()

@router.get("/bjmetro/overview/punctuality")
async def overview_punctuality():
    return await _overview().punctuality_by_line()

@router.get("/bjmetro/overview/alerts")
async def overview_alerts():
    return await _overview().realtime_alerts()

@router.get("/bjmetro/overview/line-status")
async def overview_line_status():
    return await _overview().line_status()

@router.get("/bjmetro/overview/all")
async def overview_all():
    return await _overview().overview_all()


# ── 客流分析 ────────────────────────────────────────────────────────
@router.get("/bjmetro/flow/hourly")
async def flow_hourly():
    return await _flow().hourly_distribution()

@router.get("/bjmetro/flow/hot-stations")
async def flow_hot_stations():
    return await _flow().hot_stations()

@router.get("/bjmetro/flow/od-pairs")
async def flow_od_pairs(peak_type: str = Query("morning")):
    return await _flow().od_hot_pairs(peak_type)

@router.get("/bjmetro/flow/trend")
async def flow_trend():
    return await _flow().flow_trend_30d()


# ── 列车运行 ────────────────────────────────────────────────────────
@router.get("/bjmetro/train/kpi")
async def train_kpi():
    return await _train().train_kpi()

@router.get("/bjmetro/train/punctuality-trend")
async def train_punctuality_trend():
    return await _train().punctuality_trend()

@router.get("/bjmetro/train/fault-types")
async def train_fault_types():
    return await _train().fault_type_dist()

@router.get("/bjmetro/train/list")
async def train_list():
    return await _train().train_list()


# ── 设备安全 ────────────────────────────────────────────────────────
@router.get("/bjmetro/equipment/kpi")
async def equip_kpi():
    return await _equip().equipment_kpi()

@router.get("/bjmetro/equipment/fault-dist")
async def equip_fault_dist():
    return await _equip().fault_distribution()

@router.get("/bjmetro/equipment/fault-by-line")
async def equip_fault_by_line():
    return await _equip().fault_by_line()

@router.get("/bjmetro/equipment/maintenance-log")
async def equip_maintenance_log():
    return await _equip().maintenance_log()

@router.get("/bjmetro/equipment/fault-trend")
async def equip_fault_trend():
    return await _equip().fault_trend()

@router.get("/bjmetro/equipment/device-mttr")
async def equip_device_mttr():
    return await _equip().device_mttr()


# ── 经营收益 ────────────────────────────────────────────────────────
@router.get("/bjmetro/revenue/kpi")
async def revenue_kpi():
    return await _revenue().revenue_kpi()

@router.get("/bjmetro/revenue/trend")
async def revenue_trend():
    return await _revenue().revenue_trend()

@router.get("/bjmetro/revenue/ticket-types")
async def revenue_ticket_types():
    return await _revenue().ticket_type_dist()

@router.get("/bjmetro/revenue/by-line")
async def revenue_by_line():
    return await _revenue().revenue_by_line()
