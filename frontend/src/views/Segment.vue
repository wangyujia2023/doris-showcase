<template>
  <div>
    <el-row :gutter="16">

      <!-- 左：圈选配置 -->
      <el-col :span="14">
        <div class="card">
          <div class="card-title">{{ t('segment.title') }}</div>

          <!-- 规则组 -->
          <div
            v-for="(rule, idx) in rules"
            :key="idx"
            style="display:flex;align-items:center;gap:8px;margin-bottom:10px;
                   padding:12px;border:1px solid #e4e7ed;border-radius:6px;background:#fafafa"
          >
            <span style="font-size:12px;color:#909399;width:20px;flex-shrink:0">{{ idx + 1 }}</span>

            <el-select v-model="rule.tag_name" :placeholder="t('segment.tagPlaceholder')" style="width:160px" @change="clearValues(rule)">
              <el-option-group v-for="grp in tagGroups" :key="grp.label" :label="grp.label">
                <el-option v-for="tg in grp.tags" :key="tg.value" :label="tg.label" :value="tg.value" />
              </el-option-group>
            </el-select>

            <el-select v-model="rule.op" style="width:95px;flex-shrink:0">
              <el-option :label="t('segment.opOr')" value="OR" />
              <el-option :label="t('segment.opAnd')" value="AND" />
            </el-select>

            <el-select
              v-model="rule.tag_values"
              multiple collapse-tags collapse-tags-tooltip
              :placeholder="t('segment.valPlaceholder')"
              style="flex:1"
            >
              <el-option v-for="opt in getOptions(rule.tag_name)" :key="opt" :label="opt" :value="opt" />
            </el-select>

            <el-tooltip :content="t('segment.excludeTooltip')">
              <el-checkbox v-model="rule.exclude" style="flex-shrink:0">{{ t('segment.excludeLabel') }}</el-checkbox>
            </el-tooltip>

            <el-button type="danger" link :icon="Delete" @click="removeRule(idx)" style="flex-shrink:0" />
          </div>

          <el-button type="primary" plain :icon="Plus" @click="addRule" style="width:100%;margin-bottom:16px">
            {{ t('segment.addRule') }}
          </el-button>

          <!-- 操作区 -->
          <el-row :gutter="10">
            <el-col :span="8">
              <el-button type="primary" style="width:100%" :loading="counting" :disabled="!hasValidRules" @click="handleCount">
                {{ t('segment.estimate') }}
              </el-button>
            </el-col>
            <el-col :span="16">
              <el-input v-model="segName" :placeholder="t('segment.namePlaceholder')">
                <template #append>
                  <el-button :loading="saving" :disabled="!hasValidRules || !segName.trim()" @click="handleSave">
                    {{ t('segment.saveBtn') }}
                  </el-button>
                </template>
              </el-input>
            </el-col>
          </el-row>

          <!-- 估算结果 -->
          <transition name="fade">
            <div v-if="countResult !== null" class="count-result">
              <div>
                <div style="font-size:12px;opacity:.8;margin-bottom:4px">{{ t('segment.estLabel') }}</div>
                <div style="font-size:40px;font-weight:800">{{ countResult.toLocaleString() }}</div>
                <div style="font-size:12px;opacity:.7;margin-top:4px">{{ t('segment.activeRules').replace('{0}', activeRuleCount) }}</div>
              </div>
              <div style="text-align:right">
                <div style="font-size:12px;opacity:.8">{{ t('segment.dorisCalc') }}</div>
                <div style="font-size:12px;opacity:.8">{{ t('segment.haspAccel') }}</div>
                <div style="font-size:20px;font-weight:700;margin-top:4px">{{ countCost }}ms</div>
              </div>
            </div>
          </transition>

          <!-- 标签说明 -->
          <el-collapse style="margin-top:16px">
            <el-collapse-item :title="t('segment.tagsHint')" name="1">
              <div style="display:flex;flex-wrap:wrap;gap:6px">
                <el-tag v-for="tg in allTagOptions" :key="tg.value" size="small" effect="plain">
                  {{ tg.label }}（{{ getOptions(tg.value).join(' / ') }}）
                </el-tag>
              </div>
            </el-collapse-item>
          </el-collapse>
        </div>
      </el-col>

      <!-- 右：人群包列表 -->
      <el-col :span="10">
        <div class="card">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px">
            <span class="card-title" style="margin-bottom:0">{{ t('segment.savedTitle') }}</span>
            <el-button size="small" :icon="Refresh" @click="loadSegments" :loading="loadingList">{{ t('common.refresh') }}</el-button>
          </div>

          <div v-if="loadingList" style="text-align:center;padding:30px;color:#c0c4cc">{{ t('common.loading') }}</div>
          <el-empty v-else-if="!segments.length" :description="t('segment.emptyDesc')" />

          <div v-for="seg in segments" :key="seg.segment_id" class="seg-card">
            <div class="seg-header">
              <div class="seg-title">{{ seg.segment_name }}</div>
              <el-tag type="primary" size="small" effect="dark">
                {{ (seg.user_count || 0).toLocaleString() }} 人
              </el-tag>
            </div>

            <div v-if="seg.segment_desc" class="seg-desc">{{ seg.segment_desc }}</div>

            <!-- 规则预览 -->
            <div v-if="Array.isArray(seg.rule_config) && seg.rule_config.length" class="seg-rules">
              <span
                v-for="(r, i) in seg.rule_config" :key="i"
                class="rule-chip" :class="{ exclude: r.exclude }"
              >
                <span v-if="r.exclude" style="color:#f56c6c">NOT </span>
                {{ getTagLabel(r.tag_name) }}
                <b>{{ r.op }}</b>
                {{ r.tag_values.join('、') }}
              </span>
            </div>

            <div class="seg-meta">
              <span>{{ seg.created_by }}</span>
              <span>{{ seg.snap_date }}</span>
            </div>

            <div class="seg-actions">
              <el-button size="small" type="primary" link @click="reuseRules(seg)">
                <el-icon><CopyDocument /></el-icon> {{ t('segment.reuseRules') }}
              </el-button>
              <el-button size="small" type="success" link @click="viewStats(seg)">
                <el-icon><DataAnalysis /></el-icon> {{ t('segment.distAnalysis') }}
              </el-button>
              <el-button size="small" type="info" link @click="viewUsers(seg)">
                <el-icon><User /></el-icon> {{ t('segment.viewUsers') }}
              </el-button>
              <el-button size="small" type="danger" link @click="deleteSegment(seg.segment_id)">
                <el-icon><Delete /></el-icon>
              </el-button>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 用户列表对话框 -->
    <el-dialog v-model="userDialogVisible" :title="`${t('segment.userListTitle')} — ${selectedSeg?.segment_name}`" width="900px">
      <el-table :data="segUsers" size="small" stripe border max-height="480">
        <el-table-column prop="user_id"        :label="t('segment.colId')"       width="80" />
        <el-table-column prop="user_name"      :label="t('segment.colName')"     width="72" />
        <el-table-column prop="phone"          :label="t('segment.colPhone')"    width="125" />
        <el-table-column prop="age"            :label="t('segment.colAge')"      width="55" />
        <el-table-column prop="city"           :label="t('segment.colCity')"     width="70" />
        <el-table-column prop="asset_level"    :label="t('segment.colAsset')"    width="90">
          <template #default="{row}">
            <el-tag :type="assetTagType(row.asset_level)" size="small">{{ row.asset_level }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="aum_total"      :label="t('segment.colAum')"      width="90">
          <template #default="{row}">{{ Number(row.aum_total || 0).toFixed(1) }}</template>
        </el-table-column>
        <el-table-column prop="active_level"   :label="t('segment.colActive')"   width="68" />
        <el-table-column prop="lifecycle_stage" :label="t('segment.colLifecycle')" width="85" />
        <el-table-column prop="credit_grade"   :label="t('segment.colCredit')"   width="60" />
        <el-table-column prop="churn_prob"     :label="t('segment.colChurn')">
          <template #default="{row}">
            <el-progress :percentage="+(Number(row.churn_prob||0)*100).toFixed(0)"
              :stroke-width="5" :show-text="false"
              :color="Number(row.churn_prob||0) > 0.4 ? '#f56c6c' : '#67c23a'" />
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>

    <!-- 分布分析对话框 -->
    <el-dialog v-model="statsDialogVisible" :title="`${t('segment.distTitle')} — ${selectedSeg?.segment_name}（${selectedSeg?.user_count}人）`" width="760px">
      <div v-if="loadingStats" style="text-align:center;padding:40px;color:#909399">{{ t('common.loading') }}</div>
      <div v-else-if="segStats">
        <el-row :gutter="16">
          <el-col :span="12">
            <div class="stat-block">
              <div class="stat-block-title">{{ t('segment.assetDist') }}</div>
              <div v-for="d in segStats.asset_dist" :key="d.asset_level" class="dist-row">
                <span class="dist-label">
                  <el-tag :type="assetTagType(d.asset_level)" size="small">{{ d.asset_level }}</el-tag>
                </span>
                <el-progress :percentage="pct(d.cnt, segStats.asset_dist)" :stroke-width="14"
                  :format="() => d.cnt + '人'" style="flex:1" />
              </div>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="stat-block">
              <div class="stat-block-title">{{ t('segment.activeDist') }}</div>
              <div v-for="d in segStats.active_dist" :key="d.active_level" class="dist-row">
                <span class="dist-label">{{ d.active_level }}</span>
                <el-progress :percentage="pct(d.cnt, segStats.active_dist)" :stroke-width="14"
                  :format="() => d.cnt + '人'" style="flex:1"
                  :color="{ '高活': '#67c23a', '中活': '#409eff', '低活': '#e6a23c', '沉睡': '#909399' }[d.active_level]" />
              </div>
            </div>
          </el-col>
          <el-col :span="12" style="margin-top:16px">
            <div class="stat-block">
              <div class="stat-block-title">{{ t('segment.lifecycleDist') }}</div>
              <div v-for="d in segStats.lifecycle_dist" :key="d.lifecycle_stage" class="dist-row">
                <span class="dist-label">{{ d.lifecycle_stage }}</span>
                <el-progress :percentage="pct(d.cnt, segStats.lifecycle_dist)" :stroke-width="14"
                  :format="() => d.cnt + '人'" style="flex:1" />
              </div>
            </div>
          </el-col>
          <el-col :span="12" style="margin-top:16px">
            <div class="stat-block">
              <div class="stat-block-title">{{ t('segment.channelDist') }}</div>
              <div v-for="d in segStats.channel_dist" :key="d.preferred_channel" class="dist-row">
                <span class="dist-label">{{ d.preferred_channel }}</span>
                <el-progress :percentage="pct(d.cnt, segStats.channel_dist)" :stroke-width="14"
                  :format="() => d.cnt + '人'" style="flex:1" color="#e6a23c" />
              </div>
            </div>
          </el-col>
        </el-row>

        <div class="stat-block" style="margin-top:16px">
          <div class="stat-block-title">{{ t('segment.aumStats') }}</div>
          <el-row :gutter="12">
            <el-col :span="8">
              <div class="aum-card">
                <div style="font-size:11px;color:#909399">{{ t('segment.avgAum') }}</div>
                <div style="font-size:22px;font-weight:700;color:#409eff">{{ segStats.aum_stat.avg_aum?.toFixed(1) || 0 }}</div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="aum-card">
                <div style="font-size:11px;color:#909399">{{ t('segment.maxAum') }}</div>
                <div style="font-size:22px;font-weight:700;color:#67c23a">{{ segStats.aum_stat.max_aum?.toFixed(1) || 0 }}</div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="aum-card">
                <div style="font-size:11px;color:#909399">{{ t('segment.minAum') }}</div>
                <div style="font-size:22px;font-weight:700;color:#e6a23c">{{ segStats.aum_stat.min_aum?.toFixed(1) || 0 }}</div>
              </div>
            </el-col>
          </el-row>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { Plus, Delete, Refresh, CopyDocument, DataAnalysis, User } from '@element-plus/icons-vue'
import { segmentApi } from '@/api'
import { ElMessage, ElMessageBox } from 'element-plus'
import { t, locale } from '@/i18n'

const tagGroups = computed(() => [
  {
    label: t('segment.tagGroups.asset'),
    tags: [
      { label: t('segment.tagLabels.asset_level'), value: 'asset_level' },
      { label: t('segment.tagLabels.aum_tier'),    value: 'aum_tier' },
    ]
  },
  {
    label: t('segment.tagGroups.behavior'),
    tags: [
      { label: t('segment.tagLabels.active_level'),      value: 'active_level' },
      { label: t('segment.tagLabels.preferred_channel'), value: 'preferred_channel' },
      { label: t('segment.tagLabels.app_login_tier'),    value: 'app_login_tier' },
    ]
  },
  {
    label: t('segment.tagGroups.lifecycle'),
    tags: [
      { label: t('segment.tagLabels.lifecycle_stage'), value: 'lifecycle_stage' },
    ]
  },
  {
    label: t('segment.tagGroups.profile'),
    tags: [
      { label: t('segment.tagLabels.age_group'),    value: 'age_group' },
      { label: t('segment.tagLabels.credit_grade'), value: 'credit_grade' },
      { label: t('segment.tagLabels.risk_level'),   value: 'risk_level' },
    ]
  },
  {
    label: t('segment.tagGroups.risk'),
    tags: [
      { label: t('segment.tagLabels.anomaly_flag'), value: 'anomaly_flag' },
    ]
  },
])

const tagOptions = {
  asset_level:       ['VIP私行', 'VIP钻石', 'VIP铂金', 'VIP黄金', '普通'],
  aum_tier:          ['<10万', '10-50万', '50-200万', '200-500万', '>500万'],
  active_level:      ['高活', '中活', '低活', '沉睡'],
  preferred_channel: ['APP', '网点', '小程序', '网银'],
  app_login_tier:    ['高频(>30次)', '中频(10-30次)', '低频(<10次)'],
  lifecycle_stage:   ['新客', '成长', '成熟', '沉睡', '流失预警'],
  age_group:         ['18-25', '26-35', '36-45', '46-55', '55+'],
  credit_grade:      ['AAA', 'AA', 'A', 'B', 'C'],
  risk_level:        ['1-保守', '2-稳健', '3-平衡', '4-进取', '5-激进'],
  anomaly_flag:      ['1', '0'],
}

const allTagOptions = computed(() => tagGroups.value.flatMap(g => g.tags))
const getOptions = (tagName) => tagOptions[tagName] || []
const clearValues = (rule) => { rule.tag_values = [] }
const getTagLabel = (val) => allTagOptions.value.find(tg => tg.value === val)?.label || val
const assetTagType = l => ({ 'VIP私行': 'danger', 'VIP钻石': 'warning', 'VIP铂金': '', 'VIP黄金': 'success' }[l] || 'info')

const rules        = ref([{ tag_name: 'asset_level', op: 'OR', tag_values: [], exclude: false }])
const segments     = ref([])
const segUsers     = ref([])
const segStats     = ref(null)
const segName      = ref('')
const counting     = ref(false)
const saving       = ref(false)
const loadingList  = ref(false)
const loadingStats = ref(false)
const countResult  = ref(null)
const countCost    = ref(0)
const userDialogVisible  = ref(false)
const statsDialogVisible = ref(false)
const selectedSeg  = ref(null)

const hasValidRules = computed(() => rules.value.some(r => r.tag_name && r.tag_values.length))
const activeRuleCount = computed(() => rules.value.filter(r => r.tag_name && r.tag_values.length).length)

function addRule() { rules.value.push({ tag_name: '', op: 'OR', tag_values: [], exclude: false }) }
function removeRule(idx) { rules.value.splice(idx, 1) }

function reuseRules(seg) {
  if (!Array.isArray(seg.rule_config) || !seg.rule_config.length) {
    ElMessage.warning(t('segment.msgNoRule'))
    return
  }
  rules.value = seg.rule_config.map(r => ({ ...r }))
  segName.value = seg.segment_name + t('segment.copyTag')
  countResult.value = null
  ElMessage.success(t('segment.msgRuleReused'))
}

function pct(cnt, arr) {
  const total = arr.reduce((s, d) => s + Number(d.cnt || 0), 0)
  return total ? Math.round(Number(cnt) * 100 / total) : 0
}

async function handleCount() {
  const validRules = rules.value.filter(r => r.tag_name && r.tag_values.length)
  counting.value = true
  const t0 = Date.now()
  try {
    const res = await segmentApi.count({ rules: validRules })
    countResult.value = res.crowd_size || 0
    countCost.value = Date.now() - t0
  } finally { counting.value = false }
}

async function handleSave() {
  const validRules = rules.value.filter(r => r.tag_name && r.tag_values.length)
  saving.value = true
  try {
    const res = await segmentApi.create({
      segment_name: segName.value,
      description: '',
      rules: validRules,
      created_by: '数据分析师',
    })
    ElMessage.success(t('segment.msgSaved').replace('{0}', (res.user_count || 0).toLocaleString()))
    segName.value = ''
    countResult.value = null
    loadSegments()
  } finally { saving.value = false }
}

async function loadSegments() {
  loadingList.value = true
  try { segments.value = await segmentApi.list() }
  finally { loadingList.value = false }
}

async function viewUsers(seg) {
  selectedSeg.value = seg
  const res = await segmentApi.users(seg.segment_id, 1, 50)
  segUsers.value = res.rows || []
  userDialogVisible.value = true
}

async function viewStats(seg) {
  selectedSeg.value = seg
  statsDialogVisible.value = true
  loadingStats.value = true
  segStats.value = null
  try { segStats.value = await segmentApi.stats(seg.segment_id) }
  finally { loadingStats.value = false }
}

async function deleteSegment(id) {
  await ElMessageBox.confirm(t('segment.confirmDelete'), t('common.confirm'), { type: 'warning' })
  await segmentApi.delete(id)
  ElMessage.success(t('segment.msgDeleted'))
  loadSegments()
}

onMounted(loadSegments)
</script>

<style scoped>
.seg-card { padding: 12px; border: 1px solid #e4e7ed; border-radius: 8px; margin-bottom: 10px; transition: box-shadow 0.2s; }
.seg-card:hover { box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
.seg-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.seg-title { font-weight: 600; font-size: 14px; color: #1a1a1a; }
.seg-desc { font-size: 12px; color: #909399; margin-bottom: 6px; }
.seg-rules { display: flex; flex-wrap: wrap; gap: 4px; margin: 6px 0; }
.rule-chip { font-size: 11px; padding: 2px 8px; border-radius: 10px; background: #f0f7ff; color: #409eff; border: 1px solid #c6e2ff; }
.rule-chip.exclude { background: #fff0f0; color: #f56c6c; border-color: #fbc4c4; }
.seg-meta { font-size: 11px; color: #c0c4cc; margin: 6px 0 4px; display: flex; gap: 12px; }
.seg-actions { display: flex; gap: 2px; flex-wrap: wrap; }
.count-result {
  margin-top: 14px; padding: 16px 20px;
  background: linear-gradient(135deg, #1a56db, #0ea5e9);
  border-radius: 10px; color: #fff; display: flex; justify-content: space-between; align-items: center;
}
.stat-block { background: #fafafa; border-radius: 8px; padding: 14px; }
.stat-block-title { font-size: 13px; font-weight: 600; color: #1a1a1a; margin-bottom: 10px; }
.dist-row { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
.dist-label { font-size: 12px; color: #606266; width: 72px; flex-shrink: 0; }
.aum-card { background: #fff; border: 1px solid #e4e7ed; border-radius: 6px; padding: 12px; text-align: center; }
.fade-enter-active, .fade-leave-active { transition: opacity 0.3s, transform 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-8px); }
</style>
