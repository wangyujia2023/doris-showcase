<template>
  <div class="tab-wrap">
    <div v-if="loading" class="loading-mask"><el-icon class="loading-spin"><Loading /></el-icon><span>{{ t('common.loading') }}</span></div>
    <el-alert v-else-if="error" :title="error" type="error" show-icon style="margin-bottom:8px"/>
    <template v-else>
    <div class="kpi-row" v-if="kpi">
      <div class="kpi-card" style="--top:#67c23a">
        <div class="kc-label">{{ t('bjm.faultTotal') }}</div>
        <div class="kc-value">{{ kpi.total_faults }}<span class="kc-unit">{{ t('bjm.unitItem') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#f56c6c">
        <div class="kc-label">{{ t('bjm.processing') }}</div>
        <div class="kc-value" style="color:#f56c6c">{{ kpi.open_faults }}<span class="kc-unit">{{ t('bjm.unitItem') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#e6a23c">
        <div class="kc-label">{{ t('bjm.critical') }}</div>
        <div class="kc-value">{{ kpi.critical_faults }}<span class="kc-unit">{{ t('bjm.unitFault') }}</span></div>
      </div>
      <div class="kpi-card" style="--top:#409eff">
        <div class="kc-label">{{ t('bjm.avgRepair') }}</div>
        <div class="kc-value">{{ kpi.avg_resolve_min }}<span class="kc-unit">{{ t('bjm.unitMin') }}</span></div>
      </div>
    </div>

    <div class="grid-2">
      <!-- 故障分布 -->
      <el-card class="chart-card">
        <template #header><div class="ch">🔩 {{ t('bjm.faultTypeDist') }}</div></template>
        <div id="bj-equip-dist" style="height:260px"></div>
      </el-card>

      <!-- 按线路故障统计 -->
      <el-card class="chart-card">
        <template #header><div class="ch">📊 {{ t('bjm.lineFaultStat') }}</div></template>
        <div id="bj-equip-byline" style="height:260px"></div>
      </el-card>
    </div>

    <div class="grid-2">
      <!-- 故障趋势 -->
      <el-card class="chart-card">
        <template #header><div class="ch">📉 故障趋势（近30天）</div></template>
        <div id="bj-equip-trend" style="height:240px"></div>
      </el-card>

      <!-- MTTR by device -->
      <el-card class="chart-card">
        <template #header><div class="ch">⏱️ 平均修复时长（按设备类型）</div></template>
        <div id="bj-equip-mttr" style="height:240px"></div>
      </el-card>
    </div>

    <!-- 维修工单 -->
    <el-card class="chart-card">
      <template #header>
        <div class="ch">📋 {{ t('bjm.workOrderTitle') }}
          <el-input v-model="search" :placeholder="t('bjm.searchDevice')" size="small"
                    style="width:200px;margin-left:auto" clearable/>
        </div>
      </template>
      <el-table :data="filteredLog" stripe size="small" style="width:100%" max-height="400">
        <el-table-column prop="fault_id" :label="t('bjm.workOrderId')" width="90"/>
        <el-table-column :label="t('bjm.faultTime')" width="140">
          <template #default="{ row }">{{ row.fault_time?.slice(0,16) }}</template>
        </el-table-column>
        <el-table-column :label="t('bjm.line')" width="70">
          <template #default="{ row }">
            <span v-if="row.line_name" style="font-size:11px">{{ row.line_name }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="station_name" :label="t('bjm.station')" width="120"/>
        <el-table-column prop="device_type"  :label="t('bjm.device')" width="110"/>
        <el-table-column prop="fault_type"   :label="t('bjm.faultType')" />
        <el-table-column prop="severity" :label="t('bjm.severity')" width="90">
          <template #default="{ row }">
            <el-tag :type="{ Critical:'danger', Warning:'warning', Information:'info' }[row.severity] || 'info'" size="small">
              {{ row.severity }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="resolve_min" :label="t('bjm.repairMin')" width="80"/>
        <el-table-column prop="status" :label="t('bjm.status')" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'Resolved' ? 'success' : 'danger'" size="small">
              {{ row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="handler" :label="t('bjm.handler')" width="80"/>
      </el-table>
    </el-card>
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

const kpi       = ref(null)
const faultDist = ref([])
const faultLine = ref([])
const maintLog  = ref([])
const faultTrend= ref([])
const deviceMttr= ref([])
const search    = ref('')
const loading   = ref(true)
const error     = ref('')

const filteredLog = computed(() => {
  if (!search.value) return maintLog.value
  const q = search.value.toLowerCase()
  return maintLog.value.filter(r =>
    (r.station_name || '').toLowerCase().includes(q) ||
    (r.device_type  || '').toLowerCase().includes(q) ||
    (r.fault_type   || '').toLowerCase().includes(q) ||
    (r.line_name    || '').toLowerCase().includes(q)
  )
})

onMounted(async () => {
  try {
    const [k, fd, fl, ml, ft, dm] = await Promise.all([
      bjMetroApi.equipKpi(),
      bjMetroApi.equipFaultDist(),
      bjMetroApi.equipFaultByLine(),
      bjMetroApi.equipMaintLog(),
      bjMetroApi.equipFaultTrend(),
      bjMetroApi.equipDeviceMttr(),
    ])
    kpi.value       = k
    faultDist.value = fd.data || []
    faultLine.value = fl.data || []
    maintLog.value  = ml.data || []
    faultTrend.value= ft.data || []
    deviceMttr.value= dm.data || []
    await nextTick()
    renderDist(); renderByLine(); renderTrend(); renderMttr()
  } catch (e) {
    error.value = e.message || 'Failed to load equipment data'
  } finally {
    loading.value = false
  }
})

const renderDist = () => {
  const colors = ['#f56c6c','#e6a23c','#409eff','#9c6cd4','#67c23a','#17b3a3','#c0c4cc','#f59e0b']
  renderChart('bj-equip-dist', {
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    series: [{
      type: 'pie', radius: ['38%', '65%'],
      data: faultDist.value.map((d, i) => ({
        name: d.device_type, value: d.cnt,
        itemStyle: { color: colors[i % colors.length] }
      })),
      itemStyle: { borderColor: '#fff', borderWidth: 2 },
      label: { formatter: '{b}\n{d}%', fontSize: 11 }
    }]
  })
}

const renderByLine = () => {
  renderChart('bj-equip-byline', {
    tooltip: { trigger: 'axis' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    grid: { left: 70, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    yAxis: { type: 'category', data: faultLine.value.map(d => d.line_name), axisLabel: { color: '#64748b', fontSize: 11 } },
    series: [
      { name: 'Normal', type: 'bar', stack: 'f',
        data: faultLine.value.map(d => d.total_faults - d.critical_cnt),
        itemStyle: { color: '#e6a23c', borderRadius: 0 } },
      { name: 'Critical', type: 'bar', stack: 'f',
        data: faultLine.value.map(d => d.critical_cnt),
        itemStyle: { color: '#f56c6c', borderRadius: [0,3,3,0] } },
    ]
  })
}

const renderTrend = () => {
  renderChart('bj-equip-trend', {
    tooltip: { trigger: 'axis' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    grid: { left: 40, right: 20, top: 20, bottom: 40 },
    xAxis: { type: 'category', data: faultTrend.value.map(d => d.date?.slice(5)), axisLabel: { color: '#999', fontSize: 10, rotate: 30 } },
    yAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    series: [
      { name: 'Information', type: 'bar', stack: 's', data: faultTrend.value.map(d => d.info),     itemStyle: { color: '#409eff' } },
      { name: 'Warning',     type: 'bar', stack: 's', data: faultTrend.value.map(d => d.warning),  itemStyle: { color: '#e6a23c' } },
      { name: 'Critical',    type: 'bar', stack: 's', data: faultTrend.value.map(d => d.critical), itemStyle: { color: '#f56c6c' } },
    ]
  })
}

const renderMttr = () => {
  const sorted = [...deviceMttr.value].sort((a, b) => b.avg_resolve_min - a.avg_resolve_min)
  renderChart('bj-equip-mttr', {
    tooltip: { trigger: 'axis', formatter: p => `${p[0].name}<br/>Avg: <b>${p[0].value} min</b>` },
    grid: { left: 130, right: 60, top: 10, bottom: 10 },
    xAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    yAxis: { type: 'category', data: sorted.map(d => d.device_type), axisLabel: { color: '#64748b', fontSize: 11 } },
    series: [{
      type: 'bar', data: sorted.map(d => d.avg_resolve_min), barMaxWidth: 18,
      itemStyle: { color: { type:'linear', x:0, y:0, x2:1, y2:0,
        colorStops:[{ offset:0, color:'rgba(64,158,255,.4)' },{ offset:1, color:'#409eff' }] },
        borderRadius:[0,4,4,0] },
      label: { show: true, position: 'right', formatter: p => p.value + ' min', fontSize: 10, color: '#64748b' }
    }]
  })
}
</script>

<style scoped>
.tab-wrap { display:flex; flex-direction:column; gap:12px; }
.loading-mask { display:flex; align-items:center; justify-content:center; gap:10px; height:200px; color:#909399; font-size:14px; }
.loading-spin { animation:spin 1s linear infinite; font-size:20px; color:#409eff; }
@keyframes spin { from { transform:rotate(0deg); } to { transform:rotate(360deg); } }
.kpi-row { display:grid; grid-template-columns:repeat(4,1fr); gap:10px; }
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
