<template>
  <div class="sat-wrap">
    <!-- 顶部横幅 -->
    <div class="sat-banner">
      <el-icon size="20" color="#00d4ff"><Aim /></el-icon>
      <span class="banner-title">{{ t('satellite.title') }}</span>
      <el-tag type="danger" size="small" effect="dark">{{ t('satellite.secret') }}</el-tag>
      <el-tag size="small" effect="dark" style="background:#0a2a4a;border-color:#00d4ff;color:#00d4ff">{{ t('satellite.bigintTs') }}</el-tag>
      <el-button size="small" type="primary" :loading="initing" @click="initData" style="margin-left:auto">
        {{ t('satellite.initBtn') }}
      </el-button>
    </div>

    <!-- 1. 概览卡片 -->
    <div class="overview-row">
      <div class="ov-card" v-for="c in ovCards" :key="c.label" :style="{borderColor:c.color}">
        <div class="ov-val" :style="{color:c.color}">{{ c.value }}</div>
        <div class="ov-lbl">{{ c.label }}</div>
      </div>
    </div>

    <!-- 2. 查询面板 -->
    <div class="card query-panel">
      <div class="qp-grid">
        <el-input v-model="f.satellite_name" :placeholder="t('satellite.phName')" clearable size="small" />
        <el-select v-model="f.satellite_type" :placeholder="t('satellite.phType')" clearable size="small">
          <el-option v-for="v in satelliteTypes" :key="v.value" :value="v.value" :label="v.label" />
        </el-select>
        <el-select v-model="f.data_type" :placeholder="t('satellite.phDataType')" clearable size="small">
          <el-option v-for="v in dataTypes" :key="v.value" :value="v.value" :label="v.label" />
        </el-select>
        <el-select v-model="f.target_type" :placeholder="t('satellite.phTargetType')" clearable size="small">
          <el-option v-for="v in targetTypes" :key="v.value" :value="v.value" :label="v.label" />
        </el-select>
        <el-select v-model="f.quality_min" :placeholder="t('satellite.phQuality')" clearable size="small">
          <el-option :value="90" label="≥ 90" /><el-option :value="80" label="≥ 80" />
        </el-select>
        <el-select v-model="f.status" :placeholder="t('satellite.phStatus')" clearable size="small">
          <el-option value="normal" :label="t('satellite.statusNormal')" /><el-option value="warning" :label="t('satellite.statusWarning')" /><el-option value="abnormal" :label="t('satellite.statusAbnormal')" />
        </el-select>
      </div>
      <!-- 时间仅展示 -->
      <div class="time-display">
        <el-icon><Clock /></el-icon>
        <span style="color:#909399;font-size:12px">{{ t('satellite.timeRange') }}</span>
        <el-date-picker v-model="timeRange" type="daterange" size="small" style="width:280px"
          range-separator="—" :start-placeholder="t('satellite.startTime')" :end-placeholder="t('satellite.endTime')" disabled />
        <span style="font-size:11px;color:#c0c4cc">{{ t('satellite.displayOnly') }}</span>
      </div>
      <div style="margin-top:10px;display:flex;gap:8px">
        <el-button type="primary" size="small" @click="search"><el-icon><Search /></el-icon> {{ t('satellite.search') }}</el-button>
        <el-button size="small" @click="reset">{{ t('satellite.reset') }}</el-button>
        <span style="margin-left:auto;font-size:12px;color:#909399">{{ t('satellite.totalRecords', [total]) }}</span>
      </div>
    </div>

    <!-- 3. 图表区 -->
    <div class="chart-row">
      <div class="card chart-card">
        <div class="ct">{{ t('satellite.chartSatellite') }}</div>
        <v-chart :option="pieOpt" style="height:220px" autoresize />
      </div>
      <div class="card chart-card">
        <div class="ct">{{ t('satellite.chartDataType') }}</div>
        <v-chart :option="typeBarOpt" style="height:220px" autoresize />
      </div>
      <div class="card chart-card">
        <div class="ct">{{ t('satellite.chartTarget') }}</div>
        <v-chart :option="targetBarOpt" style="height:220px" autoresize />
      </div>
      <div class="card chart-card">
        <div class="ct">{{ t('satellite.chartQuality') }}</div>
        <v-chart :option="qualityOpt" style="height:220px" autoresize />
      </div>
    </div>

    <!-- 4. 数据列表 -->
    <div class="card">
      <el-table :data="rows" v-loading="loading" size="small" stripe>
        <el-table-column prop="id" label="ID" width="60" />
        <el-table-column prop="satellite_name" :label="t('satellite.colName')" width="100" />
        <el-table-column prop="satellite_type" :label="t('satellite.colType')" width="100">
          <template #default="{row}">
            <el-tag :type="typeColor(row.satellite_type)" size="small">{{row.satellite_type}}</el-tag>
          </template>
        </el-table-column>
        <el-table-column :label="t('satellite.colCollectTime')" width="200">
          <template #default="{row}">
            <span class="mono" style="font-size:11px;color:#409eff">{{ fmtTs(row.collect_time) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="data_type" :label="t('satellite.colDataType')" width="80" />
        <el-table-column prop="target_type" :label="t('satellite.colTargetType')" width="90" />
        <el-table-column :label="t('satellite.colLngLat')" width="160">
          <template #default="{row}">
            <span class="mono" style="font-size:11px">{{ row.longitude }}, {{ row.latitude }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="data_quality" :label="t('satellite.colQuality')" width="90" sortable>
          <template #default="{row}">
            <span :style="{color: row.data_quality>=95?'#67c23a':row.data_quality>=85?'#e6a23c':'#f56c6c',fontWeight:'700'}">
              {{ row.data_quality }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="status" :label="t('satellite.colStatus')" width="80">
          <template #default="{row}">
            <el-tag :type="statusType(row.status)" size="small" effect="dark">
              {{ statusLabel(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="task_id" :label="t('satellite.colTask')" />
      </el-table>
      <div style="text-align:center;padding:12px 0">
        <el-pagination v-model:current-page="page" :page-size="20"
          layout="prev,pager,next,total" :total="total" @current-change="loadList" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive, onMounted } from 'vue'
import { Search, Clock, Aim } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { satelliteApi } from '@/api'
import { t } from '@/i18n'

use([CanvasRenderer, PieChart, BarChart, GridComponent, TooltipComponent, LegendComponent])

const COLORS = ['#00d4ff','#409eff','#67c23a','#e6a23c','#f56c6c','#9b59b6','#1abc9c','#e67e22']

const overview = ref({})
const charts   = ref({})
const rows     = ref([])
const total    = ref(0)
const loading  = ref(false)
const initing  = ref(false)
const page     = ref(1)
const timeRange = ref(null)
const f = reactive({ satellite_name:'', satellite_type:'', data_type:'', target_type:'', quality_min:null, status:'' })

const ovCards = computed(() => [
  { label:t('satellite.overviewTotal'), value: (overview.value.total||0).toLocaleString(), color:'#00d4ff' },
  { label:t('satellite.overviewOnline'), value: overview.value.satellites||0, color:'#409eff' },
  { label:t('satellite.overviewToday'), value: (overview.value.total||0).toLocaleString(), color:'#67c23a' },
  { label:t('satellite.overviewWarnings'), value: overview.value.warnings||0, color:'#f56c6c' },
  { label:t('satellite.overviewAbnormal'), value: overview.value.abnormals||0, color:'#e6a23c' },
])

const satelliteTypes = computed(() => [
  { value:'光学', label:t('satellite.typeOptical') },
  { value:'雷达', label:t('satellite.typeRadar') },
  { value:'电子侦察', label:t('satellite.typeRecon') },
])
const dataTypes = computed(() => [
  { value:'成像', label:t('satellite.dataImaging') },
  { value:'信号', label:t('satellite.dataSignal') },
  { value:'轨道', label:t('satellite.dataOrbit') },
  { value:'预警', label:t('satellite.dataWarning') },
])
const targetTypes = computed(() => [
  { value:'舰船', label:t('satellite.targetShip') },
  { value:'车辆', label:t('satellite.targetVehicle') },
  { value:'机场', label:t('satellite.targetAirport') },
  { value:'雷达站', label:t('satellite.targetRadar') },
])

const fmtTs = ts => {
  if (!ts) return '-'
  const d = new Date(Number(ts))
  return d.toLocaleString('zh-CN', { hour12: false })
}
const typeColor  = t => ({ '光学':'','雷达':'warning','电子侦察':'danger' })[t] || ''
const statusType = s => ({ normal:'success', warning:'warning', abnormal:'danger' })[s] || ''
const statusLabel = s => ({ normal:t('satellite.statusNormal'), warning:t('satellite.statusWarning'), abnormal:t('satellite.statusAbnormal') })[s] || s

const pieOpt = computed(() => {
  const d = charts.value.by_satellite || []
  return {
    tooltip: { trigger:'item', formatter:'{b}: {c} ({d}%)' },
    legend: { orient:'vertical', right:4, top:'middle', textStyle:{fontSize:10} },
    series: [{ type:'pie', radius:['35%','65%'], center:['40%','50%'],
      label:{show:false},
      data: d.map((r,i) => ({ name:r.satellite_name, value:r.cnt, itemStyle:{color:COLORS[i%COLORS.length]} }))
    }]
  }
})

const typeBarOpt = computed(() => {
  const d = charts.value.by_data_type || []
  return {
    tooltip:{trigger:'axis'},
    grid:{left:16,right:16,top:8,bottom:30},
    xAxis:{type:'category',data:d.map(r=>r.data_type),axisLabel:{fontSize:10}},
    yAxis:{type:'value',show:false},
    series:[{type:'bar',barMaxWidth:40,
      data:d.map((r,i)=>({value:r.cnt,itemStyle:{color:COLORS[i%COLORS.length]}})),
      label:{show:true,position:'top',fontSize:11}}]
  }
})

const targetBarOpt = computed(() => {
  const d = charts.value.by_target || []
  return {
    tooltip:{trigger:'axis'},
    grid:{left:16,right:16,top:8,bottom:30},
    xAxis:{type:'category',data:d.map(r=>r.target_type),axisLabel:{fontSize:10}},
    yAxis:{type:'value',show:false},
    series:[{type:'bar',barMaxWidth:40,
      data:d.map((r,i)=>({value:r.cnt,itemStyle:{color:['#f56c6c','#e6a23c','#67c23a','#409eff'][i%4]}})),
      label:{show:true,position:'top',fontSize:11}}]
  }
})

const qualityOpt = computed(() => {
  const d = [...(charts.value.by_quality||[])].sort((a,b)=>b.avg_q-a.avg_q)
  return {
    tooltip:{trigger:'axis'},
    grid:{left:16,right:16,top:8,bottom:50},
    xAxis:{type:'category',data:d.map(r=>r.satellite_name),axisLabel:{fontSize:10,rotate:20}},
    yAxis:{type:'value',min:70,max:100,axisLabel:{fontSize:10}},
    series:[{type:'bar',barMaxWidth:36,
      data:d.map((r,i)=>({value:r.avg_q,itemStyle:{color:r.avg_q>=95?'#67c23a':r.avg_q>=85?'#e6a23c':'#f56c6c'}})),
      label:{show:true,position:'top',fontSize:10,formatter:`{c}${t('satellite.scoreUnit')}`}}]
  }
})

function search() { page.value = 1; loadList() }
function reset() {
  Object.assign(f, { satellite_name:'', satellite_type:'', data_type:'', target_type:'', quality_min:null, status:'' })
  search()
}

async function loadList() {
  loading.value = true
  const params = { page: page.value, size: 20 }
  if (f.satellite_name) params.satellite_name = f.satellite_name
  if (f.satellite_type) params.satellite_type = f.satellite_type
  if (f.data_type)      params.data_type      = f.data_type
  if (f.target_type)    params.target_type    = f.target_type
  if (f.quality_min)    params.quality_min    = f.quality_min
  if (f.status)         params.status         = f.status
  try {
    const res = await satelliteApi.query(params)
    rows.value  = res.rows  || []
    total.value = res.total || 0
  } finally { loading.value = false }
}

async function initData() {
  initing.value = true
  try {
    await satelliteApi.init()
    ElMessage.success(t('satellite.initDone'))
    await Promise.all([loadOverview(), loadCharts(), loadList()])
  } finally { initing.value = false }
}

async function loadOverview() { overview.value = await satelliteApi.overview() }
async function loadCharts()   { charts.value   = await satelliteApi.charts()   }

onMounted(async () => {
  await Promise.all([loadOverview(), loadCharts(), loadList()])
})
</script>

<style scoped>
.sat-wrap { display:flex; flex-direction:column; gap:14px; }
.sat-banner { display:flex; align-items:center; gap:10px; background:#0a1628; border-radius:8px; padding:12px 20px; }
.banner-title { font-size:15px; font-weight:700; color:#00d4ff; letter-spacing:2px; }
.overview-row { display:grid; grid-template-columns:repeat(5,1fr); gap:12px; }
.ov-card { background:#fff; border-radius:8px; padding:16px; text-align:center; border-top:3px solid; box-shadow:0 1px 4px rgba(0,0,0,.06); }
.ov-val { font-size:26px; font-weight:700; }
.ov-lbl { font-size:12px; color:#909399; margin-top:4px; }
.card { background:#fff; border-radius:8px; padding:16px; box-shadow:0 1px 4px rgba(0,0,0,.06); }
.query-panel { }
.qp-grid { display:grid; grid-template-columns:repeat(6,1fr); gap:8px; margin-bottom:10px; }
.time-display { display:flex; align-items:center; gap:8px; padding:8px 0; border-top:1px solid #f0f0f0; }
.chart-row { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; }
.chart-card { }
.ct { font-size:13px; font-weight:600; color:#303133; margin-bottom:8px; }
.mono { font-family:'JetBrains Mono',Consolas,monospace; }
</style>
