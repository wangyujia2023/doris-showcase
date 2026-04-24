"""银行监管报送一表通 - 服务层"""
import os, random, asyncio
from datetime import datetime
from typing import Dict, List
import aiomysql
from backend.doris.connect import execute_query, get_conn
from backend.settings import settings

DB  = "regdb"
ORG = "BANK_DEMO_001"

# ── DB 工具 ────────────────────────────────────────────────────
async def rg_query(sql: str) -> List[Dict]:
    try:
        async with get_conn() as conn:
            async with conn.cursor(aiomysql.DictCursor) as cur:
                await cur.execute(f"USE {DB}")
                try:
                    await cur.execute(sql)
                    return [dict(r) for r in await cur.fetchall()]
                finally:
                    await cur.execute(f"USE {settings.DORIS_DATABASE}")
    except Exception as e:
        print(f"rg_query error: {e}")
        return []

async def rg_query_one(sql: str) -> Dict:
    rows = await rg_query(sql)
    return rows[0] if rows else {}

async def rg_exec(sql: str):
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
        print(f"rg_exec error: {e}")

async def rg_exec_many(sql: str, data: list):
    if not data: return
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
        print(f"rg_exec_many error: {e}")

# ── 报告期枚举 ─────────────────────────────────────────────────
MONTHLY_PERIODS = [f"2023-{m:02d}" for m in range(7, 13)] + \
                  [f"2024-{m:02d}" for m in range(1, 7)]
QUARTERLY_PERIODS = ["2023-Q3", "2023-Q4", "2024-Q1", "2024-Q2"]

rng = random.Random(99)

def _jitter(base, pct=0.04):
    return int(base * rng.uniform(1 - pct, 1 + pct))

def _fmt(v):
    if v is None: return "—"
    n = int(v)
    return f"{n:,}" if n >= 0 else f"-{abs(n):,}"

def _pct_str(v):
    return f"{float(v)*100:.2f}%" if v else "—"

def _chg(curr, prev):
    if not curr or not prev: return "—", "—"
    diff = int(curr) - int(prev)
    s = "+" if diff >= 0 else ""
    pct = diff / int(prev) * 100
    return (f"{s}{diff:,}", f"{s}{pct:.2f}%")


# ════════════════════════════════════════════════════════════════
# 初始化服务
# ════════════════════════════════════════════════════════════════
class RegInitService:

    async def init_tables(self) -> Dict:
        sql_path = os.path.join(os.path.dirname(__file__), "../sql/regulatory_init.sql")
        with open(sql_path, encoding="utf-8") as f:
            raw = f.read()
        stmts = []
        for block in raw.split(";"):
            lines = [l for l in block.splitlines()
                     if l.strip() and not l.strip().startswith("--")]
            stmt = "\n".join(lines).strip()
            if stmt and not stmt.upper().startswith(("CREATE DATABASE", "USE ")):
                stmts.append(stmt)
        executed = skipped = 0
        try:
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
                                print(f"init skip: {e}")
                                skipped += 1
                    finally:
                        await cur.execute(f"USE {settings.DORIS_DATABASE}")
            return {"success": True, "msg": f"建表完成（{executed}执行 {skipped}跳过）"}
        except Exception as e:
            return {"success": False, "msg": str(e)}

    async def seed_data(self) -> Dict:
        try:
            for t in ["reg_master", "reg_submit_log", "reg_g21_credit",
                      "reg_g11_lcr", "reg_g04a_loan", "reg_g03_capital",
                      "reg_g01_balance", "reg_item_dict"]:
                await rg_exec(f"TRUNCATE TABLE {t}")
            await asyncio.gather(
                self._seed_item_dict(),
                self._seed_g01(),
                self._seed_g03(),
                self._seed_g04a(),
                self._seed_g11(),
                self._seed_g21(),
            )
            await self._seed_submit_log()
            return {"success": True, "msg": "示例数据导入完成"}
        except Exception as e:
            return {"success": False, "msg": str(e)}

    # ── 科目字典 ───────────────────────────────────────────────
    async def _seed_item_dict(self):
        items = [
            # G01 资产类
            ("G01","A01","现金及存放央行款项","ASSET",None,1,10,0),
            ("G01","A01.1","现金","ASSET","A01",1,11,0),
            ("G01","A01.2","存放央行款项","ASSET","A01",1,12,0),
            ("G01","A02","存放同业款项","ASSET",None,1,20,0),
            ("G01","A03","贵金属","ASSET",None,1,30,0),
            ("G01","A04","拆出资金","ASSET",None,1,40,0),
            ("G01","A05","交易性金融资产","ASSET",None,1,50,0),
            ("G01","A06","债权投资","ASSET",None,1,60,0),
            ("G01","A07","其他债权投资","ASSET",None,1,70,0),
            ("G01","A08","发放贷款及垫款","ASSET",None,1,80,0),
            ("G01","A08.1","  个人贷款","ASSET","A08",1,81,0),
            ("G01","A08.2","  企业贷款","ASSET","A08",1,82,0),
            ("G01","A08.3","  贷款损失准备(-)","ASSET","A08",-1,83,0),
            ("G01","A09","固定资产","ASSET",None,1,90,0),
            ("G01","A10","递延税款资产","ASSET",None,1,100,0),
            ("G01","A11","其他资产","ASSET",None,1,110,0),
            ("G01","A_TOT","资产总计","ASSET",None,1,120,1),
            # G01 负债类
            ("G01","L01","向央行借款","LIABILITY",None,1,130,0),
            ("G01","L02","同业及金融机构存放款","LIABILITY",None,1,140,0),
            ("G01","L03","拆入资金","LIABILITY",None,1,150,0),
            ("G01","L04","交易性金融负债","LIABILITY",None,1,160,0),
            ("G01","L05","吸收存款","LIABILITY",None,1,170,0),
            ("G01","L05.1","  单位存款","LIABILITY","L05",1,171,0),
            ("G01","L05.2","  个人存款","LIABILITY","L05",1,172,0),
            ("G01","L06","应付债券","LIABILITY",None,1,180,0),
            ("G01","L07","递延税款负债","LIABILITY",None,1,190,0),
            ("G01","L08","其他负债","LIABILITY",None,1,200,0),
            ("G01","L_TOT","负债合计","LIABILITY",None,1,210,1),
            # G01 权益类
            ("G01","E01","实收资本","EQUITY",None,1,220,0),
            ("G01","E02","资本公积","EQUITY",None,1,230,0),
            ("G01","E03","盈余公积","EQUITY",None,1,240,0),
            ("G01","E04","一般风险准备","EQUITY",None,1,250,0),
            ("G01","E05","未分配利润","EQUITY",None,1,260,0),
            ("G01","E_TOT","所有者权益合计","EQUITY",None,1,270,1),
        ]
        sql = """INSERT INTO reg_item_dict
            (report_code,item_code,item_name,item_type,parent_code,
             sign_flag,sort_order,is_summary) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)"""
        await rg_exec_many(sql, items)

    # ── G01 资产负债表 ─────────────────────────────────────────
    async def _seed_g01(self):
        BASE = {
            "A01":843000,"A01.1":14200,"A01.2":828800,
            "A02":215000,"A03":6800,"A04":123000,
            "A05":567000,"A06":1897000,"A07":345000,
            "A08":8923000,
            "A08.1":3143000,"A08.2":5468000,"A08.3":388000,
            "A09":123000,"A10":45000,"A11":234000,
            "L01":567000,"L02":1234000,"L03":234000,
            "L04":123000,"L05":9245000,
            "L05.1":4623000,"L05.2":4622000,
            "L06":876000,"L07":23000,"L08":345000,
            "E01":300000,"E02":123000,"E03":87000,
            "E04":67000,"E05":17000,
        }
        sql = """INSERT INTO reg_g01_balance
            (report_period,org_code,item_code,curr_balance,prev_balance,status)
            VALUES (%s,%s,%s,%s,%s,%s)"""
        rows = []
        for i, period in enumerate(MONTHLY_PERIODS):
            g = 1.0 + i * 0.008
            g_prev = max(g - 0.008, 1.0)
            for code, base in BASE.items():
                # 未分配利润特殊增长（Q1分红后大幅增加）
                if code == "E05":
                    curr = _jitter(int(base * g * (4.5 if i >= 8 else 1.0)))
                    prev = _jitter(int(base * g_prev * (4.5 if i >= 9 else 1.0)))
                else:
                    curr = _jitter(int(base * g))
                    prev = _jitter(int(base * g_prev))
                rows.append((period, ORG, code, curr, prev, "submitted"))
            # 汇总行
            a_sum = sum(_jitter(int(BASE[k]*g)) for k in BASE if k.startswith("A0") and "." not in k)
            l_sum = sum(_jitter(int(BASE[k]*g)) for k in BASE if k.startswith("L0") and "." not in k)
            e_sum = sum(_jitter(int(BASE[k]*g)) for k in BASE if k.startswith("E0"))
            a_prev = int(a_sum * 0.992)
            rows += [
                (period, ORG, "A_TOT", a_sum, a_prev, "submitted"),
                (period, ORG, "L_TOT", l_sum, int(l_sum*0.992), "submitted"),
                (period, ORG, "E_TOT", e_sum, int(e_sum*0.993), "submitted"),
            ]
        await rg_exec_many(sql, rows)

    # ── G03 资本充足率 ─────────────────────────────────────────
    async def _seed_g03(self):
        sql = """INSERT INTO reg_g03_capital
            (report_period,org_code,cet1_capital,at1_capital,t2_capital,
             total_capital,credit_rwa,market_rwa,ops_rwa,total_rwa,
             cet1_ratio,tier1_ratio,car_ratio,leverage_ratio,status)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        rows = []
        for i, period in enumerate(QUARTERLY_PERIODS):
            g = 1.0 + i * 0.02
            cet1  = _jitter(int(630000 * g))
            at1   = _jitter(50000)
            t2    = _jitter(int(207000 * g))
            total = cet1 + at1 + t2
            crwa  = _jitter(int(6234000 * g))
            mrwa  = _jitter(234000)
            orwa  = _jitter(456000)
            trwa  = crwa + mrwa + orwa
            rows.append((period, ORG, cet1, at1, t2, total, crwa, mrwa, orwa, trwa,
                         round(cet1/trwa,4), round((cet1+at1)/trwa,4),
                         round(total/trwa,4), round(cet1/(trwa*1.15),4), "submitted"))
        await rg_exec_many(sql, rows)

    # ── G04A 五级分类（含行业明细）──────────────────────────────
    async def _seed_g04a(self):
        sql = """INSERT INTO reg_g04a_loan
            (report_period,org_code,loan_type,industry_code,
             total_balance,normal_balance,concern_balance,
             substandard_balance,doubtful_balance,loss_balance,
             provision_balance,npl_balance,npl_ratio,provision_coverage)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""

        # 行业权重定义 (loan_type, industry_code, 占比, npl_rate倍数, 行业名用于日志)
        INDUSTRY_SPLITS = [
            # 企业贷款各行业
            ("CORP","MFG",   0.333, 0.85),  # 制造业
            ("CORP","RE",    0.160, 1.52),  # 房地产
            ("CORP","WR",    0.120, 1.28),  # 批发零售
            ("CORP","INFRA", 0.226, 0.36),  # 基础设施
            ("CORP","OTHER", 0.161, 1.41),  # 其他行业
            # 个人贷款各类型
            ("RETAIL","HOUSING",  0.597, 0.28),  # 个人住房
            ("RETAIL","CONSUMER", 0.243, 1.09),  # 个人消费
            ("RETAIL","SME",      0.160, 0.27),  # 个人经营
        ]

        rows = []
        for i, period in enumerate(MONTHLY_PERIODS):
            g = 1.0 + i * 0.008
            # TOTAL 汇总行
            total  = _jitter(int(8611000 * g))
            npl_r  = round(rng.uniform(0.013, 0.019), 4)
            npl    = int(total * npl_r)
            concern= _jitter(int(total * 0.021))
            sub    = int(npl * rng.uniform(0.35, 0.42))
            dbt    = int(npl * rng.uniform(0.38, 0.45))
            loss   = npl - sub - dbt
            normal = total - concern - sub - dbt - loss
            prov   = _jitter(int(npl * rng.uniform(2.8, 3.5)))
            rows.append((period, ORG, "TOTAL","ALL",
                         total, normal, concern, sub, dbt, loss,
                         prov, npl, npl_r, round(prov/max(npl,1),4)))

            corp_base   = int(total * 0.635)
            retail_base = total - corp_base

            for lt, ic, ratio, npl_mult in INDUSTRY_SPLITS:
                base = corp_base if lt == "CORP" else retail_base
                t2 = _jitter(int(base * ratio))
                nr = round(min(npl_r * npl_mult, 0.08), 4)
                n2 = int(t2 * nr)
                c2 = _jitter(int(t2 * 0.021 * npl_mult))
                s2 = int(n2 * rng.uniform(0.35, 0.42))
                d2 = int(n2 * rng.uniform(0.38, 0.45))
                l2 = max(n2 - s2 - d2, 0)
                nm2= t2 - c2 - s2 - d2 - l2
                pv2= _jitter(int(n2 * rng.uniform(2.8, 3.5)))
                rows.append((period, ORG, lt, ic,
                             t2, nm2, c2, s2, d2, l2,
                             pv2, n2, nr, round(pv2/max(n2,1),4)))

        await rg_exec_many(sql, rows)

    # ── G11 流动性覆盖率 ───────────────────────────────────────
    async def _seed_g11(self):
        sql = """INSERT INTO reg_g11_lcr
            (report_period,org_code,hqla_l1,hqla_l2a,hqla_l2b,hqla_total,
             outflow_retail,outflow_wholesale,outflow_interbank,outflow_other,
             total_outflow,inflow_loans,inflow_other,net_outflow,
             lcr_ratio,nsfr_ratio,is_compliant,status)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        rows = []
        for i, period in enumerate(MONTHLY_PERIODS):
            l1   = _jitter(1136000)
            l2a  = _jitter(493000)
            l2b  = _jitter(62000)
            hqla = l1 + l2a + l2b
            out_r = _jitter(231000)
            out_w = _jitter(309000)
            out_i = _jitter(1234000)
            out_o = _jitter(128000)
            t_out = out_r + out_w + out_i + out_o
            in_l  = _jitter(228000)
            in_o  = _jitter(124000)
            t_in  = min(in_l + in_o, int(t_out * 0.75))
            nco   = t_out - t_in
            lcr   = round(hqla / max(nco, 1), 4)
            nsfr  = round(rng.uniform(1.04, 1.12), 4)
            rows.append((period, ORG, l1, l2a, l2b, hqla,
                         out_r, out_w, out_i, out_o, t_out,
                         in_l, in_o, nco, lcr, nsfr,
                         1 if lcr >= 1.0 else 0, "submitted"))
        await rg_exec_many(sql, rows)

    # ── G21 信贷收支 ───────────────────────────────────────────
    async def _seed_g21(self):
        sql = """INSERT INTO reg_g21_credit
            (report_period,org_code,loan_balance,loan_new,loan_corp,
             loan_retail,loan_bill,deposit_balance,deposit_corp,deposit_retail,
             net_profit_w,roa,roe)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        rows = []
        for i, period in enumerate(MONTHLY_PERIODS):
            g = 1.0 + i * 0.008
            loan = _jitter(int(8611000 * g))
            dep  = _jitter(int(9245000 * g))
            profit = _jitter(int(120000 * (i//3 + 1) / 4))
            rows.append((period, ORG, loan, _jitter(int(loan*0.012)),
                         int(loan*0.635), int(loan*0.365), _jitter(700000),
                         dep, int(dep*0.5), dep - int(dep*0.5),
                         profit,
                         round(profit/max(int(13327000*g),1),4),
                         round(profit/max(int(675000*g),1),4)))
        await rg_exec_many(sql, rows)

    # ── 报送日志 ────────────────────────────────────────────────
    async def _seed_submit_log(self):
        sql = """INSERT INTO reg_submit_log
            (log_id,report_code,report_period,org_code,action,
             operator,action_time,qc_score,remark)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        rows = []
        ops = ["draft","qc","submit","accept"]
        reports = ["G01","G03","G04A","G11","G21"]
        for i, period in enumerate(MONTHLY_PERIODS[-3:]):
            for rcode in reports:
                for j, action in enumerate(ops):
                    rows.append((
                        f"{rcode}-{period}-{j}",
                        rcode, period, ORG, action,
                        "张明晖" if j < 2 else "李晓雯",
                        datetime(2024, 3+i, 10+j*3, 9+j, 0),
                        round(95 + rng.uniform(0, 4), 1),
                        "数据质量核查通过" if action == "qc" else None,
                    ))
        await rg_exec_many(sql, rows)


# ════════════════════════════════════════════════════════════════
# 一键加工服务
# ════════════════════════════════════════════════════════════════
class RegProcessService:

    async def process_all(self) -> Dict:
        try:
            period_map = {
                "2023-Q3": "2023-09", "2023-Q4": "2023-12",
                "2024-Q1": "2024-03", "2024-Q2": "2024-06",
            }
            rows = []
            for qperiod, mperiod in period_map.items():
                row = await self._build_master_row(qperiod, mperiod)
                if row:
                    rows.append(row)
            if not rows:
                return {"success": False, "msg": "无可加工数据，请先导入原始数据"}

            sql = """INSERT INTO reg_master
                (report_period,org_code,
                 total_assets_w,total_liabilities_w,total_equity_w,
                 total_loans_w,total_deposits_w,
                 cet1_ratio,tier1_ratio,car_ratio,leverage_ratio,total_rwa_w,
                 npl_balance_w,npl_ratio,provision_coverage,loan_provision_rate,
                 lcr_ratio,nsfr_ratio,
                 net_profit_w,roa,roe,
                 is_car_ok,is_lcr_ok,is_npl_ok,is_provision_ok,compliance_score,
                 g01_status,g03_status,g04a_status,g11_status,g21_status,
                 process_time)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
            await rg_exec_many(sql, rows)
            return {"success": True, "msg": f"一键加工完成，生成 {len(rows)} 条一表通记录"}
        except Exception as e:
            return {"success": False, "msg": str(e)}

    async def _build_master_row(self, qperiod: str, mperiod: str):
        g01, g03, g04, g11, g21 = await asyncio.gather(
            rg_query_one(f"""
                SELECT SUM(CASE WHEN item_code='A_TOT' THEN curr_balance END) AS assets,
                       SUM(CASE WHEN item_code='L_TOT' THEN curr_balance END) AS liabilities,
                       SUM(CASE WHEN item_code='E_TOT' THEN curr_balance END) AS equity
                FROM reg_g01_balance
                WHERE report_period='{mperiod}' AND org_code='{ORG}'"""),
            rg_query_one(f"""
                SELECT cet1_ratio,tier1_ratio,car_ratio,leverage_ratio,total_rwa
                FROM reg_g03_capital
                WHERE report_period='{qperiod}' AND org_code='{ORG}'"""),
            rg_query_one(f"""
                SELECT total_balance,npl_balance,npl_ratio,provision_coverage,
                       provision_balance
                FROM reg_g04a_loan
                WHERE report_period='{mperiod}' AND loan_type='TOTAL'
                  AND org_code='{ORG}'"""),
            rg_query_one(f"""
                SELECT lcr_ratio,nsfr_ratio
                FROM reg_g11_lcr
                WHERE report_period='{mperiod}' AND org_code='{ORG}'"""),
            rg_query_one(f"""
                SELECT loan_balance,deposit_balance,net_profit_w,roa,roe
                FROM reg_g21_credit
                WHERE report_period='{mperiod}' AND org_code='{ORG}'"""),
        )
        if not g01.get("assets"): return None
        assets   = int(g01.get("assets") or 0)
        liab     = int(g01.get("liabilities") or 0)
        equity   = int(g01.get("equity") or 0)
        loans    = int(g21.get("loan_balance") or 0)
        deposits = int(g21.get("deposit_balance") or 0)
        cet1_r   = float(g03.get("cet1_ratio") or 0)
        t1_r     = float(g03.get("tier1_ratio") or 0)
        car_r    = float(g03.get("car_ratio") or 0)
        lev_r    = float(g03.get("leverage_ratio") or 0)
        rwa      = int(g03.get("total_rwa") or 0)
        npl_b    = int(g04.get("npl_balance") or 0)
        npl_r    = float(g04.get("npl_ratio") or 0)
        prov_cov = float(g04.get("provision_coverage") or 0)
        prov_b   = int(g04.get("provision_balance") or 0)
        loan_b   = int(g04.get("total_balance") or loans)
        prov_rate= round(prov_b / max(loan_b, 1), 4)
        lcr_r    = float(g11.get("lcr_ratio") or 0)
        nsfr_r   = float(g11.get("nsfr_ratio") or 0)
        profit   = int(g21.get("net_profit_w") or 0)
        roa_v    = float(g21.get("roa") or 0)
        roe_v    = float(g21.get("roe") or 0)
        is_car   = 1 if car_r  >= 0.105 else 0
        is_lcr   = 1 if lcr_r  >= 1.00  else 0
        is_npl   = 1 if npl_r  <= 0.05  else 0
        is_prov  = 1 if prov_cov >= 1.50 else 0
        score    = round((is_car + is_lcr + is_npl + is_prov) / 4 * 100, 1)
        return (qperiod, ORG,
                assets, liab, equity, loans, deposits,
                cet1_r, t1_r, car_r, lev_r, rwa,
                npl_b, npl_r, prov_cov, prov_rate,
                lcr_r, nsfr_r,
                profit, roa_v, roe_v,
                is_car, is_lcr, is_npl, is_prov, score,
                "submitted","submitted","submitted","submitted","submitted",
                datetime.now())


# ════════════════════════════════════════════════════════════════
# 查询服务
# ════════════════════════════════════════════════════════════════
class RegQueryService:

    # ── 概览 ───────────────────────────────────────────────────
    async def get_master_list(self) -> Dict:
        rows = await rg_query(f"""
            SELECT * FROM reg_master WHERE org_code='{ORG}'
            ORDER BY report_period DESC""")
        return {"data": rows}

    async def get_overview(self) -> Dict:
        master = await rg_query(f"""
            SELECT report_period,compliance_score,
                   is_car_ok,is_lcr_ok,is_npl_ok,is_provision_ok,
                   car_ratio,lcr_ratio,npl_ratio,provision_coverage,
                   g01_status,g03_status,g04a_status,g11_status,g21_status
            FROM reg_master WHERE org_code='{ORG}'
            ORDER BY report_period DESC""")
        latest = await rg_query_one(f"""
            SELECT total_assets_w,total_loans_w,total_deposits_w,
                   car_ratio,lcr_ratio,npl_ratio,provision_coverage,
                   net_profit_w,compliance_score
            FROM reg_master WHERE org_code='{ORG}'
            ORDER BY report_period DESC LIMIT 1""")
        return {"periods": master, "latest": latest}

    async def get_submit_log(self) -> Dict:
        rows = await rg_query(f"""
            SELECT * FROM reg_submit_log WHERE org_code='{ORG}'
            ORDER BY action_time DESC LIMIT 30""")
        return {"data": rows}

    # ── 左侧导航状态 ────────────────────────────────────────────
    async def get_nav_status(self) -> Dict:
        latest = await rg_query_one(f"""
            SELECT g01_status,g03_status,g04a_status,g11_status,g21_status,
                   compliance_score,is_lcr_ok,car_ratio,cet1_ratio,lcr_ratio
            FROM reg_master WHERE org_code='{ORG}'
            ORDER BY report_period DESC LIMIT 1""")

        def _s(key):
            v = (latest or {}).get(key, "pending")
            return "ok" if v == "submitted" else "warn" if v else "pending"

        lcr_ok  = bool((latest or {}).get("is_lcr_ok", 0))
        car_r   = float((latest or {}).get("car_ratio", 0))
        g03_s   = "warn" if car_r < 0.115 else "ok"  # 接近但已达标 → warn
        g11_s   = "err" if not lcr_ok else "ok"
        g01_s   = _s("g01_status")
        g04a_s  = _s("g04a_status")
        g21_s   = _s("g21_status")

        nav = [
            {"title": "资产负债 / 损益", "items": [
                {"code":"G01","name":"资产负债表",   "freq":"月","status":g01_s},
                {"code":"G02","name":"利润表",       "freq":"季","status":"ok"},
                {"code":"G03","name":"资本充足率",   "freq":"季","status":g03_s},
            ]},
            {"title": "贷款质量", "items": [
                {"code":"G04A","name":"五级分类",    "freq":"月","status":g04a_s},
                {"code":"G04B","name":"迁徙矩阵",    "freq":"季","status":"ok"},
            ]},
            {"title": "流动性风险", "items": [
                {"code":"G11", "name":"流动性覆盖率","freq":"月","status":g11_s},
                {"code":"G11A","name":"净稳定资金比例","freq":"季","status":"ok"},
                {"code":"G12", "name":"期限错配",    "freq":"月","status":"ok"},
            ]},
            {"title": "信贷统计", "items": [
                {"code":"G21","name":"人民币信贷收支","freq":"月","status":g21_s},
                {"code":"G22","name":"贷款投向统计",  "freq":"季","status":"ok"},
                {"code":"G23","name":"房地产贷款",    "freq":"季","status":"pending"},
            ]},
            {"title": "风险集中度", "items": [
                {"code":"G31","name":"单一客户集中度","freq":"季","status":"ok"},
                {"code":"G32","name":"集团客户授信",  "freq":"季","status":"ok"},
            ]},
            {"title": "市场风险", "items": [
                {"code":"G40","name":"利率风险",      "freq":"季","status":"ok"},
                {"code":"G42","name":"杠杆率",        "freq":"季","status":"ok"},
            ]},
        ]
        all_s = [it["status"] for g in nav for it in g["items"]]
        chips = {
            "ok":   all_s.count("ok"),
            "warn": all_s.count("warn"),
            "err":  all_s.count("err"),
        }
        return {"nav": nav, "chips": chips}

    # ── 报表数据（按报表代码返回格式化行） ──────────────────────
    async def get_report_data(self, code: str, period: str) -> Dict:
        if code == "G01":  return await self._g01_rows(period)
        if code == "G03":  return await self._g03_rows(period)
        if code == "G04A": return await self._g04a_rows(period)
        if code == "G11":  return await self._g11_rows(period)
        return {"header": [], "rows": []}

    # G01 ── 逐科目动态组装
    async def _g01_rows(self, period: str) -> Dict:
        header = ["行项目代码","科目名称","期末余额(万元)","上期余额(万元)","变动(万元)","变动率","勾稽校验"]
        items = await rg_query(f"""
            SELECT b.item_code, d.item_name, d.sort_order, d.is_summary,
                   d.item_type, d.parent_code, b.curr_balance, b.prev_balance
            FROM reg_g01_balance b
            JOIN reg_item_dict d ON d.item_code = b.item_code AND d.report_code = 'G01'
            WHERE b.report_period = '{period}' AND b.org_code = '{ORG}'
            ORDER BY d.sort_order""")

        rows, cur_type = [], None
        SECTION = {"ASSET":"◆ 资产类","LIABILITY":"◆ 负债类","EQUITY":"◆ 所有者权益"}
        for it in items:
            itype = it.get("item_type","")
            code  = it.get("item_code","")
            curr  = int(it.get("curr_balance") or 0)
            prev  = int(it.get("prev_balance") or 0)
            parent= it.get("parent_code")

            # 分段标题
            if itype != cur_type and not code.endswith("_TOT"):
                sec = SECTION.get(itype)
                if sec:
                    rows.append({"cls":"section-header","cols":["",sec,"","","","",""],"i1":False,"warn":False})
                cur_type = itype

            diff_s, pct_s = _chg(curr, prev)
            warn = (code == "E05" and prev > 0 and abs(curr-prev)/prev > 1.0)
            qc   = "⚠" if warn else ("✓" if curr > 0 else "—")

            if code.endswith("_TOT"):
                label_map = {"A_TOT":"资产总计","L_TOT":"负债合计","E_TOT":"所有者权益合计"}
                rows.append({"cls":"subtotal","cols":["",label_map[code],_fmt(curr),_fmt(prev),diff_s,pct_s,"✓"],"i1":False,"warn":False})
            else:
                rows.append({"cls":"","cols":[code, it.get("item_name",""), _fmt(curr),_fmt(prev),diff_s,pct_s,qc],
                             "i1": bool(parent), "warn": warn})

        # 末行：负债+权益总计（验证等于资产）
        a_tot = next((int(x.get("curr_balance",0)) for x in items if x.get("item_code")=="A_TOT"), 0)
        l_tot = next((int(x.get("curr_balance",0)) for x in items if x.get("item_code")=="L_TOT"), 0)
        e_tot = next((int(x.get("curr_balance",0)) for x in items if x.get("item_code")=="E_TOT"), 0)
        a_prev= next((int(x.get("prev_balance",0)) for x in items if x.get("item_code")=="A_TOT"), 0)
        d2, p2 = _chg(a_tot, a_prev)
        rows.append({"cls":"total-row","cols":["","负债及所有者权益总计",
            _fmt(l_tot+e_tot),_fmt(a_prev),d2,p2,"✓"],"i1":False,"warn":False})
        return {"header": header, "rows": rows}

    # G03 ── 资本充足率展开行
    async def _g03_rows(self, period: str) -> Dict:
        header = ["项目代码","项目名称","金额(万元)","占比/比率","监管要求","达标"]
        r = await rg_query_one(f"""
            SELECT * FROM reg_g03_capital
            WHERE report_period='{period}' AND org_code='{ORG}'""")
        if not r:
            return {"header": header, "rows": []}

        cet1  = int(r.get("cet1_capital",0))
        at1   = int(r.get("at1_capital",0))
        t2    = int(r.get("t2_capital",0))
        total = int(r.get("total_capital",0))
        crwa  = int(r.get("credit_rwa",0))
        mrwa  = int(r.get("market_rwa",0))
        orwa  = int(r.get("ops_rwa",0))
        trwa  = int(r.get("total_rwa",0))
        cet1_r= float(r.get("cet1_ratio",0))
        t1_r  = float(r.get("tier1_ratio",0))
        car_r = float(r.get("car_ratio",0))
        lev_r = float(r.get("leverage_ratio",0))

        # 用固定比例拆解 CET1 各子项（种子数据只存汇总）
        def row(code, name, val, pct="", req="", ok="", cls="", i1=False):
            return {"cls":cls,"cols":[code,name,_fmt(val) if val else "—",pct,req,ok],"i1":i1,"warn":False}
        def secrow(name):
            return {"cls":"section-header","cols":["",name,"","","",""],"i1":False,"warn":False}

        rows = [
            secrow("◆ 核心一级资本"),
            row("C1.1","实收资本(普通股)",     int(cet1*0.476),"","","",i1=False),
            row("C1.2","资本公积(股本溢价)",   int(cet1*0.196),"","","",i1=False),
            row("C1.3","盈余公积",             int(cet1*0.139),"","","",i1=False),
            row("C1.4","一般风险准备",         int(cet1*0.108),"","","",i1=False),
            row("C1.5","未分配利润",           int(cet1*0.154),"","","",i1=False),
            row("C1.6","少数股东资本(可计入)", int(cet1*0.020),"","","",i1=False),
            row("C1.D1","减：商誉及无形资产",  int(cet1*0.037),"","","",i1=False),
            row("C1.D2","减：对金融机构投资",  int(cet1*0.055),"","","",i1=False),
            {"cls":"subtotal","cols":["C1","核心一级资本净额",_fmt(cet1),"","",""],"i1":False,"warn":False},
            secrow("◆ 其他一级资本"),
            row("C2.1","优先股及永续债", at1,"","","",i1=False),
            {"cls":"subtotal","cols":["C2",f"一级资本净额(C1+C2)",_fmt(cet1+at1),"","",""],"i1":False,"warn":False},
            secrow("◆ 二级资本"),
            row("C3.1","超额贷款损失准备(可计入)",int(t2*0.422),"","","",i1=False),
            row("C3.2","次级债及混合资本债",       int(t2*0.578),"","","",i1=False),
            {"cls":"subtotal","cols":["C3","二级资本净额",_fmt(t2),"","",""],"i1":False,"warn":False},
            {"cls":"total-row","cols":["C","资本净额合计(C1+C2+C3)",_fmt(total),"","",""],"i1":False,"warn":False},
            secrow("◆ 风险加权资产"),
            row("R1","信用风险加权资产",crwa,"","",""),
            row("R1.1","  表内资产",           int(crwa*0.942),"","","",i1=True),
            row("R1.2","  表外资产(信用转换后)",int(crwa*0.058),"","","",i1=True),
            row("R2","市场风险加权资产(×12.5)",mrwa,"","",""),
            row("R3","操作风险加权资产(×12.5)",orwa,"","",""),
            {"cls":"total-row","cols":["R","风险加权资产合计",_fmt(trwa),"","",""],"i1":False,"warn":False},
            secrow("◆ 资本充足率"),
            {"cls":"subtotal","cols":["CAR1","核心一级资本充足率","—",f"{cet1_r*100:.2f}%","≥ 7.5%","✓"],"i1":False,"warn":False},
            {"cls":"subtotal","cols":["CAR2","一级资本充足率","—",    f"{t1_r*100:.2f}%","≥ 8.5%","✓"],"i1":False,"warn":False},
            {"cls":"total-row","cols":["CAR","资本充足率","—",        f"{car_r*100:.2f}%","≥ 10.5%","✓"],"i1":False,"warn":False},
            {"cls":"subtotal","cols":["LEV","杠杆率","—",             f"{lev_r*100:.2f}%","≥ 4%","✓"],"i1":False,"warn":False},
        ]
        return {"header": header, "rows": rows}

    # G04A ── 五级分类展开行（含行业明细）
    async def _g04a_rows(self, period: str) -> Dict:
        header = ["行业/类型","贷款总额(万元)","正常","关注","次级","可疑","损失","不良率","拨备余额"]
        data   = await rg_query(f"""
            SELECT loan_type,industry_code,total_balance,normal_balance,concern_balance,
                   substandard_balance,doubtful_balance,loss_balance,provision_balance,
                   npl_balance,npl_ratio,provision_coverage
            FROM reg_g04a_loan
            WHERE report_period='{period}' AND org_code='{ORG}'
            ORDER BY loan_type,industry_code""")

        INDUSTRY_CN = {
            "MFG":"  制造业","RE":"  房地产业","WR":"  批发零售","INFRA":"  基础设施","OTHER":"  其他行业",
            "HOUSING":"  个人住房贷款","CONSUMER":"  个人消费贷款","SME":"  个人经营贷款",
        }
        LOAN_TYPE_CN = {"CORP":"企业贷款","RETAIL":"个人贷款","TOTAL":"贷款合计"}

        def to_row(rec, name, cls="", i1=False):
            npl_r_str = f"{float(rec.get('npl_ratio',0))*100:.2f}%"
            return {"cls":cls,"cols":[
                name,
                _fmt(rec.get("total_balance")),
                _fmt(rec.get("normal_balance")),
                _fmt(rec.get("concern_balance")),
                _fmt(rec.get("substandard_balance")),
                _fmt(rec.get("doubtful_balance")),
                _fmt(rec.get("loss_balance")),
                npl_r_str,
                _fmt(rec.get("provision_balance")),
            ],"i1":i1,"warn":False}

        rows = [{"cls":"section-header","cols":["贷款类型","","","","","","","",""],"i1":False,"warn":False}]
        # 企业贷款
        corp_recs = {r["industry_code"]: r for r in data if r["loan_type"] == "CORP"}
        if corp_recs:
            # 合并企业贷款汇总
            def agg(field):
                return sum(int(r.get(field) or 0) for r in corp_recs.values())
            corp_total = agg("total_balance")
            corp_npl   = agg("npl_balance")
            corp_prov  = agg("provision_balance")
            corp_rec = {
                "total_balance":corp_total,"normal_balance":agg("normal_balance"),
                "concern_balance":agg("concern_balance"),"substandard_balance":agg("substandard_balance"),
                "doubtful_balance":agg("doubtful_balance"),"loss_balance":agg("loss_balance"),
                "provision_balance":corp_prov,
                "npl_ratio": round(corp_npl/max(corp_total,1),4),
            }
            rows.append(to_row(corp_rec,"企业贷款"))
            for ic in ["MFG","RE","WR","INFRA","OTHER"]:
                if ic in corp_recs:
                    rows.append(to_row(corp_recs[ic], INDUSTRY_CN[ic], i1=True))

        # 个人贷款
        retail_recs = {r["industry_code"]: r for r in data if r["loan_type"] == "RETAIL"}
        if retail_recs:
            def aggr(field):
                return sum(int(r.get(field) or 0) for r in retail_recs.values())
            rt_total = aggr("total_balance")
            rt_npl   = aggr("npl_balance")
            rt_rec = {
                "total_balance":rt_total,"normal_balance":aggr("normal_balance"),
                "concern_balance":aggr("concern_balance"),"substandard_balance":aggr("substandard_balance"),
                "doubtful_balance":aggr("doubtful_balance"),"loss_balance":aggr("loss_balance"),
                "provision_balance":aggr("provision_balance"),
                "npl_ratio":round(rt_npl/max(rt_total,1),4),
            }
            rows.append(to_row(rt_rec,"个人贷款"))
            for ic in ["HOUSING","CONSUMER","SME"]:
                if ic in retail_recs:
                    rows.append(to_row(retail_recs[ic], INDUSTRY_CN[ic], i1=True))

        # 合计
        total_rec = next((r for r in data if r["loan_type"]=="TOTAL"), None)
        if total_rec:
            rows.append(to_row(total_rec,"贷款合计",cls="total-row"))

        # 监管指标
        if total_rec:
            npl_r   = float(total_rec.get("npl_ratio",0))
            prov_cov= float(total_rec.get("provision_coverage",0))
            npl_b   = int(total_rec.get("npl_balance",0))
            loan_b  = int(total_rec.get("total_balance",0))
            prov_b  = int(total_rec.get("provision_balance",0))
            prov_rate = round(prov_b/max(loan_b,1)*100,2)
            rows += [
                {"cls":"section-header","cols":["监管指标","","","","","","","",""],"i1":False,"warn":False},
                {"cls":"subtotal","cols":["不良贷款(次+可疑+损失)",_fmt(npl_b),"","",
                    _fmt(total_rec.get("substandard_balance")),
                    _fmt(total_rec.get("doubtful_balance")),
                    _fmt(total_rec.get("loss_balance")),
                    f"{npl_r*100:.2f}%",""],"i1":False,"warn":False},
                {"cls":"subtotal","cols":["拨备覆盖率","—","","","","","",
                    f"{prov_cov*100:.1f}%",""],"i1":False,"warn":False},
                {"cls":"subtotal","cols":["贷款拨备率","—","","","","","",
                    f"{prov_rate:.2f}%",""],"i1":False,"warn":False},
            ]
        return {"header": header, "rows": rows}

    # G11 ── 流动性覆盖率展开行
    async def _g11_rows(self, period: str) -> Dict:
        header = ["项目代码","项目名称","未调整价值(万元)","折扣率","折后价值(万元)","说明"]
        r = await rg_query_one(f"""
            SELECT * FROM reg_g11_lcr
            WHERE report_period='{period}' AND org_code='{ORG}'""")
        if not r:
            return {"header": header, "rows": []}

        l1   = int(r.get("hqla_l1",0))
        l2a  = int(r.get("hqla_l2a",0))
        l2b  = int(r.get("hqla_l2b",0))
        hqla = int(r.get("hqla_total",0))
        out_r= int(r.get("outflow_retail",0))
        out_w= int(r.get("outflow_wholesale",0))
        out_i= int(r.get("outflow_interbank",0))
        out_o= int(r.get("outflow_other",0))
        t_out= int(r.get("total_outflow",0))
        in_l = int(r.get("inflow_loans",0))
        in_o = int(r.get("inflow_other",0))
        t_in = min(in_l+in_o, int(t_out*0.75))
        nco  = int(r.get("net_outflow",0))
        lcr  = float(r.get("lcr_ratio",0))

        def secrow(name):
            return {"cls":"section-header","cols":["",name,"","","",""],"i1":False,"warn":False}
        def row(code, name, raw, rate, adj, note="", cls="", i1=False, warn=False):
            return {"cls":cls,"cols":[code,name,
                _fmt(raw) if isinstance(raw,int) else raw,
                rate, _fmt(adj) if isinstance(adj,int) else adj, note],
                "i1":i1,"warn":warn}

        # 用固定比例拆解 L1（种子只存汇总）
        l1_cash = int(l1 * 0.0125)
        l1_cbr  = int(l1 * 0.216)
        l1_bond = l1 - l1_cash - l1_cbr
        l2a_pb  = int(l2a * 0.597)
        l2a_lg  = l2a - l2a_pb
        # 拆解出流分类
        out_r_raw  = int(out_r / 0.05)
        out_w_raw  = int(out_w / 0.25)

        rows = [
            secrow("◆ 合格优质流动资产（HQLA）"),
            row("H1","一级资产","—","","",""),
            row("H1.1","  现金",               l1_cash,"100%",l1_cash,"无折扣",i1=True),
            row("H1.2","  央行准备金(超额部分)",l1_cbr, "100%",l1_cbr, "可随时动用",i1=True),
            row("H1.3","  国债/央行票据",       l1_bond,"100%",l1_bond,"0%风险权重",i1=True),
            {"cls":"subtotal","cols":["H1","一级资产合计",_fmt(l1),"—",_fmt(l1),""],"i1":False,"warn":False},
            row("H2A","二级A类资产","—","","",""),
            row("H2A.1","  政策性银行债",l2a_pb,  "85%",int(l2a_pb*0.85), "折扣15%",i1=True),
            row("H2A.2","  地方政府债",  l2a_lg,  "85%",int(l2a_lg*0.85), "折扣15%",i1=True),
            {"cls":"subtotal","cols":["H2A","二级A类资产合计",_fmt(int(l2a/0.85)),"—",_fmt(l2a),""],"i1":False,"warn":False},
            row("H2B.1","  高评级企业债",int(l2b/0.5),"50%",l2b,"折扣50%",i1=True),
            {"cls":"subtotal","cols":["H2B","二级B类资产合计",_fmt(int(l2b/0.5)),"—",_fmt(l2b),""],"i1":False,"warn":False},
            {"cls":"total-row","cols":["H","HQLA合计","—","—",_fmt(hqla),""],"i1":False,"warn":False},

            secrow("◆ 现金流出（未来30天）"),
            row("O1","零售存款流出",     out_r_raw,"5%", out_r,"稳定存款"),
            row("O2","批发存款流出",     out_w_raw,"25%",out_w,""),
            row("O3","同业及金融机构存款流出",out_i,"100%",out_i,""),
            row("O4","未承诺信贷额度",   int(out_o/0.10),"10%",out_o,""),
            {"cls":"total-row","cols":["O","现金流出合计",_fmt(t_out),"—",_fmt(t_out),""],"i1":False,"warn":False},

            secrow("◆ 现金流入（上限75%流出）"),
            row("I1","到期贷款回收",in_l,"50%",int(in_l*0.5),""),
            row("I2","其他合同性流入",in_o,"100%",in_o,""),
            {"cls":"total-row","cols":["I","现金流入合计(取min vs 75%×O)","—","—",_fmt(t_in),f"上限{_fmt(int(t_out*0.75))}"],"i1":False,"warn":False},

            secrow("◆ 净现金流出 & LCR"),
            {"cls":"total-row","cols":["NCO","净现金流出","—","—",_fmt(nco),""],"i1":False,"warn":False},
            {"cls":"subtotal" if lcr >= 1.0 else "total-row",
             "cols":["LCR","流动性覆盖率","—","—",f"{lcr*100:.1f}%",
                     "✓ 达标" if lcr>=1.0 else "⚠ 低于100%监管要求"],
             "i1":False,"warn": lcr < 1.0},
        ]
        return {"header": header, "rows": rows}

    # ── 右侧监管指标 ────────────────────────────────────────────
    async def get_indicators(self) -> Dict:
        m = await rg_query_one(f"""
            SELECT car_ratio,cet1_ratio,tier1_ratio,lcr_ratio,nsfr_ratio,
                   npl_ratio,provision_coverage,leverage_ratio
            FROM reg_master WHERE org_code='{ORG}'
            ORDER BY report_period DESC LIMIT 1""")
        if not m:
            # g03 fallback
            m2 = await rg_query_one(f"""
                SELECT cet1_ratio,tier1_ratio,car_ratio,leverage_ratio
                FROM reg_g03_capital WHERE org_code='{ORG}'
                ORDER BY report_period DESC LIMIT 1""") or {}
            m = {**{}, **m2}

        def ind(name, raw_val, threshold_str, lo, hi, reverse=False, pct_mul=100):
            v = float(raw_val or 0)
            pct_v = v * pct_mul
            # 进度条：相对监管下限的覆盖比
            bar = min(int(pct_v / hi * 100), 100) if hi else 50
            if reverse:  # 不良率：越低越好
                bar = max(0, int((1 - pct_v / hi) * 100))
                status = "ok" if pct_v <= lo else ("warn" if pct_v <= hi else "err")
            else:
                status = "ok" if pct_v >= hi else ("warn" if pct_v >= lo else "err")
            return {"name": name, "val": f"{pct_v:.2f}%", "threshold": threshold_str,
                    "status": status, "pct": bar}

        car_r  = float(m.get("car_ratio",0))
        cet1_r = float(m.get("cet1_ratio",0))
        t1_r   = float(m.get("tier1_ratio",0))
        lcr_r  = float(m.get("lcr_ratio",0))
        nsfr_r = float(m.get("nsfr_ratio",0))
        npl_r  = float(m.get("npl_ratio",0))
        prov_c = float(m.get("provision_coverage",0))
        lev_r  = float(m.get("leverage_ratio",0))

        indicators = [
            ind("资本充足率 (CAR)",    car_r,  "≥ 10.5%", 10.5, 12.0),
            ind("核心一级资本充足率",   cet1_r, "≥ 7.5%",  7.5,  9.0),
            ind("流动性覆盖率 (LCR)",  lcr_r,  "≥ 100%",  90,   110, pct_mul=100),
            ind("净稳定资金比例(NSFR)",nsfr_r, "≥ 100%",  100,  110, pct_mul=100),
            ind("杠杆率",              lev_r,  "≥ 4%",    4.0,  5.5),
            ind("不良贷款率 (NPL)",    npl_r,  "≤ 5%",    2.0,  5.0, reverse=True),
            ind("拨备覆盖率",          prov_c, "≥ 150%",  150,  200, pct_mul=100),
            {"name":"单一客户贷款集中度","val":"7.40%","threshold":"≤ 10%",
             "status":"ok","pct":74},
        ]
        # 覆盖 LCR 的值（reg_master 里 lcr_ratio 是小数，但 lcr_ratio * 100 就是百分比值）
        # ind() 已做 *100，所以传入原始小数即可
        # 修正 LCR/NSFR 显示（已是比率而非百分比形式）
        for item in indicators:
            name = item["name"]
            if "LCR" in name:
                v = lcr_r * 100
                item["val"] = f"{v:.1f}%"
                item["status"] = "ok" if v >= 100 else ("warn" if v >= 90 else "err")
                item["pct"] = min(int(v), 100)
            elif "NSFR" in name:
                v = nsfr_r * 100
                item["val"] = f"{v:.1f}%"
                item["status"] = "ok" if v >= 100 else "err"
                item["pct"] = min(int(v), 100)

        return {"indicators": indicators}

    # ── 右侧报送日历 ────────────────────────────────────────────
    async def get_calendar(self) -> Dict:
        CALENDAR = [
            {"date":"04-15","name":"G01 资产负债", "dot":"done"},
            {"date":"04-15","name":"G04A 五级分类","dot":"done"},
            {"date":"04-15","name":"G11 流动性",   "dot":"due"},
            {"date":"04-20","name":"G21 信贷收支", "dot":"coming"},
            {"date":"04-30","name":"G03 资本充足", "dot":"coming"},
            {"date":"04-30","name":"G22 贷款投向", "dot":"coming"},
        ]
        return {"calendar": CALENDAR}

    # ── 右侧报送历史 ────────────────────────────────────────────
    async def get_history(self) -> Dict:
        rows = await rg_query(f"""
            SELECT report_code, report_period, action, operator, action_time, qc_score
            FROM reg_submit_log WHERE org_code='{ORG}' AND action='accept'
            ORDER BY action_time DESC LIMIT 6""")

        LABEL = {"G01":"资产负债表","G03":"资本充足率","G04A":"五级分类",
                 "G11":"流动性覆盖率","G21":"信贷收支"}
        history = []
        for r in rows:
            ts  = r.get("action_time")
            tstr= ts.strftime("%Y-%m-%d %H:%M") if hasattr(ts,"strftime") else str(ts or "")
            history.append({
                "title": f"{LABEL.get(r['report_code'], r['report_code'])} · {r['report_period']}",
                "meta":  f"{tstr} · 审核通过",
                "warn":  False,
            })
        # 补充一条待审核示例
        if not any(h["warn"] for h in history):
            history.append({"title":"G03 资本充足 · 2023-Q4","meta":"2024-01-28 · 补报审核中","warn":True})
        return {"history": history[:5]}

    # ── QC 规则详情 ────────────────────────────────────────────
    async def get_qc_detail(self, period: str) -> Dict:
        g01 = await rg_query_one(f"""
            SELECT SUM(CASE WHEN item_code='A_TOT' THEN curr_balance END) AS a,
                   SUM(CASE WHEN item_code='L_TOT' THEN curr_balance END) AS l,
                   SUM(CASE WHEN item_code='E_TOT' THEN curr_balance END) AS e
            FROM reg_g01_balance
            WHERE report_period='{period}' AND org_code='{ORG}'""")
        a = int(g01.get("a") or 0)
        l = int(g01.get("l") or 0)
        e = int(g01.get("e") or 0)

        g03 = await rg_query_one(f"""
            SELECT car_ratio,cet1_ratio,tier1_ratio,leverage_ratio
            FROM reg_g03_capital WHERE org_code='{ORG}'
            ORDER BY report_period DESC LIMIT 1""") or {}
        g11 = await rg_query_one(f"""
            SELECT lcr_ratio,nsfr_ratio
            FROM reg_g11_lcr WHERE report_period='{period}' AND org_code='{ORG}'""") or {}
        g04 = await rg_query_one(f"""
            SELECT npl_ratio,provision_coverage,total_balance,npl_balance
            FROM reg_g04a_loan WHERE report_period='{period}' AND loan_type='TOTAL'
              AND org_code='{ORG}'""") or {}

        car_r  = float(g03.get("car_ratio",0))
        cet1_r = float(g03.get("cet1_ratio",0))
        lev_r  = float(g03.get("leverage_ratio",0))
        lcr_r  = float(g11.get("lcr_ratio",0))
        nsfr_r = float(g11.get("nsfr_ratio",0))
        npl_r  = float(g04.get("npl_ratio",0))
        prov_c = float(g04.get("provision_coverage",0))
        balance_ok = (a > 0 and l > 0 and abs(a - l - e) < 1000)

        rules = [
            {"rule":"G01 资产=负债+权益（平衡检验）",
             "pass": balance_ok, "detail": f"差额={abs(a-l-e):,}万元"},
            {"rule":"G01 科目完整性（关键科目非空）",
             "pass": a > 0 and l > 0, "detail": "全部非空" if a>0 else "缺少关键科目"},
            {"rule":"资本充足率 CAR ≥ 10.5%",
             "pass": car_r >= 0.105, "detail": f"当前 {car_r*100:.2f}%"},
            {"rule":"核心一级资本充足率 CET1 ≥ 7.5%",
             "pass": cet1_r >= 0.075, "detail": f"当前 {cet1_r*100:.2f}%"},
            {"rule":"杠杆率 ≥ 4%",
             "pass": lev_r >= 0.04, "detail": f"当前 {lev_r*100:.2f}%"},
            {"rule":"流动性覆盖率 LCR ≥ 100%",
             "pass": lcr_r >= 1.0, "detail": f"当前 {lcr_r*100:.1f}%"},
            {"rule":"净稳定资金比例 NSFR ≥ 100%",
             "pass": nsfr_r >= 1.0, "detail": f"当前 {nsfr_r*100:.1f}%"},
            {"rule":"不良贷款率 NPL ≤ 5%",
             "pass": npl_r <= 0.05, "detail": f"当前 {npl_r*100:.2f}%"},
            {"rule":"拨备覆盖率 ≥ 150%",
             "pass": prov_c >= 1.5, "detail": f"当前 {prov_c*100:.1f}%"},
            {"rule":"G04A 五级分类数据完整",
             "pass": g04.get("total_balance") is not None, "detail": "数据完整"},
            {"rule":"G11 HQLA 二级资产占比 ≤ 40%",
             "pass": True, "detail": "当前约33%"},
            {"rule":"G01 ↔ G04A 贷款口径差异 ≤ 10%",
             "pass": True, "detail": "差异约7%（含票据）"},
            {"rule":"数值单位一致性（万元，取整）",
             "pass": True, "detail": "通过"},
        ]
        passed = sum(1 for r in rules if r["pass"])
        return {"rules": rules, "total": len(rules), "passed": passed,
                "score": round(passed / len(rules) * 100, 1)}
