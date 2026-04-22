<template>
  <div class="tab-wrap">
    <div class="kpi-row" v-if="kpi">
      <div class="kpi-card" style="--top:#409eff">
        <div class="kc-label">今日票务收入</div>
        <div class="kc-value">{{ kpi.ticket_revenue_w }}<span class="kc-unit">万元</span></div>
      </div>
      <div class="kpi-card" style="--top:#67c23a">
        <div class="kc-label">广告收入（今日）</div>
        <div class="kc-value">{{ kpi.ad_revenue_w }}<span class="kc-unit">万元</span></div>
      </div>
      <div class="kpi-card" style="--top:#e6a23c">
        <div class="kc-label">商业收入（今日）</div>
        <div class="kc-value">{{ kpi.commercial_revenue_w }}<span class="kc-unit">万元</span></div>
      </div>
      <div class="kpi-card" style="--top:#9c6cd4">
        <div class="kc-label">今日总收入</div>
        <div class="kc-value">{{ kpi.total_revenue_w }}<span class="kc-unit">万元</span></div>
      </div>
      <div class="kpi-card" style="--top:#17b3a3">
        <div class="kc-label">人均票价</div>
        <div class="kc-value">{{ kpi.avg_fare }}<span class="kc-unit">元</span></div>
      </div>
      <div class="kpi-card" style="--top:#f56c6c">
        <div class="kc-label">优惠补贴（今日）</div>
        <div class="kc-value">{{ kpi.subsidy_w }}<span class="kc-unit">万元</span></div>
      </div>
    </div>

    <div class="grid-2">
      <el-card class="chart-card">
        <template #header><div class="ch">💹 30天收入构成趋势</div></template>
        <div id="bj-rev-trend" style="height:260px"></div>
      </el-card>

      <el-card class="chart-card">
        <template #header><div class="ch">🎫 票务类型结构</div></template>
        <div id="bj-ticket-type" style="height:260px"></div>
      </el-card>
    </div>

    <el-card class="chart-card">
      <template #header><div class="ch">📋 各线路收益明细（30天汇总）</div></template>
      <el-table :data="revenueByLine" stripe size="small" style="width:100%">
        <el-table-column label="线路" width="100">
          <template #default="{ row }">
            <div style="display:flex;align-items:center;gap:6px">
              <span :style="{ display:'inline-block', width:'10px', height:'10px', borderRadius:'50%', background:row.line_color }"></span>
              {{ row.line_name }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="ticket_w" label="票务收入(万)" sortable/>
        <el-table-column prop="ad_w"     label="广告收入(万)" sortable/>
        <el-table-column prop="comm_w"   label="商业收入(万)" sortable/>
        <el-table-column label="总计(万)" sortable>
          <template #default="{ row }">
            <strong>{{ ((+row.ticket_w) + (+row.ad_w) + (+row.comm_w)).toFixed(1) }}</strong>
          </template>
        </el-table-column>
        <el-table-column prop="total_tickets" label="总客次" sortable/>
        <el-table-column prop="avg_fare"      label="人均票价(元)" sortable/>
        <el-table-column label="收入占比">
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
import * as echarts from 'echarts'
import { bjMetroApi } from '@/api'

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
  renderRevTrend(); renderTicketType()
})

const renderRevTrend = () => {
  const c = echarts.init(document.getElementById('bj-rev-trend'))
  c.setOption({
    tooltip: { trigger: 'axis' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    grid: { left: 55, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'category', data: revTrend.value.map(d => d.date), axisLabel: { color: '#999', fontSize: 10, rotate: 30 } },
    yAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    series: [
      { name: '票务', type: 'bar', stack: 'r', data: revTrend.value.map(d => d.ticket_w), itemStyle: { color: '#409eff' } },
      { name: '广告', type: 'bar', stack: 'r', data: revTrend.value.map(d => d.ad_w),     itemStyle: { color: '#67c23a' } },
      { name: '商业', type: 'bar', stack: 'r', data: revTrend.value.map(d => d.comm_w),   itemStyle: { color: '#e6a23c' } },
    ]
  })
  window.addEventListener('resize', () => c.resize())
}

const renderTicketType = () => {
  const c = echarts.init(document.getElementById('bj-ticket-type'))
  const colors = ['#409eff','#67c23a','#e6a23c','#9c6cd4']
  c.setOption({
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
  window.addEventListener('resize', () => c.resize())
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
