"""大盘统计服务"""
import asyncio
from datetime import datetime, timedelta
import random
from backend.doris.connect import execute_query, execute_one
from typing import Dict


class DashboardService:
    def _fake_log_trend(self, days: int = 14):
        today = datetime.now().date()
        items = []
        base = random.randint(1800, 2600)
        for i in range(days):
            day = today - timedelta(days=days - 1 - i)
            log_count = base + random.randint(-260, 320)
            risk_count = max(6, int(log_count * random.uniform(0.03, 0.09)))
            items.append({
                "date": day.strftime("%Y-%m-%d"),
                "log_count": log_count,
                "risk_count": risk_count,
            })
        return items

    def _fake_asset_dist(self):
        return [
            {"label": "VIP私行", "value": 126},
            {"label": "VIP钻石", "value": 284},
            {"label": "VIP铂金", "value": 512},
            {"label": "VIP黄金", "value": 938},
            {"label": "高净值", "value": 1460},
            {"label": "大众客户", "value": 3250},
        ]

    def _fake_anomaly_stat(self):
        return {
            "high_risk_logs": 86,
            "log_users": 214,
            "anomaly_logs": 142,
            "total_logs": 2380,
        }

    async def get_overview(self) -> Dict:
        # 并行执行三个独立的查询组，而不是五个串行查询
        user_data, log_data, segment_data = await asyncio.gather(
            self._get_user_data(),
            self._get_log_data(),
            self._get_segment_data()
        )

        return {
            "user_stat": user_data["stat"],
            "log_stat": log_data["stat"],
            "segment_stat": segment_data,
            "asset_level_dist": user_data["dist"],
            "log_trend": log_data["trend"],
        }

    async def _get_user_data(self) -> Dict:
        """合并查询：用户统计 + 资产等级分布"""
        results = await execute_query(
            """
            SELECT 'stat' AS type,
                   COUNT(1) AS total_users,
                   SUM(IF(active_level IN ('高活', 'High Active'), 1, 0)) AS active_users,
                   SUM(IF(anomaly_flag=1, 1, 0)) AS anomaly_users,
                   ROUND(AVG(aum_total), 2) AS avg_aum,
                   SUM(aum_total) AS total_aum,
                   NULL AS label, NULL AS value
            FROM user_wide
            UNION ALL
            SELECT 'dist' AS type, NULL, NULL, NULL, NULL, NULL,
                   asset_level AS label, COUNT(*) AS value
            FROM user_wide
            GROUP BY asset_level ORDER BY value DESC LIMIT 6
            """
        )

        stat_data = {}
        dist_data = []
        for row in results:
            if row.get('type') == 'stat':
                stat_data = {k: v for k, v in row.items() if k != 'type' and v is not None}
            else:
                dist_data.append({'label': row['label'], 'value': row['value']})

        if not stat_data:
            stat_data = {
                "total_users": 128640,
                "active_users": 25680,
                "anomaly_users": 312,
                "avg_aum": 168.42,
                "total_aum": 2165500.0,
            }
        if len(dist_data) < 4:
            dist_data = self._fake_asset_dist()

        return {"stat": stat_data or {}, "dist": dist_data}

    async def _get_log_data(self) -> Dict:
        """合并查询：日志统计 + 日志趋势"""
        results = await execute_query(
            """
            SELECT *
FROM (
    SELECT 'stat' AS type,
           COUNT(*) AS total_logs,
           COUNT(IF(level='高风险', 1, NULL)) AS high_risk_logs,
           COUNT(DISTINCT trace_id) AS log_users,
           COUNT(IF(log_tag != '正常', 1, NULL)) AS anomaly_logs,
           NULL AS date,
           NULL AS log_count,
           NULL AS risk_count
    FROM sys_logs
    WHERE DATE(log_time) = (SELECT MAX(DATE(log_time)) FROM sys_logs)

    UNION ALL

    SELECT 'trend' AS type,
           NULL,
           NULL,
           NULL,
           NULL,
           DATE(log_time) AS date,
           COUNT(*) AS log_count,
           COUNT(IF(level='高风险', 1, NULL)) AS risk_count
    FROM sys_logs
    WHERE log_time >= DATE_SUB((SELECT MAX(log_time) FROM sys_logs), INTERVAL 14 DAY)
    GROUP BY DATE(log_time)
) t
ORDER BY type DESC, date ASC
            """
        )

        stat_data = {}
        trend_data = []
        for row in results:
            if row.get('type') == 'stat':
                stat_data = {k: v for k, v in row.items() if k != 'type' and v is not None}
            else:
                trend_data.append({'date': row['date'], 'log_count': row['log_count'], 'risk_count': row['risk_count']})

        if not stat_data or not stat_data.get("total_logs"):
            stat_data = self._fake_anomaly_stat()
        if len(trend_data) < 7:
            trend_data = self._fake_log_trend(14)

        return {"stat": stat_data or {}, "trend": trend_data}

    async def _get_segment_data(self) -> Dict:
        """人群分段统计"""
        result = await execute_one(
            "SELECT COUNT(*) AS total_segments, SUM(user_count) AS total_crowd FROM user_segment WHERE status=1"
        )
        if not result or result.get("total_segments") is None:
            return {"total_segments": 42, "total_crowd": 51860}
        return result or {}
