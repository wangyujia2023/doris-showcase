"""London Underground (TfL) operations service"""
import asyncio
import logging
from typing import Dict, List

from backend.doris.connect import execute_query, execute_one

logger = logging.getLogger(__name__)

# ── 数据库查询工具 ────────────────────────────────────────────────────────────

async def bj_query(sql: str, args: tuple = None) -> List[Dict]:
    return await execute_query(sql, args)


async def bj_query_one(sql: str, args: tuple = None) -> Dict:
    row = await execute_one(sql, args)
    return row or {}


# ═══════════════════════════════════════════════════════════
# 运营总览
# ═══════════════════════════════════════════════════════════

class BJMetroOverviewService:

    async def today_kpi(self) -> Dict:
        # 今日全网客流（取最新有数据的日期）
        row = await bj_query_one("""
            SELECT SUM(inbound_count) AS total_passengers
            FROM bj_metro_daily_flow
            WHERE flow_date=(SELECT MAX(flow_date) FROM bj_metro_daily_flow)""")
        passengers = int(row.get("total_passengers") or 0)

        # 平均准点率
        row2 = await bj_query_one("""
            SELECT AVG(punctuality_rate) AS avg_punct,
                   SUM(fault_count) AS faults,
                   SUM(actual_trains) AS trains
            FROM bj_metro_train_ops
            WHERE ops_date=(SELECT MAX(ops_date) FROM bj_metro_train_ops)""")

        # 最新收入（万元）
        row3 = await bj_query_one("""
            SELECT SUM(ticket_revenue + ad_revenue + commercial_revenue) AS total_rev
            FROM bj_metro_revenue
            WHERE revenue_date=(SELECT MAX(revenue_date) FROM bj_metro_revenue)""")
        total_rev_w = round((row3.get("total_rev") or 0) / 100 / 10000, 1)

        row4 = await bj_query_one("SELECT COUNT(*) AS n FROM bj_metro_lines WHERE status='Operating'")

        return {
            "daily_passengers_w": round(passengers / 10000, 1),
            "punctuality_rate":   round(float(row2.get("avg_punct") or 0.994), 4),
            "daily_revenue_w":    total_rev_w,
            "fault_count":        int(row2.get("faults") or 0),
            "active_lines":       int(row4.get("n") or 0),
            "active_trains":      int(row2.get("trains") or 0),
        }

    async def flow_trend_today(self) -> Dict:
        rows = await bj_query("""
            SELECT flow_hour AS hour,
                   SUM(total_passengers) AS passengers,
                   SUM(overcapacity_cnt) AS overcapacity
            FROM bj_metro_hourly_flow
            WHERE flow_date=(SELECT MAX(flow_date) FROM bj_metro_hourly_flow)
            GROUP BY flow_hour ORDER BY flow_hour""")
        return {"data": rows}

    async def line_flow_ranking(self) -> Dict:
        rows = await bj_query("""
            SELECT f.line_id, l.line_name, l.line_color,
                   SUM(f.inbound_count) AS daily_passengers
            FROM bj_metro_daily_flow f
            JOIN bj_metro_lines l ON f.line_id=l.line_id
            WHERE f.flow_date=(SELECT MAX(flow_date) FROM bj_metro_daily_flow)
            GROUP BY f.line_id, l.line_name, l.line_color
            ORDER BY daily_passengers DESC""")
        return {"data": rows}

    async def punctuality_by_line(self) -> Dict:
        rows = await bj_query("""
            SELECT t.line_id, l.line_name,
                   ROUND(t.punctuality_rate * 100, 2) AS punctuality_pct
            FROM bj_metro_train_ops t
            JOIN bj_metro_lines l ON t.line_id=l.line_id
            WHERE t.ops_date=(SELECT MAX(ops_date) FROM bj_metro_train_ops)
            ORDER BY t.punctuality_rate DESC""")
        return {"data": rows}

    async def realtime_alerts(self) -> Dict:
        rows = await bj_query("""
            SELECT f.fault_id, f.fault_time, f.line_id, l.line_name,
                   f.station_id, s.station_name,
                   f.device_type, f.fault_type, f.severity,
                   f.description, f.status, f.handler
            FROM bj_metro_fault_log f
            LEFT JOIN bj_metro_lines l ON f.line_id=l.line_id
            LEFT JOIN bj_metro_stations s ON f.station_id=s.station_id AND f.line_id=s.line_id
            WHERE f.status != 'Resolved'
            ORDER BY f.fault_time DESC LIMIT 10""")
        return {"data": rows}

    async def line_status(self) -> Dict:
        rows = await bj_query("""
            SELECT l.line_id, l.line_name, l.line_color,
                   t.actual_trains, t.punctuality_rate, t.delay_count,
                   t.max_delay_sec, t.fault_count,
                   f.daily_passengers
            FROM bj_metro_lines l
            LEFT JOIN bj_metro_train_ops t ON l.line_id=t.line_id
                AND t.ops_date=(SELECT MAX(ops_date) FROM bj_metro_train_ops)
            LEFT JOIN (
                SELECT line_id, SUM(inbound_count) AS daily_passengers
                FROM bj_metro_daily_flow
                WHERE flow_date=(SELECT MAX(flow_date) FROM bj_metro_daily_flow)
                GROUP BY line_id
            ) f ON l.line_id=f.line_id
            ORDER BY f.daily_passengers DESC""")
        return {"data": rows}

    async def overview_all(self) -> Dict:
        """单次连接返回运营总览全部数据，减少 API 往返"""
        results = await asyncio.gather(
            self.today_kpi(),
            self.flow_trend_today(),
            self.line_flow_ranking(),
            self.punctuality_by_line(),
            self.realtime_alerts(),
            self.line_status(),
        )
        return {
            "kpi":          results[0],
            "flow_trend":   results[1].get("data", []),
            "line_ranking": results[2].get("data", []),
            "punctuality":  results[3].get("data", []),
            "alerts":       results[4].get("data", []),
            "line_status":  results[5].get("data", []),
        }


# ═══════════════════════════════════════════════════════════
# 客流分析
# ═══════════════════════════════════════════════════════════

class BJMetroFlowService:

    async def hourly_distribution(self) -> Dict:
        """工作日 vs 周末 逐时对比（近30天均值）"""
        rows = await bj_query("""
            SELECT flow_hour AS hour,
                   ROUND(AVG(CASE WHEN DAYOFWEEK(flow_date) NOT IN (1,7) THEN total_passengers END)) AS workday_avg,
                   ROUND(AVG(CASE WHEN DAYOFWEEK(flow_date) IN (1,7) THEN total_passengers END)) AS weekend_avg,
                   ROUND(AVG(overcapacity_cnt)) AS avg_overcap
            FROM bj_metro_hourly_flow
            GROUP BY flow_hour ORDER BY flow_hour""")
        return {"data": rows}

    async def hot_stations(self) -> Dict:
        rows = await bj_query("""
            SELECT f.station_id, s.station_name, s.district,
                   f.inbound_count, f.outbound_count,
                   s.is_interchange, s.interchange_lines
            FROM bj_metro_daily_flow f
            JOIN bj_metro_stations s ON f.station_id=s.station_id AND f.line_id=s.line_id
            WHERE f.flow_date=(SELECT MAX(flow_date) FROM bj_metro_daily_flow)
            ORDER BY f.inbound_count DESC LIMIT 20""")
        return {"data": rows}

    async def od_hot_pairs(self, peak_type: str = "morning") -> Dict:
        if peak_type not in ("morning", "evening", "offpeak"):
            peak_type = "morning"
        rows = await bj_query("""
            SELECT o.origin_id, s1.station_name AS origin_name,
                   o.dest_id,   s2.station_name AS dest_name,
                   SUM(o.flow_count) AS total_flow
            FROM bj_metro_od_flow o
            JOIN bj_metro_stations s1 ON o.origin_id=s1.station_id
            JOIN bj_metro_stations s2 ON o.dest_id=s2.station_id
            WHERE o.peak_type=%s
            GROUP BY o.origin_id,s1.station_name,o.dest_id,s2.station_name
            ORDER BY total_flow DESC LIMIT 15""", (peak_type,))
        return {"data": rows}

    async def flow_trend_30d(self) -> Dict:
        rows = await bj_query("""
            SELECT flow_date AS date,
                   SUM(total_passengers) AS total_passengers
            FROM bj_metro_hourly_flow
            GROUP BY flow_date ORDER BY flow_date""")
        return {"data": rows}


# ═══════════════════════════════════════════════════════════
# 列车运行
# ═══════════════════════════════════════════════════════════

class BJMetroTrainService:

    async def train_kpi(self) -> Dict:
        row = await bj_query_one("""
            SELECT AVG(punctuality_rate)   AS avg_punct,
                   SUM(actual_trains)      AS total_trains,
                   SUM(delay_count)        AS total_delays,
                   MAX(max_delay_sec)      AS max_delay,
                   SUM(fault_count)        AS total_faults,
                   SUM(total_mileage_km)   AS total_mileage
            FROM bj_metro_train_ops
            WHERE ops_date=(SELECT MAX(ops_date) FROM bj_metro_train_ops)""")
        return {
            "punctuality_rate": round(float(row.get("avg_punct") or 0.994), 4),
            "active_trains":    int(row.get("total_trains") or 0),
            "delay_count":      int(row.get("total_delays") or 0),
            "max_delay_sec":    int(row.get("max_delay") or 0),
            "fault_count":      int(row.get("total_faults") or 0),
            "total_mileage_km": round(float(row.get("total_mileage") or 0), 1),
        }

    async def punctuality_trend(self) -> Dict:
        rows = await bj_query("""
            SELECT ops_date AS date,
                   ROUND(AVG(punctuality_rate)*100, 2) AS punctuality_pct
            FROM bj_metro_train_ops
            GROUP BY ops_date ORDER BY ops_date""")
        return {"data": rows}

    async def fault_type_dist(self) -> Dict:
        rows = await bj_query("""
            SELECT fault_type, device_type, severity,
                   COUNT(*) AS cnt
            FROM bj_metro_fault_log
            GROUP BY fault_type, device_type, severity
            ORDER BY cnt DESC""")
        return {"data": rows}

    async def train_list(self) -> Dict:
        """模拟当前在线列车（取运营日报最新数据）"""
        rows = await bj_query("""
            SELECT t.line_id, l.line_name, l.line_color,
                   t.actual_trains, t.planned_trains,
                   t.punctuality_rate, t.delay_count, t.max_delay_sec
            FROM bj_metro_train_ops t
            JOIN bj_metro_lines l ON t.line_id=l.line_id
            WHERE t.ops_date=(SELECT MAX(ops_date) FROM bj_metro_train_ops)
            ORDER BY t.punctuality_rate""")
        return {"data": rows}


# ═══════════════════════════════════════════════════════════
# 设备安全
# ═══════════════════════════════════════════════════════════

class BJMetroEquipmentService:

    async def equipment_kpi(self) -> Dict:
        row = await bj_query_one("""
            SELECT COUNT(*) AS total_faults,
                   SUM(CASE WHEN status != 'Resolved' THEN 1 ELSE 0 END) AS open_faults,
                   SUM(CASE WHEN severity='Critical'  THEN 1 ELSE 0 END) AS critical,
                   ROUND(AVG(resolve_min), 1) AS avg_resolve_min
            FROM bj_metro_fault_log""")
        return {
            "total_faults":    int(row.get("total_faults") or 0),
            "open_faults":     int(row.get("open_faults") or 0),
            "critical_faults": int(row.get("critical") or 0),
            "avg_resolve_min": float(row.get("avg_resolve_min") or 0),
        }

    async def fault_distribution(self) -> Dict:
        rows = await bj_query("""
            SELECT device_type, COUNT(*) AS cnt,
                   SUM(CASE WHEN severity='Critical' THEN 1 ELSE 0 END) AS critical_cnt
            FROM bj_metro_fault_log
            GROUP BY device_type ORDER BY cnt DESC""")
        return {"data": rows}

    async def fault_by_line(self) -> Dict:
        rows = await bj_query("""
            SELECT f.line_id, l.line_name, l.line_color,
                   COUNT(*) AS total_faults,
                   SUM(CASE WHEN f.severity='Critical' THEN 1 ELSE 0 END) AS critical_cnt,
                   ROUND(AVG(f.resolve_min),1) AS avg_resolve_min
            FROM bj_metro_fault_log f
            JOIN bj_metro_lines l ON f.line_id=l.line_id
            GROUP BY f.line_id, l.line_name, l.line_color
            ORDER BY total_faults DESC""")
        return {"data": rows}

    async def maintenance_log(self) -> Dict:
        rows = await bj_query("""
            SELECT f.fault_id, f.fault_time, f.line_id, l.line_name,
                   f.station_id, s.station_name,
                   f.device_type, f.fault_type, f.severity,
                   f.description, f.resolve_min, f.status, f.handler
            FROM bj_metro_fault_log f
            LEFT JOIN bj_metro_lines l ON f.line_id=l.line_id
            LEFT JOIN bj_metro_stations s ON f.station_id=s.station_id AND f.line_id=s.line_id
            ORDER BY f.fault_time DESC LIMIT 50""")
        return {"data": rows}

    async def fault_trend(self) -> Dict:
        rows = await bj_query("""
            SELECT DATE(fault_time) AS date,
                   COUNT(*) AS total,
                   SUM(CASE WHEN severity='Critical' THEN 1 ELSE 0 END) AS critical,
                   SUM(CASE WHEN severity='Warning'  THEN 1 ELSE 0 END) AS warning,
                   SUM(CASE WHEN severity='Information' THEN 1 ELSE 0 END) AS info
            FROM bj_metro_fault_log
            WHERE fault_time >= DATE_SUB(
                (SELECT MAX(fault_time) FROM bj_metro_fault_log),
                INTERVAL 30 DAY)
            GROUP BY DATE(fault_time) ORDER BY date""")
        return {"data": rows}

    async def device_mttr(self) -> Dict:
        rows = await bj_query("""
            SELECT device_type,
                   COUNT(*) AS total,
                   ROUND(AVG(resolve_min), 0) AS avg_resolve_min,
                   ROUND(MIN(resolve_min), 0) AS min_resolve_min,
                   ROUND(MAX(resolve_min), 0) AS max_resolve_min
            FROM bj_metro_fault_log
            WHERE resolve_min IS NOT NULL
            GROUP BY device_type ORDER BY avg_resolve_min DESC""")
        return {"data": rows}


# ═══════════════════════════════════════════════════════════
# 经营收益
# ═══════════════════════════════════════════════════════════

class BJMetroRevenueService:

    async def revenue_kpi(self) -> Dict:
        # 最新有数据日期
        row = await bj_query_one("""
            SELECT SUM(ticket_revenue)     AS ticket_rev,
                   SUM(ad_revenue)         AS ad_rev,
                   SUM(commercial_revenue) AS comm_rev,
                   SUM(ticket_count)       AS tickets,
                   SUM(subsidy_amount)     AS subsidy
            FROM bj_metro_revenue
            WHERE revenue_date=(SELECT MAX(revenue_date) FROM bj_metro_revenue)""")
        ticket_w  = round((row.get("ticket_rev")  or 0) / 100 / 10000, 1)
        ad_w      = round((row.get("ad_rev")       or 0) / 100 / 10000, 1)
        comm_w    = round((row.get("comm_rev")      or 0) / 100 / 10000, 1)
        total_w   = round(ticket_w + ad_w + comm_w, 1)
        tickets   = int(row.get("tickets")          or 0)
        subsidy_w = round((row.get("subsidy")       or 0) / 100 / 10000, 1)
        avg_fare  = round(ticket_w * 10000 / max(tickets, 1), 2)
        return {
            "ticket_revenue_w":     ticket_w,
            "ad_revenue_w":         ad_w,
            "commercial_revenue_w": comm_w,
            "total_revenue_w":      total_w,
            "ticket_count":         tickets,
            "subsidy_w":            subsidy_w,
            "avg_fare":             avg_fare,
        }

    async def revenue_trend(self) -> Dict:
        rows = await bj_query("""
            SELECT revenue_date AS date,
                   ROUND(SUM(ticket_revenue)     / 100 / 10000, 1) AS ticket_w,
                   ROUND(SUM(ad_revenue)         / 100 / 10000, 1) AS ad_w,
                   ROUND(SUM(commercial_revenue) / 100 / 10000, 1) AS comm_w
            FROM bj_metro_revenue
            GROUP BY revenue_date ORDER BY revenue_date""")
        return {"data": rows}

    async def ticket_type_dist(self) -> Dict:
        """票务类型分布（模拟固定比例）"""
        return {"data": [
            {"type": "单程票",   "pct": 48},
            {"type": "月卡/定期","pct": 31},
            {"type": "老年/学生","pct": 13},
            {"type": "旅游套票", "pct":  8},
        ]}

    async def revenue_by_line(self) -> Dict:
        rows = await bj_query("""
            SELECT r.line_id, l.line_name, l.line_color,
                   ROUND(SUM(r.ticket_revenue)     / 100 / 10000, 1) AS ticket_w,
                   ROUND(SUM(r.ad_revenue)         / 100 / 10000, 1) AS ad_w,
                   ROUND(SUM(r.commercial_revenue) / 100 / 10000, 1) AS comm_w,
                   SUM(r.ticket_count)                                AS total_tickets,
                   ROUND(SUM(r.ticket_revenue) / NULLIF(SUM(r.ticket_count),0) / 100, 2) AS avg_fare
            FROM bj_metro_revenue r
            JOIN bj_metro_lines l ON r.line_id=l.line_id
            GROUP BY r.line_id, l.line_name, l.line_color
            ORDER BY ticket_w DESC""")
        return {"data": rows}
