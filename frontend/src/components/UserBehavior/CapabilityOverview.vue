<template>
  <div class="capability-page">
    <section class="hero">
      <div>
        <div class="eyebrow">{{ copy.heroEyebrow }}</div>
        <h1>{{ copy.heroTitle }}</h1>
        <p>{{ copy.heroDesc }}</p>
      </div>
      <div class="hero-metrics">
        <div v-for="item in heroMetrics" :key="item.label" class="hero-metric">
          <strong>{{ item.value }}</strong>
          <span>{{ item.label }}</span>
        </div>
      </div>
    </section>

    <section class="arch-panel">
      <div class="section-title">
        <span>{{ copy.archTitle }}</span>
        <em>{{ copy.archDesc }}</em>
      </div>
      <div class="arch-flow">
        <div class="flow-col source">
          <div v-for="node in copy.sources" :key="node.name" class="flow-node">{{ node.name }}<span>{{ node.sub }}</span></div>
        </div>
        <div class="flow-arrow">→</div>
        <div class="doris-core">
          <div class="core-title">Apache Doris</div>
          <div class="core-grid">
            <div>user_wide<br><small>UNIQUE KEY · MOW · row store</small></div>
            <div>user_tag_bitmap<br><small>RoaringBitmap</small></div>
            <div>user_event_detail<br><small>DUPLICATE KEY</small></div>
            <div>user_profile_mv<br><small>{{ copy.mvSub }}</small></div>
          </div>
        </div>
        <div class="flow-arrow">→</div>
        <div class="flow-col output">
          <div v-for="node in copy.outputs" :key="node.name" class="flow-node">{{ node.name }}<span>{{ node.sub }}</span></div>
        </div>
      </div>
    </section>

    <section class="ability-nav">
      <button
        v-for="(cap, idx) in capabilities"
        :key="cap.key"
        :class="{ active: selectedIdx === idx }"
        @click="selectedIdx = idx"
      >
        <component :is="cap.icon" />
        <span>{{ cap.title }}</span>
        <em>{{ cap.short }}</em>
      </button>
    </section>

    <section class="ability-detail">
      <div class="detail-main">
        <div class="detail-head">
          <div class="detail-icon"><component :is="selected.icon" /></div>
          <div>
            <div class="eyebrow">{{ selected.badge }}</div>
            <h2>{{ selected.title }}</h2>
            <p>{{ selected.desc }}</p>
          </div>
        </div>

        <div class="scenario-strip">
          <div v-for="item in selected.scenarios" :key="item" class="scenario">{{ item }}</div>
        </div>

        <div class="schema-card">
          <div class="card-title">{{ copy.schemaTitle }}</div>
          <div class="code-window">
            <div class="code-toolbar"><span></span><span></span><span></span><em>DDL</em></div>
            <pre v-html="highlightSql(selected.schema)"></pre>
          </div>
        </div>

        <div v-for="block in selected.sqlBlocks" :key="block.title" class="sql-card">
          <div class="card-title">{{ block.title }}</div>
          <p v-if="block.desc" class="sql-desc">{{ block.desc }}</p>
          <div class="code-window">
            <div class="code-toolbar"><span></span><span></span><span></span><em>SQL</em></div>
            <pre v-html="highlightSql(block.sql)"></pre>
          </div>
        </div>
      </div>

      <aside class="detail-side">
        <div class="side-card">
          <div class="card-title">{{ copy.metricTitle }}</div>
          <div v-for="m in selected.metrics" :key="m.label" class="metric-row">
            <strong>{{ m.value }}</strong>
            <span>{{ m.label }}</span>
          </div>
        </div>
        <div class="side-card">
          <div class="card-title">{{ copy.fitTitle }}</div>
          <ul>
            <li v-for="feature in selected.features" :key="feature">{{ feature }}</li>
          </ul>
        </div>
      </aside>
    </section>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { locale } from '@/i18n'
import { DataAnalysis, Connection, Histogram, RefreshRight } from '@element-plus/icons-vue'

const selectedIdx = ref(0)

const COPY = {
  zh: {
    heroEyebrow: 'Apache Doris · 用户分析能力全景',
    heroTitle: '一个引擎完成用户画像、圈选、行为分析与实时更新',
    heroDesc: '围绕 CDP 用户宽表，Doris 把点查、Bitmap 集合计算、行为序列函数和实时写入放在同一套 SQL 引擎内。业务页面无需在 OLAP、KV、标签系统和离线计算之间反复搬数。',
    archTitle: '数据流架构',
    archDesc: '业务数据 + 行为流 + 标签计算统一沉淀到 Doris',
    mvSub: '物化视图加速',
    schemaTitle: 'Schema 建模',
    metricTitle: '能力指标',
    fitTitle: '为什么适合用户分析',
    sources: [
      { name: 'APP / Web 行为流', sub: 'Kafka / Stream Load / Routine Load' },
      { name: '核心业务库', sub: 'Flink CDC / Batch Load' },
      { name: '营销与风控系统', sub: '标签、分群、评分部分列写入' },
    ],
    outputs: [
      { name: '用户宽表查询', sub: '毫秒级客户画像' },
      { name: '人群圈选', sub: '交并差实时预估' },
      { name: '漏斗 / 留存 / 路径', sub: '行为序列 SQL' },
    ],
    metrics: [
      { value: '4', label: '用户分析核心能力' },
      { value: '1', label: '统一 SQL 引擎' },
      { value: '0', label: '跨系统搬数' },
    ],
    capabilities: [
      {
        key: 'wide',
        title: '用户宽表高并发点查',
        short: 'UNIQUE KEY · MOW · store_row_column',
        badge: '能力 01 / 实时用户画像',
        icon: DataAnalysis,
        desc: '把用户属性、资产、活跃度、风险标记和标签摘要沉淀到 user_wide。主键索引支持按用户 ID 毫秒级定位，store_row_column 让点查读取完整行时只需一次 IO，而不是按列多次读取；列存仍服务多维过滤分析。',
        metrics: [
          { value: '<5ms', label: '单用户画像点查' },
          { value: '1000+', label: '宽表维度承载' },
          { value: 'MOW', label: '实时合并视图' },
        ],
        scenarios: ['客服 360 画像', '风控实时特征', '营销触达前校验', '用户明细筛选'],
        features: [
          'UNIQUE KEY + Merge-on-Write 保证最新画像可查',
          '主键索引避免全表扫描，适合用户详情页',
          'store_row_column 保存行存副本，点查完整画像时一次 IO 即可读取完整行',
          '列式读取仍服务资产层级、城市、生命周期等分析过滤',
        ],
    schema: `CREATE TABLE user_wide (
  user_id          BIGINT       NOT NULL,
  user_name        VARCHAR(64),
  city             VARCHAR(64),
  asset_level      VARCHAR(32),
  active_level     VARCHAR(32),
  lifecycle_stage  VARCHAR(32),
  aum_total        DECIMAL(18,2),
  credit_score     INT,
  anomaly_flag     TINYINT,
  update_time      DATETIME
)
UNIQUE KEY(user_id)
DISTRIBUTED BY HASH(user_id) BUCKETS 16
PROPERTIES (
  "enable_unique_key_merge_on_write" = "true",
  "store_row_column"                 = "true",
  "replication_num" = "1"
);`,
        sqlBlocks: [
          {
            title: 'SQL 01 · 用户详情点查',
            desc: '用户详情页、客服工作台、风控实时决策都可以按 user_id 直接读取最新画像。',
            sql: `-- 用户详情页：按 user_id 精确拉取画像
SELECT user_id, user_name, city, asset_level, active_level,
       lifecycle_stage, aum_total, credit_score, anomaly_flag
FROM user_wide
WHERE user_id = 10000088;`,
          },
          {
            title: 'SQL 02 · 多维客群明细',
            desc: '同一张宽表也能服务运营筛选，无需把画像同步到另一套检索系统。',
            sql: `-- 客群明细：多维过滤，直接服务前端列表
SELECT user_id, user_name, asset_level, aum_total
FROM user_wide
WHERE asset_level IN ('VIP钻石', 'VIP私行')
  AND active_level = '高活'
  AND anomaly_flag = 0
ORDER BY aum_total DESC
LIMIT 100;`,
          },
        ],
      },
      {
        key: 'bitmap',
        title: 'Bitmap 标签与人群圈选',
        short: 'RoaringBitmap',
        badge: '能力 02 / 亿级人群集合计算',
        icon: Connection,
        desc: '每个标签维护一组用户 Bitmap。圈选条件转换成 Bitmap 交、并、差，快速完成多标签组合、排除包、规模预估和人群包落表。',
        metrics: [
          { value: '<1s', label: '大规模圈选预估' },
          { value: 'AND/OR/NOT', label: '集合组合' },
          { value: '90%+', label: '压缩收益' },
        ],
        scenarios: ['营销人群圈选', '风险客群排除', '标签交叉分析', '人群包构建'],
        features: [
          'Bitmap 存储用户集合，避免逐行 join 和重复扫描',
          'BITMAP_AND/OR/NOT 天然表达运营圈选规则',
          '圈选结果可直接写回人群包表继续运营',
        ],
    schema: `CREATE TABLE user_tag_bitmap (
  tag_id       INT,
  tag_name     VARCHAR(128),
  category     VARCHAR(64),
  user_bitmap  BITMAP BITMAP_UNION,
  update_time  DATETIME
)
AGGREGATE KEY(tag_id, tag_name, category)
DISTRIBUTED BY HASH(tag_id) BUCKETS 8
PROPERTIES ("replication_num" = "1");`,
        sqlBlocks: [
          {
            title: 'SQL 01 · 标签集合计算',
            desc: '运营条件被翻译成 Bitmap 集合表达式，先预估规模，再决定是否创建人群包。',
            sql: `-- 高净值 ∩ 高活 ∩ 非风险用户
WITH tags AS (
  SELECT
    BITMAP_UNION(IF(tag_name = '高净值', user_bitmap, NULL)) AS high_value,
    BITMAP_UNION(IF(tag_name = '高活', user_bitmap, NULL)) AS active_users,
    BITMAP_UNION(IF(tag_name = '风险用户', user_bitmap, NULL)) AS risk_users
  FROM user_tag_bitmap
)
SELECT BITMAP_COUNT(
         BITMAP_AND(
           BITMAP_AND(high_value, active_users),
           BITMAP_NOT(risk_users)
         )
       ) AS target_user_count
FROM tags;`,
          },
        ],
      },
      {
        key: 'behavior',
        title: '行为序列分析函数',
        short: '漏斗 · 留存 · 路径',
        badge: '能力 03 / 行为分析 SQL 化',
        icon: Histogram,
        desc: '行为明细表进入 Doris 后，漏斗、留存、路径匹配可以直接用 SQL 表达。分析链路从“离线任务 + 中间表”变成“页面参数 + SQL 查询”。',
        metrics: [
          { value: '1 Scan', label: '一次扫描完成漏斗' },
          { value: 'SQL', label: '行为逻辑可解释' },
          { value: '实时', label: '最新事件可参与分析' },
        ],
        scenarios: ['注册到交易漏斗', '7日留存', '关键路径归因', 'Session 分析'],
        features: [
          'window_funnel 表达多步骤转化层级',
          'retention/sequence_match 支持留存和路径判断',
          '行为分析与用户画像表可在 Doris 内直接 JOIN',
        ],
    schema: `CREATE TABLE user_event_detail (
  event_time   DATETIME,
  user_id      BIGINT,
  session_id   VARCHAR(64),
  event_name   VARCHAR(64),
  event_value  STRING,
  channel      VARCHAR(32)
)
DUPLICATE KEY(event_time, user_id, event_name)
PARTITION BY RANGE(event_time) ()
DISTRIBUTED BY HASH(user_id) BUCKETS 16
PROPERTIES (
  "dynamic_partition.enable" = "true",
  "dynamic_partition.time_unit" = "DAY",
  "replication_num" = "1"
);`,
        sqlBlocks: [
          {
            title: 'SQL 01 · 漏斗转化',
            desc: '用窗口函数直接计算用户到达的最深步骤，适合页面按时间窗、渠道、资产层级下钻。',
            sql: `-- 7 天窗口：浏览理财 -> 加购 -> 购买 的转化层级
SELECT
  window_funnel(7 * 24 * 3600)(
    event_time,
    event_name = 'view_fund',
    event_name = 'add_to_cart',
    event_name = 'purchase'
  ) AS funnel_step,
  COUNT(DISTINCT user_id) AS users
FROM user_event_detail
WHERE event_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY funnel_step
ORDER BY funnel_step;`,
          },
          {
            title: 'SQL 02 · 行为与画像联动',
            desc: '行为事件和用户宽表都在 Doris 内，按资产层级、风险等级、生命周期分组不需要外部 ETL。',
            sql: `-- 与用户宽表联动：看不同资产层级客群转化
SELECT u.asset_level, COUNT(DISTINCT e.user_id) AS converted_users
FROM user_event_detail e
JOIN user_wide u ON e.user_id = u.user_id
WHERE e.event_name = 'purchase'
GROUP BY u.asset_level;`,
          },
        ],
      },
      {
        key: 'realtime',
        title: '实时接入与画像更新',
        short: 'Routine Load · Partial Update',
        badge: '能力 04 / 秒级新鲜度',
        icon: RefreshRight,
        desc: 'Kafka 行为流、业务库 CDC、风控评分和标签刷新持续写入 Doris。画像更新应优先使用导入链路的部分列更新能力，而不是频繁 UPDATE；Doris 更擅长高吞吐导入与分析查询。',
        metrics: [
          { value: '秒级', label: '数据接入延迟' },
          { value: '列级', label: 'Partial Update' },
          { value: '多源', label: '并发更新画像' },
        ],
        scenarios: ['实时行为入仓', '风险评分刷新', '标签回写', '运营触达后效果追踪'],
        features: [
          'Routine Load 持续消费 Kafka 行为流',
          'Stream Load / INSERT 导入链路开启 partial_columns，只写变化列',
          '避免把 Doris 当 OLTP 高频 UPDATE 库使用',
          '新数据进入后直接服务宽表查询、Bitmap 圈选和行为分析',
        ],
    schema: `-- Kafka 行为流进入 user_event_detail
CREATE ROUTINE LOAD cdp_event_load ON user_event_detail
COLUMNS(event_time, user_id, session_id, event_name, event_value, channel)
PROPERTIES (
  "format" = "json",
  "desired_concurrent_number" = "3"
)
FROM KAFKA (
  "kafka_broker_list" = "broker:9092",
  "kafka_topic" = "cdp_user_events"
);

-- user_wide 开启 MOW 后支持导入链路部分列更新`,
        sqlBlocks: [
          {
            title: 'SQL 01 · Stream Load 部分列更新',
            desc: '风控或标签系统只提交主键和变化列，Doris 在 MOW 表内合并成最新画像。',
            sql: `curl --location-trusted -u root: \\
  -H "format: json" \\
  -H "read_json_by_line: true" \\
  -H "partial_columns: true" \\
  -H "columns: user_id,credit_score,anomaly_flag,update_time" \\
  -T risk_score_patch.json \\
  http://fe-host:8030/api/cdp/user_wide/_stream_load

-- risk_score_patch.json
{"user_id":10000088,"credit_score":682,"anomaly_flag":1,"update_time":"2026-05-03 16:00:00"}`,
          },
          {
            title: 'SQL 02 · INSERT INTO 指定列补丁',
            desc: '批量标签刷新可以只写主键和标签列；适合分钟级、批量化画像刷新。',
            sql: `-- 开启部分列更新模式
SET enable_unique_key_partial_update = true;
-- 关闭严格模式（允许插入不存在的 key）
SET enable_insert_strict = false;

INSERT INTO user_wide (user_id, active_level, lifecycle_stage, update_time)
VALUES
  (10000088, '高活', '成长期', NOW()),
  (10000120, '中活', '成熟期', NOW());

-- 前提：UNIQUE KEY + MOW + partial update 导入语义
-- 结果：未出现的列保持原值，查询仍返回完整最新画像`,
          },
        ],
      },
    ],
  },
}

COPY.en = {
  ...COPY.zh,
  heroEyebrow: 'Apache Doris · User Analytics Capability Map',
  heroTitle: 'One engine for profiles, segmentation, behavior analytics, and real-time profile refresh',
  heroDesc: 'Around the CDP user wide table, Doris keeps point lookup, Bitmap set operations, behavior sequence functions, and ingestion-driven profile refresh in one SQL engine. Product pages do not need to shuttle data between OLAP, KV stores, tag systems, and offline jobs.',
  archTitle: 'Data Flow Architecture',
  archDesc: 'Business data, behavior streams, and tag computation are unified in Doris',
  mvSub: 'Materialized view acceleration',
  schemaTitle: 'Schema Model',
  metricTitle: 'Capability Metrics',
  fitTitle: 'Why it fits user analytics',
  sources: [
    { name: 'APP / Web Events', sub: 'Kafka / Stream Load / Routine Load' },
    { name: 'Core Business DB', sub: 'Flink CDC / Batch Load' },
    { name: 'Marketing & Risk Systems', sub: 'Partial-column profile patches' },
  ],
  outputs: [
    { name: 'User Wide Query', sub: 'Millisecond customer profile' },
    { name: 'Audience Segmentation', sub: 'Real-time AND/OR/NOT estimation' },
    { name: 'Funnel / Retention / Path', sub: 'Behavior sequence SQL' },
  ],
  metrics: [
    { value: '4', label: 'Core analytics capabilities' },
    { value: '1', label: 'Unified SQL engine' },
    { value: '0', label: 'Cross-system data copies' },
  ],
  capabilities: COPY.zh.capabilities.map((cap, idx) => ({
    ...cap,
    title: [
      'High-concurrency wide-table point lookup',
      'Bitmap tags and audience segmentation',
      'Behavior sequence analysis functions',
      'Real-time ingestion and profile refresh',
    ][idx],
    badge: [
      'Capability 01 / Real-time user profile',
      'Capability 02 / Large-scale audience set computing',
      'Capability 03 / Behavior analytics as SQL',
      'Capability 04 / Second-level freshness',
    ][idx],
    desc: [
      'User attributes, assets, activity, risk flags, and tag summaries are stored in user_wide. The primary-key index locates a user in milliseconds, while store_row_column lets a point lookup read the complete row with one IO instead of one IO per column. Columnar storage still serves analytical filtering.',
      'Each tag maintains a user Bitmap. Segmentation rules become Bitmap AND/OR/NOT operations for fast multi-tag combinations, exclusions, size estimation, and audience package creation.',
      'After events land in Doris, funnel, retention, and path matching can be expressed directly in SQL. The workflow changes from offline jobs and intermediate tables to page parameters plus SQL queries.',
      'Kafka events, CDC data, risk scores, and tag refreshes continuously land in Doris. Profile refresh should prefer ingestion-time partial column updates instead of frequent UPDATE statements; Doris is better at high-throughput ingestion and analytical querying.',
    ][idx],
    short: [
      'UNIQUE KEY · MOW · store_row_column',
      'RoaringBitmap',
      'Funnel · Retention · Path',
      'Routine Load · Partial Update',
    ][idx],
    scenarios: [
      ['Customer 360 profile', 'Real-time risk features', 'Pre-campaign eligibility check', 'User detail filtering'],
      ['Marketing audience build', 'Risk audience exclusion', 'Tag cross analysis', 'Audience package creation'],
      ['Registration-to-trade funnel', '7-day retention', 'Critical path attribution', 'Session analysis'],
      ['Real-time event ingestion', 'Risk score refresh', 'Tag write-back', 'Campaign effect tracking'],
    ][idx],
    metrics: [
      [{ value: '<5ms', label: 'Single-user profile lookup' }, { value: '1000+', label: 'Wide-table dimensions' }, { value: 'MOW', label: 'Latest merged view' }],
      [{ value: '<1s', label: 'Large-scale estimation' }, { value: 'AND/OR/NOT', label: 'Set composition' }, { value: '90%+', label: 'Compression gain' }],
      [{ value: '1 Scan', label: 'Funnel in one scan' }, { value: 'SQL', label: 'Explainable behavior logic' }, { value: 'Real-time', label: 'Fresh events participate' }],
      [{ value: 'Seconds', label: 'Ingestion latency' }, { value: 'Column', label: 'Partial Update' }, { value: 'Multi-source', label: 'Concurrent profile patches' }],
    ][idx],
    features: [
      ['UNIQUE KEY + Merge-on-Write keeps the latest profile queryable', 'Primary-key index avoids full table scans for detail pages', 'store_row_column stores a row copy so complete profile point lookup can read the whole row in one IO', 'Columnar reads still serve analytical filtering by asset, city, and lifecycle'],
      ['Bitmap stores user sets without row-by-row joins', 'BITMAP_AND/OR/NOT maps naturally to segmentation rules', 'Results can be persisted as audience packages for activation'],
      ['window_funnel expresses multi-step conversion depth', 'retention/sequence_match support retention and path checks', 'Events can join user_wide directly inside Doris'],
      ['Routine Load continuously consumes Kafka events', 'Stream Load / INSERT ingestion can enable partial_columns and write only changed columns', 'Avoid using Doris as a high-frequency OLTP UPDATE store', 'Fresh data immediately serves profile queries, Bitmap segmentation, and behavior analytics'],
    ][idx],
    sqlBlocks: cap.sqlBlocks.map((block) => ({
      ...block,
      title: block.title
        .replace('用户详情点查', 'User profile lookup')
        .replace('多维客群明细', 'Multi-dimensional audience details')
        .replace('标签集合计算', 'Bitmap set computation')
        .replace('漏斗转化', 'Funnel conversion')
        .replace('行为与画像联动', 'Behavior-profile join')
        .replace('Stream Load 部分列更新', 'Stream Load partial-column update')
        .replace('INSERT INTO 指定列补丁', 'INSERT specified-column patch'),
      desc: '',
    })),
  })),
}

const copy = computed(() => COPY[locale.value] || COPY.zh)
const heroMetrics = computed(() => copy.value.metrics)
const capabilities = computed(() => copy.value.capabilities)
const selected = computed(() => capabilities.value[selectedIdx.value])

function escapeHtml(text) {
  return String(text)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
}

function highlightSql(text) {
  const keywords = 'CREATE|TABLE|SELECT|FROM|WHERE|WITH|AS|INSERT|INTO|VALUES|PROPERTIES|DISTRIBUTED|BY|HASH|BUCKETS|UNIQUE|KEY|DUPLICATE|AGGREGATE|PARTITION|RANGE|ORDER|GROUP|LIMIT|JOIN|ON|SET|TRUE|FALSE|NULL|AND|OR|NOT|UPDATE|COLUMNS|KAFKA|IN|IF|COUNT|DISTINCT|NOW'
  const pattern = new RegExp(`(--.*$)|('[^']*')|("[^"]*")|\\\\b(${keywords})\\\\b|(\\\\b\\\\d+\\\\b)`, 'gmi')
  let html = ''
  let last = 0
  for (const match of String(text).matchAll(pattern)) {
    html += escapeHtml(String(text).slice(last, match.index))
    const token = match[0]
    const cls = match[1] ? 'tok-comment'
      : match[2] || match[3] ? 'tok-string'
        : match[4] ? 'tok-keyword'
          : 'tok-number'
    html += `<span class="${cls}">${escapeHtml(token)}</span>`
    last = match.index + token.length
  }
  html += escapeHtml(String(text).slice(last))
  return html
}
</script>

<style scoped>
.capability-page {
  height: calc(100vh - 180px);
  overflow-y: auto;
  padding: 12px;
  background: #f6f7f9;
  color: #1f2933;
}

.hero {
  display: grid;
  grid-template-columns: 1.6fr 360px;
  gap: 14px;
  padding: 20px;
  background: #ffffff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
}

.eyebrow {
  font-size: 12px;
  font-weight: 700;
  color: #2563eb;
  margin-bottom: 8px;
}

.hero h1 {
  margin: 0;
  font-size: 26px;
  line-height: 1.25;
  font-weight: 800;
  color: #111827;
}

.hero p {
  margin: 8px 0 0;
  max-width: 900px;
  font-size: 14px;
  line-height: 1.8;
  color: #5f6b7a;
}

.hero-metrics {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.hero-metric {
  min-height: 88px;
  padding: 12px 10px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  background: #f9fafb;
  display: flex;
  flex-direction: column;
  justify-content: center;
  text-align: center;
}

.hero-metric strong {
  font-size: 30px;
  color: #0f766e;
}

.hero-metric span {
  margin-top: 8px;
  font-size: 12px;
  color: #6b7280;
}

.arch-panel,
.ability-detail {
  margin-top: 12px;
  background: #ffffff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 14px;
}

.section-title {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
}

.section-title span,
.card-title {
  font-size: 14px;
  font-weight: 800;
  color: #111827;
}

.section-title em {
  font-size: 12px;
  color: #8a94a6;
  font-style: normal;
}

.arch-flow {
  display: grid;
  grid-template-columns: 220px 36px 1fr 36px 220px;
  gap: 12px;
  align-items: center;
}

.flow-col {
  display: grid;
  gap: 10px;
}

.flow-node {
  padding: 12px;
  border: 1px solid #d8dde6;
  border-radius: 8px;
  background: #fbfcfe;
  font-size: 13px;
  font-weight: 700;
}

.flow-node span {
  display: block;
  margin-top: 5px;
  font-size: 11px;
  font-weight: 500;
  color: #7b8494;
}

.flow-arrow {
  text-align: center;
  color: #2563eb;
  font-size: 22px;
  font-weight: 800;
}

.doris-core {
  padding: 16px;
  border: 2px solid #2563eb;
  border-radius: 8px;
  background: #eff6ff;
}

.core-title {
  text-align: center;
  font-size: 17px;
  font-weight: 900;
  color: #1d4ed8;
  margin-bottom: 12px;
}

.core-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px;
}

.core-grid div {
  padding: 12px;
  background: #ffffff;
  border: 1px solid #bfdbfe;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 800;
  color: #1e3a8a;
  text-align: center;
}

.core-grid small {
  color: #64748b;
  font-weight: 600;
}

.ability-nav {
  margin-top: 12px;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 0;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  background: #f5f7fa;
  overflow: hidden;
}

.ability-nav button {
  height: 74px;
  border: none;
  border-right: 1px solid #dcdfe6;
  border-top: 2px solid transparent;
  background: #f5f7fa;
  padding: 10px 14px;
  text-align: left;
  cursor: pointer;
  transition: background .15s, border-top-color .15s;
  position: relative;
}

.ability-nav button:last-child {
  border-right: none;
}

.ability-nav button:hover {
  background: #ecf5ff;
  border-top-color: #a0cfff;
}

.ability-nav button.active {
  background: #ffffff;
  border-top-color: #409eff;
  box-shadow: 0 1px 0 #ffffff;
  z-index: 1;
}

.ability-nav svg {
  width: 16px;
  height: 16px;
  color: #909399;
}

.ability-nav button.active svg {
  color: #409eff;
}

.ability-nav button:hover:not(.active) svg {
  color: #606266;
}

.ability-nav span,
.ability-nav em {
  display: block;
}

.ability-nav span {
  margin-top: 5px;
  font-size: 13px;
  font-weight: 600;
  color: #606266;
}

.ability-nav em {
  margin-top: 2px;
  font-size: 11px;
  color: #c0c4cc;
  font-style: normal;
}

.ability-nav button.active span {
  color: #303133;
}

.ability-nav button.active em {
  color: #909399;
}

.ability-detail {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 280px;
  gap: 14px;
}

.detail-head {
  display: flex;
  gap: 14px;
  align-items: flex-start;
}

.detail-icon {
  width: 44px;
  height: 44px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #eff6ff;
  color: #2563eb;
  flex-shrink: 0;
}

.detail-icon svg {
  width: 24px;
  height: 24px;
}

.detail-head h2 {
  margin: 0;
  font-size: 20px;
  color: #111827;
}

.detail-head p {
  margin: 8px 0 0;
  font-size: 13px;
  line-height: 1.8;
  color: #5f6b7a;
}

.scenario-strip {
  margin: 12px 0;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.scenario {
  padding: 6px 10px;
  border-radius: 4px;
  background: #ecfdf5;
  color: #047857;
  font-size: 12px;
  font-weight: 700;
}

.schema-card,
.sql-card,
.side-card {
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  background: #fbfcfe;
  padding: 12px;
}

.sql-card {
  margin-top: 12px;
}

.sql-desc {
  margin: 8px 0 0;
  color: #64748b;
  font-size: 12px;
  line-height: 1.6;
}

.code-window {
  margin-top: 10px;
  overflow: hidden;
  border: 1px solid #343b47;
  border-radius: 8px;
  background: #282d35;
  box-shadow: inset 0 1px 0 rgba(255,255,255,.04);
}

.code-toolbar {
  display: flex;
  align-items: center;
  gap: 7px;
  height: 34px;
  padding: 0 12px;
  border-bottom: 1px solid #343b47;
  background: #242932;
}

.code-toolbar span {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: #5c6573;
}

.code-toolbar span:nth-child(1) { background: #e06c75; }
.code-toolbar span:nth-child(2) { background: #d19a66; }
.code-toolbar span:nth-child(3) { background: #98c379; }

.code-toolbar em {
  margin-left: 6px;
  color: #7f8794;
  font-size: 11px;
  font-style: normal;
  font-weight: 700;
  letter-spacing: .08em;
}

pre {
  margin: 10px 0 0;
  padding: 12px 14px;
  overflow-x: auto;
  background: #282d35;
  color: #b8c0cc;
  font-size: 12px;
  line-height: 1.65;
  font-family: Menlo, Monaco, Consolas, monospace;
  white-space: pre;
}

.code-window pre {
  margin: 0;
}

:deep(.tok-comment) { color: #6f7887; font-style: italic; }
:deep(.tok-keyword) { color: #d48cf5; }
:deep(.tok-string) { color: #a6d189; }
:deep(.tok-number) { color: #d9a66c; }

.detail-side {
  display: grid;
  align-content: start;
  gap: 12px;
}

.metric-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-top: 10px;
  padding: 10px;
  border-radius: 6px;
  background: #ffffff;
  border: 1px solid #edf0f5;
}

.metric-row strong {
  color: #0f766e;
  font-size: 16px;
}

.metric-row span {
  color: #6b7280;
  font-size: 12px;
}

ul {
  margin: 10px 0 0;
  padding: 0;
  list-style: none;
}

li {
  padding: 8px 0;
  border-bottom: 1px solid #edf0f5;
  color: #4b5563;
  font-size: 12px;
  line-height: 1.6;
}

li:last-child {
  border-bottom: 0;
}

@media (max-width: 1180px) {
  .hero,
  .ability-detail,
  .arch-flow {
    grid-template-columns: 1fr;
  }

  .flow-arrow {
    transform: rotate(90deg);
  }

  .ability-nav {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 640px) {
  .capability-page {
    padding: 12px;
  }

  .hero {
    padding: 18px;
  }

  .hero h1 {
    font-size: 22px;
  }

  .hero-metrics,
  .core-grid,
  .ability-nav {
    grid-template-columns: 1fr;
  }
}
</style>
