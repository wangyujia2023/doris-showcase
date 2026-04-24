<template>
  <div class="tab-wrap">
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

    <!-- 维修工单 -->
    <el-card class="chart-card">
      <template #header>
        <div class="ch">📋 {{ t('bjm.workOrderTitle') }}
          <el-input v-model="search" :placeholder="t('bjm.searchDevice')" size="small"
                    style="width:180px;margin-left:auto" clearable/>
        </div>
      </template>
      <el-table :data="filteredLog" stripe size="small" style="width:100%">
        <el-table-column prop="fault_id" :label="t('bjm.workOrderId')" width="90"/>
        <el-table-column :label="t('bjm.faultTime')" width="140">
          <template #default="{ row }">{{ row.fault_time?.slice(0,16) }}</template>
        </el-table-column>
        <el-table-column :label="t('bjm.line')" width="70">
          <template #default="{ row }">
            <span v-if="row.line_name" style="font-size:11px">{{ row.line_name }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="station_name" :label="t('bjm.station')" width="80"/>
        <el-table-column prop="device_type"  :label="t('bjm.device')" width="90"/>
        <el-table-column prop="fault_type"   :label="t('bjm.faultType')" />
        <el-table-column prop="severity" :label="t('bjm.severity')" width="70">
          <template #default="{ row }">
            <el-tag :type="{ 严重:'danger', 警告:'warning', 信息:'info' }[row.severity]" size="small">
              {{ row.severity }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="resolve_min" :label="t('bjm.repairMin')" width="80"/>
        <el-table-column prop="status" :label="t('bjm.status')" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === '已关闭' ? 'success' : 'warning'" size="small">
              {{ row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="handler" :label="t('bjm.handler')" width="70"/>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import * as echarts from 'echarts'
import { bjMetroApi } from '@/api'
import { t } from '@/i18n'

const kpi       = ref(null)
const faultDist = ref([])
const faultLine = ref([])
const maintLog  = ref([])
const search    = ref('')

const filteredLog = computed(() => {
  if (!search.value) return maintLog.value
  return maintLog.value.filter(r =>
    (r.station_name || '').includes(search.value) ||
    (r.device_type  || '').includes(search.value) ||
    (r.fault_type   || '').includes(search.value)
  )
})

onMounted(async () => {
  const [k, fd, fl, ml] = await Promise.all([
    bjMetroApi.equipKpi(),
    bjMetroApi.equipFaultDist(),
    bjMetroApi.equipFaultByLine(),
    bjMetroApi.equipMaintLog(),
  ])
  kpi.value       = k
  faultDist.value = fd.data || []
  faultLine.value = fl.data || []
  maintLog.value  = ml.data || []
  renderDist(); renderByLine()
})

const renderDist = () => {
  const c = echarts.init(document.getElementById('bj-equip-dist'))
  const colors = ['#f56c6c','#e6a23c','#409eff','#9c6cd4','#67c23a','#17b3a3','#c0c4cc','#f59e0b']
  c.setOption({
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
  window.addEventListener('resize', () => c.resize())
}

const renderByLine = () => {
  const c = echarts.init(document.getElementById('bj-equip-byline'))
  c.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 70, right: 20, top: 20, bottom: 30 },
    xAxis: { type: 'value', axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    yAxis: { type: 'category', data: faultLine.value.map(d => d.line_name), axisLabel: { color: '#64748b', fontSize: 11 } },
    series: [
      { name: t('bjm.faultTotalShort'), type: 'bar', stack: 'f',
        data: faultLine.value.map(d => d.total_faults - d.critical_cnt),
        itemStyle: { color: '#e6a23c', borderRadius: 0 } },
      { name: t('bjm.criticalShort'), type: 'bar', stack: 'f',
        data: faultLine.value.map(d => d.critical_cnt),
        itemStyle: { color: '#f56c6c', borderRadius: [0,3,3,0] } },
    ]
  })
  window.addEventListener('resize', () => c.resize())
}
</script>

<style scoped>
.tab-wrap { display:flex; flex-direction:column; gap:12px; }
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
