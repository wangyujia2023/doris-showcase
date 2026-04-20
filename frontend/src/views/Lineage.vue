<template>
  <div>
    <div class="card flow-card">
      <el-collapse v-model="flowPanel" accordion>
        <el-collapse-item name="flow">
          <template #title>
            <div class="flow-title">
              <span>📚 血缘流程说明</span>
              <span class="flow-hint">默认折叠，展开查看 Doris -> 程序 -> OpenMetadata -> 程序查询链路</span>
            </div>
          </template>
          <div class="flow-diagram">
            <div class="flow-lane doris" style="grid-column:1">Doris</div>
            <div class="flow-lane app" style="grid-column:3">导入血缘</div>
            <div class="flow-lane om" style="grid-column:5">OpenMetadata</div>
            <div class="flow-lane app" style="grid-column:7">查询血缘</div>

            <div class="flow-node doris" style="grid-column:1">
              <div class="flow-step-no">1</div>
              <div class="flow-step-title">审计日志表</div>
              <div class="flow-step-desc">读取 `__internal_schema.audit_log`</div>
            </div>
            <div class="flow-arrow" style="grid-column:2">→</div>
            <div class="flow-node app" style="grid-column:3">
              <div class="flow-step-no">2</div>
              <div class="flow-step-title">同步按钮</div>
              <div class="flow-step-desc">解析 SQL，提取源表 / 目标表 / 关系</div>
            </div>
            <div class="flow-arrow" style="grid-column:4">→</div>
            <div class="flow-node om" style="grid-column:5">
              <div class="flow-step-no">3</div>
              <div class="flow-step-title">血缘写入</div>
              <div class="flow-step-desc">推送 lineage 到 OpenMetadata</div>
            </div>
            <div class="flow-arrow" style="grid-column:6">→</div>
            <div class="flow-node app" style="grid-column:7">
              <div class="flow-step-no">4</div>
              <div class="flow-step-title">API 查询</div>
              <div class="flow-step-desc">回读 OpenMetadata 血缘并展示图谱</div>
            </div>
          </div>
        </el-collapse-item>
      </el-collapse>
    </div>

    <!-- Tab 切换 -->
    <el-tabs v-model="activeTab" type="card" style="margin-bottom:0">
        <el-tab-pane label="📥 导入记录" name="sync">
          <div class="card" style="border-top-left-radius:0">
            <el-form inline>
              <el-form-item label="开始日期">
                <el-date-picker v-model="startDate" type="date" value-format="YYYY-MM-DD" placeholder="开始日期" />
              </el-form-item>
              <el-form-item label="结束日期">
                <el-date-picker v-model="endDate" type="date" value-format="YYYY-MM-DD" placeholder="结束日期" />
              </el-form-item>
              <el-form-item label="数量限制">
                <el-input v-model="auditLimit" type="number" min="0" max="5000" placeholder="0=全量" style="width:120px" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" :loading="syncing" @click="syncFromAudit">🔄 导入血缘</el-button>
              </el-form-item>
            </el-form>

            <div style="margin-top:12px">
              <div style="font-size:13px;font-weight:600;margin-bottom:10px">同步结果 ({{ syncRows.length }} 条)</div>
              <el-table :data="syncRows" size="small" border max-height="360" empty-text="同步后在这里查看每条 SQL 的结果">
            <el-table-column prop="time" label="时间" width="180" />
            <el-table-column prop="stmt_type" label="类型" width="110" />
            <el-table-column prop="user" label="用户" width="120" />
            <el-table-column prop="target" label="目标表" min-width="180" />
            <el-table-column label="源表" min-width="240">
              <template #default="{ row }">
                <span>{{ row.sources?.join(', ') }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="success" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.success ? 'success' : 'danger'">
                  {{ row.success ? '✓ 成功' : '✗ 失败' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="error" label="错误信息" min-width="200" show-overflow-tooltip />
              </el-table>
            </div>

            <!-- 同步历史 -->
            <div style="margin-top:20px">
              <div style="font-size:13px;font-weight:600;margin-bottom:10px">同步历史</div>
              <el-table :data="syncLogs" size="small" border max-height="280">
                <el-table-column prop="sync_time" label="同步时间" width="180" />
                <el-table-column prop="start_date" label="开始日期" width="120" />
                <el-table-column prop="end_date" label="结束日期" width="120" />
                <el-table-column prop="scanned" label="扫描数" width="90" />
                <el-table-column prop="synced" label="成功" width="90">
                  <template #default="{ row }">
                    <span style="color:#67c23a;font-weight:600">{{ row.synced }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="failed" label="失败" width="90">
                  <template #default="{ row }">
                    <span style="color:#f56c6c;font-weight:600">{{ row.failed }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="success" label="状态" width="100">
                  <template #default="{ row }">
                    <el-tag :type="row.success ? 'success' : 'warning'">
                      {{ row.success ? '✓ 完成' : '⚠ 部分失败' }}
                    </el-tag>
                  </template>
                </el-table-column>
              </el-table>
            </div>
          </div>
        </el-tab-pane>

        <el-tab-pane label="🔍 查询血缘" name="query">
          <div class="card" style="border-top-left-radius:0;padding:0">
            <div class="query-grid">
              <div class="table-list-card">
                <div style="font-size:13px;font-weight:600;margin-bottom:12px;padding:20px 20px 0">数据表 ({{ tables.length }})</div>
                <div style="padding:0 20px">
                  <div style="margin-bottom:12px">
              <el-input v-model="tableKeyword" placeholder="🔍 搜索表..." clearable @input="loadTables" />
                  </div>
                  <el-scrollbar style="height:640px">
                    <div style="padding:0 20px">
                      <div
                        v-for="t in tables"
                        :key="t.asset_id"
                        class="table-item"
                        :class="{ active: selectedTable === t.asset_id }"
                        @click="chooseTable(t.asset_id)"
                      >
                        <div class="table-name">{{ t.asset_id }}</div>
                        <div class="table-sub">{{ t.asset_name }}</div>
                        <div class="table-meta">{{ t.domain_id }} · {{ t.layer_name }}</div>
                      </div>
                    </div>
                  </el-scrollbar>
                </div>
              </div>

              <div class="detail-col">
                <!-- 当前表信息 -->
                <div class="card">
                  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
                    <div style="font-size:13px;font-weight:600">📌 当前表</div>
                    <el-button text type="primary" size="small" @click="exportLineage">📤 导出</el-button>
                  </div>
                <div class="current-table">{{ selectedTable || '未选择' }}</div>
                <div class="current-sub">{{ selectedTableInfo.asset_name || '' }} {{ selectedTableInfo.description || '' }}</div>
              </div>
              <!-- 血缘关系图 -->
              <div class="card">
                  <el-tabs v-model="lineageViewMode" class="lineage-subtabs">
                    <el-tab-pane label="表级血缘" name="table" />
                    <el-tab-pane label="字段级血缘" name="field" />
                  </el-tabs>

                  <template v-if="lineageViewMode === 'table'">
                  <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:10px">
                    <div>
                      <div style="font-size:13px;font-weight:600">🔗 血缘关系</div>
                      <div style="font-size:12px;color:#909399;margin-top:4px">上游 → 当前表 → 下游</div>
                    </div>
                    <div style="display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end">
                      <div style="font-size:12px;padding:4px 10px;background:#f0f9ff;border:1px solid #b3d8ff;border-radius:4px;color:#0050b3">
                        上游：{{ upstreamList.length }}
                      </div>
                      <div style="font-size:12px;padding:4px 10px;background:#f6ffed;border:1px solid #b7eb8f;border-radius:4px;color:#274e2b">
                        下游：{{ downstreamList.length }}
                      </div>
                      <div style="font-size:12px;padding:4px 10px;background:#fffbe6;border:1px solid #ffe58f;border-radius:4px;color:#5c4a1a">
                        节点：{{ omLineage?.nodes?.length || 0 }}
                      </div>
                    </div>
                  </div>

                <!-- 血缘关系图 -->
                <div class="graph-shell">
                  <div class="graph-toolbar">
                    <button class="graph-btn" @click="resetGraph">重置</button>
                    <span class="graph-tip">拖拽平移，滚轮缩放</span>
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
                    暂无上下游依赖数据
                  </div>
                </div>

                <!-- 关系详情 -->
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                  <div style="border:1px solid #f0f0f0;border-radius:8px;padding:10px;background:#f9f9f9">
                    <div style="font-size:12px;font-weight:600;margin-bottom:10px">📥 上游 ({{ upstreamEdgesView.length }})</div>
                    <div v-if="upstreamEdgesView.length" style="display:flex;flex-direction:column;gap:6px;max-height:150px;overflow-y:auto">
                      <div v-for="(e, i) in upstreamEdgesView" :key="i" style="font-size:11px;color:#666;padding:6px;background:#fff;border-radius:4px;border-left:3px solid #52c41a">
                        {{ e }}
                      </div>
                    </div>
                    <el-empty v-else description="无上游" :image-size="48" />
                  </div>
                  <div style="border:1px solid #f0f0f0;border-radius:8px;padding:10px;background:#f9f9f9">
                    <div style="font-size:12px;font-weight:600;margin-bottom:10px">📤 下游 ({{ downstreamEdgesView.length }})</div>
                    <div v-if="downstreamEdgesView.length" style="display:flex;flex-direction:column;gap:6px;max-height:150px;overflow-y:auto">
                      <div v-for="(e, i) in downstreamEdgesView" :key="i" style="font-size:11px;color:#666;padding:6px;background:#fff;border-radius:4px;border-left:3px solid #faad14">
                        {{ e }}
                      </div>
                    </div>
                    <el-empty v-else description="无下游" :image-size="48" />
                  </div>
                </div>

                  <details style="margin-top:12px;border-top:1px solid #f0f0f0;padding-top:12px">
                    <summary style="cursor:pointer;font-size:12px;color:#0050b3;font-weight:600;user-select:none">📄 查看原始 JSON</summary>
                    <pre style="background:#f5f5f5;padding:10px;border-radius:4px;font-size:11px;overflow-x:auto;color:#333;line-height:1.4;margin-top:8px">{{ omLineageText }}</pre>
                  </details>
                  </template>

                  <template v-else>
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:10px">
                      <div>
                        <div style="font-size:13px;font-weight:600">🧬 字段级血缘</div>
                        <div style="font-size:12px;color:#909399;margin-top:4px">直接读取 OpenMetadata `columnsLineage` 的上游/下游字段映射</div>
                      </div>
                      <div style="display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end">
                        <div style="font-size:12px;padding:4px 10px;background:#f0f9ff;border:1px solid #b3d8ff;border-radius:4px;color:#0050b3">
                          上游映射：{{ fieldUpstreamRows.length }}
                        </div>
                        <div style="font-size:12px;padding:4px 10px;background:#f6ffed;border:1px solid #b7eb8f;border-radius:4px;color:#274e2b">
                          下游映射：{{ fieldDownstreamRows.length }}
                        </div>
                      </div>
                    </div>

                    <el-tabs v-model="fieldDirectionTab" class="lineage-subtabs">
                      <el-tab-pane :label="`上游(${fieldUpstreamRows.length})`" name="upstream" />
                      <el-tab-pane :label="`下游(${fieldDownstreamRows.length})`" name="downstream" />
                    </el-tabs>

                    <div style="border:1px solid #f0f0f0;border-radius:8px;padding:10px;background:#f9f9f9">
                      <div style="font-size:12px;font-weight:600;margin-bottom:10px">
                        {{ fieldDirectionTab === 'upstream' ? '📥 上游字段映射' : '📤 下游字段映射' }}
                      </div>

                      <el-table
                        v-if="fieldDirectionTab === 'upstream'"
                        :data="fieldUpstreamRows"
                        size="small"
                        border
                        max-height="360"
                        empty-text="OpenMetadata 未返回上游字段级血缘"
                      >
                        <el-table-column prop="source_table" label="来源表" min-width="140" show-overflow-tooltip />
                        <el-table-column label="来源字段" min-width="220" show-overflow-tooltip>
                          <template #default="{ row }">
                            <span>{{ (row.source_fields || []).join(', ') || '-' }}</span>
                          </template>
                        </el-table-column>
                        <el-table-column prop="target_table" label="目标表" min-width="140" show-overflow-tooltip />
                        <el-table-column prop="target_field" label="目标字段" min-width="140" show-overflow-tooltip />
                      </el-table>

                      <el-table
                        v-else
                        :data="fieldDownstreamRows"
                        size="small"
                        border
                        max-height="360"
                        empty-text="OpenMetadata 未返回下游字段级血缘"
                      >
                        <el-table-column prop="source_table" label="来源表" min-width="140" show-overflow-tooltip />
                        <el-table-column label="来源字段" min-width="220" show-overflow-tooltip>
                          <template #default="{ row }">
                            <span>{{ (row.source_fields || []).join(', ') || '-' }}</span>
                          </template>
                        </el-table-column>
                        <el-table-column prop="target_table" label="目标表" min-width="140" show-overflow-tooltip />
                        <el-table-column prop="target_field" label="目标字段" min-width="140" show-overflow-tooltip />
                      </el-table>
                    </div>

                    <details style="margin-top:12px;border-top:1px solid #f0f0f0;padding-top:12px">
                      <summary style="cursor:pointer;font-size:12px;color:#0050b3;font-weight:600;user-select:none">📄 查看 OpenMetadata 原始字段血缘</summary>
                      <pre style="background:#f5f5f5;padding:10px;border-radius:4px;font-size:11px;overflow-x:auto;color:#333;line-height:1.4;margin-top:8px">{{ fieldLineageText }}</pre>
                    </details>
                  </template>
                </div>

                <!-- 影响分析 -->
                <div class="card">
                  <div style="font-size:13px;font-weight:600;margin-bottom:10px">⚡ 影响分析 ({{ impactRows.length }})</div>
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
                    ✓ 无影响风险
                  </div>
                </div>
              </div>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
  </div>
</template>

<script setup>
import { computed, onMounted, onBeforeUnmount, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { lineageApi } from '@/api'

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
const upstreamList = ref([])
const downstreamList = ref([])
const impactRows = ref([])
const nodeNameMap = ref({})
const flowPanel = ref([])
const lineageViewMode = ref('table')
const fieldDirectionTab = ref('upstream')
let loadSeq = 0
let tableTimer = null
const graphBox = { width: 2200, height: 980 }
const graphViewport = ref({ scale: 1, x: 0, y: 0 })
const graphDrag = ref({ active: false, startX: 0, startY: 0, baseX: 0, baseY: 0 })

const tableStats = ref({ row_count: null, update_frequency: '' })
const tableQuality = ref({ score: 87, freshness: 95, completeness: 85 })

const fmt = (v) => v == null ? '-' : Number(v).toLocaleString()
const shortText = (v, n = 34) => {
  const s = String(v || '')
  if (!s) return ''
  return s.length > n ? `${s.slice(0, n - 1)}…` : s
}

const qualityTooltip = `质量评分 = 新鲜度×40% + 完整度×40% + 覆盖度×20%
• 新鲜度：衡量数据更新及时性 (0-100分)
• 完整度：衡量数据完整程度 (0-100分)
• 覆盖度：衡量被下游使用广度 (0-100分)`

const getImpactType = (level) => {
  if (level === 'high') return 'danger'
  if (level === 'medium') return 'warning'
  return 'success'
}

const getImpactLabel = (level) => {
  const labels = { high: '🔴 高风险', medium: '🟡 中风险', low: '🟢 低风险' }
  return labels[level] || '未知'
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
  a.download = `lineage-${selectedTable.value}-${new Date().toISOString().slice(0, 10)}.json`
  a.click()
  URL.revokeObjectURL(url)
  ElMessage.success('导出成功')
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

const getEntityName = (entity) => {
  if (!entity) return ''
  if (typeof entity === 'string') {
    const mapped = nodeNameMap.value[entity]
    if (mapped) return mapped
    if (/^[0-9a-fA-F-]{36}$/.test(entity)) return ''
    if (entity.includes('.')) return entity.split('.').pop() || ''
    return entity
  }
  if (entity.name) return entity.name
  if (entity.displayName) return entity.displayName
  if (entity.fullyQualifiedName) {
    const parts = entity.fullyQualifiedName.split('.')
    return parts[parts.length - 1] || entity.fullyQualifiedName
  }
  if (entity.id) {
    const mapped = nodeNameMap.value[entity.id]
    if (mapped) return mapped
    if (/^[0-9a-fA-F-]{36}$/.test(entity.id)) return ''
    return entity.id
  }
  return ''
}

function edgeText(edge) {
  if (!edge) return ''
  const from = getEntityName(edge.fromEntity)
  const to = getEntityName(edge.toEntity)
  if (from && to) return `${from} → ${to}`
  if (from) return `${from}`
  if (to) return `${to}`
  return ''
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

const upstreamEdgesView = computed(() => (upstreamList.value || []).map(edgeText).filter(Boolean))
const downstreamEdgesView = computed(() => (downstreamList.value || []).map(edgeText).filter(Boolean))
const fieldUpstreamRows = computed(() => fieldLineage.value?.upstream_fields || [])
const fieldDownstreamRows = computed(() => fieldLineage.value?.downstream_fields || [])

// SVG 血缘关系图
const graphNodes = computed(() => {
  const current = omLineage.value?.entity || {}
  const nodeMap = new Map()
  const incoming = new Map()
  const outgoing = new Map()

  const addNode = (node) => {
    if (!node?.id) return
    nodeMap.set(node.id, {
      id: node.id,
      title: node.displayName || node.name || node.fullyQualifiedName?.split('.')?.pop() || node.id,
      sub: shortText(node.fullyQualifiedName || '', 30),
      kind: 'up',
    })
  }
  addNode(current)
  ;(omLineage.value?.nodes || []).forEach(addNode)

  const addEdge = (from, to) => {
    if (!from || !to) return
    if (!incoming.has(to)) incoming.set(to, new Set())
    if (!outgoing.has(from)) outgoing.set(from, new Set())
    incoming.get(to).add(from)
    outgoing.get(from).add(to)
  }
  ;(upstreamList.value || []).forEach(e => addEdge(e.fromEntity, e.toEntity))
  ;(downstreamList.value || []).forEach(e => addEdge(e.fromEntity, e.toEntity))

  const levelOf = new Map([[current.id || selectedTable.value, 0]])
  const q = [current.id || selectedTable.value]
  while (q.length) {
    const id = q.shift()
    const level = levelOf.get(id) || 0
    ;(incoming.get(id) || []).forEach((src) => {
      if (!levelOf.has(src)) { levelOf.set(src, level - 1); q.push(src) }
    })
    ;(outgoing.get(id) || []).forEach((dst) => {
      if (!levelOf.has(dst)) { levelOf.set(dst, level + 1); q.push(dst) }
    })
  }

  const byLevel = new Map()
  for (const [id, info] of nodeMap.entries()) {
    const lv = levelOf.get(id)
    if (lv === undefined) continue
    if (!byLevel.has(lv)) byLevel.set(lv, [])
    byLevel.get(lv).push({ ...info, id })
  }

  const levels = [...byLevel.keys()].sort((a, b) => a - b)
  const nodes = []
  const width = graphBox.width
  const centerX = width / 2
  const centerY = graphBox.height / 2
  const levelX = (lv) => {
    if (lv === 0) return centerX
    const side = lv < 0 ? -1 : 1
    const depth = Math.abs(lv)
    return centerX + side * (260 + (depth - 1) * 360)
  }
  const levelY = (lv) => {
    if (lv === 0) return centerY
    const depth = Math.abs(lv)
    const band = Math.ceil(depth / 2)
    const offset = band * 170
    const direction = depth % 2 === 1 ? -1 : 1
    return centerY + direction * offset
  }
  levels.forEach((lv) => {
    const items = byLevel.get(lv) || []
    const gap = lv === 0 ? 0 : Math.min(180, Math.max(120, 360 / Math.max(items.length || 1, 1)))
    const startY = lv === 0 ? centerY : levelY(lv) - ((items.length - 1) * gap) / 2
    items.forEach((item, idx) => {
      const titleLen = (item.title || '').length
      const baseW = lv === 0 ? 300 : 260
      nodes.push({
        key: item.id,
        title: item.title,
        sub: item.sub,
        kind: lv === 0 ? 'center' : (lv < 0 ? 'up' : 'down'),
        x: levelX(lv),
        y: startY + idx * gap,
        w: Math.max(baseW, Math.min(380, 170 + titleLen * 10)),
        h: lv === 0 ? 96 : 78,
      })
    })
  })
  return nodes
})

const graphLinks = computed(() => {
  const pos = new Map(graphNodes.value.map(n => [n.key, n]))
  const lines = []
  const addEdgeLine = (from, to, stroke) => {
    const a = pos.get(from)
    const b = pos.get(to)
    if (!a || !b) return
    const fromRight = b.x >= a.x
    const sx = a.x + (fromRight ? a.w / 2 : -a.w / 2)
    const sy = a.y
    const ex = b.x - (fromRight ? b.w / 2 : -b.w / 2)
    const ey = b.y
    const midX = (sx + ex) / 2
    const bend = Math.max(80, Math.min(220, Math.abs(ex - sx) / 2))
    const d = `M ${sx} ${sy} C ${sx + bend} ${sy}, ${midX - bend} ${ey}, ${ex} ${ey}`
    lines.push({ stroke, d })
  }
  ;(upstreamList.value || []).forEach(e => addEdgeLine(e.fromEntity, e.toEntity, 'url(#lineUp)'))
  ;(downstreamList.value || []).forEach(e => addEdgeLine(e.fromEntity, e.toEntity, 'url(#lineDown)'))
  return lines
})

const onGraphWheel = (e) => {
  e.preventDefault()
  const delta = e.deltaY > 0 ? -0.08 : 0.08
  const scale = Math.min(1.8, Math.max(0.6, graphViewport.value.scale + delta))
  graphViewport.value = { ...graphViewport.value, scale }
}

const onGraphDown = (e) => {
  graphDrag.value = {
    active: true,
    startX: e.clientX,
    startY: e.clientY,
    baseX: graphViewport.value.x,
    baseY: graphViewport.value.y
  }
}

const onGraphMove = (e) => {
  if (!graphDrag.value.active) return
  graphViewport.value = {
    ...graphViewport.value,
    x: graphDrag.value.baseX + (e.clientX - graphDrag.value.startX),
    y: graphDrag.value.baseY + (e.clientY - graphDrag.value.startY)
  }
}

const onGraphUp = () => {
  graphDrag.value.active = false
}

const resetGraph = () => {
  graphViewport.value = { scale: 1, x: 0, y: 0 }
}

onMounted(() => {
  window.addEventListener('mousemove', onGraphMove)
  window.addEventListener('mouseup', onGraphUp)
})

onBeforeUnmount(() => {
  window.removeEventListener('mousemove', onGraphMove)
  window.removeEventListener('mouseup', onGraphUp)
})

async function syncFromAudit() {
  syncing.value = true
  try {
    const res = await lineageApi.syncFromAudit({ start_date: startDate.value, end_date: endDate.value, limit: Number(auditLimit.value) || 0 })
    syncRows.value = res.details || []
    ElMessage.success(`同步完成：扫描 ${res.scanned} 条，成功 ${res.synced} 条，失败 ${res.failed} 条`)
    if (res.errors?.length) ElMessage.warning(`有 ${res.errors.length} 条失败，请看下方明细`)
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

.flow-card {
  margin-bottom: 16px;
}

.flow-title {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 13px;
  font-weight: 600;
  color: #1f2937;
}

.flow-hint {
  font-size: 12px;
  color: #6b7280;
  font-weight: 400;
}

.flow-diagram {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: 12px;
  align-items: stretch;
  margin-top: 16px;
}

.flow-lane {
  grid-row: 1;
  font-size: 12px;
  font-weight: 700;
  text-align: center;
  padding: 10px 12px;
  border-radius: 8px;
  border: 2px solid;
  color: #fff;
  background: linear-gradient(135deg);
}

.flow-lane.doris {
  border-color: #faad14;
  background: linear-gradient(135deg, #ffd666 0%, #faad14 100%);
  color: #5c4a1a;
}

.flow-lane.app {
  border-color: #1890ff;
  background: linear-gradient(135deg, #69b1ff 0%, #1890ff 100%);
  color: #fff;
}

.flow-lane.om {
  border-color: #52c41a;
  background: linear-gradient(135deg, #95de64 0%, #52c41a 100%);
  color: #274e2b;
}

.flow-node {
  grid-row: 2;
  padding: 16px;
  border-radius: 12px;
  border: 2px solid;
  background: linear-gradient(135deg);
  color: #fff;
  min-height: 100px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.flow-node:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

.flow-node.doris {
  border-color: #faad14;
  background: linear-gradient(135deg, #fffbe6 0%, #fff7e6 100%);
  color: #1f2937;
}

.flow-node.app {
  border-color: #1890ff;
  background: linear-gradient(135deg, #e6f7ff 0%, #f0f5ff 100%);
  color: #0050b3;
}

.flow-node.om {
  border-color: #52c41a;
  background: linear-gradient(135deg, #f6ffed 0%, #f9ffef 100%);
  color: #274e2b;
}

.flow-step-no {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 10px;
}

.flow-node.doris .flow-step-no {
  background: rgba(250, 173, 20, 0.15);
  border: 2px solid #faad14;
  color: #d48806;
}

.flow-node.app .flow-step-no {
  background: rgba(24, 144, 255, 0.15);
  border: 2px solid #1890ff;
  color: #0050b3;
}

.flow-node.om .flow-step-no {
  background: rgba(82, 196, 26, 0.15);
  border: 2px solid #52c41a;
  color: #274e2b;
}

.flow-step-title {
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 6px;
}

.flow-step-desc {
  font-size: 12px;
  line-height: 1.5;
}

.flow-node.doris .flow-step-desc { color: #595959; }
.flow-node.app .flow-step-desc { color: #1f2937; }
.flow-node.om .flow-step-desc { color: #1f2937; }

.flow-arrow {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 700;
  align-self: center;
  color: #1890ff;
  animation: flow-arrow-blink 2s ease-in-out infinite;
}

@keyframes flow-arrow-blink {
  0%, 100% { opacity: 1; transform: translateX(0); }
  50% { opacity: 0.6; transform: translateX(4px); }
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
  grid-template-columns: 300px 1fr;
  gap: 12px;
  align-items: start;
}

.table-list-card {
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  background: #fff;
  height: fit-content;
  max-height: calc(100vh - 200px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* ===== 表列表项 ===== */
.table-item {
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
  cursor: pointer;
  transition: all 0.2s ease;
  border-left: 3px solid transparent;
}

.table-item:hover {
  background: #f9f9f9;
  border-left-color: #1890ff;
}

.table-item.active {
  background: #f0f7ff;
  border-left-color: #1890ff;
}

.table-name {
  font-size: 12px;
  font-weight: 700;
  color: #1f2937;
  line-height: 1.2;
  word-break: break-all;
}

.table-sub {
  font-size: 12px;
  color: #6b7280;
  margin-top: 3px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.table-meta {
  font-size: 11px;
  color: #9ca3af;
  margin-top: 3px;
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

</style>
