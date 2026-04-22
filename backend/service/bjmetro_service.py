"""北京地铁运营分析平台 - 服务层"""
import os
import random
import asyncio
from datetime import date, datetime, timedelta
from typing import Dict, List

import aiomysql
from backend.doris.connect import execute_query, get_conn
from backend.settings import settings

DB = "bjmetro"

# ── 数据库查询工具 ────────────────────────────────────────────────────────────

async def bj_query(sql: str) -> List[Dict]:
    try:
        async with get_conn() as conn:
            async with conn.cursor(aiomysql.DictCursor) as cur:
                await cur.execute(f"USE {DB}")
                try:
                    await cur.execute(sql)
                    rows = await cur.fetchall()
                    return [dict(r) for r in rows]
                finally:
                    await cur.execute(f"USE {settings.DORIS_DATABASE}")
    except Exception as e:
        print(f"bj_query error: {e}")
        return []


async def bj_query_one(sql: str) -> Dict:
    rows = await bj_query(sql)
    return rows[0] if rows else {}


async def bj_exec(sql: str):
    try:
        async with get_conn() as conn:
            async with conn.cursor() as cur:
                await cur.execute(f"USE {DB}")
                try:
                    await cur.execute(sql)
                    await conn.commit()
                finally:
                    await cur.execute(f"USE {settings.DORIS_DATABASE}")
    except Exception as e:
        print(f"bj_exec error: {e}")


async def bj_exec_many(sql: str, data: list):
    if not data:
        return
    try:
        async with get_conn() as conn:
            async with conn.cursor() as cur:
                await cur.execute(f"USE {DB}")
                try:
                    await cur.executemany(sql, data)
                    await conn.commit()
                finally:
                    await cur.execute(f"USE {settings.DORIS_DATABASE}")
    except Exception as e:
        print(f"bj_exec_many error: {e}")


# ── 静态参考数据 ──────────────────────────────────────────────────────────────

LINES = [
    ("L1",  "1号线",  "#c41f3b", 27, 30.44, 2000, 220, 120, 240),
    ("L2",  "2号线",  "#004b96", 18, 23.10, 1984, 180, 135, 270),
    ("L4",  "4号线",  "#007a3d", 35, 50.17, 2009, 200, 108, 216),
    ("L5",  "5号线",  "#003b99", 23, 27.60, 2007, 185, 120, 240),
    ("L6",  "6号线",  "#e05a08", 34, 52.90, 2012, 165, 108, 216),
    ("L7",  "7号线",  "#1464aa", 30, 40.60, 2014, 120, 120, 240),
    ("L8",  "8号线",  "#008b60", 34, 62.60, 2008, 120, 120, 240),
    ("L9",  "9号线",  "#8cc21c", 13, 16.50, 2011,  70, 120, 270),
    ("L10", "10号线", "#f6ab00", 45, 57.10, 2008, 230, 108, 216),
    ("L13", "13号线", "#f5a623", 16, 40.30, 2002, 140, 180, 360),
    ("L14", "14号线", "#82a43b", 17, 47.70, 2013,  85, 120, 240),
    ("L15", "15号线", "#84d1e5", 20, 41.40, 2010,  80, 120, 240),
]

# (station_id, name, line_id, seq, district, capacity, is_interchange, interchange_lines, is_terminal)
STATIONS = [
    # 1号线
    ("S101", "苹果园",  "L1",  1, "石景山", 35000, 0, "",      1),
    ("S102", "古城",    "L1",  2, "石景山", 28000, 0, "",      0),
    ("S103", "八角游乐园","L1",3, "石景山", 25000, 0, "",      0),
    ("S104", "八宝山",  "L1",  4, "石景山", 30000, 0, "",      0),
    ("S105", "玉泉路",  "L1",  5, "石景山", 32000, 0, "",      0),
    ("S106", "五棵松",  "L1",  6, "海淀",   45000, 0, "",      0),
    ("S107", "万寿路",  "L1",  7, "海淀",   38000, 0, "",      0),
    ("S108", "公主坟",  "L1",  8, "海淀",   55000, 1, "L10",   0),
    ("S109", "木樨地",  "L1",  9, "海淀",   42000, 0, "",      0),
    ("S110", "军事博物馆","L1",10,"海淀",   40000, 0, "",      0),
    ("S111", "王府井",  "L1", 13, "东城",   75000, 0, "",      0),
    ("S112", "建国门",  "L1", 16, "东城",   60000, 1, "L2",    0),
    ("S113", "国贸",    "L1", 17, "朝阳",   90000, 1, "L10",   0),
    ("S114", "大望路",  "L1", 18, "朝阳",   50000, 1, "L14",   0),
    ("S115", "四惠东",  "L1", 27, "朝阳",   40000, 0, "",      1),
    # 2号线
    ("S201", "西直门",  "L2",  1, "西城",   75000, 1, "L4,L13",0),
    ("S202", "鼓楼大街","L2",  3, "东城",   48000, 0, "",      0),
    ("S203", "东直门",  "L2",  7, "东城",   70000, 1, "L13",   0),
    ("S204", "建国门",  "L2", 10, "东城",   60000, 1, "L1",    0),
    ("S205", "北京站",  "L2", 11, "东城",   65000, 0, "",      0),
    ("S206", "宣武门",  "L2", 16, "西城",   62000, 1, "L4",    0),
    # 4号线
    ("S401", "北京南站","L4",  2, "丰台",   95000, 1, "L14",   0),
    ("S402", "马家堡",  "L4",  4, "丰台",   35000, 0, "",      0),
    ("S403", "角门西",  "L4",  5, "丰台",   38000, 1, "L10",   0),
    ("S404", "公益西桥","L4",  7, "丰台",   40000, 1, "L10",   0),
    ("S405", "宣武门",  "L4",  9, "西城",   62000, 1, "L2",    0),
    ("S406", "西单",    "L4", 10, "西城",   80000, 1, "L1",    0),
    ("S407", "西四",    "L4", 11, "西城",   45000, 0, "",      0),
    ("S408", "中关村",  "L4", 14, "海淀",   60000, 0, "",      0),
    ("S409", "北京大学东门","L4",15,"海淀", 50000, 0, "",      0),
    ("S410", "西二旗",  "L4", 20, "昌平",   88000, 1, "L13",   0),
    # 5号线
    ("S501", "天通苑北","L5",  1, "昌平",   72000, 0, "",      1),
    ("S502", "天通苑",  "L5",  2, "昌平",   85000, 0, "",      0),
    ("S503", "天通苑南","L5",  3, "昌平",   68000, 0, "",      0),
    ("S504", "立汤路",  "L5",  4, "昌平",   32000, 0, "",      0),
    ("S505", "惠新西街北口","L5",6,"朝阳",  50000, 1, "L10",   0),
    ("S506", "雍和宫",  "L5", 10, "东城",   55000, 1, "L2",    0),
    ("S507", "东单",    "L5", 12, "东城",   70000, 1, "L1",    0),
    ("S508", "崇文门",  "L5", 13, "东城",   58000, 1, "L2",    0),
    ("S509", "宋家庄",  "L5", 23, "丰台",   62000, 1, "L10,L14",1),
    # 10号线（部分）
    ("S1001","巴沟",    "L10", 1, "海淀",   38000, 1, "L4",    0),
    ("S1002","知春路",  "L10", 4, "海淀",   52000, 1, "L13",   0),
    ("S1003","西土城",  "L10", 5, "海淀",   42000, 1, "L10",   0),
    ("S1004","牡丹园",  "L10", 7, "朝阳",   38000, 0, "",      0),
    ("S1005","惠新西街南口","L10",8,"朝阳", 50000, 1, "L5",    0),
    ("S1006","三元桥",  "L10",10, "朝阳",   58000, 0, "",      0),
    ("S1007","国贸",    "L10",22, "朝阳",   90000, 1, "L1",    0),
    ("S1008","劲松",    "L10",24, "朝阳",   45000, 0, "",      0),
    ("S1009","成寿寺",  "L10",26, "丰台",   40000, 0, "",      0),
    ("S1010","宋家庄",  "L10",28, "丰台",   62000, 1, "L5,L14",0),
    ("S1011","角门西",  "L10",30, "丰台",   38000, 1, "L4",    0),
    ("S1012","公益西桥","L10",32, "丰台",   40000, 1, "L4",    0),
    # 13号线（部分）
    ("S1301","西直门",  "L13", 1, "西城",   75000, 1, "L2,L4", 1),
    ("S1302","大钟寺",  "L13", 2, "海淀",   38000, 0, "",      0),
    ("S1303","知春路",  "L13", 3, "海淀",   52000, 1, "L10",   0),
    ("S1304","西二旗",  "L13", 5, "昌平",   88000, 1, "L4",    0),
    ("S1305","龙泽",    "L13", 6, "昌平",   55000, 0, "",      0),
    ("S1306","回龙观",  "L13", 7, "昌平",   72000, 0, "",      0),
    ("S1307","霍营",    "L13", 8, "昌平",   48000, 0, "",      0),
    ("S1308","东直门",  "L13",16, "东城",   70000, 1, "L2",    1),
]

# OD 热点对 (origin_id, dest_id)
OD_PAIRS = [
    ("S502","S113"), ("S502","S406"), ("S1306","S1304"), ("S1306","S410"),
    ("S501","S408"), ("S401","S406"), ("S401","S113"),   ("S503","S507"),
    ("S1304","S410"),("S1001","S408"),("S113","S1007"),  ("S506","S113"),
    ("S201","S1304"),("S502","S507"), ("S1302","S1304"), ("S503","S113"),
    ("S410","S1304"),("S401","S507"), ("S205","S113"),   ("S504","S410"),
]

# 每小时乘客倍率（相对基准）
HOUR_MULT = [0.03,0.02,0.01,0.01,0.02,0.08,0.45,1.80,1.85,1.22,
             0.88,0.92,1.05,0.90,0.76,1.18,1.62,1.72,1.46,1.12,
             0.80,0.56,0.33,0.14]

# 线路日均基准客流（万人次）
LINE_BASE = {
    "L1":175,"L2":135,"L4":185,"L5":147,"L6":125,
    "L7":112,"L8":108,"L9": 58,"L10":198,"L13":128,
    "L14": 72,"L15": 65,
}

DEVICE_TYPES  = ["AFC闸机","空调通风","信号系统","电梯","扶梯","照明","消防","通信"]
FAULT_TYPES   = ["磁卡读头故障","制冷效果下降","信号延迟","驱动链条断裂",
                 "电机过热","传感器失效","门控故障","紧急停机"]
SEVERITIES    = ["严重","警告","信息"]
HANDLERS      = ["张工","李工","王工","刘工","陈工"]
DISTRICTS     = ["东城","西城","朝阳","海淀","丰台","石景山","昌平","顺义"]

rng = random.Random(42)


# ═══════════════════════════════════════════════════════════
# 初始化服务
# ═══════════════════════════════════════════════════════════

class BJMetroInitService:

    async def init_tables(self) -> Dict:
        """建表：使用独立连接 + finally 恢复，避免污染连接池上下文"""
        sql_path = os.path.join(os.path.dirname(__file__), "../sql/bjmetro_init.sql")
        with open(sql_path, encoding="utf-8") as f:
            raw = f.read()

        # 过滤掉注释行，提取有效 SQL 语句
        stmts = []
        for block in raw.split(";"):
            lines = [l for l in block.splitlines() if l.strip() and not l.strip().startswith("--")]
            stmt = "\n".join(lines).strip()
            if stmt and not stmt.upper().startswith("CREATE DATABASE") and not stmt.upper().startswith("USE"):
                stmts.append(stmt)

        executed, skipped = 0, 0
        try:
            # 先用无上下文依赖的方式建库
            await execute_query(f"CREATE DATABASE IF NOT EXISTS {DB}")

            async with get_conn() as conn:
                async with conn.cursor() as cur:
                    await cur.execute(f"USE {DB}")
                    try:
                        for stmt in stmts:
                            try:
                                await cur.execute(stmt)
                                executed += 1
                            except Exception as e:
                                print(f"init_tables skip: {e}")
                                skipped += 1
                    finally:
                        # 恢复默认库，避免污染连接池
                        await cur.execute(f"USE {settings.DORIS_DATABASE}")

            return {"success": True, "msg": f"建表完成（{executed}条执行，{skipped}条跳过）"}
        except Exception as e:
            return {"success": False, "msg": str(e)}

    async def seed_data(self) -> Dict:
        try:
            # 先清空，确保旧脏数据不残留
            for t in ["bj_metro_od_flow","bj_metro_revenue","bj_metro_fault_log",
                      "bj_metro_train_ops","bj_metro_hourly_flow","bj_metro_daily_flow",
                      "bj_metro_stations","bj_metro_lines"]:
                await bj_exec(f"TRUNCATE TABLE {t}")
            await self._seed_lines()
            await self._seed_stations()
            await self._seed_daily_flow()
            await self._seed_hourly_flow()
            await self._seed_train_ops()
            await self._seed_fault_log()
            await self._seed_revenue()
            await self._seed_od_flow()
            return {"success": True, "msg": "示例数据导入完成（30天）"}
        except Exception as e:
            return {"success": False, "msg": str(e)}

    async def _seed_lines(self):
        sql = """INSERT INTO bj_metro_lines
            (line_id,line_name,line_color,total_stations,total_length_km,
             open_year,daily_capacity_w,peak_interval_s,offpeak_interval_s,status)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,'运营')"""
        await bj_exec_many(sql, [r[:9] for r in LINES])

    async def _seed_stations(self):
        sql = """INSERT INTO bj_metro_stations
            (station_id,station_name,line_id,sequence_no,district,
             daily_capacity,is_interchange,interchange_lines,is_terminal)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        await bj_exec_many(sql, STATIONS)

    async def _seed_daily_flow(self):
        sql = """INSERT INTO bj_metro_daily_flow
            (flow_date,station_id,line_id,inbound_count,outbound_count,peak_inbound)
            VALUES (%s,%s,%s,%s,%s,%s)"""
        today = date.today()
        rows = []
        for d in range(30):
            day = today - timedelta(days=29 - d)
            is_weekend = day.weekday() >= 5
            factor = 0.75 if is_weekend else 1.0
            for sid, sname, lid, *rest in STATIONS:
                cap = rest[2]  # daily_capacity (index: seq=0, district=1, capacity=2)
                base = int(cap * factor * rng.uniform(0.70, 0.95))
                peak = int(base * rng.uniform(0.08, 0.14))
                rows.append((day, sid, lid, base, base, peak))
        await bj_exec_many(sql, rows)

    async def _seed_hourly_flow(self):
        sql = """INSERT INTO bj_metro_hourly_flow
            (flow_date,flow_hour,line_id,total_passengers,overcapacity_cnt)
            VALUES (%s,%s,%s,%s,%s)"""
        today = date.today()
        rows = []
        for d in range(30):
            day = today - timedelta(days=29 - d)
            is_weekend = day.weekday() >= 5
            factor = 0.75 if is_weekend else 1.0
            for lid, _n, _c, _s, _l, _y, base_w, _p, _o in LINES:
                base_day = base_w * 10000 * factor
                for h in range(24):
                    passengers = int(base_day * HOUR_MULT[h] * rng.uniform(0.93, 1.07))
                    overcap = rng.randint(0, 3) if HOUR_MULT[h] > 1.5 else 0
                    rows.append((day, h, lid, passengers, overcap))
        await bj_exec_many(sql, rows)

    async def _seed_train_ops(self):
        sql = """INSERT INTO bj_metro_train_ops
            (ops_date,line_id,planned_trains,actual_trains,punctuality_rate,
             delay_count,max_delay_sec,total_mileage_km,fault_count)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        today = date.today()
        rows = []
        for d in range(30):
            day = today - timedelta(days=29 - d)
            for lid, _n, _c, _s, _l, _y, _b, peak_s, _o in LINES:
                planned = rng.randint(80, 120)
                actual  = planned - rng.randint(0, 2)
                punct   = round(rng.uniform(0.972, 0.999), 4)
                delays  = rng.randint(0, 5)
                max_d   = rng.randint(30, 180) if delays > 0 else 0
                mileage = round(actual * rng.uniform(400, 600), 2)
                faults  = rng.randint(0, 3)
                rows.append((day, lid, planned, actual, punct, delays, max_d, mileage, faults))
        await bj_exec_many(sql, rows)

    async def _seed_fault_log(self):
        sql = """INSERT INTO bj_metro_fault_log
            (fault_id,fault_time,line_id,station_id,device_type,fault_type,
             severity,description,resolve_time,resolve_min,status,handler)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        today = datetime.now()
        rows = []
        for i in range(300):
            delta_h = rng.uniform(0, 30 * 24)
            ft_dt   = today - timedelta(hours=delta_h)
            sid, sname, lid, *_ = rng.choice(STATIONS)
            dev  = rng.choice(DEVICE_TYPES)
            ftyp = rng.choice(FAULT_TYPES)
            sev  = rng.choices(SEVERITIES, weights=[1, 3, 5])[0]
            res_m = rng.randint(15, 240)
            res_dt = ft_dt + timedelta(minutes=res_m)
            status = "已关闭" if res_dt < today else "处理中"
            desc = f"{sname}站 {dev} {ftyp}，已{'派遣维修人员' if sev=='严重' else '登记处理'}"
            rows.append((
                f"F{i+1:05d}", ft_dt, lid, sid, dev, ftyp, sev,
                desc, res_dt, res_m, status, rng.choice(HANDLERS)
            ))
        await bj_exec_many(sql, rows)

    async def _seed_revenue(self):
        sql = """INSERT INTO bj_metro_revenue
            (revenue_date,line_id,ticket_revenue,subsidy_amount,
             ticket_count,ad_revenue,commercial_revenue)
            VALUES (%s,%s,%s,%s,%s,%s,%s)"""
        today = date.today()
        rows = []
        for d in range(30):
            day = today - timedelta(days=29 - d)
            is_weekend = day.weekday() >= 5
            factor = 0.75 if is_weekend else 1.0
            for lid, _n, _c, _s, _l, _y, base_w, _p, _o in LINES:
                passengers = int(base_w * 10000 * factor * rng.uniform(0.93, 1.07))
                avg_fare   = rng.randint(280, 340)          # 分
                ticket_rev = passengers * avg_fare
                subsidy    = int(ticket_rev * rng.uniform(0.08, 0.12))
                ad_rev     = int(base_w * rng.uniform(1500, 2500) * 100)  # 分
                comm_rev   = int(base_w * rng.uniform(800, 1500) * 100)
                rows.append((day, lid, ticket_rev, subsidy, passengers, ad_rev, comm_rev))
        await bj_exec_many(sql, rows)

    async def _seed_od_flow(self):
        sql = """INSERT INTO bj_metro_od_flow
            (flow_date,origin_id,dest_id,peak_type,flow_count)
            VALUES (%s,%s,%s,%s,%s)"""
        today = date.today()
        rows = []
        for d in range(30):
            day = today - timedelta(days=29 - d)
            is_weekend = day.weekday() >= 5
            factor = 0.75 if is_weekend else 1.0
            for orig, dest in OD_PAIRS:
                for ptype, mult in [("morning", 1.4), ("evening", 1.2), ("off", 0.5)]:
                    cnt = int(rng.randint(15000, 45000) * factor * mult)
                    rows.append((day, orig, dest, ptype, cnt))
        await bj_exec_many(sql, rows)


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

        return {
            "daily_passengers_w": round(passengers / 10000, 1),
            "punctuality_rate":   round(float(row2.get("avg_punct") or 0.994), 4),
            "daily_revenue_w":    total_rev_w,
            "fault_count":        int(row2.get("faults") or 0),
            "active_lines":       len(LINES),
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
            WHERE f.status='处理中'
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
                   ROUND(AVG(CASE WHEN DAYOFWEEK(flow_date) IN (1,7) THEN total_passengers END)) AS weekend_avg
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
        rows = await bj_query(f"""
            SELECT o.origin_id, s1.station_name AS origin_name,
                   o.dest_id,   s2.station_name AS dest_name,
                   SUM(o.flow_count) AS total_flow
            FROM bj_metro_od_flow o
            JOIN bj_metro_stations s1 ON o.origin_id=s1.station_id
            JOIN bj_metro_stations s2 ON o.dest_id=s2.station_id
            WHERE o.peak_type='{peak_type}'
            GROUP BY o.origin_id,s1.station_name,o.dest_id,s2.station_name
            ORDER BY total_flow DESC LIMIT 15""")
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
                   SUM(CASE WHEN status='处理中' THEN 1 ELSE 0 END) AS open_faults,
                   SUM(CASE WHEN severity='严重'  THEN 1 ELSE 0 END) AS critical,
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
                   SUM(CASE WHEN severity='严重' THEN 1 ELSE 0 END) AS critical_cnt
            FROM bj_metro_fault_log
            GROUP BY device_type ORDER BY cnt DESC""")
        return {"data": rows}

    async def fault_by_line(self) -> Dict:
        rows = await bj_query("""
            SELECT f.line_id, l.line_name, l.line_color,
                   COUNT(*) AS total_faults,
                   SUM(CASE WHEN f.severity='严重' THEN 1 ELSE 0 END) AS critical_cnt,
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
            ORDER BY f.fault_time DESC LIMIT 20""")
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
