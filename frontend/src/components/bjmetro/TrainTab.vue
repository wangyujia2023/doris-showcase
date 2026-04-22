<template>
  <div class="tab-wrap">
    <div class="kpi-row" v-if="kpi">
      <div class="kpi-card" style="--top:#67c23a">
        <div class="kc-label">全网准点率</div>
        <div class="kc-value">{{ (kpi.punctuality_rate*100).toFixed(1) }}<span class="kc-unit">%</span></div>
      </div>
      <div class="kpi-card" style="--top:#409eff">
        <div class="kc-label">在线列车</div>
        <div class="kc-value">{{ kpi.active_trains }}<span class="kc-unit">列</span></div>
      </div>
      <div class="kpi-card" style="--top:#e6a23c">
        <div class="kc-label">当前延误</div>
        <div class="kc-value">{{ kpi.delay_count }}<span class="kc-unit">列</span></div>
      </div>
      <div class="kpi-card" style="--top:#f56c6c">
        <div class="kc-label">今日故障</div>
        <div class="kc-value" style="color:#f56c6c">{{ kpi.fault_count }}<span class="kc-unit">起</span></div>
      </div>
      <div class="kpi-card" style="--top:#9c6cd4">
        <div class="kc-label">最大延误</div>
        <div class="kc-value">{{ Math.floor((kpi.max_delay_sec||0)/60) }}<span class="kc-unit">分{{ (kpi.max_delay_sec||0)%60 }}秒</span></div>
      </div>
      <div class="kpi-card" style="--top:#17b3a3">
        <div class="kc-label">今日总里程</div>
        <div class="kc-value">{{ Math.round((kpi.total_mileage_km||0)/10000) }}<span class="kc-unit">万km</span></div>
      </div>
    </div>

    <div class="grid-2">
      <el-card class="chart-card">
        <template #header><div class="ch">📉 准点率趋势（30天）</div></template>
        <div id="bj-punct-trend" style="height:250px"></div>
      </el-card>

      <el-card class="chart-card">
        <template #header><div class="ch">🔧 故障原因分类</div></template>
        <div id="bj-fault-pie" style="height:250px"></div>
      </el-card>
    </div>

    <el-card class="chart-card">
      <template #header><div class="ch">🚇 各线路运营情况（今日）</div></template>
      <el-table :data="trainList" stripe size="small" style="width:100%">
        <el-table-column label="线路" width="90">
          <template #default="{ row }">
            <div style="display:flex;align-items:center;gap:6px">
              <span :style="{ display:'inline-block', width:'10px', height:'10px', borderRadius:'50%', background:row.line_color }"></span>
              {{ row.line_name }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="actual_trains" label="在线车数" width="80"/>
        <el-table-column prop="planned_trains" label="计划车数" width="80"/>
        <el-table-column label="准点率" width="90">
          <template #default="{ row }">
            <el-progress :percentage="+(row.punctuality_rate*100).toFixed(1)"
                         :status="row.punctuality_rate >= 0.99 ? 'success' : row.punctuality_rate >= 0.97 ? '' : 'exception'"
                         :stroke-width="6" style="width:120px"/>
          </template>
        </el-table-column>
        <el-table-column prop="delay_count" label="延误次数" width="80"/>
        <el-table-column label="最大延误" width="90">
          <template #default="{ row }">
            {{ row.max_delay_sec > 0 ? Math.floor(row.max_delay_sec/60)+"'"+row.max_delay_sec%60+'"' : '—' }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.delay_count > 2 ? 'danger' : row.delay_count > 0 ? 'warning' : 'success'" size="small">
              {{ row.delay_count > 2 ? '告警' : row.delay_count > 0 ? '延误' : '正常' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
import { bjMetroApi } from '@/api'

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
  renderPunctTrend(); renderFaultPie()
})

const renderPunctTrend = () => {
  const c = echarts.init(document.getElementById('bj-punct-trend'))
  c.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 50, right: 20, top: 30, bottom: 40 },
    xAxis: { type: 'category', data: punctTrend.value.map(d => d.date), axisLabel: { color: '#999', fontSize: 10, rotate: 30 } },
    yAxis: { type: 'value', min: 96, max: 100, axisLabel: { color: '#999', fontSize: 11 }, splitLine: { lineStyle: { color: '#f0f2f5' } } },
    series: [{
      type: 'line', smooth: true, symbol: 'none',
      data: punctTrend.value.map(d => d.punctuality_pct),
      lineStyle: { color: '#67c23a', width: 2.5 },
      areaStyle: { color: 'rgba(103,194,58,.12)' },
      markLine: { data: [{ yAxis: 99, name: '目标线', lineStyle: { color: '#f56c6c', type: 'dashed' } }] }
    }]
  })
  window.addEventListener('resize', () => c.resize())
}

const renderFaultPie = () => {
  const c = echarts.init(document.getElementById('bj-fault-pie'))
  // 按 device_type 合并
  const map = {}
  faultTypes.value.forEach(d => { map[d.device_type] = (map[d.device_type] || 0) + d.cnt })
  const colors = ['#f56c6c','#e6a23c','#409eff','#9c6cd4','#67c23a','#17b3a3','#c0c4cc','#f59e0b']
  c.setOption({
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    series: [{
      type: 'pie', radius: ['38%', '65%'],
      data: Object.entries(map).map(([name, value], i) => ({ name, value, itemStyle: { color: colors[i % colors.length] } })),
      itemStyle: { borderColor: '#fff', borderWidth: 2 },
      label: { formatter: '{b}: {d}%', fontSize: 11 }
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
