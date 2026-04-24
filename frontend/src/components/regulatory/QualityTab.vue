<template>
  <div class="qc-wrap">
    <!-- 总分卡 -->
    <div class="score-row">
      <div class="score-big">
        <div class="score-num" :style="`color:${scoreColor}`">{{ result.score ?? '—' }}</div>
        <div class="score-label">{{ t('regulatory.qcScore') }}</div>
        <div class="score-sub">{{ result.passed ?? 0 }}/{{ result.total ?? 0 }} {{ t('regulatory.status') }}</div>
      </div>
      <div class="score-detail">
        <div class="sd-item" v-for="d in scoreDist" :key="d.label">
          <div class="sd-icon" :class="d.cls">{{ d.icon }}</div>
          <div class="sd-info">
            <div class="sd-label">{{ d.label }}</div>
            <div class="sd-val">{{ d.val }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 规则列表 -->
    <el-card class="qc-card" style="margin-top:12px">
      <template #header>
        <div style="display:flex;align-items:center;gap:8px">
          <span class="ch">{{ t('regulatory.qcRuleDetail') }} · {{ period }}</span>
          <el-button size="small" @click="load">{{ t('regulatory.reload') }}</el-button>
        </div>
      </template>
      <div class="rule-list">
        <div v-for="r in result.rules" :key="r.rule"
             class="rule-item" :class="r.pass ? 'pass' : 'fail'">
          <div class="rule-icon">{{ r.pass ? '✅' : '❌' }}</div>
          <div class="rule-body">
            <div class="rule-name">{{ r.rule }}</div>
            <div class="rule-detail">{{ r.detail }}</div>
          </div>
          <div class="rule-badge" :class="r.pass ? 'badge-ok' : 'badge-err'">
            {{ r.pass ? 'OK' : 'Fail' }}
          </div>
        </div>
        <div v-if="!result.rules?.length" style="padding:40px;text-align:center;color:#c0c4cc">
          {{ t('regulatory.dataEmpty') }}
        </div>
      </div>
    </el-card>

    <!-- 勾稽关系说明 -->
    <el-card class="qc-card" style="margin-top:12px">
      <template #header><span class="ch">{{ t('regulatory.coreRuleDesc') }}</span></template>
      <div class="formula-grid">
        <div class="fg-item" v-for="f in formulaList" :key="f.title">
          <div class="fg-title">{{ f.title }}</div>
          <div class="fg-expr">{{ f.expr }}</div>
          <div class="fg-desc">{{ f.desc }}</div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { regulatoryApi } from '@/api'
import { t } from '@/i18n'

const props  = defineProps({ period: String })
const result = ref({})

const scoreColor = computed(() => {
  const s = result.value.score ?? 0
  return s >= 90 ? '#67c23a' : s >= 75 ? '#e6a23c' : '#f56c6c'
})

const scoreDist = computed(() => {
  const rules = result.value.rules || []
  const passed = rules.filter(r => r.pass).length
  const failed = rules.filter(r => !r.pass).length
  return [
    { label:'Passed', val: passed + ' items', icon:'✅', cls:'ok' },
    { label:'Failed',  val: failed + ' items', icon:'❌', cls:'err' },
    { label:t('regulatory.latestPeriod'), val: props.period,  icon:'📅', cls:'info' },
    { label:t('regulatory.scope'), val: 'G01·G03·G04A·G11', icon:'📋', cls:'info' },
  ]
})

const formulaList = [
  { title: 'G01 Balance Equation', expr: 'Assets = Liabilities + Equity', desc: 'Basic accounting identity, difference should be 0' },
  { title: 'Capital Adequacy', expr: 'CAR = Net Capital / RWA ≥ 10.5%', desc: 'CET1 ≥ 7.5%, Tier1 ≥ 8.5%' },
  { title: 'NPL Ratio', expr: 'NPL = (Substandard + Doubtful + Loss) / Loans ≤ 5%', desc: 'Regulatory red line' },
  { title: 'Provision Coverage', expr: 'Coverage = Loan Loss Provisions / NPL ≥ 150%', desc: '150% is the minimum benchmark' },
  { title: 'LCR', expr: 'LCR = HQLA / Net Cash Outflow(30d) ≥ 100%', desc: 'HQLA = Level1 + Level2A×85% + Level2B×50%' },
  { title: 'G01↔G04A Reconciliation', expr: 'G01.A08 Loan Net ≈ G04A Loans - Loan Loss Provisions', desc: 'Difference allowed for special item differences' },
]

const load = async () => {
  const p = props.period || '2024-03'
  result.value = await regulatoryApi.qc(p)
}

onMounted(load)
watch(() => props.period, load)
</script>

<style scoped>
.qc-wrap { display:flex; flex-direction:column; gap:0; }

/* 总分区 */
.score-row {
  background:#fff; border:1px solid #e4e7ed; border-radius:6px;
  padding:20px; display:flex; gap:32px; align-items:center;
}
.score-big { text-align:center; flex-shrink:0; width:120px; }
.score-num  { font-size:52px; font-weight:800; line-height:1; }
.score-label{ font-size:13px; color:#606266; margin-top:6px; font-weight:600; }
.score-sub  { font-size:11px; color:#909399; margin-top:4px; }
.score-detail { display:grid; grid-template-columns:1fr 1fr; gap:10px; flex:1; }
.sd-item { display:flex; align-items:center; gap:10px; background:#f9fafc; border-radius:6px; padding:10px 14px; }
.sd-icon { font-size:20px; }
.sd-label { font-size:11px; color:#909399; }
.sd-val   { font-size:15px; font-weight:700; color:#303133; }

/* 规则列表 */
.qc-card { background:#fff; border:1px solid #e8edf3; }
.qc-card :deep(.el-card__header) { padding:10px 14px; border-bottom:1px solid #f0f2f5; }
.ch { font-weight:600; font-size:13px; color:#1f2a37; }
.rule-list { display:flex; flex-direction:column; gap:6px; }
.rule-item {
  display:flex; align-items:center; gap:10px;
  padding:10px 14px; border-radius:5px; border-left:3px solid;
}
.rule-item.pass { background:#f6ffed; border-color:#b7eb8f; }
.rule-item.fail { background:#fff2f0; border-color:#ffa39e; }
.rule-icon { font-size:16px; flex-shrink:0; }
.rule-body { flex:1; }
.rule-name   { font-size:13px; font-weight:600; color:#303133; }
.rule-detail { font-size:11px; color:#909399; margin-top:2px; }
.rule-badge  { padding:2px 8px; border-radius:10px; font-size:11px; font-weight:600; }
.badge-ok  { background:#f6ffed; color:#52c41a; border:1px solid #b7eb8f; }
.badge-err { background:#fff2f0; color:#f56c6c; border:1px solid #ffa39e; }

/* 计算公式 */
.formula-grid { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
.fg-item { background:#f9fafc; border:1px solid #ebeef5; border-radius:5px; padding:10px 12px; }
.fg-title { font-size:12px; font-weight:700; color:#303133; margin-bottom:5px; }
.fg-expr  { font-family:monospace; font-size:11px; color:#409eff; background:#f0f7ff; padding:4px 8px; border-radius:3px; margin-bottom:5px; }
.fg-desc  { font-size:11px; color:#909399; }
</style>
