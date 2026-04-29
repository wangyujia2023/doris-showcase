<template>
  <div class="table-list-card">
    <div style="font-size:13px;font-weight:600;margin-bottom:12px;padding:20px 20px 0">{{ t('lineage.tableListTitle') }} ({{ tables.length }})</div>
    <div style="padding:0 20px">
      <div style="margin-bottom:12px">
        <el-input v-model="keywordModel" :placeholder="t('lineage.searchPlaceholder')" clearable @input="$emit('search')" />
      </div>
      <el-scrollbar style="height:640px">
        <div style="padding:0 20px">
          <div
            v-for="item in tables"
            :key="item.asset_id"
            class="table-item"
            :class="{ active: selectedTable === item.asset_id }"
            @click="$emit('choose', item.asset_id)"
          >
            <div class="table-name">{{ item.asset_id }}</div>
            <div class="table-sub">{{ item.asset_name }}</div>
            <div class="table-meta">{{ item.domain_id }} · {{ item.layer_name }}</div>
          </div>
        </div>
      </el-scrollbar>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { t } from '@/i18n'

const props = defineProps({
  tables: { type: Array, default: () => [] },
  selectedTable: String,
  keyword: String,
})
const emit = defineEmits(['update:keyword', 'search', 'choose'])
const keywordModel = computed({ get: () => props.keyword, set: v => emit('update:keyword', v) })
</script>

<style scoped>
.table-list-card {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, .06);
  height: fit-content;
  max-height: calc(100vh - 200px);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.table-item {
  padding: 10px 12px;
  border: 1px solid #ebeef5;
  border-radius: 6px;
  margin-bottom: 8px;
  cursor: pointer;
  transition: all .2s ease;
  background: #fff;
}

.table-item:hover {
  border-color: #409eff;
  background: #f0f9ff;
}

.table-item.active {
  border-color: #409eff;
  background: #ecf5ff;
}

.table-name {
  font-size: 12px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
  word-break: break-word;
}

.table-sub {
  font-size: 12px;
  color: #606266;
  margin-bottom: 4px;
}

.table-meta {
  font-size: 11px;
  color: #909399;
}
</style>
