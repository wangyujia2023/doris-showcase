<template>
  <div class="bjmetro-wrap">
    <!-- 子导航 Tab -->
    <div class="sub-nav">
      <div class="sub-nav-left">
      </div>
      <div class="sn-tabs">
        <div v-for="tab in TABS" :key="tab.key"
             class="sn-tab" :class="{ active: activeTab === tab.key }"
             @click="switchTab(tab.key)">
          {{ tab.label }}
        </div>
      </div>
      <div class="sn-actions">
        <el-button size="small" type="primary" :loading="initLoading" @click="handleInit">{{ t('metro.initBtn') }}</el-button>
        <el-button size="small" type="success" :loading="seedLoading" @click="handleSeed">{{ t('metro.seedBtn') }}</el-button>
        <span class="live-dot-wrap"><span class="live-dot"></span>{{ t('metro.realtime') }}</span>
      </div>
    </div>

    <!-- Tab 内容 -->
    <div class="tab-body">
      <OverviewTab  v-if="activeTab === 'overview'"  />
      <FlowTab      v-if="activeTab === 'flow'"      />
      <TrainTab     v-if="activeTab === 'train'"     />
      <EquipmentTab v-if="activeTab === 'equipment'" />
      <RevenueTab   v-if="activeTab === 'revenue'"   />
      <ArchTab      v-if="activeTab === 'arch'"      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { t, locale } from '@/i18n'
import { ElMessage } from 'element-plus'
import { bjMetroApi } from '@/api'
import OverviewTab  from '@/components/bjmetro/OverviewTab.vue'
import FlowTab      from '@/components/bjmetro/FlowTab.vue'
import TrainTab     from '@/components/bjmetro/TrainTab.vue'
import EquipmentTab from '@/components/bjmetro/EquipmentTab.vue'
import RevenueTab   from '@/components/bjmetro/RevenueTab.vue'
import ArchTab      from '@/components/bjmetro/ArchTab.vue'

const TABS = computed(() => [
  { key: 'overview',  label: `📊 ${t('metro.tabOverview')}` },
  { key: 'flow',      label: `👥 ${t('metro.tabFlow')}` },
  { key: 'train',     label: `🚇 ${t('metro.tabTrain')}` },
  { key: 'equipment', label: `⚙️ ${t('metro.tabEquip')}` },
  { key: 'revenue',   label: `💰 ${t('metro.tabRevenue')}` },
  { key: 'arch',      label: `🏗️ ${t('metro.tabArch')}` },
])

const activeTab  = ref('overview')
const initLoading = ref(false)
const seedLoading = ref(false)

const switchTab = (key) => { activeTab.value = key }

const handleInit = async () => {
  initLoading.value = true
  try {
    const res = await bjMetroApi.init()
    ElMessage[res.success ? 'success' : 'error'](res.msg)
  } finally { initLoading.value = false }
}

const handleSeed = async () => {
  seedLoading.value = true
  try {
    const res = await bjMetroApi.seed()
    ElMessage[res.success ? 'success' : 'error'](res.msg)
  } finally { seedLoading.value = false }
}
</script>

<style scoped>
.bjmetro-wrap {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #f5f6fa;
}

/* ── 子导航 ── */
.sub-nav {
  display: flex;
  align-items: center;
  gap: 0;
  background: #fff;
  border-bottom: 1px solid #e4e7ed;
  padding: 0 16px;
  height: 46px;
  flex-shrink: 0;
  box-shadow: 0 1px 4px rgba(0,0,0,.06);
}
.sub-nav-left {
  display: flex;
  align-items: center;
  gap: 8px;
  padding-right: 20px;
  border-right: 1px solid #e4e7ed;
  margin-right: 8px;
}
.sn-logo { font-size: 16px; }
.sn-title {
  color: #303133;
  font-weight: 600;
  font-size: 13px;
  white-space: nowrap;
}
.sn-tabs {
  display: flex;
  align-items: center;
  gap: 2px;
  flex: 1;
}
.sn-tab {
  padding: 6px 16px;
  border-radius: 4px;
  color: #606266;
  font-size: 13px;
  cursor: pointer;
  transition: all .2s;
  white-space: nowrap;
}
.sn-tab:hover { color: #409eff; background: #ecf5ff; }
.sn-tab.active {
  color: #409eff;
  background: #ecf5ff;
  font-weight: 600;
  position: relative;
}
.sn-tab.active::after {
  content: '';
  position: absolute;
  bottom: -6px;
  left: 16px;
  right: 16px;
  height: 2px;
  background: #409eff;
  border-radius: 1px;
}
.sn-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-left: auto;
}
.live-dot-wrap {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 3px 10px;
  background: #f0faf0;
  border: 1px solid #b7eb8f;
  border-radius: 10px;
  color: #52c41a;
  font-size: 11px;
  font-weight: 600;
}
.live-dot {
  width: 6px; height: 6px;
  border-radius: 50%;
  background: #52c41a;
  animation: blink 1.5s infinite;
}
@keyframes blink { 0%,100%{opacity:1} 50%{opacity:.3} }

/* ── 内容区 ── */
.tab-body {
  flex: 1;
  overflow-y: auto;
  padding: 14px 16px;
}
</style>
