<template>
  <div class="lineage-wrap">
    <div class="lg-header">
      <span class="lg-title">{{ t('regulatory.tabLineage') }}</span>
      <span class="lg-sub">Raw data → Master output</span>
      <div class="lg-legend">
        <span v-for="l in legend" :key="l.label" class="lg-legend-item">
          <span class="lg-dot" :style="`background:${l.color}`"></span>{{ l.label }}
        </span>
      </div>
    </div>
    <div id="lineage-chart" style="height:calc(100vh - 220px); min-height:500px"></div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import * as echarts from 'echarts'
import { t } from '@/i18n'

const legend = [
  { label:'Source', color:'#409eff' },
  { label:'ODS',  color:'#67c23a' },
  { label:'DWD',  color:'#e6a23c' },
  { label:'DWS',  color:'#9c6cd4' },
  { label:'ADS',  color:'#f56c6c' },
]

onMounted(() => {
  const c = echarts.init(document.getElementById('lineage-chart'))

  // 节点定义：[id, name, x%, y%, layer, desc]
  const nodesDef = [
    // 业务源系统 (x=5%)
    ['src_core',   'Core\nSystem',     80,  80, 0, 'Raw GL entries'],
    ['src_credit', 'Credit\nSystem',     80, 220, 0, 'Loan ledger and classification'],
    ['src_fund',   'Treasury\nSystem',     80, 360, 0, 'Liquidity assets and holdings'],
    ['src_risk',   'Risk\nSystem',     80, 500, 0, 'Capital and RWA calc'],
    ['src_biz',    'Branch\nSystem',     80, 640, 0, 'Deposits and retail loans'],

    // ODS贴源层 (x=25%)
    ['ods_g01',    'ODS\nG01',     280, 120, 1, 'Historical raw storage'],
    ['ods_g04',    'ODS\nLoans',    280, 300, 1, 'Loan-level detail'],
    ['ods_g11',    'ODS\nLiquidity',  280, 460, 1, 'Daily HQLA snapshot'],
    ['ods_g03',    'ODS\nCapital',    280, 600, 1, 'Raw capital and RWA inputs'],

    // DWD明细层 (x=48%)
    ['dwd_g01',    'DWD\nBalance',    520, 120, 2, 'Cleaned and standardized'],
    ['dwd_loan',   'DWD\nLoan Quality',    520, 300, 2, 'Classification and migration'],
    ['dwd_lcr',    'DWD\nLiquidity',      520, 460, 2, 'HQLA haircut and outflow'],
    ['dwd_cap',    'DWD\nCapital',    520, 600, 2, 'Credit/market/op risk RWA'],

    // DWS汇总层 (x=70%)
    ['dws_bal',    'DWS\nBalance', 760, 200, 3, 'Period summary'],
    ['dws_risk',   'DWS\nRisk Metrics', 760, 480, 3, 'Unified risk metrics'],

    // ADS一表通 (x=90%)
    ['ads_master', 'Master\nreg_master', 960, 340, 4, 'Core metrics and submission status'],
  ]

  const colorMap = ['#409eff','#67c23a','#e6a23c','#9c6cd4','#f56c6c']
  const sizeMap  = [
    [130, 46],
    [138, 46],
    [144, 48],
    [154, 50],
    [172, 54],
  ]

  const nodes = nodesDef.map(([id, name, x, y, layer, desc]) => ({
    id, name, x, y,
    symbol: 'rect',
    symbolSize: sizeMap[layer],
    itemStyle: { color: colorMap[layer], borderColor: '#fff', borderWidth: 2 },
      label: {
        show: true,
        color: '#fff',
        fontSize: 12,
        fontWeight: 600,
        width: 112,
        overflow: 'breakAll',
        lineHeight: 16,
        formatter: name,
      },
    tooltip: { formatter: () => `<b>${name.replace('\n','')}</b><br/>${desc}` },
  }))

  const edgesDef = [
    // 源 → ODS
    ['src_core',   'ods_g01'],
    ['src_biz',    'ods_g01'],
    ['src_credit', 'ods_g04'],
    ['src_fund',   'ods_g11'],
    ['src_risk',   'ods_g03'],
    // ODS → DWD
    ['ods_g01', 'dwd_g01'],
    ['ods_g04', 'dwd_loan'],
    ['ods_g11', 'dwd_lcr'],
    ['ods_g03', 'dwd_cap'],
    // DWD → DWS
    ['dwd_g01',  'dws_bal'],
    ['dwd_loan', 'dws_bal'],
    ['dwd_loan', 'dws_risk'],
    ['dwd_lcr',  'dws_risk'],
    ['dwd_cap',  'dws_risk'],
    // DWS → ADS
    ['dws_bal',  'ads_master'],
    ['dws_risk', 'ads_master'],
  ]

  const edges = edgesDef.map(([s, t]) => ({
    source: s, target: t,
    lineStyle: { color: '#c0c4cc', width: 1.5, curveness: 0.1 },
    emphasis: { lineStyle: { color: '#409eff', width: 3 } },
  }))

  c.setOption({
    tooltip: { trigger: 'item' },
    animationDurationUpdate: 800,
    series: [{
      type: 'graph',
      layout: 'none',
      nodes, edges,
      roam: true,
      zoom: 0.9,
      edgeSymbol: ['none', 'arrow'],
      edgeSymbolSize: [0, 8],
      emphasis: { focus: 'adjacency' },
      lineStyle: { opacity: 0.7 },
    }]
  })
  window.addEventListener('resize', () => c.resize())
})
</script>

<style scoped>
.lineage-wrap { display:flex; flex-direction:column; background:#fff; border:1px solid #e4e7ed; border-radius:6px; overflow:hidden; }
.lg-header {
  display:flex; align-items:center; gap:12px; padding:12px 16px;
  border-bottom:1px solid #f0f2f5; flex-shrink:0; flex-wrap:wrap;
}
.lg-title { font-size:14px; font-weight:700; color:#1f2a37; }
.lg-sub   { font-size:12px; color:#909399; flex:1; }
.lg-legend { display:flex; gap:12px; flex-wrap:wrap; }
.lg-legend-item { display:flex; align-items:center; gap:5px; font-size:11px; color:#606266; }
.lg-dot { width:10px; height:10px; border-radius:50%; }

#lineage-chart {
  width: 100%;
}
</style>
