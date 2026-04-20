from fastapi import APIRouter, Query
from functools import lru_cache

from backend.service.retail_lineage_service import RetailLineageService

router = APIRouter()


@lru_cache
def get_lineage_svc() -> RetailLineageService:
    return RetailLineageService()


@router.get("/lineage/domains")
async def lineage_domains():
    return await get_lineage_svc().list_domains()


@router.get("/lineage/assets")
async def lineage_assets(keyword: str = Query("", description="搜索关键字")):
    return await get_lineage_svc().list_assets(keyword)


@router.get("/lineage/asset/{asset_id}")
async def lineage_asset(asset_id: str):
    return await get_lineage_svc().get_asset(asset_id)


@router.get("/lineage/graph")
async def lineage_graph(domain: str = "", depth: int = 2):
    return await get_lineage_svc().graph(domain, depth)


@router.get("/lineage/impact")
async def lineage_impact(asset_id: str):
    return await get_lineage_svc().impact(asset_id)


@router.post("/lineage/sync-from-audit")
async def lineage_sync_from_audit(start_date: str = "", end_date: str = "", limit: int = 0):
    return await get_lineage_svc().sync_from_audit_log(start_date=start_date, end_date=end_date, limit=limit)


@router.get("/lineage/sync-logs")
async def lineage_sync_logs(limit: int = 50):
    return await get_lineage_svc().list_sync_logs(limit)


@router.get("/lineage/om-lineage")
async def lineage_om_lineage(table_name: str, depth: int = 3):
    return await get_lineage_svc().get_openmetadata_lineage(table_name, depth=depth)
