<template>
  <div class="reg-wrap">
    <!-- 子导航 -->
    <div class="sub-nav">
      <div class="sn-tabs">
        <div v-for="t in tabs" :key="t.key"
             class="sn-tab" :class="{ active: activeTab === t.key }"
             @click="activeTab = t.key">
          {{ t.label }}
        </div>
      </div>
      <div class="sn-actions">
        <el-select v-model="period" size="small" style="width:110px" @change="onPeriodChange">
          <el-option v-for="p in periods" :key="p" :label="p" :value="p"/>
        </el-select>
        <el-button size="small" :loading="initLoading" @click="handleInit">{{ t('regulatory.buildTable') }}</el-button>
        <el-button size="small" type="success" :loading="seedLoading" @click="handleSeed">{{ t('regulatory.seedData') }}</el-button>
        <el-button size="small" type="warning" :loading="processLoading" @click="handleProcess">
          {{ t('regulatory.process') }}
        </el-button>
        <el-button size="small" type="primary" @click="handleSubmit">{{ t('regulatory.submit') }}</el-button>
      </div>
    </div>

    <div class="tab-body">
      <RegulatoryOverviewTab  v-if="activeTab==='overview'" :period="period" ref="overviewRef"/>
      <LineageTab   v-if="activeTab==='lineage'" />
      <MasterTab    v-if="activeTab==='master'"  ref="masterRef"/>
      <QualityTab   v-if="activeTab==='quality'" :period="period"/>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { regulatoryApi } from '@/api'
import RegulatoryOverviewTab from '@/components/regulatory/RegulatoryOverviewTab.vue'
import LineageTab  from '@/components/regulatory/LineageTab.vue'
import MasterTab   from '@/components/regulatory/MasterTab.vue'
import QualityTab  from '@/components/regulatory/QualityTab.vue'
import { t } from '@/i18n'

const TABS = [
  { key: 'overview', labelKey: 'regulatory.tabOverview' },
  { key: 'lineage',  labelKey: 'regulatory.tabLineage' },
  { key: 'master',   labelKey: 'regulatory.tabMaster' },
  { key: 'quality',  labelKey: 'regulatory.tabQuality' },
]

const activeTab     = ref('overview')
const period        = ref('2024-03')
const periods       = ['2024-03','2023-12','2023-09','2023-06']
const initLoading   = ref(false)
const seedLoading   = ref(false)
const processLoading= ref(false)
const overviewRef   = ref()
const masterRef     = ref()
const tabs = computed(() => TABS.map(tab => ({ ...tab, label: t(tab.labelKey) })))

const onPeriodChange = () => {
  overviewRef.value?.reload?.()
}

const handleInit = async () => {
  initLoading.value = true
  try {
    const r = await regulatoryApi.init()
    ElMessage[r.success ? 'success' : 'error'](r.msg)
  } finally { initLoading.value = false }
}

const handleSeed = async () => {
  seedLoading.value = true
  try {
    const r = await regulatoryApi.seed()
    ElMessage[r.success ? 'success' : 'error'](r.msg)
    if (r.success) overviewRef.value?.reload?.()
  } finally { seedLoading.value = false }
}

const handleProcess = async () => {
  processLoading.value = true
  try {
    const r = await regulatoryApi.process()
    ElMessage[r.success ? 'success' : 'error'](r.msg)
    if (r.success) {
      masterRef.value?.reload?.()
      ElMessage.info(t('regulatory.processDone'))
    }
  } finally { processLoading.value = false }
}

const handleSubmit = () => {
  ElMessage.success(t('regulatory.submitOk'))
}
</script>

<style scoped>
.reg-wrap { display: flex; flex-direction: column; height: 100%; background: #f5f6fa; }

.sub-nav {
  display: flex; align-items: center; gap: 0;
  background: #fff; border-bottom: 1px solid #e4e7ed;
  padding: 0 16px; height: 46px; flex-shrink: 0;
  box-shadow: 0 1px 4px rgba(0,0,0,.06);
}
.sn-tabs { display: flex; align-items: center; gap: 2px; flex: 1; }
.sn-tab {
  padding: 6px 16px; border-radius: 4px; color: #606266;
  font-size: 13px; cursor: pointer; transition: all .2s; white-space: nowrap;
}
.sn-tab:hover { color: #409eff; background: #ecf5ff; }
.sn-tab.active { color: #409eff; background: #ecf5ff; font-weight: 600; }
.sn-actions { display: flex; align-items: center; gap: 8px; margin-left: auto; }

.tab-body { flex: 1; overflow-y: auto; padding: 16px; }
</style>
