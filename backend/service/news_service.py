"""
基金资讯 AI Function 分析
直接调用 Doris 内置 AI Function，依赖 Doris default_ai_resource：
  AI_SUMMARIZE(content)
  AI_SENTIMENT(content)
  AI_EXTRACT(content, ARRAY(...))
"""
import json
import re
from datetime import datetime, timedelta
from backend.doris.connect import execute_query, execute_write, execute_many


_EXTRACT_LABELS = ["Event Type", "Affected Sector", "Key Policy or Technology", "Core Companies", "Market Impact Direction"]


def _parse_extract(ex):
    """兼容 JSON 和 Doris AI_EXTRACT 返回的 key=value 格式
    示例: 事件类型=政策发布,影响板块=半导体板块,核心公司=中芯国际、北方华创
    """
    if not ex:
        return {}
    if isinstance(ex, dict):
        return ex
    ex = str(ex).strip()
    # 尝试 JSON
    if ex.startswith('{'):
        try:
            return json.loads(ex)
        except Exception:
            pass
    # 解析 key=value 格式：以","分隔键值对，"、"分隔多值
    result = {}
    for pair in re.split(r',(?=[\u4e00-\u9fff])', ex):
        if '=' not in pair:
            continue
        key, _, val = pair.partition('=')
        key = key.strip()
        val = val.strip()
        if not val:
            continue
        result[key] = [v.strip() for v in val.split('、') if v.strip()] if '、' in val else val
    return result

# ── Investment news samples: five English long-form articles ───────────────
_RAW_NEWS = [
    {
        'id': 'INV001',
        'sector': 'Macro',
        'title': 'Multi-asset outlook: investors rotate from cash into duration, quality equities and gold hedges',
        'source': 'Global Asset Review',
        'content': 'Global portfolio managers are beginning the second quarter with a more balanced risk budget after nearly two years of unusually high cash allocations. The central investment debate is no longer whether interest rates will remain restrictive, but how quickly inflation can fall without forcing a sharp decline in corporate earnings. Several large asset allocators now expect policy rates in the United States and Europe to move lower over the next twelve months, creating a more constructive backdrop for intermediate duration bonds and high quality equities. The change is meaningful because money market funds still hold a record level of assets, and even a modest rotation out of cash could provide steady demand for government bonds, investment grade credit and companies with visible free cash flow.\n\nThe report recommends a barbell approach rather than a full risk-on position. On one side, investors are increasing exposure to five to seven year government bonds, agency mortgage securities and high grade corporate debt, where yields remain attractive relative to the last decade. On the other side, equity allocations are being concentrated in profitable technology platforms, health care leaders and financial companies with strong capital ratios. Analysts argue that the strongest franchises can protect margins even if nominal growth cools. They also highlight that buyback activity is recovering, which may provide an additional source of earnings-per-share support.\n\nHowever, the outlook is not one dimensional. Energy supply risk, fiscal deficits and election uncertainty could keep volatility elevated. Gold is therefore being used as a portfolio hedge rather than a pure directional trade. The metal has benefited from central bank purchases and from investors seeking protection against geopolitical shocks. Strategists caution that a rapid rebound in inflation would hurt both bonds and equities, while a hard landing would pressure cyclical earnings. The preferred investment stance is gradual deployment of cash, disciplined rebalancing and avoiding excessive leverage. In short, the opportunity set has improved, but investors are being paid to diversify rather than chase a single theme.',
    },
    {
        'id': 'INV002',
        'sector': 'Financials',
        'title': 'Bank dividend strategy returns as loan growth stabilizes and credit costs peak',
        'source': 'Institutional Banking Weekly',
        'content': 'Bank equities are attracting renewed attention from income-oriented investors after a difficult period of deposit competition, margin compression and worries about commercial real estate exposure. The latest sector review from several brokerage desks suggests that the worst phase of funding pressure may have passed. Deposit betas have stopped rising in many markets, wholesale funding spreads are narrowing and loan repricing is catching up with the higher rate environment. Although loan growth remains moderate, the combination of stable net interest margins and disciplined cost control is improving visibility for earnings.\n\nDividend strategies are particularly relevant because many large banks continue to trade below long-term valuation averages while offering payout yields above broader equity benchmarks. Analysts argue that investors do not need aggressive loan expansion for the sector to work. A steady balance sheet, lower credit migration and reliable capital return may be enough to drive total return. Stress test results in major markets also suggest that systemically important banks have sufficient capital buffers to continue dividends and selective share repurchases. For long-term portfolios, the sector can provide cash flow, value exposure and a partial hedge against a scenario where rates stay higher for longer.\n\nThe article also points out the risks that should not be ignored. Commercial real estate losses may still rise, especially in office portfolios with weak occupancy. Smaller regional banks remain more vulnerable to deposit volatility and securities losses. In emerging markets, property-related credit exposure and local government financing vehicles require careful review. The recommended approach is therefore selective: focus on banks with granular deposits, conservative provisioning, high common equity tier one ratios and clear digital banking efficiency gains. The report concludes that bank dividends are not a risk-free carry trade, but the risk-reward profile has improved enough to justify a higher allocation in balanced income portfolios.',
    },
    {
        'id': 'INV003',
        'sector': 'Semiconductors',
        'title': 'AI semiconductor supply chain broadens beyond GPUs as memory, networking and power components re-rate',
        'source': 'Technology Investment Journal',
        'content': 'The artificial intelligence semiconductor trade is moving into its second phase. During the first phase, investor attention was concentrated on graphics processors and the immediate beneficiaries of data center accelerator demand. The new phase is broader and more complex. Hyperscale cloud companies are still ordering large volumes of accelerators, but bottlenecks have shifted toward high bandwidth memory, advanced packaging capacity, optical networking modules, power management chips and liquid cooling infrastructure. This broadening matters for investors because earnings revisions are now appearing across a wider set of suppliers rather than only at the most visible AI leaders.\n\nMemory makers are experiencing one of the clearest changes in fundamentals. High bandwidth memory requires more wafer capacity and tighter process control than commodity DRAM, which is improving pricing power for leading suppliers. Advanced packaging is another constraint. Chip-on-wafer-on-substrate capacity remains limited, and foundries with proven packaging ecosystems are able to command premium pricing. Networking companies are also benefiting as larger AI clusters require faster switching, lower latency and more reliable optical interconnects. In parallel, power semiconductor companies are seeing stronger demand because AI servers consume significantly more electricity than traditional servers.\n\nThe article warns that valuation discipline is becoming more important. Some AI supply chain stocks already discount several years of strong growth, leaving little margin for execution delays. Export controls, customer concentration and capital expenditure cyclicality remain important risks. Still, the structural demand drivers appear durable: enterprise AI adoption is moving from pilots to production, sovereign AI projects are being funded and cloud providers are competing to secure compute capacity. The recommended strategy is to combine core exposure to dominant platforms with selective positions in underappreciated enablers such as memory packaging, testing equipment, optical modules and power delivery. Investors should focus on companies with pricing power, capacity scarcity and long-term customer commitments.',
    },
    {
        'id': 'INV004',
        'sector': 'Renewables',
        'title': 'Renewable energy investing shifts from capacity growth to profitability, grid access and overseas execution',
        'source': 'Clean Energy Capital',
        'content': 'Renewable energy remains one of the largest structural investment themes, but the criteria for selecting winners are changing. For several years, the market rewarded companies that expanded capacity quickly and captured share in solar modules, batteries and wind equipment. That approach is now less effective because many segments are dealing with excess supply, falling product prices and weaker returns on incremental capital. Investors are shifting their focus from headline shipment growth to profitability, grid access, technology differentiation and overseas execution.\n\nSolar is the clearest example of this transition. Module prices have fallen sharply as new capacity entered the market, putting pressure on manufacturers with weaker cost positions. Companies with advanced cell technology, integrated supply chains and strong overseas channels are better placed, but even leaders need to manage inventory and capital expenditure carefully. In batteries, electric vehicle demand is still growing, yet pricing pressure is intense. Energy storage offers a more attractive demand curve because grid operators and commercial customers need storage to balance renewable generation. However, project profitability depends on software, safety performance, financing cost and local service capability, not only cell cost.\n\nThe article argues that grid equipment and storage integration may provide a more stable investment angle than commodity manufacturing. Transmission upgrades, digital substations, inverters and energy management systems are becoming bottlenecks for renewable deployment. Companies with engineering capability and international certifications can benefit from infrastructure spending in Europe, the Middle East, Latin America and Southeast Asia. Policy risk remains significant, including tariffs, local content rules and subsidy changes. The recommended approach is to avoid highly leveraged capacity expansion stories and favor firms with positive free cash flow, diversified customer bases and proven overseas delivery. Renewable investing is not over; it is becoming more selective and more focused on execution quality.',
    },
    {
        'id': 'INV005',
        'sector': 'Consumer',
        'title': 'Consumer recovery becomes more selective as premium services outperform mass discretionary goods',
        'source': 'Asia Consumer Strategy',
        'content': 'The consumer sector is recovering, but the pattern is far from uniform. Household balance sheets are improving gradually, employment expectations are stabilizing and travel demand remains resilient. Yet consumers are still price sensitive in many discretionary categories, especially furniture, apparel and lower-end electronics. This creates a selective investment environment where companies exposed to premium services, tourism, sports events, health management and membership-based retail are performing better than companies reliant on broad-based impulse spending.\n\nThe strongest data points are coming from experience consumption. Hotel occupancy, outbound travel bookings and restaurant reservations are all above last year levels in major cities. Consumers appear willing to pay for experiences that create social value or save time, while delaying purchases of durable goods that can be postponed. Digital platforms with strong user data and merchant networks are capturing this shift by offering targeted promotions, loyalty programs and bundled services. Premium brands are also outperforming when they maintain pricing power and product scarcity, although growth rates are normalizing from the post-pandemic surge.\n\nFor investors, the key is to distinguish between revenue recovery and margin recovery. Some retailers are generating sales growth only through discounts, which may not translate into earnings growth. Companies with efficient supply chains, strong private-label products or subscription models have more room to protect margins. The article recommends focusing on businesses with recurring customer engagement, low inventory risk and clear operating leverage. Risks include slower wage growth, higher savings preference and intense competition from value platforms. The conclusion is balanced: consumer spending is not weak enough to avoid the sector, but not broad enough to buy indiscriminately. Stock selection and category exposure matter more than top-down optimism.',
    },
]


class NewsService:

    # ── 建表（仅首次，IF NOT EXISTS，不清数据）──────────────
    async def init_table(self):
        await execute_write("""
            CREATE TABLE IF NOT EXISTS news_article (
                article_id      VARCHAR(10)   NOT NULL,
                publish_ts      DATETIME      NOT NULL,
                title           VARCHAR(300),
                content         TEXT,
                source          VARCHAR(50),
                sector_tag      VARCHAR(30),
                ai_summary      VARCHAR(500),
                summarized      TINYINT       DEFAULT 0,
                ai_sentiment    VARCHAR(20),
                sentiment_score INT,
                sentiment_done  TINYINT       DEFAULT 0,
                ai_extract      VARCHAR(2000),
                extracted       TINYINT       DEFAULT 0,
                ai_method       VARCHAR(20)   DEFAULT 'PENDING'
            ) UNIQUE KEY(article_id, publish_ts)
            DISTRIBUTED BY HASH(article_id) BUCKETS 4
            PROPERTIES("replication_num"="1")
        """)
        return {"msg": "表已就绪（IF NOT EXISTS，数据保留）"}

    # ── 生成单条随机资讯（每次调用生成全新内容）──────────────
    async def import_news(self):
        import random
        import uuid

        sample = random.choice(_RAW_NEWS)
        article_id = f"N{str(uuid.uuid4())[:9].upper()}"
        ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        title = sample["title"]
        content = sample["content"]
        source = sample["source"]
        sector = sample["sector"]

        await execute_write(f"""
            INSERT INTO news_article
            VALUES('{article_id}', '{ts}', '{title.replace("'", "''")}',
                   '{content.replace("'", "''")}', '{source}', '{sector}',
                   NULL, 0, NULL, NULL, 0, NULL, 0, 'PENDING')
        """)
        return {
            "msg": f"Imported investment article: {title[:50]}...",
            "article_id": article_id,
            "title": title,
            "sector": sector,
        }

    async def get_list(self, sector: str = None, sentiment: str = None, keyword: str = None):
        where = ["1=1"]
        if sector:    where.append(f"sector_tag='{sector}'")
        if sentiment: where.append(f"ai_sentiment='{sentiment}'")
        if keyword:   where.append(f"(title LIKE '%{keyword}%' OR content LIKE '%{keyword}%')")
        sql = f"""
            SELECT article_id, publish_ts, title, source, sector_tag,
                   ai_summary, ai_sentiment, sentiment_score,
                   ai_extract, summarized, sentiment_done, extracted, ai_method
            FROM news_article
            WHERE {' AND '.join(where)}
            QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
            ORDER BY publish_ts DESC
        """
        return await execute_query(sql) or []

    async def get_detail(self, article_id: str):
        rows = await execute_query(f"""
            SELECT * FROM news_article
            WHERE article_id = '{article_id}'
            QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
        """)
        return rows[0] if rows else {}

    # ── AI_SUMMARIZE ────────────────────────────────────────
    async def run_summarize(self, article_ids: list = None):
        where = self._build_where("summarized", 0, article_ids)
        sql_display = f"""-- Doris AI_SUMMARIZE：对金融资讯正文进行高度概括
-- Resource: default_ai_resource
UPDATE news_article
SET ai_summary = AI_SUMMARIZE(content),
    summarized  = 1,
    ai_method   = 'DORIS_AI_FUNCTION'
WHERE {where}"""

        rc = await execute_write(f"""
            UPDATE news_article
            SET ai_summary = AI_SUMMARIZE(content),
                summarized  = 1,
                ai_method   = 'DORIS_AI_FUNCTION'
            WHERE {where}
        """)
        return {
            "msg": f"AI_SUMMARIZE 完成，处理 {rc} 篇",
            "processed": rc,
            "sql": sql_display,
        }

    # ── AI_SENTIMENT ────────────────────────────────────────
    async def run_sentiment(self, article_ids: list = None):
        where = self._build_where("sentiment_done", 0, article_ids)
        sql_display = f"""-- Doris AI_SENTIMENT：分析情感倾向
-- 返回值: positive | negative | neutral | mixed
-- Resource: default_ai_resource
UPDATE news_article
SET ai_sentiment  = AI_SENTIMENT(content),
    sentiment_done = 1,
    ai_method      = 'DORIS_AI_FUNCTION'
WHERE {where}"""

        # Step 1: 情感分类
        rc = await execute_write(f"""
            UPDATE news_article
            SET ai_sentiment  = AI_SENTIMENT(content),
                sentiment_done = 1,
                ai_method      = 'DORIS_AI_FUNCTION'
            WHERE {where}
        """)
        # Step 2: 根据情感类型映射评分
        score_where = self._build_where("sentiment_done", 1, article_ids)
        await execute_write(f"""
            UPDATE news_article
            SET sentiment_score = CASE ai_sentiment
                WHEN 'positive' THEN  70
                WHEN 'negative' THEN -70
                WHEN 'mixed'    THEN  15
                ELSE 0
            END
            WHERE {score_where}
        """)
        return {
            "msg": f"AI_SENTIMENT 完成，处理 {rc} 篇",
            "processed": rc,
            "sql": sql_display,
        }

    # ── AI_EXTRACT ──────────────────────────────────────────
    async def run_extract(self, article_ids: list = None):
        where = self._build_where("extracted", 0, article_ids)
        labels_sql = "ARRAY(" + ",".join(f"'{l}'" for l in _EXTRACT_LABELS) + ")"
        sql_display = f"""-- Doris AI_EXTRACT：按标签列表提取结构化信息（返回 JSON）
-- Resource: default_ai_resource
UPDATE news_article
SET ai_extract = AI_EXTRACT(
        content,
        {labels_sql}
    ),
    extracted = 1,
    ai_method = 'DORIS_AI_FUNCTION'
WHERE {where}"""

        rc = await execute_write(f"""
            UPDATE news_article
            SET ai_extract = AI_EXTRACT(
                    content,
                    {labels_sql}
                ),
                extracted = 1,
                ai_method = 'DORIS_AI_FUNCTION'
            WHERE {where}
        """)
        return {
            "msg": f"AI_EXTRACT 完成，处理 {rc} 篇",
            "processed": rc,
            "sql": sql_display,
        }

    # ── 统计进度 ────────────────────────────────────────────
    async def get_stats(self):
        rows = await execute_query("""
            SELECT
                COUNT(DISTINCT article_id) AS total,
                SUM(summarized)            AS summarized,
                SUM(sentiment_done)        AS sentiment_done,
                SUM(extracted)             AS extracted
            FROM (
                SELECT article_id, summarized, sentiment_done, extracted
                FROM news_article
                QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
            ) t
        """) or []
        return rows[0] if rows else {"total": 0, "summarized": 0, "sentiment_done": 0, "extracted": 0}

    # ── 标签分析 ────────────────────────────────────────────
    async def get_tag_analysis(self):
        # 情感分布（SQL聚合，避免Python遍历）
        stats = await execute_query("""
            SELECT ai_sentiment, COUNT(*) AS cnt
            FROM (
                SELECT article_id, ai_sentiment
                FROM news_article
                WHERE extracted = 1
                QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
            ) t
            GROUP BY ai_sentiment
        """) or []
        sentiment_dist = {(r.get("ai_sentiment") or "neutral"): r.get("cnt", 0) for r in stats}

        # 板块×情感分布
        sector_stats = await execute_query("""
            SELECT sector_tag, ai_sentiment, COUNT(*) AS cnt
            FROM (
                SELECT article_id, sector_tag, ai_sentiment
                FROM news_article
                WHERE extracted = 1
                QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
            ) t
            GROUP BY sector_tag, ai_sentiment
        """) or []
        sector_sentiment = {}
        for r in sector_stats:
            sec = r.get("sector_tag") or "其他"
            sent = r.get("ai_sentiment") or "neutral"
            if sec not in sector_sentiment:
                sector_sentiment[sec] = {"positive": 0, "negative": 0, "neutral": 0, "mixed": 0, "total": 0}
            sector_sentiment[sec][sent] = r.get("cnt", 0)
            sector_sentiment[sec]["total"] += r.get("cnt", 0)

        # 分值分布：后端计算（避免前端遍历）
        score_buckets = [0] * 10
        score_rows = await execute_query("""
            SELECT sentiment_score
            FROM (
                SELECT article_id, sentiment_score
                FROM news_article
                WHERE extracted = 1 AND sentiment_score IS NOT NULL
                QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
            ) t
        """) or []
        for r in score_rows:
            score = r.get("sentiment_score") or 0
            idx = min(int((score + 100) / 20), 9)
            score_buckets[idx] += 1

        # 标签频率
        rows = await execute_query("""
            SELECT ai_extract
            FROM (
                SELECT article_id, ai_extract
                FROM news_article
                WHERE extracted = 1
                QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
            ) t
        """) or []
        tag_freq = {}
        for r in rows:
            ex = r.get("ai_extract")
            if ex:
                data = _parse_extract(ex)
                for label, val in data.items():
                    if isinstance(val, list):
                        for v in val:
                            if v:
                                tag_freq[f"{label}:{v}"] = tag_freq.get(f"{label}:{v}", 0) + 1
                    elif val:
                        tag_freq[f"{label}:{val}"] = tag_freq.get(f"{label}:{val}", 0) + 1

        top_tags = sorted(tag_freq.items(), key=lambda x: -x[1])[:30]
        return {
            "sentiment_dist": sentiment_dist,
            "sector_sentiment": sector_sentiment,
            "top_tags": [{"tag": k, "freq": v} for k, v in top_tags],
            "score_buckets": score_buckets,  # 后端返回，前端无需计算
            "total": len(rows),
        }

    # ── 板块情感指标聚合 ────────────────────────────────────
    async def get_sector_metrics(self):
        rows = await execute_query("""
            SELECT
                sector_tag,
                COUNT(DISTINCT article_id)                                AS article_count,
                ROUND(AVG(sentiment_score), 1)                            AS avg_score,
                SUM(CASE WHEN ai_sentiment='positive' THEN 1 ELSE 0 END)  AS positive_cnt,
                SUM(CASE WHEN ai_sentiment='negative' THEN 1 ELSE 0 END)  AS negative_cnt,
                SUM(CASE WHEN ai_sentiment='neutral'  THEN 1 ELSE 0 END)  AS neutral_cnt,
                SUM(CASE WHEN ai_sentiment='mixed'    THEN 1 ELSE 0 END)  AS mixed_cnt,
                MAX(publish_ts)                                           AS latest_ts
            FROM (
                SELECT article_id, sector_tag, ai_sentiment, sentiment_score, publish_ts
                FROM news_article
                WHERE sentiment_done = 1
                QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
            ) t
            GROUP BY sector_tag
            ORDER BY avg_score DESC
        """) or []
        for r in rows:
            total = r.get("article_count") or 1
            r["positive_ratio"] = round((r.get("positive_cnt") or 0) / total * 100, 1)
            r["negative_ratio"] = round((r.get("negative_cnt") or 0) / total * 100, 1)
        return rows

    # ── 投资信号（板块情感→信号） ────────────────────────────
    async def get_signals(self):
        rows = await execute_query("""
            SELECT
                sector_tag,
                ROUND(AVG(sentiment_score), 1)                           AS avg_score,
                COUNT(DISTINCT article_id)                                AS cnt,
                SUM(CASE WHEN ai_sentiment='positive' THEN 1 ELSE 0 END)  AS pos,
                SUM(CASE WHEN ai_sentiment='negative' THEN 1 ELSE 0 END)  AS neg,
                SUM(CASE WHEN ai_sentiment='neutral'  THEN 1 ELSE 0 END)  AS neu,
                SUM(CASE WHEN ai_sentiment='mixed'    THEN 1 ELSE 0 END)  AS mix
            FROM (
                SELECT article_id, sector_tag, ai_sentiment, sentiment_score
                FROM news_article
                WHERE sentiment_done = 1
                QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
            ) t
            GROUP BY sector_tag
        """) or []
        signals = []
        for r in rows:
            score = float(r.get("avg_score") or 0)
            cnt   = r.get("cnt") or 0
            if score >= 35:
                sig = "bullish"
            elif score <= -20:
                sig = "bearish"
            else:
                sig = "neutral"
            confidence = min(int(abs(score) / 100 * 75 + 25), 95) if sig != "neutral" else 50
            signals.append({
                "sector":        r["sector_tag"],
                "signal":        sig,
                "avg_score":     round(score, 1),
                "confidence":    confidence,
                "article_count": cnt,
                "positive":      r.get("pos") or 0,
                "negative":      r.get("neg") or 0,
                "neutral":       r.get("neu") or 0,
                "mixed":         r.get("mix") or 0,
            })
        signals.sort(key=lambda x: -x["avg_score"])
        return signals

    # ── 热点公司（从 AI_EXTRACT 核心公司字段聚合） ──────────
    async def get_hot_companies(self):
        rows = await execute_query("""
            SELECT article_id, sector_tag, ai_extract
            FROM news_article
            WHERE extracted = 1
            QUALIFY ROW_NUMBER() OVER (PARTITION BY article_id ORDER BY publish_ts DESC) = 1
        """) or []
        company_map: dict = {}
        for r in rows:
            ex = r.get("ai_extract")
            if not ex:
                continue
            try:
                data = _parse_extract(ex)
                companies = data.get("Core Companies") or data.get("核心公司", [])
                if isinstance(companies, str):
                    companies = [c.strip() for c in re.split(r"[,、]", companies) if c.strip()]
                sector = r.get("sector_tag", "其他")
                for c in companies:
                    if c and len(c) > 1:
                        if c not in company_map:
                            company_map[c] = {"company": c, "count": 0, "sectors": set()}
                        company_map[c]["count"] += 1
                        company_map[c]["sectors"].add(sector)
            except Exception:
                pass
        result = [
            {"company": v["company"], "count": v["count"], "sectors": list(v["sectors"])}
            for v in company_map.values()
        ]
        result.sort(key=lambda x: -x["count"])
        return result[:20]

    # ── 手动添加资讯（用户自定义内容）──────────────────────
    async def add_manual_news(self, title: str, content: str, source: str, sector: str):
        """手动添加一条资讯，不包含AI结果"""
        import uuid
        article_id = f"M{str(uuid.uuid4())[:9].upper()}"  # M 前缀表示手动添加
        ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        await execute_write(f"""
            INSERT INTO news_article
            VALUES('{article_id}', '{ts}', '{title.replace("'", "''")}',
                   '{content.replace("'", "''")}', '{source}', '{sector}',
                   NULL, 0, NULL, NULL, 0, NULL, 0, 'MANUAL')
        """)
        return {
            "msg": f"✅ 已添加手动资讯：{title[:40]}...",
            "article_id": article_id,
            "title": title,
            "sector": sector,
        }

    # ── 3合1：一键运行所有AI分析（仅更新未完成数据）────────
    async def run_all_ai(self):
        """依次运行 AI_SUMMARIZE → AI_SENTIMENT → AI_EXTRACT"""
        results = []
        labels_sql = "ARRAY(" + ",".join(f"'{l}'" for l in _EXTRACT_LABELS) + ")"

        # Step 1: AI_SUMMARIZE（未概括的）
        r1 = await execute_write(f"""
            UPDATE news_article
            SET ai_summary = AI_SUMMARIZE(content),
                summarized  = 1,
                ai_method   = 'DORIS_AI_FUNCTION'
            WHERE summarized = 0
        """)
        results.append(f"AI_SUMMARIZE: 处理 {r1} 篇")

        # Step 2: AI_SENTIMENT（未分析情感的）
        r2 = await execute_write(f"""
            UPDATE news_article
            SET ai_sentiment  = AI_SENTIMENT(content),
                sentiment_done = 1,
                ai_method      = 'DORIS_AI_FUNCTION'
            WHERE sentiment_done = 0
        """)
        results.append(f"AI_SENTIMENT: 处理 {r2} 篇")

        # Step 2b: 映射情感分数
        await execute_write("""
            UPDATE news_article
            SET sentiment_score = CASE ai_sentiment
                WHEN 'positive' THEN  60
                WHEN 'negative' THEN -60
                WHEN 'mixed'    THEN  15
                ELSE 0
            END
            WHERE sentiment_done = 1 AND sentiment_score IS NULL
        """)

        # Step 3: AI_EXTRACT（未提取标签的）
        r3 = await execute_write(f"""
            UPDATE news_article
            SET ai_extract = AI_EXTRACT(content, {labels_sql}),
                extracted = 1,
                ai_method = 'DORIS_AI_FUNCTION'
            WHERE extracted = 0
        """)
        results.append(f"AI_EXTRACT: 处理 {r3} 篇")

        return {
            "msg": "✅ AI 分析完成！" + " | ".join(results),
            "details": results,
            "total_processed": r1 + r2 + r3,
        }

    # ── 内部工具 ────────────────────────────────────────────
    def _build_where(self, flag: str, val: int, ids: list = None) -> str:
        parts = [f"{flag} = {val}"]
        if ids:
            id_str = ",".join(f"'{i}'" for i in ids)
            parts.append(f"article_id IN ({id_str})")
        return " AND ".join(parts)
