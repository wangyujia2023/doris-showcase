<template>
  <div class="tab-wrap">
    <div class="kpi-row" v-if="kpi">
      <div class="kpi-card" style="--top:#409eff">
        <div class="kc-label">{{ t('bjm.ticketRevTitle') }}</div>
        <div class="kc-value">{{ kpi.ticket_revenue_w }}<span class="kc-unit">{{ t('bjm.unitWanYuan') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#67c23a">
        <div class="kc-label">{{ t('bjm.adRevTitle') }}</div>
        <div class="kc-value">{{ kpi.ad_revenue_w }}<span class="kc-unit">{{ t('bjm.unitWanYuan') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#e6a23c">
        <div class="kc-label">{{ t('bjm.commRevTitle') }}</div>
        <div class="kc-value">{{ kpi.commercial_revenue_w }}<span class="kc-unit">{{ t('bjm.unitWanYuan') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#9c6cd4">
        <div class="kc-label">{{ t('bjm.totalRevTitle') }}</div>
        <div class="kc-value">{{ kpi.total_revenue_w }}<span class="kc-unit">{{ t('bjm.unitWanYuan') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#17b3a3">
        <div class="kc-label">{{ t('bjm.avgFare') }}</div>
        <div class="kc-value">{{ kpi.avg_fare }}<span class="kc-unit">{{ t('bjm.unitYuan') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#f56c6c">
        <div class="kc-label">{{ t('bjm.subsidy') }}</div>
        <div class="kc-value">{{ kpi.subsidy_w }}<span class="kc-unit">{{ t('bjm.unitWanYuan') }}</span></div>
      </div>
    </div>

    <div class="grid-2">
      <el-card class="chart-card">
        <template #header><div class="ch">💹 {{ t('bjm.revTrendTitle') }}</div></template>
        <div id="bj-rev-trend" style="height:260px"></div>
      </el-card>

      <el-card class="chart-card">
        <template #header><div class="ch">🎫 {{ t('bjm.ticketTypeTitle') }}</div></template>
        <div id="bj-ticket-type" style="height:260px"></div>
      </el-card>
    </div>

    <el-card class="chart-card">
      <template #header><div class="ch">📊 各线路收入对比（万英镑）</div></template>
      <div id="bj-rev-byline" style="height:240px"></div>
    </el-card>

    <el-card class="chart-card">
      <template #header><div class="ch">📋 {{ t('bjm.revenueDetailTitle') }}</div></template>
      <el-table :data="revenueByLine" stripe size="small" style="width:100%">
        <el-table-column :label="t('bjm.line')" width="100">
          <template #default="{ row }">
            <div style="display:flex;align-items:center;gap:6px">
              <span :style="{ display:'inline-block', width:'10px', height:'10px', borderRadius:'50%', background:row.line_color }"></span>
              {{ row.line_name }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="ticket_w" :label="`${t('bjm.ticketRevShort')}(万)`" sortable/>
        <el-table-column prop="ad_w"     :label="`${t('bjm.adRevShort')}(万)`" sortable/>
        <el-table-column prop="comm_w"   :label="`${t('bjm.commRevShort')}(万)`" sortable/>
        <el-table-column :label="`${t('bjm.total')}(万)`" sortable>
          <template #default="{ row }">
            <strong>{{ ((+row.ticket_w) + (+row.ad_w) + (+row.comm_w)).toFixed(1) }}</strong>
          </template>
        </el-table-column>
        <el-table-column prop="total_tickets" :label="t('bjm.totalPassengers')" sortable/>
        <el-table-column prop="avg_fare"      :label="`${t('bjm.avgFare')}(元)`" sortable/>
        <el-table-column :label="t('bjm.revenueShare')">
          <template #default="{ row }">
            <el-progress
              :percentage="+(( (+row.ticket_w)/totalTicketRev*100 ).toFixed(1))"
              :stroke-width="6" style="width:100px"/>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { bjMetroApi } from '@/api'
import { t } from '@/i18n'
import { useDomChart } from '@/composables/useChart'

const { renderChart } = useDomChart()

const kpi           = ref(null)
const revTrend      = ref([])
const ticketTypes   = ref([])
const revenueByLine = ref([])

const totalTicketRev = computed(() =>
  revenueByLine.value.reduce((s, r) => s + (+r.ticket_w || 0), 0) || 1
)

onMounted(async () => {
  const [k, rt, tt, rb] = await Promise.all([
    bjMetroApi.revenueKpi(),
    bjMetroApi.revenueTrend(),
    bjMetroApi.revenueTicketTypes(),
    bjMetroApi.revenueByLine(),
  ])
  kpi.value           = k
  revTrend.value      = rt.data || []
  ticketTypes.value   = tt.data || []
  revenueByLine.value = rb.data || []
  renderRevTrend(); renderTicketType(); renderByLineChart()
})

const renderRevTrend = () => {
  renderChart('bj-rev-trend', {
    tooltip: { trigger: 'axis' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    grid: { left: 55, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'category', data: revTrend.value.map(d => d.date), axisLabel: { color: '#999', fontSize: 10, rotate: 30 } },
    yAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    series: [
      { name: t('bjm.ticketRevShort'), type: 'bar', stack: 'r', data: revTrend.value.map(d => d.ticket_w), itemStyle: { color: '#409eff' } },
      { name: t('bjm.adRevShort'), type: 'bar', stack: 'r', data: revTrend.value.map(d => d.ad_w),     itemStyle: { color: '#67c23a' } },
      { name: t('bjm.commRevShort'), type: 'bar', stack: 'r', data: revTrend.value.map(d => d.comm_w),   itemStyle: { color: '#e6a23c' } },
    ]
  })
}

const renderByLineChart = () => {
  const sorted = [...revenueByLine.value].sort((a, b) => (+b.ticket_w + +b.ad_w + +b.comm_w) - (+a.ticket_w + +a.ad_w + +a.comm_w))
  renderChart('bj-rev-byline', {
    tooltip: { trigger: 'axis' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    grid: { left: 90, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    yAxis: { type: 'category', data: sorted.map(d => d.line_name), axisLabel: { color: '#64748b', fontSize: 11 } },
    series: [
      { name: t('bjm.ticketRevShort'), type: 'bar', stack: 'r', data: sorted.map(d => +d.ticket_w), itemStyle: { color: '#409eff' } },
      { name: t('bjm.adRevShort'),     type: 'bar', stack: 'r', data: sorted.map(d => +d.ad_w),     itemStyle: { color: '#67c23a' } },
      { name: t('bjm.commRevShort'),   type: 'bar', stack: 'r', data: sorted.map(d => +d.comm_w),   itemStyle: { color: '#e6a23c', borderRadius: [0,3,3,0] } },
    ]
  })
}

const renderTicketType = () => {
  const colors = ['#409eff','#67c23a','#e6a23c','#9c6cd4']
  renderChart('bj-ticket-type', {
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    series: [{
      type: 'pie', radius: ['40%', '68%'],
      data: ticketTypes.value.map((d, i) => ({
        name: d.type, value: d.pct, itemStyle: { color: colors[i % colors.length] }
      })),
      itemStyle: { borderColor: '#fff', borderWidth: 3 },
      label: { formatter: '{b}\n{d}%', fontSize: 11 }
    }]
  })
}
</script>

<style scoped>
.tab-wrap { display:flex; flex-direction:column; gap:12px; }
.kpi-row { display:grid; grid-template-columns:repeat(6,1fr); gap:10px; }
.kpi-card { background:#fff; border:1px solid #e8edf3; border-top:3px solid var(--top,#409eff); border-radius:6px; padding:14px 16px; }
.kc-label { font-size:12px; color:#909399; margin-bottom:8px; }
.kc-value { font-size:22px; font-weight:700; color:#1f2a37; }
.kc-unit  { font-size:12px; font-weight:400; color:#909399; margin-left:2px; }
.grid-2   { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.chart-card { background:#fff; border:1px solid #e8edf3; }
.chart-card:hover { box-shadow:0 4px 14px rgba(27,39,51,.07); }
.chart-card :deep(.el-card__header) { padding:12px 16px; border-bottom:1px solid #f0f2f5; }
.ch { font-weight:600; font-size:13px; color:#1f2a37; display:flex; align-items:center; gap:8px; }
</style>
