<template>
  <div class="tab-wrap">
    <!-- 全局 loading -->
    <div v-if="loading" class="loading-mask">
      <el-icon class="loading-spin"><Loading /></el-icon>
      <span>数据加载中…</span>
    </div>

    <!-- KPI 行 -->
    <div class="kpi-row" v-if="kpi && !loading">
      <div class="kpi-card" style="--top:#409eff">
        <div class="kc-label">今日累计客流</div>
        <div class="kc-value">{{ kpi.daily_passengers_w }}<span class="kc-unit">万人次</span></div>
      </div>
      <div class="kpi-card" style="--top:#67c23a">
        <div class="kc-label">平均准点率</div>
        <div class="kc-value">{{ (kpi.punctuality_rate * 100).toFixed(1) }}<span class="kc-unit">%</span></div>
      </div>
      <div class="kpi-card" style="--top:#e6a23c">
        <div class="kc-label">今日运营收入</div>
        <div class="kc-value">{{ kpi.daily_revenue_w }}<span class="kc-unit">万元</span></div>
      </div>
      <div class="kpi-card" style="--top:#f56c6c">
        <div class="kc-label">当前故障告警</div>
        <div class="kc-value" style="color:#f56c6c">{{ kpi.fault_count }}<span class="kc-unit">项</span></div>
      </div>
      <div class="kpi-card" style="--top:#9c6cd4">
        <div class="kc-label">运营线路</div>
        <div class="kc-value">{{ kpi.active_lines }}<span class="kc-unit">条</span></div>
      </div>
      <div class="kpi-card" style="--top:#17b3a3">
        <div class="kc-label">在线列车</div>
        <div class="kc-value">{{ kpi.active_trains }}<span class="kc-unit">列</span></div>
      </div>
    </div>

    <div class="grid-2-1" v-if="!loading">
      <!-- 客流趋势 -->
      <el-card class="chart-card">
        <template #header><div class="ch">📈 今日全网客流趋势</div></template>
        <div id="bj-flow-trend" style="height:240px"></div>
      </el-card>

      <!-- 实时告警 -->
      <el-card class="chart-card">
        <template #header>
          <div class="ch">🚨 实时告警
            <el-tag type="danger" size="small" style="margin-left:8px">{{ alerts.length }} 待处理</el-tag>
          </div>
        </template>
        <div class="alert-list">
          <div v-for="a in alerts" :key="a.fault_id"
               class="alert-item" :class="severityClass(a.severity)">
            <div class="ai-dot"></div>
            <div class="ai-body">
              <div class="ai-title">{{ a.line_name }} · {{ a.station_name }} · {{ a.fault_type }}</div>
              <div class="ai-meta">{{ a.severity }} · {{ a.device_type }} · {{ a.handler }}</div>
            </div>
          </div>
          <div v-if="!alerts.length" class="empty">暂无告警</div>
        </div>
      </el-card>
    </div>

    <div class="grid-3" v-if="!loading">
      <!-- 线路客流排行 -->
      <el-card class="chart-card">
        <template #header><div class="ch">🏆 线路客流排行</div></template>
        <div class="rank-list">
          <div v-for="(row, i) in lineRanking" :key="row.line_id" class="rank-item">
            <span class="rank-num" :class="i < 3 ? 'top' : ''">{{ i + 1 }}</span>
            <span class="line-dot" :style="{ background: row.line_color }"></span>
            <span class="rank-name">{{ row.line_name }}</span>
            <div class="rank-bar-wrap">
              <div class="rank-bar" :style="{
                width: lineRanking[0]?.daily_passengers
                  ? (row.daily_passengers / lineRanking[0].daily_passengers * 100) + '%'
                  : '0%',
                background: row.line_color
              }"></div>
            </div>
            <span class="rank-val">{{ fmtPassengers(row.daily_passengers) }}万</span>
          </div>
        </div>
      </el-card>

      <!-- 准点率雷达 -->
      <el-card class="chart-card">
        <template #header><div class="ch">⏱️ 各线准点率</div></template>
        <div id="bj-punctuality" style="height:260px"></div>
      </el-card>

      <!-- 线路状态表 -->
      <el-card class="chart-card">
        <template #header><div class="ch">🟢 线路运营状态</div></template>
        <el-table :data="lineStatus" size="small" style="width:100%">
          <el-table-column prop="line_name" label="线路" width="80"/>
          <el-table-column label="状态" width="70">
            <template #default="{ row }">
              <el-tag :type="row.delay_count > 0 ? 'warning' : 'success'" size="small">
                {{ row.delay_count > 0 ? '延误' : '正常' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="准点率" width="70">
            <template #default="{ row }">
              {{ row.punctuality_rate ? (row.punctuality_rate * 100).toFixed(1) + '%' : '-' }}
            </template>
          </el-table-column>
          <el-table-column label="客流(万)" width="70">
            <template #default="{ row }">
              {{ fmtPassengers(row.daily_passengers) }}
            </template>
          </el-table-column>
        </el-table>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { Loading } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { bjMetroApi } from '@/api'

const kpi         = ref(null)
const flowTrend   = ref([])
const lineRanking = ref([])
const punctuality = ref([])
const alerts      = ref([])
const lineStatus  = ref([])
const loading     = ref(true)

const severityClass = (s) => ({ '严重': 'crit', '警告': 'warn', '信息': 'info' }[s] || 'info')

// 客流(万) 显示：0 是有效值，null/undefined 才显示 -
const fmtPassengers = (v) => (v != null ? Math.round(v / 10000) : '-')

onMounted(async () => {
  try {
    const res = await bjMetroApi.overviewAll()
    kpi.value         = res.kpi         || {}
    flowTrend.value   = res.flow_trend  || []
    lineRanking.value = res.line_ranking|| []
    punctuality.value = res.punctuality || []
    alerts.value      = res.alerts      || []
    lineStatus.value  = res.line_status || []
  } finally {
    loading.value = false
  }
  await nextTick()
  renderFlowTrend()
  renderPunctuality()
})

const renderFlowTrend = () => {
  const c = echarts.init(document.getElementById('bj-flow-trend'))
  const hours = flowTrend.value.map(d => `${String(d.hour).padStart(2,'0')}:00`)
  const vals  = flowTrend.value.map(d => d.passengers)
  c.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 50, right: 20, top: 20, bottom: 30 },
    xAxis: { type: 'category', data: hours, axisLabel: { color: '#999', fontSize: 11 } },
    yAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    series: [{
      type: 'line', data: vals, smooth: true, symbol: 'none',
      lineStyle: { color: '#409eff', width: 2.5 },
      areaStyle: { color: { type: 'linear', x:0,y:0,x2:0,y2:1, colorStops: [{ offset:0, color:'rgba(64,158,255,.25)' },{ offset:1, color:'rgba(64,158,255,.01)' }] } },
    }]
  })
  window.addEventListener('resize', () => c.resize())
}

const renderPunctuality = () => {
  const c = echarts.init(document.getElementById('bj-punctuality'))
  c.setOption({
    tooltip: { trigger: 'item' },
    radar: {
      indicator: punctuality.value.map(d => ({ name: d.line_name, max: 100, min: 96 })),
      radius: '68%', axisName: { color: '#64748b', fontSize: 11 }
    },
    series: [{
      type: 'radar',
      data: [{ value: punctuality.value.map(d => d.punctuality_pct), name: '准点率',
               areaStyle: { color: 'rgba(64,158,255,.15)' },
               lineStyle: { color: '#409eff' }, itemStyle: { color: '#409eff' } }]
    }]
  })
  window.addEventListener('resize', () => c.resize())
}
</script>

<style scoped>
.tab-wrap { display: flex; flex-direction: column; gap: 12px; }

.loading-mask {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  height: 200px;
  color: #909399;
  font-size: 14px;
}
.loading-spin {
  animation: spin 1s linear infinite;
  font-size: 20px;
  color: #409eff;
}
@keyframes spin { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
.kpi-row { display: grid; grid-template-columns: repeat(6, 1fr); gap: 10px; }
.kpi-card {
  background: #fff;
  border: 1px solid #e8edf3;
  border-top: 3px solid var(--top, #409eff);
  border-radius: 6px;
  padding: 14px 16px;
  transition: box-shadow .2s;
}
.kpi-card:hover { box-shadow: 0 4px 14px rgba(27,39,51,.08); }
.kc-label { font-size: 12px; color: #909399; margin-bottom: 8px; }
.kc-value { font-size: 24px; font-weight: 700; color: #1f2a37; }
.kc-unit  { font-size: 12px; font-weight: 400; color: #909399; margin-left: 2px; }

.grid-2-1 { display: grid; grid-template-columns: 2fr 1fr; gap: 12px; }
.grid-3   { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }

.chart-card { background: #fff; border: 1px solid #e8edf3; }
.chart-card:hover { box-shadow: 0 4px 14px rgba(27,39,51,.07); }
.chart-card :deep(.el-card__header) { padding: 12px 16px; border-bottom: 1px solid #f0f2f5; }
.ch { font-weight: 600; font-size: 13px; color: #1f2a37; display: flex; align-items: center; }

/* 告警 */
.alert-list { display: flex; flex-direction: column; gap: 7px; max-height: 280px; overflow-y: auto; padding: 2px 0; }
.alert-item { display: flex; align-items: flex-start; gap: 8px; padding: 8px 10px; border-radius: 5px; border-left: 3px solid; }
.alert-item.crit { background: #fef2f2; border-color: #f56c6c; }
.alert-item.warn { background: #fff7ed; border-color: #e6a23c; }
.alert-item.info { background: #eff6ff; border-color: #409eff; }
.ai-dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; margin-top: 4px; flex-shrink: 0; }
.crit .ai-dot { color: #f56c6c; }
.warn .ai-dot { color: #e6a23c; }
.info .ai-dot { color: #409eff; }
.ai-title { font-size: 12px; font-weight: 500; color: #1f2a37; }
.ai-meta  { font-size: 11px; color: #909399; margin-top: 2px; }
.empty { text-align: center; color: #c0c4cc; padding: 20px; font-size: 13px; }

/* 排行 */
.rank-list { display: flex; flex-direction: column; gap: 8px; }
.rank-item { display: flex; align-items: center; gap: 8px; font-size: 12px; }
.rank-num  { width: 18px; text-align: center; font-weight: 700; color: #c0c4cc; flex-shrink: 0; }
.rank-num.top { color: #e6a23c; }
.line-dot  { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; }
.rank-name { width: 52px; color: #1f2a37; font-weight: 500; flex-shrink: 0; }
.rank-bar-wrap { flex: 1; background: #f0f2f5; border-radius: 3px; height: 7px; overflow: hidden; }
.rank-bar  { height: 100%; border-radius: 3px; opacity: .8; }
.rank-val  { width: 36px; text-align: right; color: #409eff; font-weight: 600; }
</style>
