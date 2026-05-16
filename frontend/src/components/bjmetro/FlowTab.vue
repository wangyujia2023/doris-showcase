<template>
  <div class="tab-wrap">
    <div v-if="loading" class="loading-mask"><el-icon class="loading-spin"><Loading /></el-icon><span>{{ t('common.loading') }}</span></div>
    <el-alert v-else-if="error" :title="error" type="error" show-icon style="margin-bottom:8px"/>
    <template v-else>
    <div class="kpi-row">
      <div class="kpi-card" style="--top:#409eff">
        <div class="kc-label">{{ t('bjm.flowToday') }}</div>
        <div class="kc-value">{{ todayTotal }}<span class="kc-unit">{{ t('bjm.unitWanTimes') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#67c23a">
        <div class="kc-label">{{ t('bjm.morningPeak') }}</div>
        <div class="kc-value">{{ morningPeak }}<span class="kc-unit">{{ t('bjm.unitWanPerHour') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#e6a23c">
        <div class="kc-label">{{ t('bjm.eveningPeak') }}</div>
        <div class="kc-value">{{ eveningPeak }}<span class="kc-unit">{{ t('bjm.unitWanPerHour') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#f56c6c">
        <div class="kc-label">{{ t('bjm.overcap') }}</div>
        <div class="kc-value" style="color:#f56c6c">{{ overcapTotal }}<span class="kc-unit">{{ t('bjm.unitStation') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#9c6cd4">
        <div class="kc-label">{{ t('bjm.hotspotTop') }}</div>
        <div class="kc-value">{{ hotStations[0]?.station_name || '-' }}</div>
      </div>
    </div>

    <div class="grid-2">
      <el-card class="chart-card">
        <template #header>
          <div class="ch">⏰ {{ t('bjm.periodFlow') }}</div>
        </template>
        <div id="bj-hourly" style="height:260px"></div>
      </el-card>

      <el-card class="chart-card">
        <template #header><div class="ch">📊 {{ t('bjm.trend30d') }}</div></template>
        <div id="bj-flow-30d" style="height:260px"></div>
      </el-card>
    </div>

    <div class="grid-2">
      <!-- 热点站点 -->
      <el-card class="chart-card">
        <template #header><div class="ch">🔥 {{ t('bjm.hotspotStations') }}</div></template>
        <div id="bj-hot-stations" style="height:300px"></div>
      </el-card>

      <!-- OD对 -->
      <el-card class="chart-card">
        <template #header>
          <div class="ch">🔄 {{ t('bjm.odFlow') }}
            <el-radio-group v-model="peakType" size="small" style="margin-left:auto"
                            @change="loadOd">
              <el-radio-button label="morning">{{ t('bjm.morning') }}</el-radio-button>
              <el-radio-button label="evening">{{ t('bjm.evening') }}</el-radio-button>
              <el-radio-button label="off">{{ t('bjm.off') }}</el-radio-button>
            </el-radio-group>
          </div>
        </template>
        <el-table :data="odPairs.slice(0,10)" size="small" style="width:100%">
          <el-table-column type="index" label="#" width="36"/>
          <el-table-column prop="origin_name" :label="t('bjm.originStation')" />
          <el-table-column prop="dest_name"   :label="t('bjm.destStation')" />
          <el-table-column prop="total_flow"  :label="`${t('bjm.flowCount')}`" sortable/>
        </el-table>
      </el-card>
    </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { Loading } from '@element-plus/icons-vue'
import { bjMetroApi } from '@/api'
import { t } from '@/i18n'
import { useDomChart } from '@/composables/useChart'

const { renderChart } = useDomChart()

const hourly     = ref([])
const trend30d   = ref([])
const hotStations= ref([])
const odPairs    = ref([])
const peakType   = ref('morning')

const todayTotal = computed(() => {
  const sum = hourly.value.reduce((a, b) => a + (b.workday_avg || 0), 0)
  return Math.round(sum / 10000)
})
const morningPeak = computed(() => {
  const h = hourly.value.find(d => d.hour === 8)
  return h ? Math.round((h.workday_avg || 0) / 10000) : 0
})
const eveningPeak = computed(() => {
  const h = hourly.value.find(d => d.hour === 17)
  return h ? Math.round((h.workday_avg || 0) / 10000) : 0
})
const overcapTotal = computed(() =>
  hourly.value.reduce((s, h) => s + (h.avg_overcap || 0), 0)
)

const loading = ref(true)
const error   = ref('')

onMounted(async () => {
  try {
    const [h, trend, hs, od] = await Promise.all([
      bjMetroApi.flowHourly(),
      bjMetroApi.flowTrend(),
      bjMetroApi.flowHotStations(),
      bjMetroApi.flowOdPairs('morning'),
    ])
    hourly.value     = h.data || []
    trend30d.value   = trend.data || []
    hotStations.value= hs.data || []
    odPairs.value    = od.data || []
    await nextTick()
    renderHourly(); renderTrend(); renderHotStations()
  } catch (e) {
    error.value = e.message || 'Failed to load flow data'
  } finally {
    loading.value = false
  }
})

const loadOd = async () => {
  const od = await bjMetroApi.flowOdPairs(peakType.value)
  odPairs.value = od.data || []
}

const renderHourly = () => {
  const labels = hourly.value.map(d => `${String(d.hour).padStart(2,'0')}:00`)
  renderChart('bj-hourly', {
    tooltip: { trigger: 'axis' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    grid: { left: 50, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'category', data: labels, axisLabel: { color: '#999', fontSize: 10 } },
    yAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    series: [
      { name: t('bjm.weekday'), type: 'line', smooth: true, symbol: 'none',
        data: hourly.value.map(d => d.workday_avg),
        lineStyle: { color: '#409eff', width: 2.5 },
        areaStyle: { color: 'rgba(64,158,255,.1)' } },
      { name: t('bjm.weekend'), type: 'line', smooth: true, symbol: 'none',
        data: hourly.value.map(d => d.weekend_avg),
        lineStyle: { color: '#67c23a', width: 2, type: 'dashed' } },
    ]
  })
}

const renderTrend = () => {
  renderChart('bj-flow-30d', {
    tooltip: { trigger: 'axis' },
    grid: { left: 60, right: 20, top: 20, bottom: 30 },
    xAxis: { type: 'category', data: trend30d.value.map(d => d.date), axisLabel: { color: '#999', fontSize: 10, rotate: 30 } },
    yAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    series: [{
      type: 'bar', data: trend30d.value.map(d => d.total_passengers), barMaxWidth: 18,
      itemStyle: { color: { type: 'linear', x:0,y:0,x2:0,y2:1,
        colorStops: [{ offset:0, color:'#409eff' },{ offset:1, color:'rgba(64,158,255,.3)' }] },
        borderRadius: [3,3,0,0] }
    }]
  })
}

const renderHotStations = () => {
  const top = hotStations.value.slice(0, 15).reverse()
  renderChart('bj-hot-stations', {
    tooltip: { trigger: 'axis', formatter: p => `${p[0].name}: ${p[0].value?.toLocaleString()}${t('bjm.unitWanTimes')}` },
    grid: { left: 80, right: 60, top: 10, bottom: 10 },
    xAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    yAxis: { type: 'category', data: top.map(d => d.station_name), axisLabel: { color: '#64748b', fontSize: 11 } },
    series: [{
      type: 'bar', data: top.map(d => d.inbound_count), barMaxWidth: 14,
      itemStyle: { color: { type: 'linear', x:0,y:0,x2:1,y2:0,
        colorStops: [{ offset:0, color:'rgba(64,158,255,.4)' },{ offset:1, color:'#409eff' }] },
        borderRadius: [0,4,4,0] },
      label: { show: true, position: 'right', formatter: p => (p.value/10000).toFixed(1)+t('bjm.unitWanTimes'), fontSize: 10, color: '#64748b' }
    }]
  })
}
</script>

<style scoped>
.tab-wrap { display: flex; flex-direction: column; gap: 12px; }
.loading-mask { display:flex; align-items:center; justify-content:center; gap:10px; height:200px; color:#909399; font-size:14px; }
.loading-spin { animation:spin 1s linear infinite; font-size:20px; color:#409eff; }
@keyframes spin { from { transform:rotate(0deg); } to { transform:rotate(360deg); } }
.kpi-row { display: grid; grid-template-columns: repeat(5,1fr); gap: 10px; }
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
