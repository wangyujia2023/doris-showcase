import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { use } from 'echarts/core'
import { FunnelChart, BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent, LegendComponent } from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import { t, locale } from '@/i18n'
import { cdpApi } from '@/api'

export function useUserTagAnalysis() {
  use([FunnelChart, BarChart, GridComponent, TooltipComponent, LegendComponent, CanvasRenderer])

  const route = useRoute()
  const activeTab = ref(route.query.tab || route.meta?.defaultTab || 'crowd')

  // ── 标签元数据 ──
  const tagMeta = ref([])
  const allCats = computed(() => tagMeta.value.map(g => g.category))

  async function loadTagMeta() {
    const data = await cdpApi.tagMeta()
    tagMeta.value = data
  }
  function groupLabel(cat) {
    const key = String(cat || '').trim()
    const val = t(`segment.tagGroups.${key}`)
    return val === `segment.tagGroups.${key}` ? key : val
  }
  function tagText(name) {
    const key = String(name || '').trim()
    const val = t(`segment.tagLabels.${key}`)
    return val === `segment.tagLabels.${key}` ? key : val
  }
  function tagLabel(tid) {
    for (const grp of tagMeta.value) {
      const tg = grp.tags.find(x => x.tag_id === tid)
      if (tg) return tagText(tg.label)
    }
    return String(tid)
  }

  // ══════════════════════════════════════════
  // 人群包构建
  // ══════════════════════════════════════════
  const includeTagIds  = ref([])
  const excludeTagIds  = ref([])
  const bitmapLoading  = ref(false)
  const crowdSize      = ref(null)
  const crowdName      = ref('')
  const crowdDesc      = ref('')
  const crowdList      = ref([])
  const compareIds     = ref([])
  const compareLoading = ref(false)
  const compareResult  = ref(null)

  function tagClass(tid) {
    if (includeTagIds.value.includes(tid)) return 'chip-include'
    if (excludeTagIds.value.includes(tid)) return 'chip-exclude'
    return 'chip-default'
  }
  function toggleInclude(tid) {
    excludeTagIds.value = excludeTagIds.value.filter(x => x !== tid)
    if (includeTagIds.value.includes(tid)) {
      includeTagIds.value = includeTagIds.value.filter(x => x !== tid)
    } else {
      includeTagIds.value.push(tid)
    }
    crowdSize.value = null
  }
  function toggleExclude(tid) {
    includeTagIds.value = includeTagIds.value.filter(x => x !== tid)
    if (excludeTagIds.value.includes(tid)) {
      excludeTagIds.value = excludeTagIds.value.filter(x => x !== tid)
    } else {
      excludeTagIds.value.push(tid)
    }
    crowdSize.value = null
  }

  async function computeBitmapCrowd() {
    bitmapLoading.value = true
    try {
      const data = await cdpApi.bitmapCompute({
        include_tag_ids: includeTagIds.value,
        exclude_tag_ids: excludeTagIds.value,
      })
      crowdSize.value = data.crowd_size
    } finally {
      bitmapLoading.value = false
    }
  }

  async function saveCrowd() {
    const data = await cdpApi.crowdSave({
      name: crowdName.value,
      desc: crowdDesc.value,
      include_tag_ids: includeTagIds.value,
      exclude_tag_ids: excludeTagIds.value,
      crowd_size: crowdSize.value,
    })
    crowdList.value.unshift(data)
    crowdName.value = ''
    crowdDesc.value = ''
  }

  async function deleteCrowd(id) {
    await cdpApi.crowdDelete(id)
    crowdList.value = crowdList.value.filter(p => p.crowd_id !== id)
    compareIds.value = compareIds.value.filter(x => x !== id)
  }

  async function loadCrowdList() {
    const data = await cdpApi.crowdList()
    crowdList.value = data
  }

  async function runCompare() {
    if (compareIds.value.length !== 2) return
    compareLoading.value = true
    try {
      const data = await cdpApi.crowdCompare({
        id_a: compareIds.value[0],
        id_b: compareIds.value[1],
      })
      compareResult.value = data
    } finally {
      compareLoading.value = false
    }
  }

  // ══════════════════════════════════════════
  // 人群画像
  // ══════════════════════════════════════════
  const portraitTab = ref('tgi')

  // TGI
  const tgiTagIds  = ref([])
  const tgiLoading = ref(false)
  const tgiData    = ref([])
  const tgiCat     = ref('')
  const tgiCats    = computed(() => [...new Set(tgiData.value.map(x => x.category))])

  async function runTgi() {
    tgiLoading.value = true
    try {
      const data = await cdpApi.tgi({ include_tag_ids: tgiTagIds.value })
      tgiData.value = data
    } finally {
      tgiLoading.value = false
    }
  }

  const tgiOption = computed(() => {
    let rows = tgiData.value
    if (tgiCat.value) rows = rows.filter(x => x.category === tgiCat.value)
    rows = rows.slice(0, 20).reverse()
    return {
      tooltip: { trigger: 'axis', formatter: params => {
        const d = params[0]
        return `${d.name}<br/>TGI: <b>${d.value}</b><br/>${t('ut.target')}: ${rows[d.dataIndex]?.seg_pct}% / ${t('ut.baseline')}: ${rows[d.dataIndex]?.base_pct}%`
      }},
      grid: { left: '28%', right: '10%', top: '4%', bottom: '4%' },
      xAxis: { type: 'value', axisLabel: { fontSize: 11 } },
      yAxis: { type: 'category', data: rows.map(r => tagText(r.label)), axisLabel: { fontSize: 11 } },
      series: [{
        type: 'bar',
        data: rows.map(r => ({
          value: r.tgi,
          itemStyle: { color: r.tgi >= 120 ? '#67c23a' : r.tgi >= 80 ? '#409eff' : '#f56c6c' }
        })),
        markLine: { data: [{ xAxis: 100, lineStyle: { color: '#e6a23c', type: 'dashed' } }] },
        label: { show: true, position: 'right', fontSize: 11 },
      }],
    }
  })

  // 交叉分析
  const crossCat1   = ref('')
  const crossCat2   = ref('')
  const crossLoading = ref(false)
  const crossData   = ref(null)
  const crossMaxPct = computed(() => crossData.value
    ? Math.max(...crossData.value.matrix.flatMap(r => r.cells.map(c => c.pct)), 1)
    : 1
  )
  function crossColor(pct, max) {
    const r = Math.min(pct / max, 1)
    return `rgba(64,158,255,${0.1 + r * 0.7})`
  }

  async function runCross() {
    crossLoading.value = true
    try {
      const data = await cdpApi.cross({ cat1: crossCat1.value, cat2: crossCat2.value })
      crossData.value = data
    } finally {
      crossLoading.value = false
    }
  }

  // 地域分布
  const geoTagIds  = ref([])
  const geoLoading = ref(false)
  const geoData    = ref(null)

  async function runGeo() {
    geoLoading.value = true
    try {
      const data = await cdpApi.geo({ include_tag_ids: geoTagIds.value })
      geoData.value = data
    } finally {
      geoLoading.value = false
    }
  }

  const geoProvinceOption = computed(() => {
    if (!geoData.value) return {}
    const rows = [...geoData.value.province_list].slice(0, 15).reverse()
    return {
      tooltip: { trigger: 'axis' },
      grid: { left: '22%', right: '10%', top: '4%', bottom: '4%' },
      xAxis: { type: 'value' },
      yAxis: { type: 'category', data: rows.map(r => r.province), axisLabel: { fontSize: 11 } },
      series: [{ type: 'bar', data: rows.map(r => r.cnt), label: { show: true, position: 'right', fontSize: 11 } }],
    }
  })

  // ══════════════════════════════════════════
  // 地图投放
  // ══════════════════════════════════════════
  const provinces = [
    '北京', '上海', '天津', '重庆',
    '广东', '浙江', '江苏', '山东', '河南', '四川', '湖北', '湖南',
    '福建', '安徽', '河北', '陕西', '云南', '辽宁', '江西', '广西',
    '黑龙江', '内蒙古', '山西', '贵州', '新疆', '吉林', '西藏', '甘肃',
    '海南', '宁夏', '青海',
  ]
  const selectedProvinces = ref([])
  const mapLoading        = ref(false)
  const targetingData     = ref(null)
  const strategy = ref({ channels: ['APP', 'SMS'], timeStart: null, timeEnd: null, freqCap: 3, theme: '' })
  const strategyPlan      = ref(null)

  function toggleProvince(p) {
    if (selectedProvinces.value.includes(p)) {
      selectedProvinces.value = selectedProvinces.value.filter(x => x !== p)
    } else {
      selectedProvinces.value.push(p)
    }
    targetingData.value = null
  }

  async function runTargeting() {
    mapLoading.value = true
    try {
      const data = await cdpApi.targeting({ provinces: selectedProvinces.value })
      targetingData.value = data
    } finally {
      mapLoading.value = false
    }
  }

  function genStrategy() {
    const s = strategy.value
    const selectedRegion = selectedProvinces.value.map(displayProvince).join(', ') || t('ut.noProvince')
    const channels = s.channels.map(channelLabel).join(' + ')
    strategyPlan.value = [
      `📍 ${t('ut.strategyRegion')}: ${selectedRegion}`,
      `📡 ${t('ut.deliveryChannel')}: ${channels}`,
      `🕐 ${t('ut.deliveryTime')}: ${formatTime(s.timeStart)} - ${formatTime(s.timeEnd)}`,
      `🔁 ${t('ut.frequencyCap')}: ${s.freqCap} ${t('ut.timesPerDay')}`,
      `🎯 ${t('ut.campaignTheme')}: ${s.theme || '-'}`,
      `👥 ${t('ut.estimatedCoverage')}: ${targetingData.value ? `${targetingData.value.total.toLocaleString()} ${t('ut.peopleUnit')}` : t('ut.pleaseEstimate')}`,
    ]
  }

  function displayProvince(value) {
    const key = `ut.provinces.${value}`
    const label = t(key)
    return label === key ? value : label
  }

  function channelLabel(value) {
    const labels = {
      APP: t('ut.channelApp'),
      SMS: t('ut.channelSms'),
      EMAIL: t('ut.channelEmail'),
      WECHAT: t('ut.channelWechat'),
    }
    return labels[value] || value
  }

  function formatTime(d) {
    if (!d) return '--:--'
    const t = new Date(d)
    return `${String(t.getHours()).padStart(2,'0')}:${String(t.getMinutes()).padStart(2,'0')}`
  }

  // ══════════════════════════════════════════
  // 标签分析
  // ══════════════════════════════════════════
  const taTab        = ref('weight')
  const weightTagIds = ref([])
  const weightLoading = ref(false)
  const weightData   = ref(null)
  const anomalyLoading = ref(false)
  const anomalyData  = ref(null)

  async function runWeight() {
    weightLoading.value = true
    try {
      const data = await cdpApi.tagWeight({ include_tag_ids: weightTagIds.value })
      weightData.value = data
    } finally {
      weightLoading.value = false
    }
  }

  async function runAnomaly() {
    anomalyLoading.value = true
    try {
      const data = await cdpApi.tagAnomaly()
      anomalyData.value = data
    } finally {
      anomalyLoading.value = false
    }
  }

  // ══════════════════════════════════════════
  // 宽表查询
  // ══════════════════════════════════════════
  const selectedTagIds = ref([])
  const wideLoading    = ref(false)
  const wideResult     = ref(null)
  const widePage       = ref(1)
  const distribution   = ref([])
  const distMax        = computed(() => Math.max(...distribution.value.map(d => d.count), 1))
  const distPercent    = cnt => Math.round(cnt * 100 / distMax.value)

  async function queryWide(page = 1) {
    if (typeof page !== 'number') page = 1
    wideLoading.value = true
    widePage.value = page
    try {
      const data = await cdpApi.wideQuery({ tag_ids: selectedTagIds.value, page, page_size: 20 })
      wideResult.value = data
    } finally {
      wideLoading.value = false
    }
  }
  async function loadDistribution() {
    const data = await cdpApi.wideDistribution()
    distribution.value = data
  }
  function onWidePage(p) { queryWide(p) }

  // ══════════════════════════════════════════
  // ETL
  // ══════════════════════════════════════════
  const etlLoading  = ref(false)
  const etlResult   = ref(null)
  const etlOverview = ref([])

  async function runEtl() {
    etlLoading.value = true
    try {
      const data = await cdpApi.etlSync()
      etlResult.value = data
      await loadEtlOverview()
    } finally {
      etlLoading.value = false
    }
  }
  async function loadEtlOverview() {
    const data = await cdpApi.etlOverview()
    etlOverview.value = data
  }

  // ══════════════════════════════════════════
  // 行为分析
  // ══════════════════════════════════════════
  const behaviorTab    = ref('funnel')
  const eventTypes     = ['REGISTER', 'LOGIN', 'BROWSE_PRODUCT', 'APPLY', 'TRANSACTION', 'TRANSFER', 'REPAY']
  const funnelSteps    = ref(['REGISTER', 'LOGIN', 'BROWSE_PRODUCT', 'APPLY', 'TRANSACTION'])
  const funnelWindow   = ref(86400)
  const funnelFilterTags = ref([])
  const newStep        = ref('')
  const funnelLoading  = ref(false)
  const funnelData     = ref(null)

  function addStep(v) {
    if (v && !funnelSteps.value.includes(v)) funnelSteps.value.push(v)
    newStep.value = ''
  }
  async function runFunnel() {
    funnelLoading.value = true
    try {
      const data = await cdpApi.funnel({
        steps: funnelSteps.value,
        window_seconds: funnelWindow.value,
        filter_tag_ids: funnelFilterTags.value.length ? funnelFilterTags.value : null,
      })
      funnelData.value = data
    } finally {
      funnelLoading.value = false
    }
  }
  const funnelOption = computed(() => {
    if (!funnelData.value) return {}
    return {
      tooltip: { trigger: 'item' },
      series: [{
        type: 'funnel', sort: 'none',
        label: { position: 'inside', formatter: ({ name, value }) => `${name}: ${value}${t('ut.peopleUnit')}` },
        data: funnelData.value.steps.map(s => ({ name: s.step_name, value: s.user_count })),
      }],
    }
  })

  const retCohort     = ref('REGISTER')
  const retReturn     = ref('LOGIN')
  const retLoading    = ref(false)
  const retentionData = ref(null)

  async function runRetention() {
    retLoading.value = true
    try {
      const data = await cdpApi.retention({
        cohort_event: retCohort.value, return_event: retReturn.value,
      })
      retentionData.value = data
    } finally {
      retLoading.value = false
    }
  }
  function heatColor(rate) {
    if (!rate) return '#f5f7fa'
    const r = Math.min(rate, 100) / 100
    const g = Math.round(200 - r * 100)
    const b = Math.round(240 - r * 80)
    return `rgba(64,${g},${b},${0.3 + r * 0.5})`
  }

  const pathLoading = ref(false)
  const pathData    = ref(null)

  async function runPath() {
    pathLoading.value = true
    try {
      const data = await cdpApi.path(10)
      pathData.value = data
    } finally {
      pathLoading.value = false
    }
  }
  const pathOption = computed(() => {
    if (!pathData.value) return {}
    const rows = [...pathData.value].sort((a, b) => a.freq - b.freq)
    return {
      tooltip: { trigger: 'axis' },
      grid: { left: '30%', right: '8%' },
      xAxis: { type: 'value' },
      yAxis: { type: 'category', data: rows.map(r => r.path) },
      series: [{ type: 'bar', data: rows.map(r => r.freq), label: { show: true, position: 'right' } }],
    }
  })

  onMounted(async () => {
    await Promise.allSettled([
      loadTagMeta(),
      loadDistribution(),
      loadEtlOverview(),
      loadCrowdList(),
    ])
  })

  watch(
    () => route.query.tab,
    tab => {
      if (tab) activeTab.value = String(tab)
    }
  )
  return {
    activeTab,
    tagMeta,
    allCats,
    groupLabel,
    tagText,
    tagLabel,
    includeTagIds,
    excludeTagIds,
    bitmapLoading,
    crowdSize,
    crowdName,
    crowdDesc,
    crowdList,
    compareIds,
    compareLoading,
    compareResult,
    tagClass,
    toggleInclude,
    toggleExclude,
    computeBitmapCrowd,
    saveCrowd,
    deleteCrowd,
    runCompare,
    portraitTab,
    tgiTagIds,
    tgiLoading,
    tgiData,
    tgiCat,
    tgiCats,
    runTgi,
    tgiOption,
    crossCat1,
    crossCat2,
    crossLoading,
    crossData,
    crossMaxPct,
    crossColor,
    runCross,
    geoTagIds,
    geoLoading,
    geoData,
    runGeo,
    geoProvinceOption,
    provinces,
    selectedProvinces,
    mapLoading,
    targetingData,
    strategy,
    strategyPlan,
    toggleProvince,
    runTargeting,
    genStrategy,
    displayProvince,
    taTab,
    weightTagIds,
    weightLoading,
    weightData,
    anomalyLoading,
    anomalyData,
    runWeight,
    runAnomaly,
    selectedTagIds,
    wideLoading,
    wideResult,
    widePage,
    distribution,
    distPercent,
    queryWide,
    loadDistribution,
    onWidePage,
    etlLoading,
    etlResult,
    etlOverview,
    runEtl,
    loadEtlOverview,
    behaviorTab,
    eventTypes,
    funnelSteps,
    funnelWindow,
    funnelFilterTags,
    newStep,
    funnelLoading,
    funnelData,
    addStep,
    runFunnel,
    funnelOption,
    retCohort,
    retReturn,
    retLoading,
    retentionData,
    runRetention,
    heatColor,
    pathLoading,
    pathData,
    runPath,
    pathOption,
  }
}
