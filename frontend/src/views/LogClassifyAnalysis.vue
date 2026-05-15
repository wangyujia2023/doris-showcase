<template>
  <div>

    <!-- ═══ AI_CLASSIFY 核心展示区 ═══ -->
    <div class="card showcase-card">
      <div class="showcase-header">
        <div>
          <div class="showcase-title">{{ t('title') }}</div>
          <div class="showcase-sub">{{ t('subtitle') }}</div>
        </div>
        <div class="showcase-actions">
          <el-button
            type="primary"
            size="large"
            :loading="classifying"
            :icon="MagicStick"
            @click="runClassify"
          >{{ t('run') }}</el-button>
          <el-button size="large" @click="reloadAll">{{ t('common.refresh') }}</el-button>
        </div>
      </div>

      <!-- SQL 展示（默认折叠） -->
      <div class="sql-showcase">
        <div class="sql-label" @click="sqlExpanded = !sqlExpanded" style="cursor:pointer;user-select:none">
          <el-tag type="success" effect="dark" size="small">{{ t('sql') }}</el-tag>
          <span style="margin-left:8px;color:#67c23a;font-size:12px">{{ t('sqlHint') }}</span>
          <span style="margin-left:auto;color:#67c23a;font-size:12px">{{ sqlExpanded ? t('common.collapse') : t('common.expand') }}</span>
        </div>
        <div v-if="!sqlExpanded" class="sql-collapsed" @click="sqlExpanded = true">
          <span class="sql-collapsed-hint">UPDATE user_wide SET log_tags = AI_CLASSIFY('llm_resource', CONCAT(...), ARRAY[...])  </span>
          <el-link type="success" :underline="false" style="font-size:12px">{{ t('expandSql') }}</el-link>
        </div>
        <pre v-else class="sql-code">{{ showcaseSQL }}</pre>
      </div>

      <!-- 执行结果 -->
      <div v-if="classifyResult" class="classify-result">
        <el-alert
          :title="t('done', [classifyResult.total, classifyResult.tagged])"
          type="success"
          :closable="false"
          show-icon
        >
          <template #default>
            <div style="margin-top:8px">
              <span style="color:#606266;font-size:13px">{{ t('samples') }}：</span>
              <el-tag
                v-for="s in classifyResult.samples" :key="s.user_id"
                style="margin:2px 4px"
                effect="plain"
              >{{ t('userTag', [s.user_id, joinTags(s.tags)]) }}</el-tag>
            </div>
          </template>
        </el-alert>
      </div>

      <!-- 状态指示 -->
      <div class="flow-row">
        <div class="flow-step">
          <div class="flow-icon" style="background:#e8f4ff;color:#409eff">
            <el-icon size="22"><DataBoard /></el-icon>
          </div>
          <div class="flow-text">
            <div class="flow-title">{{ t('flowLog') }}</div>
            <div class="flow-desc">asset_level / aum / active_level</div>
          </div>
        </div>
        <div class="flow-arrow">→</div>
        <div class="flow-step">
          <div class="flow-icon" style="background:#f0f9eb;color:#67c23a">
            <el-icon size="22"><Cpu /></el-icon>
          </div>
          <div class="flow-text">
            <div class="flow-title">AI_CLASSIFY()</div>
            <div class="flow-desc">{{ t('flowAi') }}</div>
          </div>
        </div>
        <div class="flow-arrow">→</div>
        <div class="flow-step">
          <div class="flow-icon" style="background:#fff8e6;color:#e6a23c">
            <el-icon size="22"><Finished /></el-icon>
          </div>
          <div class="flow-text">
            <div class="flow-title">{{ t('flowWriteback') }}</div>
            <div class="flow-desc">{{ t('flowWritebackDesc') }}</div>
          </div>
        </div>
        <div class="flow-arrow">→</div>
        <div class="flow-step">
          <div class="flow-icon" style="background:#fef0f0;color:#f56c6c">
            <el-icon size="22"><TrendCharts /></el-icon>
          </div>
          <div class="flow-text">
            <div class="flow-title">{{ t('flowAnalysis') }}</div>
            <div class="flow-desc">{{ t('flowAnalysisDesc') }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 顶部统计 -->
    <div class="stat-row">
      <div class="stat-card">
        <div class="stat-label">{{ t('totalUsers') }}</div>
        <div class="stat-value" style="color:#409eff">{{ fmt(summary.total_users) }}</div>
        <div class="stat-sub">{{ t('allUsers') }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">{{ t('taggedUsers') }}</div>
        <div class="stat-value" style="color:#67c23a">{{ fmt(summary.tagged_users) }}</div>
        <div class="stat-sub">{{ t('coverPct', [coverPct]) }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">{{ t('riskUsers') }}</div>
        <div class="stat-value" style="color:#f56c6c">{{ fmt(summary.risk_users) }}</div>
        <div class="stat-sub">{{ t('riskHint') }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">{{ t('tagKinds') }}</div>
        <div class="stat-value" style="color:#e6a23c">{{ tagDist.length }}</div>
        <div class="stat-sub">{{ t('coverCats', [tagCategories.length]) }}</div>
      </div>
    </div>

    <!-- ═══ 分析 Tab ═══ -->
    <el-tabs v-model="activeTab" type="card" style="margin-bottom:0">
      <el-tab-pane :label="t('logClassify.tabDist')" name="dist" />
      <el-tab-pane :label="t('logClassify.tabRisk')" name="risk" />
      <el-tab-pane :label="t('logClassify.tabCross')" name="cross" />
      <el-tab-pane :label="t('logClassify.tabCooc')" name="cooc" />
      <el-tab-pane :label="t('logClassify.tabUsers')" name="users" />
    </el-tabs>

    <!-- ─── {{ t('logClassify.tabDist') }} ─── -->
    <div v-if="activeTab === 'dist'" class="card" style="border-top-left-radius:0">
      <el-row :gutter="16">
        <el-col :span="10">
          <div class="card-title">{{ t('logClassify.coverUsers') }}</div>
          <v-chart :option="distBarOption" style="height:360px" autoresize />
        </el-col>
        <el-col :span="7">
          <div class="card-title">{{ t('logClassify.categoryRatio') }}</div>
          <v-chart :option="catPieOption" style="height:360px" autoresize />
        </el-col>
        <el-col :span="7">
          <div class="card-title">{{ t('logClassify.tagDetail') }}</div>
          <div class="tag-list">
            <div
              v-for="tag in tagDist" :key="tag.tag_name"
              class="tag-item"
              :class="{ risk: tag.is_risk }"
              @click="jumpToUsers(tag.tag_name)"
            >
              <div class="tag-dot" :style="{ background: tag.color }"></div>
              <div class="tag-info">
                <span class="tag-name">{{ tagText(tag.tag_name) }}</span>
                <span class="tag-cat">{{ categoryText(tag.category) }}</span>
              </div>
              <div class="tag-count">{{ tag.user_count }}<small>{{ t('logClassify.unitPerson') }}</small></div>
              <el-tag v-if="tag.is_risk" type="danger" size="small" effect="plain" style="margin-left:4px">{{ t('logClassify.risk') }}</el-tag>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- ─── {{ t('logClassify.tabRisk') }} ─── -->
    <div v-if="activeTab === 'risk'" class="card" style="border-top-left-radius:0">
      <div class="card-title">{{ t('logClassify.riskTitle') }}</div>
      <el-row :gutter="16">
        <el-col :span="14">
          <el-table :data="riskData" border stripe size="small">
            <el-table-column prop="tag_name" :label="t('logClassify.riskTag')" width="100">
              <template #default="{row}">
                <el-tag type="danger" size="small" effect="dark">{{ tagText(row.tag_name) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="total_users" :label="t('logClassify.users')" width="80" align="center" />
            <el-table-column prop="anomaly_users" :label="t('logClassify.anomalyUsers')" width="90" align="center">
              <template #default="{row}">
                <span style="color:#f56c6c;font-weight:600">{{ row.anomaly_users }}</span>
              </template>
            </el-table-column>
            <el-table-column :label="t('logClassify.anomalyRate')" width="140">
              <template #default="{row}">
                <el-progress
                  :percentage="row.total_users ? Math.round(row.anomaly_users * 100 / row.total_users) : 0"
                  :stroke-width="8"
                  :color="row.anomaly_users / row.total_users > 0.4 ? '#f56c6c' : '#e6a23c'"
                />
              </template>
            </el-table-column>
            <el-table-column prop="avg_aum" :label="t('logClassify.avgAum')" width="110" align="right">
              <template #default="{row}">{{ row.avg_aum.toFixed(1) }}</template>
            </el-table-column>
            <el-table-column prop="avg_churn_pct" :label="t('logClassify.avgChurn')" width="110" align="right">
              <template #default="{row}">
                <span :style="{color: row.avg_churn_pct > 30 ? '#f56c6c' : '#e6a23c', fontWeight:'600'}">
                  {{ row.avg_churn_pct }}%
                </span>
              </template>
            </el-table-column>
          </el-table>
        </el-col>
        <el-col :span="10">
          <v-chart :option="riskBarOption" style="height:300px" autoresize />
        </el-col>
      </el-row>
    </div>

    <!-- ─── {{ t('logClassify.tabCross') }} ─── -->
    <div v-if="activeTab === 'cross'" class="card" style="border-top-left-radius:0">
      <div class="card-title">{{ t('logClassify.crossTitle') }}</div>
      <div class="cross-grid">
        <div v-for="tag in crossData" :key="tag.tag_name" class="cross-item">
          <div class="cross-tag" :style="{ borderColor: tag.color, color: tag.color }">
            {{ tagText(tag.tag_name) }}
            <small>{{ categoryText(tag.category) }}</small>
          </div>
          <div class="cross-bars">
            <div v-for="d in tag.asset_dist" :key="d.level" class="cross-bar-row">
              <span class="cross-label">
                <el-tag :type="assetTagType(d.level)" size="small" style="font-size:10px">{{ assetText(d.level) }}</el-tag>
              </span>
              <el-progress
                :percentage="Math.min(d.cnt * 100, 100)"
                :stroke-width="10"
                :show-text="false"
                :color="tag.color"
                style="flex:1"
              />
              <span class="cross-cnt">{{ d.cnt }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ─── {{ t('logClassify.tabCooc') }} ─── -->
    <div v-if="activeTab === 'cooc'" class="card" style="border-top-left-radius:0">
      <div class="card-title">{{ t('logClassify.coocTitle') }}</div>
      <el-row :gutter="16">
        <el-col :span="12">
          <el-table :data="coocData" border size="small" stripe>
            <el-table-column type="index" width="40" />
            <el-table-column prop="tag_a" :label="t('logClassify.tagA')" width="110">
              <template #default="{row}">
                <el-tag size="small" effect="plain" :style="{borderColor: tagColor(row.tag_a), color: tagColor(row.tag_a)}">
                  {{ tagText(row.tag_a) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column :label="'+'" width="30" align="center">
              <template #default><b style="color:#c0c4cc">+</b></template>
            </el-table-column>
            <el-table-column prop="tag_b" :label="t('logClassify.tagB')" width="110">
              <template #default="{row}">
                <el-tag size="small" effect="plain" :style="{borderColor: tagColor(row.tag_b), color: tagColor(row.tag_b)}">
                  {{ tagText(row.tag_b) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="count" :label="t('logClassify.coocUsers')" align="center">
              <template #default="{row}">
                <el-tag type="primary" effect="dark" size="small">{{ row.count }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-col>
        <el-col :span="12">
          <v-chart :option="coocChordOption" style="height:360px" autoresize />
        </el-col>
      </el-row>
    </div>

    <!-- ─── {{ t('logClassify.tabUsers') }} ─── -->
    <div v-if="activeTab === 'users'" class="card" style="border-top-left-radius:0">
      <el-form inline style="margin-bottom:12px">
        <el-form-item :label="t('logClassify.filterTag')">
          <el-select v-model="userFilter.tag_name" clearable :placeholder="t('logClassify.allTags')" style="width:130px" @change="loadUsers">
            <el-option v-for="tag in tagDist" :key="tag.tag_name" :label="tagText(tag.tag_name)" :value="tag.tag_name">
              <span :style="{color: tag.color}">● </span>{{ tagText(tag.tag_name) }}
              <span style="color:#c0c4cc;margin-left:4px">({{ tag.user_count }}{{ t('logClassify.unitPerson') }})</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="t('logClassify.onlyRisk')">
          <el-switch v-model="userFilter.onlyRisk" @change="loadUsers" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadUsers">{{ t('common.search') }}</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="userRows" v-loading="userLoading" border size="small" stripe>
        <el-table-column prop="user_id"        :label="t('logClassify.userId')"  width="80" />
        <el-table-column prop="user_name"      :label="t('logClassify.name')"    width="72" />
        <el-table-column prop="age_group"      :label="t('logClassify.ageGroup')"  width="72" />
        <el-table-column prop="city"           :label="t('logClassify.city')"    width="65" />
        <el-table-column prop="asset_level"    :label="t('logClassify.assetLevel')" width="90">
          <template #default="{row}">
            <el-tag :type="assetTagType(row.asset_level)" size="small">{{ assetText(row.asset_level) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="aum_total"      :label="t('logClassify.aum')" width="85" align="right">
          <template #default="{row}">{{ row.aum_total.toFixed(1) }}</template>
        </el-table-column>
        <el-table-column prop="active_level"   :label="t('logClassify.active')"   width="85">
          <template #default="{row}">{{ activeText(row.active_level) }}</template>
        </el-table-column>
        <el-table-column prop="lifecycle_stage" :label="t('logClassify.lifecycle')"  width="95">
          <template #default="{row}">{{ lifecycleText(row.lifecycle_stage) }}</template>
        </el-table-column>
        <el-table-column prop="log_tags"       :label="t('logClassify.aiTags')" min-width="180">
          <template #default="{row}">
            <template v-if="parseTags(row.log_tags).length">
              <el-tag
                v-for="tag in parseTags(row.log_tags)" :key="tag"
                size="small" effect="plain" round
                :style="{ marginRight:'3px', borderColor: tagColor(tag), color: tagColor(tag) }"
              >{{ tagText(tag) }}</el-tag>
            </template>
            <span v-else style="color:#c0c4cc;font-size:12px">— {{ t('logClassify.noTag') }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="anomaly_flag"   :label="t('logClassify.anomaly')"   width="60" align="center">
          <template #default="{row}">
            <el-tag v-if="+row.anomaly_flag" type="danger" size="small">{{ t('common.yes') }}</el-tag>
            <span v-else style="color:#67c23a;font-size:12px">{{ t('common.no') }}</span>
          </template>
        </el-table-column>
      </el-table>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { MagicStick, DataBoard, Cpu, Finished, TrendCharts } from '@element-plus/icons-vue'
import { BarChart, PieChart } from 'echarts/charts'
import VChart from 'vue-echarts'
import { tagAnalysisApi } from '@/api'
import { t, locale } from '@/i18n'
import { registerEchartsBasic } from '@/plugins/registerEchartsBasic'

registerEchartsBasic()


const showcaseSQL = `-- Doris AI_CLASSIFY tagging (one-click, no offline training)
UPDATE user_wide
SET log_tags = AI_CLASSIFY(
    'llm_resource',
    CONCAT(
        'Asset Level:', asset_level,
        ' AUM:', aum_total, '(10k)',
        ' Activity:', active_level,
        ' Lifecycle:', lifecycle_stage
    ),
    ARRAY('High Net Worth','Fund Preference','Wealth Preference','Loan Demand',
          'Remote Login','Large Transfer','Frequent Operations','Insurance Preference',
          'Conservative','VIP','New Customer','High-Frequency Trading')
)
WHERE log_tags IS NULL OR log_tags = '[]';`

const activeTab   = ref('dist')
const classifying = ref(false)
const classifyResult = ref(null)
const sqlExpanded = ref(false)

const summary   = ref({ total_users: 0, tagged_users: 0, risk_users: 0 })
const tagDist   = ref([])
const riskData  = ref([])
const crossData = ref([])
const coocData  = ref([])
const userRows  = ref([])
const userLoading = ref(false)
const userFilter  = ref({ tag_name: '', onlyRisk: false })

const coverPct = computed(() =>
  summary.value.total_users
    ? Math.round(summary.value.tagged_users * 100 / summary.value.total_users)
    : 0
)
const tagCategories = computed(() => [...new Set(tagDist.value.map(t => t.category))])
const fmt = v => v == null ? '-' : Number(v).toLocaleString()
const assetTagType = l => ({ 'VIP私行': 'danger', 'VIP钻石': 'warning', 'VIP铂金': '', 'VIP黄金': 'success' }[l] || 'info')
const tagColorMap = computed(() => Object.fromEntries(tagDist.value.map(t => [t.tag_name, t.color])))
function tagColor(name) { return tagColorMap.value[name] || '#909399' }
function translateDict(group, name) {
  const key = String(name || '').trim()
  if (!key) return ''
  const path = `logClassify.${group}.${key}`
  const value = t(path)
  return value === path ? key : value
}
function tagText(name) { return translateDict('tagLabels', name) }
function categoryText(name) { return translateDict('tagCategories', name) }
function assetText(name) { return translateDict('assetLabels', name) }
function activeText(name) { return translateDict('activeLabels', name) }
function lifecycleText(name) { return translateDict('lifecycleLabels', name) }
function joinTags(tags = []) {
  return tags.map(tagText).join(locale.value === 'zh' ? '、' : ', ')
}
function parseTags(raw) {
  if (!raw || raw === '[]') return []
  try { return JSON.parse(raw) } catch { return [] }
}
function jumpToUsers(tag) {
  userFilter.value.tag_name = tag
  activeTab.value = 'users'
  loadUsers()
}

async function runClassify() {
  classifying.value = true
  classifyResult.value = null
  try {
    const res = await tagAnalysisApi.runClassify()
    classifyResult.value = res
    ElMessage.success(`AI tagging complete, tagged ${res.tagged} users`)
    await reloadAll()
  } finally {
    classifying.value = false
  }
}

async function reloadAll() {
  await loadOverview()
  Promise.all([loadRisk(), loadCross(), loadCooc(), loadUsers()])
}

async function loadOverview() {
  const res = await tagAnalysisApi.overview()
  tagDist.value  = res.tag_distribution || []
  summary.value  = res.summary || {}
}
async function loadRisk()  { riskData.value  = await tagAnalysisApi.risk() }
async function loadCross() { crossData.value = await tagAnalysisApi.cross() }
async function loadCooc()  { coocData.value  = await tagAnalysisApi.cooccurrence() }
async function loadUsers() {
  userLoading.value = true
  try {
    const params = {}
    if (userFilter.value.tag_name) params.tag_name = userFilter.value.tag_name
    if (userFilter.value.onlyRisk) params.is_risk = 1
    userRows.value = await tagAnalysisApi.users(params)
  } finally { userLoading.value = false }
}

// ── ECharts ──────────────────────────────────────────────────────
const distBarOption = computed(() => ({
  tooltip: { trigger: 'axis' },
  grid: { left: 70, right: 20, top: 10, bottom: 10 },
  xAxis: { type: 'value' },
  yAxis: { type: 'category', data: tagDist.value.map(t => tagText(t.tag_name)) },
  series: [{
    type: 'bar',
    data: tagDist.value.map(t => ({ value: t.user_count, itemStyle: { color: t.color } })),
    label: { show: true, position: 'right', fontSize: 11 }
  }]
}))

const catPieOption = computed(() => {
  const catMap = {}
  tagDist.value.forEach(t => { catMap[t.category] = (catMap[t.category] || 0) + t.user_count })
  return {
    tooltip: { trigger: 'item', formatter: '{b}: {c}users ({d}%)' },
    legend: { bottom: 0, textStyle: { fontSize: 11 } },
    series: [{
      type: 'pie', radius: ['35%', '60%'],
      data: Object.entries(catMap).map(([name, value]) => ({ name: categoryText(name), value })),
      label: { formatter: '{b}\n{d}%', fontSize: 11 }
    }]
  }
})

const riskBarOption = computed(() => ({
  tooltip: { trigger: 'axis' },
  legend: { data: ['Total Users', 'Anomaly Users'], top: 0 },
  grid: { left: 70, right: 20, top: 36, bottom: 10 },
  xAxis: { type: 'value' },
  yAxis: { type: 'category', data: riskData.value.map(r => tagText(r.tag_name)) },
  series: [
    { name: 'Total Users',  type: 'bar', data: riskData.value.map(r => r.total_users),  itemStyle: { color: '#c0d9f0' } },
    { name: 'Anomaly Users', type: 'bar', data: riskData.value.map(r => r.anomaly_users), itemStyle: { color: '#f56c6c' } },
  ]
}))

const coocChordOption = computed(() => {
  if (!coocData.value.length) return {}
  const allTags = [...new Set(coocData.value.flatMap(r => [r.tag_a, r.tag_b]))]
  const displayTags = allTags.map(tagText)
  return {
    tooltip: {},
    grid: { left: 20, right: 20, top: 20, bottom: 20 },
    xAxis: { type: 'category', data: displayTags, axisLabel: { fontSize: 10, rotate: 30 } },
    yAxis: { type: 'category', data: displayTags, axisLabel: { fontSize: 10 } },
    series: [{
      type: 'scatter',
      data: coocData.value.flatMap(r => [
        [allTags.indexOf(r.tag_a), allTags.indexOf(r.tag_b), r.count],
        [allTags.indexOf(r.tag_b), allTags.indexOf(r.tag_a), r.count],
      ]),
      symbolSize: v => Math.max(v[2] * 14, 8),
      itemStyle: { color: '#409eff', opacity: 0.75 },
      tooltip: {
        formatter: p => {
          const [xi, yi, cnt] = p.value
          return `${displayTags[xi]} + ${displayTags[yi]}<br/>${t('logClassify.coocTooltip', [cnt])}`
        }
      }
    }]
  }
})

onMounted(async () => {
  // 并行加载所有数据
  await Promise.all([
    loadOverview(),
    loadRisk(),
    loadCross(),
    loadCooc(),
    loadUsers()
  ])
})
</script>

<style scoped>
.showcase-card { border: 1.5px solid #409eff22; background: linear-gradient(135deg, #f0f7ff 0%, #fff 60%); }
.showcase-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; }
.showcase-title { font-size: 17px; font-weight: 700; color: #1a1a1a; margin-bottom: 4px; }
.showcase-sub { font-size: 13px; color: #606266; }
.showcase-actions { display: flex; gap: 8px; flex-shrink: 0; }

.sql-showcase { background: #1e1e2e; border-radius: 8px; padding: 16px 20px; margin-bottom: 16px; }
.sql-label { margin-bottom: 10px; display: flex; align-items: center; border-radius: 4px; padding: 2px 4px; transition: background 0.15s; }
.sql-label:hover { background: rgba(255,255,255,0.06); }
.sql-collapsed {
  display: flex; align-items: center; gap: 8px; padding: 8px 4px;
  cursor: pointer;
}
.sql-collapsed-hint {
  font-family: 'JetBrains Mono', Consolas, monospace;
  font-size: 12px; color: #6e7c9a; white-space: nowrap;
  overflow: hidden; text-overflow: ellipsis; max-width: 480px;
}
.sql-code {
  font-family: 'JetBrains Mono', 'Fira Code', Consolas, monospace;
  font-size: 13px; line-height: 1.7; color: #a8b3cf;
  white-space: pre; overflow-x: auto; margin: 0;
}

.classify-result { margin-bottom: 16px; }

.flow-row { display: flex; align-items: center; gap: 0; padding-top: 4px; }
.flow-step { display: flex; align-items: center; gap: 10px; flex: 1; }
.flow-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.flow-text { flex: 1; }
.flow-title { font-size: 13px; font-weight: 600; color: #1a1a1a; }
.flow-desc { font-size: 11px; color: #909399; margin-top: 2px; }
.flow-arrow { font-size: 22px; color: #c0c4cc; padding: 0 8px; flex-shrink: 0; }

.tag-list { display: flex; flex-direction: column; gap: 6px; max-height: 360px; overflow-y: auto; }
.tag-item {
  display: flex; align-items: center; gap: 8px;
  padding: 7px 10px; border-radius: 6px; background: #fafafa;
  border: 1px solid #f0f0f0; cursor: pointer; transition: all 0.15s;
}
.tag-item:hover { border-color: #c6e2ff; background: #f0f7ff; }
.tag-item.risk { border-color: #fbc4c4; background: #fff5f5; }
.tag-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
.tag-info { flex: 1; display: flex; flex-direction: column; }
.tag-name { font-size: 13px; font-weight: 600; color: #1a1a1a; }
.tag-cat  { font-size: 11px; color: #909399; }
.tag-count { font-size: 16px; font-weight: 700; color: #409eff; }
.tag-count small { font-size: 11px; font-weight: 400; color: #909399; margin-left: 2px; }

.cross-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.cross-item { background: #fafafa; border-radius: 8px; padding: 12px; border: 1px solid #f0f0f0; }
.cross-tag {
  font-size: 13px; font-weight: 600; padding: 4px 10px;
  border-radius: 14px; border: 1.5px solid; display: inline-flex;
  flex-direction: column; margin-bottom: 10px;
}
.cross-tag small { font-size: 10px; opacity: 0.7; font-weight: 400; }
.cross-bars { display: flex; flex-direction: column; gap: 6px; }
.cross-bar-row { display: flex; align-items: center; gap: 6px; }
.cross-label { width: 72px; flex-shrink: 0; }
.cross-cnt { font-size: 11px; color: #909399; width: 20px; text-align: right; flex-shrink: 0; }
</style>
