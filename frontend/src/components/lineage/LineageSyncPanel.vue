<template>
  <div class="card" style="border-top-left-radius:0">
    <el-form inline>
      <el-form-item :label="t('lineage.labelStartDate')">
        <el-date-picker v-model="localStart" type="date" value-format="YYYY-MM-DD" :placeholder="t('lineage.labelStartDate')" />
      </el-form-item>
      <el-form-item :label="t('lineage.labelEndDate')">
        <el-date-picker v-model="localEnd" type="date" value-format="YYYY-MM-DD" :placeholder="t('lineage.labelEndDate')" />
      </el-form-item>
      <el-form-item :label="t('lineage.labelLimit')">
        <el-input v-model="localLimit" type="number" min="0" max="5000" :placeholder="t('lineage.limitHint')" style="width:120px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :loading="syncing" @click="$emit('sync')">{{ t('lineage.btnSync') }}</el-button>
      </el-form-item>
    </el-form>

    <div style="margin-top:12px">
      <div style="font-size:13px;font-weight:600;margin-bottom:10px">{{ t('lineage.syncResultTitle') }} {{ t('lineage.syncResultCount').replace('{0}', syncRows.length) }}</div>
      <el-table :data="syncRows" size="small" border max-height="360" :empty-text="t('lineage.syncEmptyText')" class="lineage-compact-table">
        <el-table-column prop="time" :label="t('lineage.syncTableCol.time')" width="180" />
        <el-table-column prop="stmt_type" :label="t('lineage.syncTableCol.type')" width="110" />
        <el-table-column prop="user" :label="t('lineage.syncTableCol.user')" width="120" />
        <el-table-column prop="target" :label="t('lineage.syncTableCol.target')" min-width="180" />
        <el-table-column :label="t('lineage.syncTableCol.sources')" min-width="240">
          <template #default="{ row }"><span>{{ row.sources?.join(', ') }}</span></template>
        </el-table-column>
        <el-table-column prop="success" :label="t('lineage.syncTableCol.status')" width="100">
          <template #default="{ row }">
            <el-tag :type="row.success ? 'success' : 'danger'">{{ row.success ? t('lineage.syncStatusSuccess') : t('lineage.syncStatusFail') }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column :label="t('lineage.syncTableCol.expressions')" min-width="260" show-overflow-tooltip>
          <template #default="{ row }"><span>{{ formatExpressionSummary(row.expressions) }}</span></template>
        </el-table-column>
        <el-table-column prop="error" :label="t('lineage.syncTableCol.error')" min-width="200" show-overflow-tooltip />
      </el-table>
    </div>

    <div style="margin-top:20px">
      <div style="font-size:13px;font-weight:600;margin-bottom:10px">{{ t('lineage.syncHistoryTitle') }}</div>
      <el-table :data="syncLogs" size="small" border max-height="280" class="lineage-compact-table">
        <el-table-column prop="sync_time" :label="t('lineage.historyTableCol.time')" width="180" />
        <el-table-column prop="start_date" :label="t('lineage.historyTableCol.startDate')" width="120" />
        <el-table-column prop="end_date" :label="t('lineage.historyTableCol.endDate')" width="120" />
        <el-table-column prop="scanned" :label="t('lineage.historyTableCol.scanned')" width="90" />
        <el-table-column prop="synced" :label="t('lineage.historyTableCol.synced')" width="90">
          <template #default="{ row }"><span style="color:#67c23a;font-weight:600">{{ row.synced }}</span></template>
        </el-table-column>
        <el-table-column prop="failed" :label="t('lineage.historyTableCol.failed')" width="90">
          <template #default="{ row }"><span style="color:#f56c6c;font-weight:600">{{ row.failed }}</span></template>
        </el-table-column>
        <el-table-column prop="success" :label="t('lineage.historyTableCol.status')" width="100">
          <template #default="{ row }">
            <el-tag :type="row.success ? 'success' : 'warning'">{{ row.success ? t('lineage.historyStatusDone') : t('lineage.historyStatusPartial') }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { t } from '@/i18n'
import { formatExpressionSummary } from '@/composables/useLineageFormat'

const props = defineProps({
  startDate: String,
  endDate: String,
  auditLimit: [String, Number],
  syncing: Boolean,
  syncRows: { type: Array, default: () => [] },
  syncLogs: { type: Array, default: () => [] },
})
const emit = defineEmits(['update:startDate', 'update:endDate', 'update:auditLimit', 'sync'])

const localStart = computed({ get: () => props.startDate, set: v => emit('update:startDate', v) })
const localEnd = computed({ get: () => props.endDate, set: v => emit('update:endDate', v) })
const localLimit = computed({ get: () => props.auditLimit, set: v => emit('update:auditLimit', v) })
</script>

<style scoped>
.card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, .06);
}

:deep(.lineage-compact-table .el-table__cell) {
  padding: 6px 8px;
  font-size: 12px;
}
</style>
