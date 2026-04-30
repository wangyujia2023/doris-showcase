<template>
  <div>
    <LineageFlowPanel />

    <!-- Tab 切换 -->
    <el-tabs v-model="activeTab" type="card" style="margin-bottom:0">
        <el-tab-pane :label="t('lineage.tabImportRecords')" name="sync">
          <LineageSyncPanel
            v-model:start-date="startDate"
            v-model:end-date="endDate"
            v-model:audit-limit="auditLimit"
            :syncing="syncing"
            :sync-rows="syncRows"
            :sync-logs="syncLogs"
            @sync="syncFromAudit"
          />
        </el-tab-pane>

        <el-tab-pane :label="t('lineage.tabQueryLineage')" name="query">
          <div class="card" style="border-top-left-radius:0;padding:0">
            <div class="query-grid">
              <LineageTableList
                v-model:keyword="tableKeyword"
                :tables="tables"
                :selected-table="selectedTable"
                @search="loadTables"
                @choose="chooseTable"
              />

              <div class="detail-col">
                <!-- 当前表信息 -->
                <div class="card">
                  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
                    <div style="font-size:13px;font-weight:600">{{ t('lineage.currentTableLabel') }}</div>
                    <el-button text type="primary" size="small" @click="exportLineage">{{ t('lineage.btnExport') }}</el-button>
                  </div>
                <div class="current-table">{{ selectedTable || t('lineage.unselected') }}</div>
                <div class="current-sub">{{ selectedTableInfo.asset_name || '' }} {{ selectedTableInfo.description || '' }}</div>
              </div>
              <!-- 血缘关系图 -->
              <div class="card">
                  <el-tabs v-model="lineageViewMode" class="lineage-subtabs">
                    <el-tab-pane :label="t('lineage.viewModeTable')" name="table" />
                    <el-tab-pane :label="t('lineage.viewModeField')" name="field" />
                  </el-tabs>

                  <template v-if="lineageViewMode === 'table'">
                  <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:10px">
                    <div>
                      <div style="font-size:13px;font-weight:600">{{ t('lineage.lineageTitle') }}</div>
                      <div style="font-size:12px;color:#909399;margin-top:4px">{{ t('lineage.lineageDesc') }}</div>
                    </div>
                    <div style="display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end">
                      <div style="font-size:12px;padding:4px 10px;background:#f0f9ff;border:1px solid #b3d8ff;border-radius:4px;color:#0050b3">
                        {{ t('lineage.lineageUp').replace('{0}', upstreamList.length) }}
                      </div>
                      <div style="font-size:12px;padding:4px 10px;background:#f6ffed;border:1px solid #b7eb8f;border-radius:4px;color:#274e2b">
                        {{ t('lineage.lineageDown').replace('{0}', downstreamList.length) }}
                      </div>
                      <div style="font-size:12px;padding:4px 10px;background:#fffbe6;border:1px solid #ffe58f;border-radius:4px;color:#5c4a1a">
                        {{ t('lineage.lineageNodes').replace('{0}', omLineage?.nodes?.length || 0) }}
                      </div>
                    </div>
                  </div>

                <!-- 血缘关系图 -->
                <div class="graph-shell">
                  <div class="graph-toolbar">
                    <button class="graph-btn" @click="resetGraph">{{ t('lineage.btnReset') }}</button>
                    <span class="graph-tip">{{ t('lineage.graphTip') }}</span>
                  </div>
                  <svg
                    v-if="graphNodes.length"
                    class="graph-svg"
                    :viewBox="`0 0 ${graphBox.width} ${graphBox.height}`"
                    preserveAspectRatio="none"
                    @wheel.prevent="onGraphWheel"
                    @mousedown="onGraphDown"
                  >
                    <defs>
                      <linearGradient id="lineUp" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stop-color="#10B981" stop-opacity="0.25" />
                        <stop offset="100%" stop-color="#06B6D4" stop-opacity="0.9" />
                      </linearGradient>
                      <linearGradient id="lineDown" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stop-color="#06B6D4" stop-opacity="0.9" />
                        <stop offset="100%" stop-color="#F59E0B" stop-opacity="0.25" />
                      </linearGradient>
                    </defs>

                    <g :transform="`translate(${graphViewport.x}, ${graphViewport.y}) scale(${graphViewport.scale})`">
                      <path v-for="(l, i) in graphLinks" :key="`l-${i}`" :d="l.d" :stroke="l.stroke" class="graph-line" />

                      <g v-for="node in graphNodes" :key="node.key" :transform="`translate(${node.x}, ${node.y})`">
                        <rect :x="-node.w/2" :y="-node.h/2" :width="node.w" :height="node.h" rx="14" class="graph-node" :class="node.kind" />
                        <rect :x="-node.w/2-2" :y="-node.h/2-2" :width="node.w+4" :height="node.h+4" rx="16" class="graph-halo" :class="node.kind" />
                        <text class="graph-node-title" text-anchor="middle" x="0" y="-4">{{ node.title }}</text>
                        <text class="graph-node-sub" text-anchor="middle" x="0" y="14">{{ node.sub }}</text>
                      </g>
                    </g>
                  </svg>
                  <div v-else class="graph-empty">
                    {{ t('lineage.graphEmpty') }}
                  </div>
                </div>

                <!-- 关系详情 -->
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                  <div style="border:1px solid #f0f0f0;border-radius:8px;padding:10px;background:#f9f9f9">
                    <div style="font-size:12px;font-weight:600;margin-bottom:10px">{{ t('lineage.upstreamTitle') }} ({{ upstreamEdgesView.length }})</div>
                    <div v-if="upstreamEdgesView.length" style="display:flex;flex-direction:column;gap:6px;max-height:150px;overflow-y:auto">
                      <div v-for="(e, i) in upstreamEdgesView" :key="i" style="font-size:11px;color:#666;padding:6px;background:#fff;border-radius:4px;border-left:3px solid #52c41a">
                        {{ e }}
                      </div>
                    </div>
                    <el-empty v-else :description="t('lineage.upstreamEmpty')" :image-size="48" />
                  </div>
                  <div style="border:1px solid #f0f0f0;border-radius:8px;padding:10px;background:#f9f9f9">
                    <div style="font-size:12px;font-weight:600;margin-bottom:10px">{{ t('lineage.downstreamTitle') }} ({{ downstreamEdgesView.length }})</div>
                    <div v-if="downstreamEdgesView.length" style="display:flex;flex-direction:column;gap:6px;max-height:150px;overflow-y:auto">
                      <div v-for="(e, i) in downstreamEdgesView" :key="i" style="font-size:11px;color:#666;padding:6px;background:#fff;border-radius:4px;border-left:3px solid #faad14">
                        {{ e }}
                      </div>
                    </div>
                    <el-empty v-else :description="t('lineage.downstreamEmpty')" :image-size="48" />
                  </div>
                </div>

                  <details style="margin-top:12px;border-top:1px solid #f0f0f0;padding-top:12px">
                    <summary style="cursor:pointer;font-size:12px;color:#0050b3;font-weight:600;user-select:none">{{ t('lineage.btnViewJson') }}</summary>
                    <pre style="background:#f5f5f5;padding:10px;border-radius:4px;font-size:11px;overflow-x:auto;color:#333;line-height:1.4;margin-top:8px">{{ omLineageText }}</pre>
                  </details>
                  </template>

                  <template v-else>
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:10px">
                      <div>
                        <div style="font-size:13px;font-weight:600">{{ t('lineage.fieldLineageTitle') }}</div>
                        <div style="font-size:12px;color:#909399;margin-top:4px">{{ t('lineage.fieldLineageDesc') }}</div>
                      </div>
                      <div style="display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end">
                        <div style="font-size:12px;padding:4px 10px;background:#f0f9ff;border:1px solid #b3d8ff;border-radius:4px;color:#0050b3">
                          {{ t('lineage.fieldUpstreamCount').replace('{0}', fieldUpstreamRows.length) }}
                        </div>
                        <div style="font-size:12px;padding:4px 10px;background:#f6ffed;border:1px solid #b7eb8f;border-radius:4px;color:#274e2b">
                          {{ t('lineage.fieldDownstreamCount').replace('{0}', fieldDownstreamRows.length) }}
                        </div>
                      </div>
                    </div>

                    <el-tabs v-model="fieldDirectionTab" class="lineage-subtabs">
                      <el-tab-pane :label="t('lineage.fieldTabUpstream').replace('{0}', fieldUpstreamRows.length)" name="upstream" />
                      <el-tab-pane :label="t('lineage.fieldTabDownstream').replace('{0}', fieldDownstreamRows.length)" name="downstream" />
                    </el-tabs>

                    <div class="field-lineage-panel">
                      <div style="font-size:12px;font-weight:600;margin-bottom:10px">
                        {{ fieldDirectionTab === 'upstream' ? t('lineage.fieldUpstreamLabel') : t('lineage.fieldDownstreamLabel') }}
                      </div>

                      <el-table
                        v-if="fieldDirectionTab === 'upstream'"
                        :data="fieldUpstreamRows"
                        size="small"
                        max-height="620"
                        :empty-text="t('lineage.fieldEmptyUp')"
                        class="lineage-merged-table"
                      >
                        <el-table-column prop="source_table" :label="t('lineage.fieldColSourceTable')" min-width="180" />
                        <el-table-column :label="t('lineage.fieldColSourceField')" min-width="260">
                          <template #default="{ row }">
                            <div class="field-chip-group">
                              <span v-for="field in (row.source_fields || [])" :key="`up-${row.target_field}-${field}`" class="field-badge upstream">{{ field }}</span>
                              <span v-if="!(row.source_fields || []).length" class="field-badge upstream">-</span>
                            </div>
                          </template>
                        </el-table-column>
                        <el-table-column label="" width="50" align="center">
                          <template>
                            <div class="flow-arrow-icon upstream">→</div>
                          </template>
                        </el-table-column>
                        <el-table-column prop="target_table" :label="t('lineage.fieldColTargetTable')" min-width="180" />
                        <el-table-column :label="t('lineage.fieldColTargetField')" min-width="160">
                          <template #default="{ row }">
                            <span class="target-field">{{ row.target_field || '-' }}</span>
                          </template>
                        </el-table-column>
                        <el-table-column :label="t('lineage.fieldColExpression')" min-width="360">
                          <template #default="{ row }">
                            <span class="expr-text">{{ row.expression || '-' }}</span>
                          </template>
                        </el-table-column>
                      </el-table>

                      <el-table
                        v-else
                        :data="fieldDownstreamRows"
                        size="small"
                        max-height="620"
                        :empty-text="t('lineage.fieldEmptyDown')"
                        class="lineage-merged-table"
                      >
                        <el-table-column prop="source_table" :label="t('lineage.fieldColSourceTable')" min-width="180" />
                        <el-table-column :label="t('lineage.fieldColSourceField')" min-width="260">
                          <template #default="{ row }">
                            <div class="field-chip-group">
                              <span v-for="field in (row.source_fields || [])" :key="`down-${row.target_field}-${field}`" class="field-badge downstream">{{ field }}</span>
                              <span v-if="!(row.source_fields || []).length" class="field-badge downstream">-</span>
                            </div>
                          </template>
                        </el-table-column>
                        <el-table-column label="" width="50" align="center">
                          <template>
                            <div class="flow-arrow-icon downstream">→</div>
                          </template>
                        </el-table-column>
                        <el-table-column prop="target_table" :label="t('lineage.fieldColTargetTable')" min-width="180" />
                        <el-table-column :label="t('lineage.fieldColTargetField')" min-width="160">
                          <template #default="{ row }">
                            <span class="target-field">{{ row.target_field || '-' }}</span>
                          </template>
                        </el-table-column>
                        <el-table-column :label="t('lineage.fieldColExpression')" min-width="360">
                          <template #default="{ row }">
                            <span class="expr-text">{{ row.expression || '-' }}</span>
                          </template>
                        </el-table-column>
                      </el-table>
                    </div>

                    <div class="json-action-bar">
                      <el-button text type="primary" size="small" @click="fieldJsonVisible = true">
                        {{ t('lineage.btnViewFieldJson') }}
                      </el-button>
                    </div>
                  </template>
                </div>

                <!-- 影响分析 -->
                <div class="card">
                  <div style="font-size:13px;font-weight:600;margin-bottom:10px">{{ t('lineage.impactTitle') }} ({{ impactRows.length }})</div>
                  <div v-if="impactRows.length" style="display:flex;flex-direction:column;gap:8px">
                    <div
                      v-for="(row, idx) in impactRows"
                      :key="idx"
                      style="padding:10px 12px;border-left:3px solid;border-radius:4px;background:#fafafa;border-top:1px solid #f0f0f0;border-right:1px solid #f0f0f0;border-bottom:1px solid #f0f0f0"
                      :style="getImpactStyle(row.impact_level)"
                    >
                      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:4px">
                        <span style="font-size:12px;font-weight:600;color:#333">{{ row.impacted_asset_id }}</span>
                        <el-tag
                          :type="getImpactType(row.impact_level)"
                          size="small"
                        >
                          {{ getImpactLabel(row.impact_level) }}
                        </el-tag>
                      </div>
                      <div style="font-size:12px;color:#666;line-height:1.5">{{ row.impact_reason }}</div>
                    </div>
                  </div>
                  <div v-else style="text-align:center;padding:30px;color:#999;font-size:13px">
                    {{ t('lineage.impactEmpty') }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>

    <el-dialog v-model="fieldJsonVisible" :title="t('lineage.btnViewFieldJson')" width="72%" top="6vh" append-to-body>
      <pre class="raw-json-dialog">{{ fieldLineageText }}</pre>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { lineageApi } from '@/api'
import { t, locale } from '@/i18n'
import { useLineageGraph } from '@/composables/useLineageGraph'
import LineageFlowPanel from '@/components/lineage/LineageFlowPanel.vue'
import LineageSyncPanel from '@/components/lineage/LineageSyncPanel.vue'
import LineageTableList from '@/components/lineage/LineageTableList.vue'
import { formatLineageEdge } from '@/composables/useLineageFormat'

const activeTab = ref('sync')
const syncing = ref(false)
const auditLimit = ref(0)
const startDate = ref('')
const endDate = ref('')
const syncRows = ref([])
const syncLogs = ref([])
const tables = ref([])
const tableKeyword = ref('')
const selectedTable = ref('')
const selectedTableInfo = ref({})
const omLineage = ref({})
const omLineageText = ref('')
const fieldLineage = ref({})
const fieldLineageText = ref('')
const fieldJsonVisible = ref(false)
const upstreamList = ref([])
const downstreamList = ref([])
const impactRows = ref([])
const nodeNameMap = ref({})
const lineageViewMode = ref('table')
const fieldDirectionTab = ref('upstream')
let loadSeq = 0
let tableTimer = null

const tableStats = ref({ row_count: null, update_frequency: '' })
const tableQuality = ref({ score: 87, freshness: 95, completeness: 85 })

const getImpactType = (level) => {
  if (level === 'high') return 'danger'
  if (level === 'medium') return 'warning'
  return 'success'
}

const getImpactLabel = (level) => {
  const labels = { high: t('lineage.impactRiskHigh'), medium: t('lineage.impactRiskMedium'), low: t('lineage.impactRiskLow') }
  return labels[level] || '-'
}

const getImpactStyle = (level) => {
  const styles = {
    high: { borderLeftColor: '#f5222d', backgroundColor: '#fff1f0' },
    medium: { borderLeftColor: '#faad14', backgroundColor: '#fffbe6' },
    low: { borderLeftColor: '#52c41a', backgroundColor: '#f6ffed' }
  }
  return styles[level] || styles.low
}

const exportLineage = () => {
  const data = {
    table: selectedTable.value,
    tableInfo: selectedTableInfo.value,
    upstream: upstreamList.value,
    downstream: downstreamList.value,
    impact: impactRows.value,
    quality: tableQuality.value,
    stats: tableStats.value
  }
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = t('lineage.exportFilename').replace('{0}', selectedTable.value).replace('{1}', new Date().toISOString().slice(0, 10))
  a.click()
  URL.revokeObjectURL(url)
  ElMessage.success(t('common.export'))
}

async function refreshLogs() {
  syncLogs.value = await lineageApi.syncLogs(20)
}

async function loadTables(keyword = tableKeyword.value) {
  const seq = ++loadSeq
  const rows = await lineageApi.assets((keyword || '').trim())
  if (seq !== loadSeq) return
  const seen = new Set()
  tables.value = rows.filter((row) => {
    if (!row?.asset_id || seen.has(row.asset_id)) return false
    seen.add(row.asset_id)
    return true
  })
  if (!selectedTable.value && tables.value.length) {
    await chooseTable(tables.value[0].asset_id)
  }
}

async function chooseTable(tableId) {
  selectedTable.value = tableId
  selectedTableInfo.value = await lineageApi.asset(tableId)
  const [res, fieldRes, impactRes] = await Promise.all([
    lineageApi.omLineage(tableId),
    lineageApi.fieldLineage(tableId),
    lineageApi.impact(tableId)
  ])
  omLineage.value = res || {}
  fieldLineage.value = fieldRes || {}
  fieldLineageText.value = JSON.stringify(fieldRes || {}, null, 2)
  nodeNameMap.value = Object.fromEntries((res?.nodes || []).map(n => [n.id, n.name || n.fullyQualifiedName || n.id]))
  upstreamList.value = res?.upstreamEdges || []
  downstreamList.value = res?.downstreamEdges || []
  omLineageText.value = JSON.stringify(res, null, 2)
  impactRows.value = impactRes || []

  tableQuality.value = {
    score: Math.floor(Math.random() * 20) + 75,
    freshness: Math.floor(Math.random() * 15) + 80,
    completeness: Math.floor(Math.random() * 20) + 75
  }

  // 更新表统计信息（从后端元数据获取）
  tableStats.value = {
    row_count: selectedTableInfo.value.row_count || null,
    update_frequency: selectedTableInfo.value.update_frequency || ''
  }
}

const fieldUpstreamRows = computed(() => fieldLineage.value?.upstream_fields || [])
const fieldDownstreamRows = computed(() => fieldLineage.value?.downstream_fields || [])
const edgeText = (edge) => formatLineageEdge(edge, nodeNameMap)
const upstreamEdgesView = computed(() => (upstreamList.value || []).map(edgeText).filter(Boolean))
const downstreamEdgesView = computed(() => (downstreamList.value || []).map(edgeText).filter(Boolean))

const {
  graphBox,
  graphViewport,
  graphNodes,
  graphLinks,
  onGraphWheel,
  onGraphDown,
  resetGraph,
} = useLineageGraph({ selectedTable, omLineage, upstreamList, downstreamList })

async function syncFromAudit() {
  syncing.value = true
  try {
    const res = await lineageApi.syncFromAudit({ start_date: startDate.value, end_date: endDate.value, limit: Number(auditLimit.value) || 0 })
    syncRows.value = res.details || []
    ElMessage.success(t('lineage.msgSyncSuccess').replace('{0}', res.scanned).replace('{1}', res.synced).replace('{2}', res.failed))
    if (res.errors?.length) ElMessage.warning(t('lineage.msgSyncWarning').replace('{0}', res.errors.length))
    await refreshLogs()
    await loadTables()
  } finally {
    syncing.value = false
  }
}

onMounted(async () => {
  await refreshLogs()
  await loadTables()
})

watch(tableKeyword, () => {
  clearTimeout(tableTimer)
  tableTimer = setTimeout(() => {
    loadTables(tableKeyword.value)
  }, 250)
})
</script>

<style scoped>
/* ===== 页面标题 ===== */
.page-title {
  padding: 0 0 16px;
  margin-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.page-title h1 {
  margin: 0 0 8px;
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
}

.page-title p {
  margin: 0;
  font-size: 13px;
  color: #6b7280;
}

/* ===== 卡片和通用 ===== */
.card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

/* ===== 查询网格 ===== */
.query-grid {
  display: grid;
  grid-template-columns: 240px minmax(0, 1fr);
  gap: 12px;
  align-items: start;
}

.table-list-card {
  width: 100%;
}

/* ===== 详情列 ===== */
.detail-col {
  display: grid;
  gap: 12px;
}

/* ===== 质量评分 ===== */
.quality-section {
  margin: 12px 0;
  padding: 12px;
  background: #f0f7ff;
  border: 1px solid #b3d8ff;
  border-radius: 6px;
}

.quality-label {
  font-size: 11px;
  font-weight: 600;
  color: #0050b3;
  text-transform: uppercase;
  margin-bottom: 6px;
}

.quality-score {
  font-size: 20px;
  font-weight: 700;
  color: #1890ff;
  margin-bottom: 8px;
}

.score-bars {
  display: grid;
  gap: 6px;
}

.score-bar {
  display: grid;
  grid-template-columns: 50px 1fr 35px;
  gap: 6px;
  align-items: center;
}

.bar-name {
  font-size: 10px;
  color: #6b7280;
  text-align: right;
}

.bar-container {
  height: 4px;
  background: #e5e7eb;
  border-radius: 2px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #1890ff, #52c41a);
  border-radius: 2px;
  transition: width 0.5s ease;
}

.bar-val {
  font-size: 10px;
  font-weight: 600;
  color: #6b7280;
  text-align: right;
}

/* ===== 元数据 ===== */
.metadata-section {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
}

.meta-item {
  padding: 8px;
  background: #f9f9f9;
  border: 1px solid #f0f0f0;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.meta-key {
  font-size: 10px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
}

.meta-val {
  font-size: 12px;
  color: #1f2937;
  font-weight: 500;
  word-break: break-all;
}

.graph-shell {
  position: relative;
  margin-bottom: 12px;
  border: 1px solid rgba(148,163,184,.18);
  border-radius: 12px;
  background: linear-gradient(180deg, rgba(2,6,23,.95), rgba(15,23,42,.92));
  overflow: auto;
  min-height: 400px;
}

.graph-svg {
  width: 100%;
  min-width: 100%;
  height: 520px;
  display: block;
  cursor: grab;
}

.graph-line {
  fill: none;
  stroke-width: 2.8;
  stroke-linecap: round;
  stroke-dasharray: 10 8;
  animation: dash 10s linear infinite;
}

.graph-node {
  filter: drop-shadow(0 8px 18px rgba(0,0,0,.35));
  stroke-width: 1.5;
}

.graph-node.up { fill: rgba(16,185,129,.12); stroke: #10B981; }
.graph-node.center { fill: rgba(6,182,212,.14); stroke: #06B6D4; }
.graph-node.down { fill: rgba(245,158,11,.12); stroke: #F59E0B; }

.graph-halo {
  fill: none;
  opacity: .16;
  stroke-width: 1.2;
}
.graph-halo.up { stroke: #10B981; }
.graph-halo.center { stroke: #06B6D4; }
.graph-halo.down { stroke: #F59E0B; }

.graph-node-title {
  fill: #f1f5f9;
  font-size: 14px;
  font-weight: 700;
}

.graph-node-sub {
  fill: #9fb3c8;
  font-size: 10px;
}

.graph-empty {
  text-align: center;
  padding: 90px 16px;
  color: #9fb3c8;
  font-size: 13px;
}

.graph-toolbar {
  position: absolute;
  z-index: 2;
  top: 10px;
  right: 10px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.graph-btn {
  border: 1px solid rgba(6,182,212,.35);
  background: rgba(8,15,28,.72);
  color: #d7f3ff;
  border-radius: 10px;
  padding: 6px 10px;
  font-size: 12px;
  cursor: pointer;
}

.graph-tip {
  color: #8aa0b7;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 999px;
  background: rgba(8,15,28,.58);
  border: 1px solid rgba(148,163,184,.16);
}

/* ===== SVG 图表 ===== */
.graph-shell::before {
  content: '';
  display: block;
}

@keyframes dash {
  to { stroke-dashoffset: -180; }
}

/* ===== 血缘合并表格 ===== */
.field-lineage-panel {
  border: 1px solid #e8edf3;
  border-radius: 10px;
  padding: 12px;
  background: #f8fafc;
  overflow: hidden;
}

.json-action-bar {
  margin-top: 12px;
  border-top: 1px solid #f0f0f0;
  padding-top: 10px;
  display: flex;
  justify-content: flex-start;
}

.raw-json-dialog {
  max-height: 72vh;
  overflow: auto;
  margin: 0;
  padding: 14px;
  border-radius: 8px;
  background: #0f172a;
  color: #dbeafe;
  font-size: 12px;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-word;
}

:deep(.lineage-compact-table .el-table__header th) {
  padding: 8px 8px !important;
  font-size: 12px;
}

:deep(.lineage-compact-table .el-table__body td) {
  padding: 7px 8px !important;
  font-size: 12px;
  line-height: 1.35;
}

:deep(.lineage-compact-table .el-table__cell) {
  padding: 7px 8px !important;
}

:deep(.lineage-merged-table) {
  border-collapse: collapse !important;
  width: 100%;
}

:deep(.lineage-merged-table .el-table__header) {
  background: linear-gradient(90deg, #f0f7ff 0%, #f6ffed 100%);
}

:deep(.lineage-merged-table .el-table__header th) {
  background: transparent !important;
  color: #1f2937 !important;
  font-weight: 700 !important;
  border-bottom: 2px solid #d9d9d9 !important;
  padding: 8px 8px !important;
  font-size: 12px;
}

:deep(.lineage-merged-table .el-table__body) {
  background: #fff;
}

:deep(.lineage-merged-table .el-table__body tr) {
  transition: all 0.2s ease;
}

:deep(.lineage-merged-table .el-table__body tr:hover) {
  background-color: #fafafa !important;
}

:deep(.lineage-merged-table .el-table__body td) {
  border-bottom: 1px solid #f0f0f0 !important;
  padding: 8px 8px !important;
  color: #595959;
  font-size: 12px;
  line-height: 1.45;
  vertical-align: top;
}

:deep(.lineage-merged-table .el-table__body tr:last-child td) {
  border-bottom: none !important;
}

:deep(.lineage-merged-table .el-table__cell) {
  vertical-align: middle;
  padding: 7px 8px;
}

.flow-arrow-icon {
  font-size: 20px;
  font-weight: 700;
  animation: arrow-pulse 1.5s ease-in-out infinite;
}

.flow-arrow-icon.upstream {
  color: #52c41a;
  text-shadow: 0 0 8px rgba(82, 196, 26, 0.3);
}

.flow-arrow-icon.downstream {
  color: #faad14;
  text-shadow: 0 0 8px rgba(250, 173, 20, 0.3);
}

@keyframes arrow-pulse {
  0%, 100% {
    opacity: 1;
    transform: translateX(0);
  }
  50% {
    opacity: 0.5;
    transform: translateX(4px);
  }
}

.field-badge {
  display: inline-flex;
  align-items: center;
  max-width: 100%;
  padding: 3px 8px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 600;
  word-break: break-all;
  line-height: 1.5;
  background: rgba(24, 144, 255, 0.08);
  color: #0050b3;
  border: 1px solid rgba(24, 144, 255, 0.22);
}

.field-badge.upstream {
  background: rgba(82, 196, 26, 0.1);
  color: #274e2b;
  border-color: rgba(82, 196, 26, 0.28);
}

.field-badge.downstream {
  background: rgba(250, 173, 20, 0.1);
  color: #5c4a1a;
  border-color: rgba(250, 173, 20, 0.32);
}

.field-chip-group {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  max-width: 100%;
}

.target-field {
  display: inline-block;
  color: #1f2937;
  font-weight: 700;
  word-break: break-all;
}

.expr-text {
  display: block;
  color: #4b5563;
  font-family: 'JetBrains Mono', Consolas, monospace;
  font-size: 11px;
  line-height: 1.55;
  white-space: normal;
  word-break: break-word;
}

</style>
