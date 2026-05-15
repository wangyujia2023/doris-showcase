<template>
  <div class="tab-wrap">
    <div class="kpi-row" v-if="kpi">
      <div class="kpi-card" style="--top:#67c23a">
        <div class="kc-label">{{ t('bjm.trainPunctuality') }}</div>
        <div class="kc-value">{{ (kpi.punctuality_rate*100).toFixed(1) }}<span class="kc-unit">%</span></div>
      </div>
      <div class="kpi-card" style="--top:#409eff">
        <div class="kc-label">{{ t('bjm.trainActive') }}</div>
        <div class="kc-value">{{ kpi.active_trains }}<span class="kc-unit">{{ t('bjm.unitTrain') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#e6a23c">
        <div class="kc-label">{{ t('bjm.trainDelay') }}</div>
        <div class="kc-value">{{ kpi.delay_count }}<span class="kc-unit">{{ t('bjm.unitTrain') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#f56c6c">
        <div class="kc-label">{{ t('bjm.trainFaultToday') }}</div>
        <div class="kc-value" style="color:#f56c6c">{{ kpi.fault_count }}<span class="kc-unit">{{ t('bjm.unitFault') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#9c6cd4">
        <div class="kc-label">{{ t('bjm.trainMaxDelay') }}</div>
        <div class="kc-value">{{ Math.floor((kpi.max_delay_sec||0)/60) }}<span class="kc-unit">{{ t('bjm.unitMin') }}{{ (kpi.max_delay_sec||0)%60 }}{{ t('bjm.unitSec') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#17b3a3">
        <div class="kc-label">{{ t('bjm.trainMileage') }}</div>
        <div class="kc-value">{{ Math.round((kpi.total_mileage_km||0)/10000) }}<span class="kc-unit">{{ t('bjm.unitWanKm') }}</span></div>
      </div>
    </div>

    <div class="grid-2">
      <el-card class="chart-card">
        <template #header><div class="ch">📉 {{ t('bjm.trainPunctTrend') }}</div></template>
        <div id="bj-punct-trend" style="height:250px"></div>
      </el-card>

      <el-card class="chart-card">
        <template #header><div class="ch">🔧 {{ t('bjm.trainFaultReason') }}</div></template>
        <div id="bj-fault-pie" style="height:250px"></div>
      </el-card>
    </div>

    <div class="grid-2">
      <!-- 各线路准点率对比 -->
      <el-card class="chart-card">
        <template #header><div class="ch">🚦 各线路准点 vs 延误列车</div></template>
        <div id="bj-delay-byline" style="height:260px"></div>
      </el-card>

      <!-- 准点率分布 -->
      <el-card class="chart-card">
        <template #header><div class="ch">⭐ 各线路准点率排名</div></template>
        <div id="bj-punct-rank" style="height:260px"></div>
      </el-card>
    </div>

    <el-card class="chart-card">
      <template #header><div class="ch">🚇 {{ t('bjm.trainLineStatus') }}</div></template>
      <el-table :data="trainList" stripe size="small" style="width:100%">
        <el-table-column :label="t('bjm.line')" width="130">
          <template #default="{ row }">
            <div style="display:flex;align-items:center;gap:6px">
              <span :style="{ display:'inline-block', width:'10px', height:'10px', borderRadius:'50%', background:row.line_color }"></span>
              {{ row.line_name }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="actual_trains" :label="t('bjm.trainActual')" width="80"/>
        <el-table-column prop="planned_trains" :label="t('bjm.trainPlan')" width="80"/>
        <el-table-column :label="t('bjm.punctuality')" width="150">
          <template #default="{ row }">
            <el-progress :percentage="+(row.punctuality_rate*100).toFixed(1)"
                         :status="row.punctuality_rate >= 0.99 ? 'success' : row.punctuality_rate >= 0.97 ? '' : 'exception'"
                         :stroke-width="6" style="width:120px"/>
          </template>
        </el-table-column>
        <el-table-column prop="delay_count" :label="t('bjm.trainDelayCnt')" width="80"/>
        <el-table-column :label="t('bjm.trainMaxDelay')" width="100">
          <template #default="{ row }">
            {{ row.max_delay_sec > 0 ? Math.floor(row.max_delay_sec/60)+"'"+row.max_delay_sec%60+'"' : '—' }}
          </template>
        </el-table-column>
        <el-table-column :label="t('bjm.status')" width="90">
          <template #default="{ row }">
            <el-tag :type="row.delay_count > 2 ? 'danger' : row.delay_count > 0 ? 'warning' : 'success'" size="small">
              {{ row.delay_count > 2 ? t('bjm.delayedWarn') : row.delay_count > 0 ? t('bjm.delayed') : t('bjm.normal') }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { bjMetroApi } from '@/api'
import { t } from '@/i18n'
import { useDomChart } from '@/composables/useChart'

const { renderChart } = useDomChart()

const kpi        = ref(null)
const punctTrend = ref([])
const faultTypes = ref([])
const trainList  = ref([])

onMounted(async () => {
  const [k, pt, ft, tl] = await Promise.all([
    bjMetroApi.trainKpi(),
    bjMetroApi.trainPunctTrend(),
    bjMetroApi.trainFaultTypes(),
    bjMetroApi.trainList(),
  ])
  kpi.value        = k
  punctTrend.value = pt.data || []
  faultTypes.value = ft.data || []
  trainList.value  = tl.data || []
  await nextTick()
  renderPunctTrend(); renderFaultPie(); renderDelayByLine(); renderPunctRank()
})

const renderPunctTrend = () => {
  renderChart('bj-punct-trend', {
    tooltip: { trigger: 'axis' },
    grid: { left: 50, right: 20, top: 30, bottom: 40 },
    xAxis: { type: 'category', data: punctTrend.value.map(d => d.date?.slice(5)), axisLabel: { color: '#999', fontSize: 10, rotate: 30 } },
    yAxis: { type: 'value', min: 96, max: 100, axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    series: [{
      type: 'line', smooth: true, symbol: 'none',
      data: punctTrend.value.map(d => d.punctuality_pct),
      lineStyle: { color: '#67c23a', width: 2.5 },
      areaStyle: { color: 'rgba(103,194,58,.12)' },
      markLine: { data: [{ yAxis: 99, name: t('bjm.targetLine'), lineStyle: { color: '#f56c6c', type: 'dashed' } }] }
    }]
  })
}

const renderFaultPie = () => {
  const map = {}
  faultTypes.value.forEach(d => { map[d.device_type] = (map[d.device_type] || 0) + d.cnt })
  const colors = ['#f56c6c','#e6a23c','#409eff','#9c6cd4','#67c23a','#17b3a3','#c0c4cc','#f59e0b']
  renderChart('bj-fault-pie', {
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    series: [{
      type: 'pie', radius: ['38%', '65%'],
      data: Object.entries(map).map(([name, value], i) => ({ name, value, itemStyle: { color: colors[i % colors.length] } })),
      itemStyle: { borderColor: '#fff', borderWidth: 2 },
      label: { formatter: '{b}: {d}%', fontSize: 11 }
    }]
  })
}

const renderDelayByLine = () => {
  const data = trainList.value
  renderChart('bj-delay-byline', {
    tooltip: { trigger: 'axis' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    grid: { left: 90, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    yAxis: { type: 'category', data: data.map(d => d.line_name), axisLabel: { color: '#64748b', fontSize: 11 } },
    series: [
      { name: 'On Time', type: 'bar', stack: 't',
        data: data.map(d => Math.max(0, (d.actual_trains||0) - (d.delay_count||0))),
        itemStyle: { color: '#67c23a' } },
      { name: 'Delayed', type: 'bar', stack: 't',
        data: data.map(d => d.delay_count || 0),
        itemStyle: { color: '#f56c6c', borderRadius:[0,3,3,0] } },
    ]
  })
}

const renderPunctRank = () => {
  const sorted = [...trainList.value].sort((a, b) => b.punctuality_rate - a.punctuality_rate)
  renderChart('bj-punct-rank', {
    tooltip: { trigger: 'axis', formatter: p => `${p[0].name}: <b>${p[0].value}%</b>` },
    grid: { left: 90, right: 60, top: 10, bottom: 10 },
    xAxis: { type: 'value', min: 96, max: 100, axisLabel: { color: '#999', fontSize: 11 } },
    yAxis: { type: 'category', data: sorted.map(d => d.line_name), axisLabel: { color: '#64748b', fontSize: 11 } },
    series: [{
      type: 'bar', data: sorted.map(d => +(d.punctuality_rate*100).toFixed(2)), barMaxWidth: 16,
      itemStyle: {
        color: (params) => {
          const v = params.value
          return v >= 99 ? '#67c23a' : v >= 98 ? '#e6a23c' : '#f56c6c'
        },
        borderRadius: [0,4,4,0]
      },
      label: { show: true, position: 'right', formatter: p => p.value + '%', fontSize: 10, color: '#64748b' }
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
