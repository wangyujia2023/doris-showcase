<template>
  <div class="table-list-card">
    <div class="list-title">{{ t('lineage.tableListTitle') }} <span>{{ tables.length }}</span></div>
    <div class="list-body">
      <div class="search-wrap">
        <el-input v-model="keywordModel" :placeholder="t('lineage.searchPlaceholder')" clearable @input="$emit('search')" />
      </div>
      <el-scrollbar class="table-scroll">
        <div class="table-list">
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
  --hsap-bg: #f5f7fb;
  --hsap-border: rgba(59, 130, 246, .15);
  --hsap-border-strong: rgba(59, 130, 246, .35);
  --hsap-blue: #2563eb;
  --hsap-text: #0f1c35;
  --hsap-muted: #8fa3be;
  background: #fff;
  border: 1px solid var(--hsap-border);
  border-radius: 12px;
  box-shadow: none;
  height: calc(100vh - 220px);
  min-height: 560px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.list-title {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 14px 10px;
  font-size: 11px;
  font-weight: 700;
  color: var(--hsap-muted);
  letter-spacing: .04em;
  text-transform: uppercase;
}

.list-title span {
  padding: 1px 8px;
  border: 1px solid var(--hsap-border);
  border-radius: 999px;
  color: var(--hsap-blue);
  background: rgba(37, 99, 235, .07);
}

.list-body {
  min-height: 0;
  flex: 1;
  padding: 0 12px 12px;
  display: flex;
  flex-direction: column;
}

.search-wrap { margin-bottom: 10px; }
.table-scroll { flex: 1; }
.table-list { display: flex; flex-direction: column; gap: 8px; padding-right: 4px; }

.table-item {
  padding: 10px 11px;
  border: 1px solid var(--hsap-border);
  border-radius: 10px;
  cursor: pointer;
  transition: all .18s ease;
  background: var(--hsap-bg);
}

.table-item:hover {
  border-color: var(--hsap-border-strong);
  background: #fff;
}

.table-item.active {
  border-color: rgba(37, 99, 235, .45);
  background: rgba(37, 99, 235, .08);
  box-shadow: 0 0 18px rgba(37, 99, 235, .12);
}

.table-name {
  font-size: 13px;
  font-weight: 700;
  color: var(--hsap-text);
  margin-bottom: 4px;
  word-break: break-word;
}

.table-sub {
  font-size: 12px;
  color: #4a6080;
  margin-bottom: 4px;
}

.table-meta {
  font-size: 11px;
  color: var(--hsap-muted);
}
</style>
