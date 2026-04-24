<template>
  <div>
    <!-- Tab 切换 -->
    <el-tabs v-model="activeTab" type="card" style="margin-bottom:0">
      <el-tab-pane :label="t('behavior.tabFunnel')"    name="funnel" />
      <el-tab-pane :label="t('behavior.tabRetention')" name="retention" />
      <el-tab-pane :label="t('behavior.tabTrend')"     name="trend" />
      <el-tab-pane :label="t('behavior.tabRfm')"       name="rfm" />
    </el-tabs>

    <!-- ═══════════════════ 漏斗分析 ═══════════════════ -->
    <div v-if="activeTab === 'funnel'" class="card" style="border-top-left-radius:0">
      <el-form inline>
        <el-form-item :label="t('behavior.labelChannel')">
          <el-select v-model="funnelChannel" clearable :placeholder="t('common.all')" style="width:100px">
            <el-option v-for="c in channels" :key="c" :label="c" :value="c" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="funnelLoading" @click="runFunnel">{{ t('common.analyze') }}</el-button>
        </el-form-item>
      </el-form>

      <div v-if="funnelData" style="margin-top:8px">
        <v-chart :option="funnelOption" style="height:320px" autoresize />
        <el-table :data="funnelData.steps" border size="small" style="margin-top:12px">
          <el-table-column prop="step"      :label="t('behavior.colStep')" width="60" />
          <el-table-column prop="step_name" :label="t('behavior.colEvent')" />
          <el-table-column prop="user_count" :label="t('behavior.colUsers')">
            <template #default="{row}">{{ (row.user_count || 0).toLocaleString() }}</template>
          </el-table-column>
          <el-table-column prop="conversion_rate" :label="t('behavior.colConvRate')">
            <template #default="{row}">
              <el-progress :percentage="row.conversion_rate || 0" :stroke-width="8" />
            </template>
          </el-table-column>
          <el-table-column prop="overall_rate" :label="t('behavior.colOverallRate')">
            <template #default="{row}">
              <el-tag type="primary" size="small">{{ row.overall_rate }}%</el-tag>
            </template>
          </el-table-column>
        </el-table>
        <div style="font-size:12px;color:#909399;margin-top:8px">{{ t('behavior.funnelHint') }}</div>
      </div>
    </div>

    <!-- ═══════════════════ 留存分析 ═══════════════════ -->
    <div v-if="activeTab === 'retention'" class="card" style="border-top-left-radius:0">
      <el-form inline>
        <el-form-item :label="t('behavior.labelStart')">
          <el-select v-model="retCohortEvent" style="width:120px">
            <el-option v-for="e in eventTypes" :key="e" :label="e" :value="e" />
          </el-select>
        </el-form-item>
        <el-form-item :label="t('behavior.labelReturn')">
          <el-select v-model="retReturnEvent" style="width:120px">
            <el-option v-for="e in eventTypes" :key="e" :label="e" :value="e" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="retLoading" @click="runRetention">{{ t('common.analyze') }}</el-button>
        </el-form-item>
      </el-form>

      <div v-if="retentionData" style="margin-top:12px;overflow-x:auto">
        <table class="retention-matrix">
          <thead>
            <tr>
              <th>{{ t('behavior.retColDate') }}</th>
              <th>{{ t('behavior.retColInitial') }}</th>
              <th v-for="d in retDays" :key="d">{{ t('behavior.retDay').replace('{0}', d) }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in retentionData.rows" :key="row.cohort_date">
              <td>{{ row.cohort_date }}</td>
              <td>{{ (row.cohort_size || 0).toLocaleString() }}</td>
              <td v-for="d in retDays" :key="d" :style="heatStyle(row[`d${d}`])">
                {{ row[`d${d}`] != null ? row[`d${d}`] + '%' : '-' }}
              </td>
            </tr>
          </tbody>
        </table>
        <div style="font-size:12px;color:#909399;margin-top:8px">{{ t('behavior.retHint') }}</div>
      </div>
    </div>

    <!-- ═══════════════════ 交易趋势 ═══════════════════ -->
    <div v-if="activeTab === 'trend'" class="card" style="border-top-left-radius:0">
      <el-form inline>
        <el-form-item :label="t('behavior.labelChannel')">
          <el-select v-model="trendChannel" clearable :placeholder="t('common.all')" style="width:100px">
            <el-option v-for="c in channels" :key="c" :label="c" :value="c" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="trendLoading" @click="runTrend">{{ t('common.search') }}</el-button>
        </el-form-item>
      </el-form>
      <v-chart v-if="trendData" :option="trendOption" style="height:340px;margin-top:12px" autoresize />
    </div>

    <!-- ═══════════════════ RFM ═══════════════════ -->
    <div v-if="activeTab === 'rfm'" class="card" style="border-top-left-radius:0">
      <el-form inline>
        <el-form-item>
          <el-button type="primary" :loading="rfmLoading" @click="runRfm">{{ t('common.analyze') }}</el-button>
        </el-form-item>
      </el-form>

      <div v-if="rfmData" style="margin-top:12px">
        <el-row :gutter="16">
          <el-col :span="12">
            <v-chart :option="rfmPieOption" style="height:300px" autoresize />
          </el-col>
          <el-col :span="12">
            <el-table :data="rfmData" border size="small">
              <el-table-column prop="rfm_segment"  :label="t('behavior.rfmColSegment')" />
              <el-table-column prop="user_count"   :label="t('behavior.rfmColUsers')">
                <template #default="{row}">{{ (row.user_count || 0).toLocaleString() }}</template>
              </el-table-column>
              <el-table-column prop="avg_recency"  :label="t('behavior.rfmColR')" />
              <el-table-column prop="avg_frequency" :label="t('behavior.rfmColF')" />
              <el-table-column prop="avg_monetary"  :label="t('behavior.rfmColM')">
                <template #default="{row}">{{ Number(row.avg_monetary || 0).toFixed(0) }}</template>
              </el-table-column>
            </el-table>
          </el-col>
        </el-row>
        <div style="font-size:12px;color:#909399;margin-top:8px">{{ t('behavior.rfmHint') }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import VChart from 'vue-echarts'
import { behaviorApi } from '@/api'
import { t, locale } from '@/i18n'

const activeTab = ref('funnel')
const channels  = ['APP', 'H5', '网点', '网银', '小程序']
const eventTypes = ['REGISTER', 'LOGIN', 'BROWSE_PRODUCT', 'APPLY', 'TRANSACTION']

// ── 漏斗 ──────────────────────────────────────────────────────
const funnelChannel = ref('')
const funnelLoading = ref(false)
const funnelData    = ref(null)

const funnelOption = computed(() => {
  if (!funnelData.value) return {}
  const steps = funnelData.value.steps || []
  return {
    tooltip: { trigger: 'item', formatter: `{a} <br/>{b}: {c} ${locale.value === 'zh' ? '人' : 'users'}` },
    series: [{
      name: t('behavior.funnelName'), type: 'funnel',
      left: '10%', width: '80%',
      min: 0, max: steps[0]?.user_count || 1,
      sort: 'none',
      data: steps.map(s => ({ name: s.step_name, value: s.user_count })),
      label: { formatter: locale.value === 'zh' ? '{b}\n{c} 人' : '{b}\n{c} users' },
    }]
  }
})

async function runFunnel() {
  funnelLoading.value = true
  try {
    funnelData.value = await behaviorApi.funnel({ channel: funnelChannel.value || undefined })
  } finally { funnelLoading.value = false }
}

// ── 留存 ──────────────────────────────────────────────────────
const retCohortEvent  = ref('REGISTER')
const retReturnEvent  = ref('LOGIN')
const retLoading      = ref(false)
const retentionData   = ref(null)
const retDays         = [1, 3, 7, 14, 30, 60, 90]

const heatStyle = (v) => {
  if (v == null) return { background: '#f5f7fa', color: '#c0c4cc' }
  const pct = Math.min(v, 100) / 100
  return { background: `rgba(103,194,58,${0.15 + pct * 0.65})`, color: '#1a1a1a', fontWeight: '500' }
}

async function runRetention() {
  retLoading.value = true
  try {
    retentionData.value = await behaviorApi.retention({
      cohort_event: retCohortEvent.value,
      return_event: retReturnEvent.value,
      retention_days: retDays,
    })
  } finally { retLoading.value = false }
}

// ── 趋势 ──────────────────────────────────────────────────────
const trendChannel = ref('')
const trendLoading = ref(false)
const trendData    = ref(null)

const trendOption = computed(() => {
  if (!trendData.value) return {}
  const rows = trendData.value.rows || []
  return {
    tooltip: { trigger: 'axis' },
    legend: { data: [t('behavior.legDau'), t('behavior.legTx'), t('behavior.legMa7')], top: 0 },
    grid: { left: 50, right: 20, top: 36, bottom: 30 },
    xAxis: { type: 'category', data: rows.map(r => r.event_date || r.date) },
    yAxis: [
      { type: 'value', name: t('behavior.yUsers') },
      { type: 'value', name: t('behavior.yTrade'), position: 'right' }
    ],
    series: [
      { name: t('behavior.legDau'),  type: 'bar',  data: rows.map(r => r.dau), itemStyle: { color: '#409eff' } },
      { name: t('behavior.legTx'),   type: 'line', yAxisIndex: 1, data: rows.map(r => r.tx_count), smooth: true, lineStyle: { color: '#67c23a' }, itemStyle: { color: '#67c23a' } },
      { name: t('behavior.legMa7'),  type: 'line', data: rows.map(r => r.dau_7d_avg ? Number(r.dau_7d_avg).toFixed(0) : null), smooth: true, lineStyle: { color: '#e6a23c', type: 'dashed' }, itemStyle: { color: '#e6a23c' } },
    ]
  }
})

async function runTrend() {
  trendLoading.value = true
  try {
    trendData.value = await behaviorApi.transaction({ channel: trendChannel.value || undefined })
  } finally { trendLoading.value = false }
}

// ── RFM ──────────────────────────────────────────────────────
const rfmLoading = ref(false)
const rfmData    = ref(null)
const rfmColors  = ['#409eff','#67c23a','#e6a23c','#f56c6c','#909399','#c71585','#20b2aa','#ff7f50']

const rfmPieOption = computed(() => ({
  tooltip: { trigger: 'item' },
  legend: { bottom: 0 },
  series: [{
    type: 'pie', radius: ['35%', '60%'],
    data: (rfmData.value || []).map((r, i) => ({
      name: r.rfm_segment, value: r.user_count,
      itemStyle: { color: rfmColors[i % rfmColors.length] }
    })),
    label: { formatter: '{b}\n{d}%' }
  }]
}))

async function runRfm() {
  rfmLoading.value = true
  try { rfmData.value = await behaviorApi.rfm() }
  finally { rfmLoading.value = false }
}

onMounted(() => { runFunnel() })
</script>

<style scoped>
.retention-matrix { border-collapse: collapse; font-size: 12px; width: 100%; }
.retention-matrix th, .retention-matrix td {
  border: 1px solid #ebeef5; padding: 6px 10px; text-align: center; white-space: nowrap;
}
.retention-matrix th { background: #f5f7fa; font-weight: 600; }
</style>
