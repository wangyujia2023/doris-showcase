<template>
  <div>
    <!-- 核心指标 -->
    <div class="stat-row">
      <div class="stat-card">
        <div class="stat-label">{{ t('dashboard.totalUsers') }}</div>
        <div class="stat-value" style="color:#409eff">{{ fmt(data.user_stat?.total_users) }}</div>
        <div class="stat-sub">{{ t('dashboard.activeUsersSub').replace('{0}', fmt(data.user_stat?.active_users)) }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">{{ t('dashboard.todayLogs') }}</div>
        <div class="stat-value" style="color:#67c23a">{{ fmt(data.log_stat?.total_logs) }}</div>
        <div class="stat-sub">{{ t('dashboard.aiTaggedSub').replace('{0}', fmt(data.log_stat?.log_users)) }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">{{ t('dashboard.anomalyLogs') }}</div>
        <div class="stat-value" style="color:#f56c6c">{{ fmt(data.log_stat?.high_risk_logs) }}</div>
        <div class="stat-sub">{{ t('dashboard.anomalyOpsSub').replace('{0}', fmt(data.log_stat?.anomaly_logs)) }}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">{{ t('dashboard.activeCrowd') }}</div>
        <div class="stat-value" style="color:#e6a23c">{{ fmt(data.segment_stat?.total_segments) }}</div>
        <div class="stat-sub">{{ t('dashboard.coverUsersSub').replace('{0}', fmt(data.segment_stat?.total_crowd)) }}</div>
      </div>
    </div>

    <el-row :gutter="16">
      <el-col :span="16">
        <div class="card">
          <div class="card-title">{{ t('dashboard.logTrend') }}</div>
          <v-chart :option="trendOption" style="height:280px" autoresize />
        </div>
      </el-col>
      <el-col :span="8">
        <div class="card">
          <div class="card-title">{{ t('dashboard.assetDist') }}</div>
          <v-chart :option="assetOption" style="height:280px" autoresize />
        </div>
      </el-col>
    </el-row>

    <!-- 快捷入口 -->
    <div class="card">
      <div class="card-title">{{ t('dashboard.quickEntry') }}</div>
      <el-row :gutter="12">
        <el-col :span="6" v-for="item in shortcuts" :key="item.path">
          <el-card
            shadow="hover"
            style="cursor:pointer;text-align:center;padding:16px 0"
            @click="$router.push(item.path)"
          >
            <el-icon :size="32" :color="item.color"><component :is="item.icon" /></el-icon>
            <div style="margin-top:8px;font-size:14px;font-weight:500">{{ item.label }}</div>
            <div style="font-size:12px;color:#909399;margin-top:4px">{{ item.desc }}</div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 异常用户预警 -->
    <div class="card">
      <div class="card-title">{{ t('dashboard.anomalyAlert') }}</div>
      <el-table :data="anomalyUsers" stripe size="small">
        <el-table-column prop="user_id"   :label="t('dashboard.userId')" width="100" />
        <el-table-column prop="user_name" :label="t('dashboard.name')"   width="90" />
        <el-table-column prop="asset_level" :label="t('dashboard.assetLevel')" width="100">
          <template #default="{row}">
            <el-tag :type="assetTagType(row.asset_level)" size="small">{{ row.asset_level }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="city"      :label="t('dashboard.city')"   width="80" />
        <el-table-column :label="t('dashboard.anomalyType')">
          <template #default>
            <el-tag type="danger" size="small">{{ t('dashboard.anomalyTypeVal') }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column :label="t('dashboard.riskLevel')" width="90">
          <template #default><el-tag type="danger" size="small">{{ t('dashboard.riskHigh') }}</el-tag></template>
        </el-table-column>
        <el-table-column :label="t('common.operation')" width="120">
          <template #default="{row}">
            <el-button type="primary" size="small" link @click="$router.push(`/user?user_id=${row.user_id}`)">
              {{ t('common.detail') }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import VChart from 'vue-echarts'
import { dashboardApi, userApi } from '@/api'
import { t, locale } from '@/i18n'

const data = ref({ user_stat: {}, log_stat: {}, segment_stat: {}, asset_level_dist: [], log_trend: [] })
const anomalyUsers = ref([])

const fmt = (v) => v == null ? '-' : Number(v).toLocaleString()

const shortcuts = computed(() => [
  { path: '/user',     icon: 'User',        color: '#409eff', ...t('dashboard.scUser') },
  { path: '/segment',  icon: 'Grid',        color: '#67c23a', ...t('dashboard.scSegment') },
  { path: '/behavior', icon: 'TrendCharts', color: '#e6a23c', ...t('dashboard.scBehavior') },
  { path: '/ai-tag',   icon: 'MagicStick',  color: '#f56c6c', ...t('dashboard.scAiTag') },
])

const assetTagType = (level) => ({
  'VIP私行': 'danger', 'VIP钻石': 'warning', 'VIP铂金': '', 'VIP黄金': 'success'
}[level] || 'info')

const trendOption = computed(() => {
  const trend = data.value.log_trend || []
  return {
    tooltip: { trigger: 'axis' },
    legend: { data: [t('dashboard.legendTotal'), t('dashboard.legendRisk')], top: 0 },
    grid: { left: 40, right: 20, top: 36, bottom: 30 },
    xAxis: { type: 'category', data: trend.map(r => r.date || r.log_date) },
    yAxis: { type: 'value' },
    series: [
      {
        name: t('dashboard.legendTotal'), type: 'line', smooth: true,
        data: trend.map(r => r.log_count),
        areaStyle: { opacity: 0.15 },
        lineStyle: { color: '#409eff' }, itemStyle: { color: '#409eff' }
      },
      {
        name: t('dashboard.legendRisk'), type: 'bar',
        data: trend.map(r => r.risk_count),
        itemStyle: { color: '#f56c6c' }
      }
    ]
  }
})

const assetOption = computed(() => ({
  tooltip: { trigger: 'item' },
  legend: { bottom: 0, left: 'center' },
  series: [{
    type: 'pie', radius: ['40%', '65%'], center: ['50%', '44%'],
    data: (data.value.asset_level_dist || []).map(r => ({ name: r.label, value: r.value })),
    label: { formatter: '{b}: {d}%' }
  }]
}))

onMounted(async () => {
  try {
    data.value = await dashboardApi.overview()
  } catch {}
  userApi.queryWide({ anomaly_flag: 1, page_size: 5 })
    .then(res => { anomalyUsers.value = res.rows || [] })
    .catch(() => { anomalyUsers.value = [] })
})
</script>
