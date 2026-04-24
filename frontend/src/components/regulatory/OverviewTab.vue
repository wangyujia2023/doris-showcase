<template>
  <div class="ov-wrap">
    <!-- KPI 行 -->
    <div class="kpi-row">
      <div class="kpi-card" v-for="k in kpis" :key="k.label" :style="`--top:${k.color}`">
        <div class="kc-label">{{ k.label }}</div>
        <div class="kc-value" :style="k.alert ? 'color:#f56c6c' : ''">
          {{ k.value }}<span class="kc-unit">{{ k.unit }}</span>
        </div>
        <div class="kc-sub" :class="k.ok ? 'ok' : 'err'">{{ k.ok ? '✓ 达标' : '✗ 不达标' }}</div>
      </div>
    </div>

    <!-- 报表状态列表 -->
    <div class="grid-2">
      <el-card class="card">
        <template #header><span class="ch">{{ t('regulatory.reportOverview') }} · {{ period }}</span></template>
        <el-table :data="reportList" size="small">
          <el-table-column :label="t('regulatory.report')" width="160">
            <template #default="{ row }">
              <span class="report-code">{{ row.code }}</span>
              <span class="report-name">{{ row.name }}</span>
            </template>
          </el-table-column>
          <el-table-column :label="t('regulatory.freq')" width="55" align="center">
            <template #default="{ row }">
              <el-tag :type="row.freq==='月' ? 'success' : 'warning'" size="small">{{ row.freq }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column :label="t('regulatory.deadline')" width="80" prop="deadline"/>
          <el-table-column :label="t('regulatory.status')">
            <template #default="{ row }">
              <el-tag :type="statusType(row.status)" size="small">{{ row.statusLabel }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column :label="t('regulatory.qcScore')" width="70" align="center">
            <template #default="{ row }">
              <span :style="`color:${row.score>=95?'#67c23a':row.score>=85?'#e6a23c':'#f56c6c'}`">
                {{ row.score }}
              </span>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <!-- 趋势图 -->
      <el-card class="card">
        <template #header><span class="ch">{{ t('regulatory.coreTrend') }}</span></template>
        <div id="reg-trend-chart" style="height:280px"></div>
      </el-card>
    </div>

    <!-- 报送历史 -->
    <el-card class="card" style="margin-top:12px">
      <template #header><span class="ch">{{ t('regulatory.recentSubmit') }}</span></template>
      <el-table :data="submitLog" size="small" max-height="200">
        <el-table-column :label="t('regulatory.report')" prop="report_code" width="70"/>
        <el-table-column :label="t('regulatory.period')" prop="report_period" width="85"/>
        <el-table-column :label="t('regulatory.status')" width="80">
          <template #default="{ row }">
            <el-tag :type="actionType(row.action)" size="small">{{ actionLabel(row.action) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="Operator" prop="operator" width="80"/>
        <el-table-column label="Time" prop="action_time"/>
        <el-table-column :label="t('regulatory.qcScore')" width="70" align="center">
          <template #default="{ row }">{{ row.qc_score || '—' }}</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import * as echarts from 'echarts'
import { regulatoryApi } from '@/api'
import { t } from '@/i18n'

const props = defineProps({ period: String })

const kpis       = ref([])
const reportList = ref([])
const submitLog  = ref([])

const REPORT_META = [
  { code:'G01', name:'资产负债表',    freq:'月', deadline:'次月15日', baseScore:97.5 },
  { code:'G03', name:'资本充足率',    freq:'季', deadline:'季末后30日',baseScore:98.2 },
  { code:'G04A',name:'贷款五级分类',  freq:'月', deadline:'次月15日', baseScore:96.8 },
  { code:'G11', name:'流动性覆盖率',  freq:'月', deadline:'次月15日', baseScore:94.3 },
  { code:'G11A',name:'净稳定资金',    freq:'季', deadline:'季末后30日',baseScore:97.1 },
  { code:'G21', name:'信贷收支',      freq:'月', deadline:'次月20日', baseScore:98.5 },
  { code:'G22', name:'贷款投向',      freq:'季', deadline:'季末后30日',baseScore:96.2 },
  { code:'G31', name:'单一客户集中',  freq:'季', deadline:'季末后30日',baseScore:97.8 },
]

const statusType  = s => ({ submitted:'success', draft:'info', pending:'warning', rejected:'danger' }[s]||'info')
const actionType  = a => ({ accept:'success', submit:'primary', qc:'warning', draft:'info', reject:'danger' }[a]||'info')
const actionLabel = a => ({ accept:'审核通过', submit:'已报送', qc:'质检通过', draft:'起草', reject:'退回' }[a]||a)

const buildKpis = (d) => {
  if (!d) return []
  return [
    { label:'资本充足率',    value: (d.car_ratio*100).toFixed(2),    unit:'%', color:'#409eff', ok: d.car_ratio>=0.105 },
    { label:'核心一级充足率',value: ((d.cet1_ratio||0.091)*100).toFixed(2), unit:'%', color:'#67c23a', ok: (d.cet1_ratio||0.091)>=0.075 },
    { label:'流动性覆盖率',  value: (d.lcr_ratio*100).toFixed(1),    unit:'%', color: d.lcr_ratio<1?'#f56c6c':'#67c23a', ok: d.lcr_ratio>=1.0, alert: d.lcr_ratio<1 },
    { label:'不良贷款率',    value: (d.npl_ratio*100).toFixed(2),    unit:'%', color:'#e6a23c', ok: d.npl_ratio<=0.05 },
    { label:'拨备覆盖率',    value: (d.provision_coverage*100).toFixed(1), unit:'%', color:'#9c6cd4', ok: d.provision_coverage>=1.5 },
    { label:'合规综合得分',  value: d.compliance_score,               unit:'分', color:'#17b3a3', ok: d.compliance_score>=80 },
  ]
}

const load = async () => {
  const [ov, log] = await Promise.all([
    regulatoryApi.overview(),
    regulatoryApi.submitLog(),
  ])
  const latest = ov.latest || {}
  kpis.value = buildKpis(latest)
  reportList.value = REPORT_META.map(m => ({
    ...m,
    status: ['G01','G03','G04A','G11','G21'].includes(m.code) ? 'submitted' : 'pending',
    statusLabel: ['G01','G03','G04A','G11','G21'].includes(m.code) ? '已报送' : '待处理',
    score: m.baseScore,
  }))
  submitLog.value = (log.data || []).slice(0, 15)

  // 趋势图
  const periods = (ov.periods || []).map(p => p.report_period).reverse()
  const cars    = (ov.periods || []).map(p => +(p.car_ratio*100).toFixed(2)).reverse()
  const lcrs    = (ov.periods || []).map(p => +(p.lcr_ratio*100).toFixed(1)).reverse()
  const npls    = (ov.periods || []).map(p => +(p.npl_ratio*100).toFixed(2)).reverse()
  renderTrend(periods, cars, lcrs, npls)
}

const renderTrend = (xData, cars, lcrs, npls) => {
  const el = document.getElementById('reg-trend-chart')
  if (!el) return
  const c = echarts.init(el)
  c.setOption({
    tooltip: { trigger:'axis' },
    legend: { data:['资本充足率%','LCR%','不良率%'], top:0, textStyle:{fontSize:11} },
    grid: { left:50, right:20, top:30, bottom:30 },
    xAxis: { type:'category', data: xData, axisLabel:{color:'#999',fontSize:10} },
    yAxis: [
      { type:'value', name:'%', axisLabel:{color:'#999',fontSize:10}, splitLine:{lineStyle:{color:'#f0f2f5'}} },
    ],
    series: [
      { name:'资本充足率%', type:'line', data:cars, smooth:true, symbol:'circle', symbolSize:4,
        lineStyle:{color:'#409eff',width:2}, itemStyle:{color:'#409eff'} },
      { name:'LCR%', type:'line', data:lcrs, smooth:true, symbol:'circle', symbolSize:4,
        lineStyle:{color:'#67c23a',width:2}, itemStyle:{color:'#67c23a'} },
      { name:'不良率%', type:'line', data:npls, smooth:true, symbol:'circle', symbolSize:4,
        lineStyle:{color:'#e6a23c',width:2}, itemStyle:{color:'#e6a23c'},
        yAxisIndex:0 },
    ]
  })
  window.addEventListener('resize', () => c.resize())
}

defineExpose({ reload: load })
onMounted(load)
watch(() => props.period, load)
</script>

<style scoped>
.ov-wrap { display:flex; flex-direction:column; gap:12px; }
.kpi-row { display:grid; grid-template-columns:repeat(6,1fr); gap:10px; }
.kpi-card {
  background:#fff; border:1px solid #e8edf3;
  border-top:3px solid var(--top,#409eff);
  border-radius:6px; padding:12px 14px;
}
.kc-label { font-size:12px; color:#909399; margin-bottom:6px; }
.kc-value { font-size:22px; font-weight:700; color:#1f2a37; }
.kc-unit  { font-size:12px; font-weight:400; color:#909399; margin-left:2px; }
.kc-sub   { font-size:11px; margin-top:4px; }
.kc-sub.ok  { color:#67c23a; }
.kc-sub.err { color:#f56c6c; }
.grid-2 { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.card { background:#fff; border:1px solid #e8edf3; }
.card :deep(.el-card__header) { padding:10px 14px; border-bottom:1px solid #f0f2f5; }
.ch { font-weight:600; font-size:13px; color:#1f2a37; }
.report-code { font-size:11px; font-weight:700; color:#409eff; margin-right:5px; }
.report-name { font-size:12px; color:#303133; }
</style>
