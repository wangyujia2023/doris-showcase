<template>
  <div class="master-wrap">
    <div class="master-header">
      <div class="mh-info">
        <span class="mh-title">📊 {{ t('regulatory.tabMaster') }} · reg_master</span>
        <span class="mh-sub">{{ t('regulatory.tabMaster') }} / reg_master</span>
      </div>
      <div style="margin-left:auto;display:flex;gap:8px;align-items:center">
        <el-tag type="info" size="small">{{ rows.length }} {{ t('regulatory.latestPeriod') }}</el-tag>
        <el-button size="small" @click="load">{{ t('regulatory.reload') }}</el-button>
      </div>
    </div>

    <!-- 空状态 -->
    <el-empty v-if="!loading && !rows.length"
              :description="t('regulatory.noData')" style="padding:60px 0"/>

    <!-- 一表通主表 -->
    <div v-else class="table-scroll">
      <table class="master-table">
        <thead>
          <tr>
            <th rowspan="2" class="th-period">{{ t('regulatory.period') }}</th>
            <th colspan="5" class="th-group g01">G01 Assets/Liabilities</th>
            <th colspan="4" class="th-group g03">G03 Capital Adequacy</th>
            <th colspan="3" class="th-group g04">G04A Loan Quality</th>
            <th colspan="2" class="th-group g11">G11 Liquidity</th>
            <th colspan="2" class="th-group g21">G21 Profitability</th>
            <th colspan="2" class="th-group stat">{{ t('regulatory.status') }}</th>
          </tr>
          <tr>
            <th>Assets</th><th>Liabilities</th><th>Equity</th>
            <th>Loans</th><th>Deposits</th>
            <th>CET1</th><th>Tier1</th><th>CAR</th><th>Leverage</th>
            <th>NPL</th><th>Coverage</th><th>Provision</th>
            <th>LCR</th><th>NSFR</th>
            <th>Net Profit</th><th>ROE</th>
            <th>{{ t('regulatory.qcScore') }}</th><th>{{ t('regulatory.status') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.report_period" class="data-row">
            <td class="td-period">{{ row.report_period }}</td>
            <!-- G01 -->
            <td>{{ fmtB(row.total_assets_w) }}</td>
            <td>{{ fmtB(row.total_liabilities_w) }}</td>
            <td>{{ fmtB(row.total_equity_w) }}</td>
            <td>{{ fmtB(row.total_loans_w) }}</td>
            <td>{{ fmtB(row.total_deposits_w) }}</td>
            <!-- G03 -->
            <td :class="ratioClass(row.cet1_ratio, 0.075)">{{ fmtPct(row.cet1_ratio) }}</td>
            <td :class="ratioClass(row.tier1_ratio, 0.085)">{{ fmtPct(row.tier1_ratio) }}</td>
            <td :class="ratioClass(row.car_ratio,   0.105)">{{ fmtPct(row.car_ratio) }}</td>
            <td :class="ratioClass(row.leverage_ratio, 0.04)">{{ fmtPct(row.leverage_ratio) }}</td>
            <!-- G04A -->
            <td :class="nplClass(row.npl_ratio)">{{ fmtPct(row.npl_ratio) }}</td>
            <td :class="ratioClass(row.provision_coverage, 1.5)">{{ fmtPct(row.provision_coverage) }}</td>
            <td>{{ fmtPct(row.loan_provision_rate) }}</td>
            <!-- G11 -->
            <td :class="ratioClass(row.lcr_ratio, 1.0)">{{ fmtPct(row.lcr_ratio) }}</td>
            <td :class="ratioClass(row.nsfr_ratio, 1.0)">{{ fmtPct(row.nsfr_ratio) }}</td>
            <!-- G21 -->
            <td>{{ fmtB(row.net_profit_w) }}</td>
            <td>{{ fmtPct(row.roe) }}</td>
            <!-- 合规 -->
            <td class="td-score">
              <div class="score-bar-wrap">
                <div class="score-bar" :style="`width:${row.compliance_score}%;background:${scoreColor(row.compliance_score)}`"></div>
                <span class="score-val">{{ row.compliance_score }}</span>
              </div>
            </td>
            <td class="td-status">
              <div class="status-dots">
                <span v-for="s in statusList(row)" :key="s.code"
                      :class="['sdot', s.ok ? 'ok' : 'err']"
                      :title="s.code">{{ s.code }}</span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 指标说明 -->
    <div class="legend-footer">
      <span class="lf-pass">■ OK</span>
      <span class="lf-fail">■ NG</span>
      <span class="lf-note">CAR≥10.5% · LCR/NSFR≥100% · NPL≤5% · Coverage≥150%</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { regulatoryApi } from '@/api'
import { t } from '@/i18n'

const rows    = ref([])
const loading = ref(true)

const fmtPct = v => v != null ? (v * 100).toFixed(2) + '%' : '—'
const fmtB   = v => v != null ? (v / 10000).toFixed(1) : '—'

const ratioClass = (v, threshold) =>
  v != null ? (v >= threshold ? 'cell-ok' : 'cell-err') : ''

const nplClass = (v) =>
  v != null ? (v <= 0.05 ? 'cell-ok' : 'cell-err') : ''

const scoreColor = s => s >= 90 ? '#67c23a' : s >= 70 ? '#e6a23c' : '#f56c6c'

const statusList = row => [
  { code:'G01', ok: row.g01_status === 'submitted' },
  { code:'G03', ok: row.g03_status === 'submitted' },
  { code:'G04A',ok: row.g04a_status=== 'submitted' },
  { code:'G11', ok: row.g11_status === 'submitted' },
  { code:'G21', ok: row.g21_status === 'submitted' },
]

const load = async () => {
  loading.value = true
  try {
    const r = await regulatoryApi.master()
    rows.value = r.data || []
  } finally { loading.value = false }
}

defineExpose({ reload: load })
onMounted(load)
</script>

<style scoped>
.master-wrap {
  background:#fff; border:1px solid #e4e7ed; border-radius:6px;
  display:flex; flex-direction:column; overflow:hidden;
}
.master-header {
  display:flex; align-items:center; padding:12px 16px;
  border-bottom:1px solid #f0f2f5; flex-shrink:0; gap:10px; flex-wrap:wrap;
}
.mh-title { font-size:14px; font-weight:700; color:#1f2a37; }
.mh-sub   { font-size:12px; color:#909399; margin-left:8px; }

.table-scroll { overflow-x:auto; flex:1; }
.master-table { width:100%; border-collapse:collapse; font-size:11.5px; white-space:nowrap; }
.master-table th {
  background:#f7f8fa; color:#606266; font-weight:600;
  padding:7px 10px; text-align:center;
  border:1px solid #ebeef5; font-size:11px;
}
.th-period { background:#f0f4ff; color:#409eff; min-width:80px; }
.th-group { border-bottom:2px solid; }
.th-group.g01 { border-color:#409eff; background:#f0f7ff; color:#409eff; }
.th-group.g03 { border-color:#67c23a; background:#f0fff4; color:#4caf50; }
.th-group.g04 { border-color:#e6a23c; background:#fffbf0; color:#e6a23c; }
.th-group.g11 { border-color:#9c6cd4; background:#f9f0ff; color:#9c6cd4; }
.th-group.g21 { border-color:#17b3a3; background:#f0fffe; color:#17b3a3; }
.th-group.stat{ border-color:#303133; background:#f5f5f5; color:#303133; }

.master-table td {
  padding:7px 10px; text-align:center;
  border:1px solid #ebeef5; color:#303133;
}
.data-row:hover td { background:#f5f7ff; }
.td-period { font-weight:700; color:#409eff; background:#f8faff; }

.cell-ok  { color:#52c41a; font-weight:600; background:rgba(82,196,26,.06); }
.cell-err { color:#f56c6c; font-weight:600; background:rgba(245,108,108,.06); }

/* 合规得分 */
.score-bar-wrap {
  display:flex; align-items:center; gap:6px;
}
.score-bar { height:6px; border-radius:3px; min-width:4px; transition: width .3s; }
.score-val { font-size:11px; font-weight:700; min-width:24px; }

/* 报送状态点 */
.status-dots { display:flex; gap:3px; justify-content:center; flex-wrap:wrap; }
.sdot {
  padding:1px 4px; border-radius:2px; font-size:9px; font-weight:700;
}
.sdot.ok  { background:#f0fff4; color:#52c41a; border:1px solid #b7eb8f; }
.sdot.err { background:#fff2f0; color:#f56c6c; border:1px solid #ffa39e; }

/* 图例 */
.legend-footer {
  padding:8px 16px; border-top:1px solid #f0f2f5;
  display:flex; gap:16px; font-size:11px; flex-shrink:0;
}
.lf-pass  { color:#52c41a; }
.lf-fail  { color:#f56c6c; }
.lf-note  { color:#909399; margin-left:auto; }
</style>
