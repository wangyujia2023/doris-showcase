"""Semantic API aliases.

These routes keep the legacy short prefixes working while exposing clearer
paths for new integrations and future frontend modules.
"""
from fastapi import APIRouter, Query

from backend.api.manufacturing_routes import get_mfg_svc
from backend.api.securities_routes import get_sec_svc

router = APIRouter()

# Manufacturing aliases for /mfg/*
@router.post("/manufacturing/init")
async def manufacturing_init():
    return await get_mfg_svc().init_table()

@router.post("/manufacturing/generate")
async def manufacturing_generate():
    return await get_mfg_svc().generate_step()

@router.get("/manufacturing/overview")
async def manufacturing_overview():
    return await get_mfg_svc().get_overview()

@router.get("/manufacturing/oee-trend")
async def manufacturing_oee_trend():
    return await get_mfg_svc().get_oee_trend()

@router.get("/manufacturing/machine-status")
async def manufacturing_machine_status():
    return await get_mfg_svc().get_machine_status()

@router.get("/manufacturing/causal")
async def manufacturing_causal():
    return await get_mfg_svc().get_causal_analysis()

@router.post("/manufacturing/batch")
async def manufacturing_batch(steps: int = 5):
    return await get_mfg_svc().batch_generate(steps)

@router.get("/manufacturing/detail")
async def manufacturing_detail(limit: int = Query(60, ge=1, le=200)):
    return await get_mfg_svc().get_detail(limit)

@router.get("/manufacturing/machine-trend")
async def manufacturing_machine_trend(machine_id: str):
    return await get_mfg_svc().get_machine_trend(machine_id)

@router.get("/manufacturing/quality-stats")
async def manufacturing_quality_stats():
    return await get_mfg_svc().get_quality_stats()

@router.get("/manufacturing/energy-stats")
async def manufacturing_energy_stats():
    return await get_mfg_svc().get_energy_stats()

@router.get("/manufacturing/maintenance-stats")
async def manufacturing_maintenance_stats():
    return await get_mfg_svc().get_maintenance_stats()

@router.get("/manufacturing/process-trend")
async def manufacturing_process_trend():
    return await get_mfg_svc().get_process_trend()

@router.post("/manufacturing/reset")
async def manufacturing_reset():
    return await get_mfg_svc().reset()

# Securities aliases for /sec/*
@router.post("/securities/init")
async def securities_init():
    return await get_sec_svc().init_table()

@router.post("/securities/generate")
async def securities_generate():
    return await get_sec_svc().generate_step()

@router.post("/securities/batch")
async def securities_batch(steps: int = Query(6, ge=1, le=24)):
    return await get_sec_svc().batch_generate(steps)

@router.post("/securities/reset")
async def securities_reset():
    return await get_sec_svc().reset()

@router.get("/securities/overview")
async def securities_overview():
    return await get_sec_svc().get_overview()

@router.get("/securities/trend")
async def securities_trend():
    return await get_sec_svc().get_trend()

@router.get("/securities/trades")
async def securities_trades(limit: int = Query(60, ge=20, le=200)):
    return await get_sec_svc().get_trades(limit)

@router.get("/securities/accounts")
async def securities_accounts():
    return await get_sec_svc().get_accounts()

@router.get("/securities/positions")
async def securities_positions():
    return await get_sec_svc().get_positions()

@router.get("/securities/sector-heat")
async def securities_sector_heat():
    return await get_sec_svc().get_sector_heat()

@router.get("/securities/risk-alerts")
async def securities_risk_alerts():
    return await get_sec_svc().get_risk_alerts()

@router.get("/securities/branches")
async def securities_branches():
    return await get_sec_svc().get_branches()
