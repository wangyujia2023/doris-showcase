<template>
  <div class="modern-wrap">
    <!-- Header Section -->
    <header class="page-header">
      <div class="header-content">
        <div class="eyebrow">Apache Doris · Realtime Financial Analytics</div>
        <h1>{{ t('securities.archTitle') }}</h1>
        <p class="desc">高性能实时证券分析看板，基于 Doris 极速查询能力，提供毫秒级多维分析体验。</p>
      </div>
      <div class="header-actions">
        <div class="status-pill">
          <span class="pulse"></span>
          Doris Cluster Connected
        </div>
        <el-button type="primary" class="modern-btn" :loading="loading" @click="doInit">
          {{ t('securities.initBtn') }}
        </el-button>
      </div>
    </header>

    <!-- KPI Row -->
    <div v-if="!overview.empty" class="kpi-grid">
      <div class="kpi-card" v-for="k in kpis" :key="k.label">
        <div class="kpi-icon" :style="{ backgroundColor: k.softColor, color: k.color }">
          <component :is="k.icon" />
        </div>
        <div class="kpi-body">
          <div class="kpi-value" :style="{ color: k.color }">{{ k.value }}</div>
          <div class="kpi-label">{{ k.label }}</div>
          <div class="kpi-delta" :class="k.deltaClass">{{ k.sub }}</div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <template v-if="!overview.empty">
      <div class="content-grid">
        <!-- Left Column: Charts -->
        <div class="span-8">
          <div class="glass-card">
            <div class="card-hd">
              <div>
                <div class="card-title">分钟成交趋势</div>
                <div class="card-sub">Realtime turnover and active client volume</div>
              </div>
              <div class="card-actions">
                <el-date-picker
                  v-model="localTimeRange"
                  type="datetimerange"
                  size="small"
                  class="modern-picker"
                  :start-placeholder="t('securities.startPh')"
                  :end-placeholder="t('securities.endPh')"
                />
              </div>
            </div>
            <div class="chart-box">
              <v-chart :option="trendOption" autoresize />
            </div>
          </div>

          <div class="glass-card mt-16">
            <div class="card-hd">
              <div>
                <div class="card-title">营业部实时经营</div>
                <div class="card-sub">Top branches performance metrics</div>
              </div>
            </div>
            <el-table :data="filteredBranches" class="modern-table">
              <el-table-column prop="branch_name" label="营业部" min-width="140" />
              <el-table-column label="成交额" width="120" align="right">
                <template #default="{ row }">
                  <span class="val-bold">{{ fmtYi(row.turnover_amt) }}</span>
                  <span class="unit">亿</span>
                </template>
              </el-table-column>
              <el-table-column label="净流入" width="120" align="right">
                <template #default="{ row }">
                  <span :class="numCls(row.net_inflow_amt)">{{ fmtWan(row.net_inflow_amt) }}</span>
                  <span class="unit">万</span>
                </template>
              </el-table-column>
              <el-table-column prop="active_clients" label="活跃客户" width="100" align="right" />
              <el-table-column label="状态" width="100">
                <template #default="{ row }">
                  <span class="status-tag" :class="row.avg_maintenance > 2 ? 'ok' : 'warn'">
                    {{ row.avg_maintenance > 2 ? '稳健' : '预警' }}
                  </span>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </div>

        <!-- Right Column: Distribution & Risk -->
        <div class="span-4">
          <div class="glass-card">
            <div class="card-hd">
              <div class="card-title">客户层级分布</div>
            </div>
            <div class="chart-box small">
              <v-chart :option="tierOption" autoresize />
            </div>
          </div>

          <div class="glass-card mt-16">
            <div class="card-hd">
              <div class="card-title">实时风险预警</div>
            </div>
            <div class="risk-list">
              <div v-for="r in filteredRisks.slice(0, 5)" :key="r.id" class="risk-item">
                <div class="risk-indicator" :class="riskTag(r.risk_level)"></div>
                <div class="risk-content">
                  <div class="risk-title">{{ r.alert_type }}</div>
                  <div class="risk-meta">{{ r.client_name }} · {{ r.branch_name }}</div>
                </div>
                <div class="risk-val">{{ r.metric_value }}</div>
              </div>
            </div>
          </div>

          <div class="glass-card mt-16">
            <div class="card-hd">
              <div class="card-title">板块热度</div>
            </div>
            <div class="tag-cloud">
              <span v-for="s in sectorHeat" :key="s.sector_name" 
                    class="modern-tag" 
                    :class="numCls(s.net_inflow_bn)">
                {{ s.sector_name }} {{ fmtYi(s.net_inflow_bn * 100000000) }}亿
              </span>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-illu">📈</div>
      <h2>等待数据初始化</h2>
      <p>点击上方按钮开启实时证券沙盘演示</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import dayjs from 'dayjs'
import { ElMessage } from 'element-plus'
import VChart from 'vue-echarts'
import { securitiesApi } from '@/api'
import { t } from '@/i18n'
import { registerEchartsBasic } from '@/plugins/registerEchartsBasic'
import { 
  TrendCharts, 
  User, 
  Wallet, 
  Warning, 
  Notification,
  DataAnalysis
} from '@element-plus/icons-vue'

registerEchartsBasic()

const loading = ref(false)
const overview = ref({ empty: true, tier_dist: [] })
const trend = ref([])
const branches = ref([])
const sectorHeat = ref([])
const risks = ref([])
const localTimeRange = ref([])

const filteredBranches = computed(() => branches.value)
const filteredRisks = computed(() => risks.value)

const kpis = computed(() => [
  {
    label: '客户总 AUM',
    value: fmtYi(overview.value.total_aum),
    sub: `${overview.value.account_cnt || 0} 个账户`,
    color: '#1570EF',
    softColor: '#EFF6FF',
    icon: Wallet,
    deltaClass: ''
  },
  {
    label: '当日成交额',
    value: fmtYi(overview.value.turnover_today),
    sub: `共 ${overview.value.trade_count || 0} 笔`,
    color: '#15A46E',
    softColor: '#ECFDF3',
    icon: TrendCharts,
    deltaClass: 'up'
  },
  {
    label: '风险预警',
    value: overview.value.risk_alert_cnt || 0,
    sub: `高风险 ${risks.value.filter(r => r.risk_level === '高').length} 条`,
    color: '#E5484D',
    softColor: '#FFF1F0',
    icon: Warning,
    deltaClass: 'down'
  }
])

const trendOption = computed(() => ({
  tooltip: { 
    trigger: 'axis',
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderWidth: 0,
    boxShadow: '0 8px 30px rgba(0,0,0,0.1)',
    textStyle: { color: '#1F2937' }
  },
  grid: { left: 40, right: 20, top: 20, bottom: 30 },
  xAxis: { 
    type: 'category', 
    data: trend.value.map(i => dayjs(i.ts).format('HH:mm')),
    axisLine: { lineStyle: { color: '#E5E7EB' } },
    axisLabel: { color: '#6B7280' }
  },
  yAxis: [
    { type: 'value', splitLine: { lineStyle: { type: 'dashed', color: '#F3F4F6' } } },
    { type: 'value', show: false }
  ],
  series: [
    {
      name: '成交额',
      type: 'line',
      smooth: true,
      symbol: 'none',
      data: trend.value.map(i => i.turnover_bn),
      lineStyle: { width: 3, color: '#1570EF' },
      areaStyle: {
        color: {
          type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
          colorStops: [{ offset: 0, color: 'rgba(21, 112, 239, 0.15)' }, { offset: 1, color: 'rgba(21, 112, 239, 0)' }]
        }
      }
    }
  ]
}))

const tierOption = computed(() => ({
  series: [{
    type: 'pie',
    radius: ['50%', '80%'],
    itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
    label: { show: false },
    data: (overview.value.tier_dist || []).map(i => ({ name: i.client_tier, value: i.cnt }))
  }],
  color: ['#1570EF', '#0EA5A4', '#7C3AED', '#F59E0B', '#E5484D']
}))

const fmtYi = v => (Number(v || 0) / 100000000).toFixed(2)
const fmtWan = v => (Number(v || 0) / 10000).toFixed(2)
const numCls = v => Number(v) >= 0 ? 'up' : 'down'
const riskTag = v => v === '高' ? 'bad' : v === '中' ? 'warn' : 'info'

async function loadAll() {
  const [ov, tr, br, sh, rs] = await Promise.all([
    securitiesApi.overview(),
    securitiesApi.trend(),
    securitiesApi.branches(),
    securitiesApi.sectorHeat(),
    securitiesApi.riskAlerts()
  ])
  overview.value = ov || { empty: true, tier_dist: [] }
  trend.value = tr || []
  branches.value = br || []
  sectorHeat.value = sh || []
  risks.value = rs || []
}

async function doInit() {
  loading.value = true
  try {
    await securitiesApi.init()
    await securitiesApi.batch(18)
    await loadAll()
    ElMessage.success('证券演示数据已就绪')
  } finally {
    loading.value = false
  }
}

onMounted(loadAll)
</script>

<style scoped>
.modern-wrap {
  padding: 24px;
  min-height: 100%;
  background: 
    radial-gradient(circle at 12% -8%, rgba(21,112,239,0.08), transparent 30%),
    radial-gradient(circle at 82% 0%, rgba(14,165,164,0.06), transparent 28%),
    #F9FAFB;
  font-family: "Inter", -apple-system, sans-serif;
}

/* Header */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-bottom: 32px;
}
.eyebrow {
  color: #1570EF;
  font-weight: 700;
  font-size: 12px;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  margin-bottom: 8px;
}
h1 {
  font-size: 32px;
  font-weight: 850;
  letter-spacing: -0.04em;
  color: #111827;
  margin: 0 0 8px 0;
}
.desc {
  color: #6B7280;
  font-size: 14px;
  margin: 0;
}
.header-actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 12px;
}
.status-pill {
  background: white;
  border: 1px solid #E5E7EB;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 8px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.03);
}
.pulse {
  width: 8px; height: 8px; background: #15A46E; border-radius: 50%;
  box-shadow: 0 0 0 4px rgba(21, 164, 110, 0.1);
}
.modern-btn {
  border-radius: 12px;
  height: 42px;
  padding: 0 24px;
  font-weight: 700;
  background: linear-gradient(135deg, #1570EF, #3B82F6);
  border: none;
  box-shadow: 0 10px 20px rgba(21, 112, 239, 0.2);
}

/* KPI Grid */
.kpi-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}
.kpi-card {
  background: white;
  border: 1px solid #E5E7EB;
  border-radius: 20px;
  padding: 24px;
  display: flex;
  gap: 20px;
  align-items: center;
  transition: transform 0.2s;
}
.kpi-card:hover { transform: translateY(-4px); }
.kpi-icon {
  width: 56px; height: 56px; border-radius: 16px;
  display: grid; place-items: center;
  font-size: 24px;
}
.kpi-value { font-size: 32px; font-weight: 850; letter-spacing: -0.05em; }
.kpi-label { font-size: 13px; color: #6B7280; font-weight: 600; margin-top: 2px; }
.kpi-delta { font-size: 12px; margin-top: 4px; font-weight: 700; }

/* Grid Layout */
.content-grid {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 24px;
}
.span-8 { grid-column: span 8; }
.span-4 { grid-column: span 4; }

/* Cards */
.glass-card {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(229, 231, 235, 0.5);
  border-radius: 24px;
  padding: 24px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.04);
}
.card-hd {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
}
.card-title { font-size: 18px; font-weight: 800; color: #111827; letter-spacing: -0.02em; }
.card-sub { font-size: 13px; color: #9CA3AF; margin-top: 4px; }
.chart-box { height: 320px; }
.chart-box.small { height: 240px; }

/* Table */
.modern-table {
  --el-table-border-color: transparent;
  --el-table-header-bg-color: #F9FAFB;
}
.val-bold { font-weight: 750; color: #111827; }
.unit { font-size: 11px; color: #9CA3AF; margin-left: 2px; }
.up { color: #E5484D !important; font-weight: 700; }
.down { color: #15A46E !important; font-weight: 700; }

/* Tags & Tags Cloud */
.modern-tag {
  display: inline-flex;
  padding: 6px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  background: #F3F4F6;
  color: #374151;
  margin: 4px;
}
.modern-tag.up { background: #FFF1F0; color: #E5484D; }
.modern-tag.down { background: #ECFDF3; color: #15A46E; }

.status-tag {
  padding: 2px 8px; border-radius: 6px; font-size: 11px; font-weight: 800;
}
.status-tag.ok { background: #ECFDF3; color: #15A46E; }
.status-tag.warn { background: #FFF7ED; color: #F59E0B; }

/* Risk List */
.risk-list { display: flex; flex-direction: column; gap: 12px; }
.risk-item {
  display: flex; align-items: center; gap: 12px;
  padding: 12px; border-radius: 14px; background: #F9FAFB;
}
.risk-indicator { width: 4px; height: 32px; border-radius: 2px; }
.risk-indicator.bad { background: #E5484D; }
.risk-indicator.warn { background: #F59E0B; }
.risk-content { flex: 1; }
.risk-title { font-size: 13px; font-weight: 700; }
.risk-meta { font-size: 11px; color: #9CA3AF; }
.risk-val { font-weight: 800; font-size: 14px; }

/* Empty */
.empty-state {
  text-align: center; padding: 100px 0;
}
.empty-illu { font-size: 64px; margin-bottom: 20px; }

.mt-16 { margin-top: 16px; }
</style>
