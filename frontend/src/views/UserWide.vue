<template>
  <div>
    <!-- 查询条件 -->
    <div class="card">
      <div class="card-title">{{ t('user.queryTitle') }}</div>
      <el-form :model="query" inline label-width="80px">
        <el-form-item :label="t('user.labelName')">
          <el-input v-model="query.user_name" :placeholder="t('user.phFuzzy')" clearable style="width:140px" />
        </el-form-item>
        <el-form-item :label="t('user.labelIdCard')">
          <el-input v-model="query.id_card" :placeholder="t('user.phExact')" clearable style="width:180px" />
        </el-form-item>
        <el-form-item :label="t('user.labelPhone')">
          <el-input v-model="query.phone" :placeholder="t('user.phExact')" clearable style="width:140px" />
        </el-form-item>
        <el-form-item :label="t('user.labelAsset')">
          <el-select v-model="query.asset_level" clearable :placeholder="t('user.phAll')" style="width:130px">
            <el-option v-for="o in assetLevels" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item :label="t('user.labelActive')">
          <el-select v-model="query.active_level" clearable :placeholder="t('user.phAll')" style="width:110px">
            <el-option v-for="o in activeLevels" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item :label="t('user.labelLifecycle')">
          <el-select v-model="query.lifecycle_stage" clearable :placeholder="t('user.phAll')" style="width:120px">
            <el-option v-for="o in lifecycles" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item :label="t('user.labelChannel')">
          <el-select v-model="query.preferred_channel" clearable :placeholder="t('user.phAll')" style="width:110px">
            <el-option v-for="o in channels" :key="o.value" :label="o.label" :value="o.value" />
          </el-select>
        </el-form-item>
        <el-form-item :label="t('user.labelAge')">
          <el-input-number v-model="query.age_min" :min="18" :max="99" style="width:90px" controls-position="right" />
          <span style="margin:0 6px">-</span>
          <el-input-number v-model="query.age_max" :min="18" :max="99" style="width:90px" controls-position="right" />
        </el-form-item>
        <el-form-item :label="t('user.labelAum')">
          <el-input-number v-model="query.aum_min" :min="0" style="width:90px" controls-position="right" />
          <span style="margin:0 6px">-</span>
          <el-input-number v-model="query.aum_max" :min="0" style="width:90px" controls-position="right" />
        </el-form-item>
        <el-form-item :label="t('user.labelAnomaly')">
          <el-select v-model="query.anomaly_flag" clearable :placeholder="t('user.phAll')" style="width:90px">
            <el-option :label="t('common.yes')" :value="1" />
            <el-option :label="t('common.no')" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleSearch">{{ t('common.search') }}</el-button>
          <el-button @click="handleReset">{{ t('common.reset') }}</el-button>
          <el-button type="success" :loading="exporting" @click="handleExport">{{ t('common.export') }}</el-button>
        </el-form-item>
      </el-form>
      <div style="font-size:12px;color:#909399;margin-top:4px">{{ t('user.haspHint') }}</div>
    </div>

    <!-- 结果统计 -->
    <div class="card" style="padding:12px 20px">
      <el-row align="middle">
        <el-col :span="12">
          <span style="font-size:13px;color:#606266">
            <span v-html="t('user.resultCount').replace('{0}', `<strong style=\'color:#409eff;font-size:16px\'>${total.toLocaleString()}</strong>`)" />
          </span>
        </el-col>
        <el-col :span="12" style="text-align:right">
          <el-tag size="small" type="info">{{ queryTime }}ms</el-tag>
        </el-col>
      </el-row>
    </div>

    <!-- 数据表格 -->
    <div class="card" style="padding:0">
      <el-table
        :data="rows"
        v-loading="loading"
        stripe border size="small" style="width:100%"
        :row-class-name="rowClass"
        @row-click="showDetail"
      >
        <el-table-column prop="user_id"   :label="t('user.colId')"     width="90" fixed />
        <el-table-column prop="user_name" :label="t('user.colName')"   width="80" fixed />
        <el-table-column prop="phone"     :label="t('user.colPhone')"  width="130" />
        <el-table-column prop="id_card"   :label="t('user.colIdCard')" width="150" />
        <el-table-column prop="age"       :label="t('user.colAge')"    width="60" />
        <el-table-column prop="city"      :label="t('user.colCity')"   width="80" />
        <el-table-column prop="asset_level" :label="t('user.colAsset')" width="100">
          <template #default="{row}">
            <el-tag :type="assetTagType(row.asset_level)" size="small">{{ dictLabel('asset_level', row.asset_level) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="aum_total" :label="t('user.colAum')" width="100" sortable>
          <template #default="{row}">{{ fmtNum(row.aum_total) }}</template>
        </el-table-column>
        <el-table-column prop="deposit_amount" :label="t('user.colDeposit')" width="90">
          <template #default="{row}">{{ fmtNum(row.deposit_amount) }}</template>
        </el-table-column>
        <el-table-column prop="fund_amount"    :label="t('user.colFund')" width="90">
          <template #default="{row}">{{ fmtNum(row.fund_amount) }}</template>
        </el-table-column>
        <el-table-column prop="loan_amount"    :label="t('user.colLoan')" width="90">
          <template #default="{row}">{{ fmtNum(row.loan_amount) }}</template>
        </el-table-column>
        <el-table-column prop="preferred_channel" :label="t('user.colChannel')" width="90">
          <template #default="{row}">{{ dictLabel('channel', row.preferred_channel) }}</template>
        </el-table-column>
        <el-table-column prop="active_level"   :label="t('user.colActiveLevel')" width="90">
          <template #default="{row}">
            <el-tag :type="activeTagType(row.active_level)" size="small">{{ dictLabel('active_level', row.active_level) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lifecycle_stage" :label="t('user.colLifecycle')" width="100">
          <template #default="{row}">{{ dictLabel('lifecycle_stage', row.lifecycle_stage) }}</template>
        </el-table-column>
        <el-table-column prop="credit_score"   :label="t('user.colCredit')" width="80" />
        <el-table-column prop="churn_prob"     :label="t('user.colChurn')" width="90">
          <template #default="{row}">
            <el-progress
              :percentage="Math.round((row.churn_prob || 0) * 100)"
              :color="row.churn_prob > 0.5 ? '#f56c6c' : '#67c23a'"
              :stroke-width="8" style="width:70px"
            />
          </template>
        </el-table-column>
        <el-table-column prop="anomaly_flag"   :label="t('user.colAnomaly')" width="70">
          <template #default="{row}">
            <el-tag v-if="row.anomaly_flag" type="danger" size="small">{{ t('common.anomaly') }}</el-tag>
            <el-tag v-else type="success" size="small">{{ t('common.normal') }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column :label="t('common.operation')" width="100" fixed="right">
          <template #default="{row}">
            <el-button type="primary" size="small" link @click.stop="showDetail(row)">{{ t('user.col360') }}</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="page"
        v-model:page-size="pageSize"
        :page-sizes="[20, 50, 100, 200]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        style="padding:12px 20px;justify-content:flex-end;display:flex"
        @change="fetchData"
      />
    </div>

    <!-- 用户360°视图抽屉 -->
    <el-drawer v-model="drawerVisible" :title="t('user.drawerTitle')" size="500px">
      <div v-if="selectedUser">
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item :label="t('user.dUserId')">{{ selectedUser.user_id }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dName')">{{ selectedUser.user_name }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dPhone')">{{ selectedUser.phone }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dIdCard')">{{ selectedUser.id_card }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dAge')">{{ selectedUser.age }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dCity')">{{ selectedUser.city }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dAsset')">
            <el-tag :type="assetTagType(selectedUser.asset_level)" size="small">{{ dictLabel('asset_level', selectedUser.asset_level) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item :label="t('user.dAum')">{{ fmtNum(selectedUser.aum_total) }} {{ t('user.wan') }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dDeposit')">{{ fmtNum(selectedUser.deposit_amount) }} {{ t('user.wan') }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dFund')">{{ fmtNum(selectedUser.fund_amount) }} {{ t('user.wan') }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dWm')">{{ fmtNum(selectedUser.wm_amount) }} {{ t('user.wan') }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dLoan')">{{ fmtNum(selectedUser.loan_amount) }} {{ t('user.wan') }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dCredit')">{{ selectedUser.credit_score }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dCreditGrade')">{{ selectedUser.credit_grade }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dRisk')">{{ dictLabel('risk_level', selectedUser.risk_level) }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dChannel')">{{ dictLabel('channel', selectedUser.preferred_channel) }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dLogin')">{{ selectedUser.app_login_30d }} {{ t('user.times') }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dActiveLevel')">{{ dictLabel('active_level', selectedUser.active_level) }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dLifecycle')">{{ dictLabel('lifecycle_stage', selectedUser.lifecycle_stage) }}</el-descriptions-item>
          <el-descriptions-item :label="t('user.dChurn')">{{ ((selectedUser.churn_prob || 0) * 100).toFixed(1) }}%</el-descriptions-item>
          <el-descriptions-item :label="t('user.dAnomalyFlag')">
            <el-tag :type="selectedUser.anomaly_flag ? 'danger' : 'success'" size="small">
              {{ selectedUser.anomaly_flag ? t('common.anomaly') : t('common.normal') }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item :label="t('user.dRegDate')" :span="2">{{ selectedUser.register_date }}</el-descriptions-item>
        </el-descriptions>

        <div v-if="selectedUser.log_tags" style="margin-top:16px">
          <div style="font-size:13px;font-weight:600;margin-bottom:8px">{{ t('user.dAiTags') }}</div>
          <el-tag
            v-for="tag in parseTags(selectedUser.log_tags)"
            :key="tag" style="margin:3px" size="small" type="warning"
          >{{ tag }}</el-tag>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { userApi } from '@/api'
import { ElMessage } from 'element-plus'
import { t } from '@/i18n'
import { useDictionaryStore } from '@/store/dictionary'

const dict = useDictionaryStore()
const optionList = (type, values) => computed(() => values.map(value => ({ value, label: dict.label(type, value, value) })))
const dictLabel = (type, value) => dict.label(type, value, value || '-')

const assetLevels = optionList('asset_level', ['VIP私行', 'VIP钻石', 'VIP铂金', 'VIP黄金', '普通'])
const activeLevels = optionList('active_level', ['高活', '中活', '低活', '沉睡'])
const lifecycles   = optionList('lifecycle_stage', ['新客', '成长', '成熟', '沉睡', '流失预警'])
const channels     = optionList('channel', ['APP', '网点', '小程序', '网银'])

const query = reactive({
  user_name: '', id_card: '', phone: '',
  asset_level: '', active_level: '', lifecycle_stage: '', preferred_channel: '',
  age_min: undefined, age_max: undefined,
  aum_min: undefined, aum_max: undefined,
  anomaly_flag: undefined,
})
const rows     = ref([])
const total    = ref(0)
const page     = ref(1)
const pageSize = ref(20)
const loading  = ref(false)
const exporting = ref(false)
const queryTime = ref(0)
const drawerVisible = ref(false)
const selectedUser  = ref(null)

const fmtNum = v => v == null ? '-' : Number(v).toFixed(2)
const parseTags = v => { try { return JSON.parse(v) } catch { return [] } }
const assetTagType = l => ({ 'VIP私行': 'danger', 'VIP钻石': 'warning', 'VIP铂金': '', 'VIP黄金': 'success' }[l] || 'info')
const activeTagType = l => ({ '高活': 'success', '中活': '', '低活': 'warning', '沉睡': 'info' }[l] || '')
const rowClass = ({ row }) => row.anomaly_flag ? 'anomaly-row' : ''

async function fetchData() {
  loading.value = true
  const t0 = Date.now()
  try {
    const params = { page: page.value, page_size: pageSize.value }
    Object.entries(query).forEach(([k, v]) => { if (v !== '' && v !== undefined && v !== null) params[k] = v })
    const res = await userApi.queryWide(params)
    rows.value  = res.rows || []
    total.value = res.total || 0
    queryTime.value = Date.now() - t0
  } finally { loading.value = false }
}

function handleSearch() { page.value = 1; fetchData() }
function handleReset() {
  Object.keys(query).forEach(k => query[k] = undefined)
  query.user_name = query.id_card = query.phone = query.asset_level =
    query.active_level = query.lifecycle_stage = query.preferred_channel = ''
  handleSearch()
}

function showDetail(row) { selectedUser.value = row; drawerVisible.value = true }

async function handleExport() {
  exporting.value = true
  try {
    ElMessage.info(t('user.exportMsg'))
  } finally { exporting.value = false }
}

onMounted(fetchData)
</script>

<style>
.anomaly-row td { background: #fff5f5 !important; }
</style>
