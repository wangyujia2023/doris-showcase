<template>
  <div>
    <div class="home-wrap">
      <div class="stat-row">
        <div class="stat-card">
          <div class="stat-label">{{ t('dashboard.totalUsers') }}</div>
          <div class="stat-value" style="color:#409eff">{{ fmt(homeData.user_stat?.total_users) }}</div>
          <div class="stat-sub">{{ t('dashboard.activeUsersSub').replace('{0}', fmt(homeData.user_stat?.active_users)) }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">{{ t('dashboard.todayLogs') }}</div>
          <div class="stat-value" style="color:#67c23a">{{ fmt(homeData.log_stat?.total_logs) }}</div>
          <div class="stat-sub">{{ t('dashboard.aiTaggedSub').replace('{0}', fmt(homeData.log_stat?.log_users)) }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">{{ t('dashboard.anomalyLogs') }}</div>
          <div class="stat-value" style="color:#f56c6c">{{ fmt(homeData.log_stat?.high_risk_logs) }}</div>
          <div class="stat-sub">{{ t('dashboard.anomalyOpsSub').replace('{0}', fmt(homeData.log_stat?.anomaly_logs)) }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">{{ t('dashboard.activeCrowd') }}</div>
          <div class="stat-value" style="color:#e6a23c">{{ fmt(homeData.segment_stat?.total_segments) }}</div>
          <div class="stat-sub">{{ t('dashboard.coverUsersSub').replace('{0}', fmt(homeData.segment_stat?.total_crowd)) }}</div>
        </div>
      </div>

      <el-row :gutter="16">
        <el-col :span="16">
          <div class="card">
            <div class="card-title">{{ t('dashboard.logTrend') }}</div>
            <v-chart :option="homeTrendOption" style="height:280px" autoresize />
          </div>
        </el-col>
        <el-col :span="8">
          <div class="card">
            <div class="card-title">{{ t('dashboard.assetDist') }}</div>
            <v-chart :option="homeAssetOption" style="height:280px" autoresize />
          </div>
        </el-col>
      </el-row>

      <div class="card quick-card">
        <div class="card-title">{{ t('dashboard.quickEntry') }}</div>
        <el-row :gutter="8">
          <el-col :span="6" v-for="item in shortcuts" :key="item.path">
            <el-card shadow="hover" class="quick-entry" @click="$router.push(item.path)">
              <el-icon :size="24" :color="item.color"><component :is="item.icon" /></el-icon>
              <div class="quick-text">
                <div class="quick-label">{{ item.label }}</div>
                <div class="quick-desc">{{ item.desc }}</div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>

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

    <div class="management-wrap">
      <el-row :gutter="16" style="margin-bottom: 20px">
        <el-col :span="6"><div class="kpi kpi-1"><div class="kpi-label">{{ t('mgmt.revenue') }}</div><div class="kpi-value">{{ fmt(mgmtComputed.biz.revenue) }}</div><div class="kpi-unit">{{ t('mgmt.unit') }}</div></div></el-col>
        <el-col :span="6"><div class="kpi kpi-2"><div class="kpi-label">{{ t('mgmt.profit') }}</div><div class="kpi-value">{{ fmt(mgmtComputed.biz.profit) }}</div><div class="kpi-unit">{{ t('mgmt.unit') }}</div></div></el-col>
        <el-col :span="6"><div class="kpi kpi-3"><div class="kpi-label">{{ t('mgmt.aum') }}</div><div class="kpi-value">{{ fmt(mgmtComputed.totalAUM / 100000000) }}B</div><div class="kpi-unit">{{ t('mgmt.unit') }}</div></div></el-col>
        <el-col :span="6"><div class="kpi kpi-4"><div class="kpi-label">{{ t('mgmt.risk') }}</div><div class="kpi-value">{{ fmt(mgmtComputed.totalRiskExposure / 100000000) }}B</div><div class="kpi-unit">{{ t('mgmt.unit') }}</div></div></el-col>
      </el-row>

      <el-row :gutter="16" style="margin-bottom: 20px">
        <el-col :span="14"><div class="card"><div class="card-title">{{ t('mgmt.trendTitle') }}</div><v-chart :option="mgmtComputed.trendOption" style="height: 320px" autoresize /></div></el-col>
        <el-col :span="10"><div class="card"><div class="card-title">{{ t('mgmt.aumTitle') }}</div><v-chart :option="mgmtComputed.aumOption" style="height: 320px" autoresize /></div></el-col>
      </el-row>

      <el-row :gutter="16" style="margin-bottom: 20px">
        <el-col :span="12"><div class="card"><div class="card-title">{{ t('mgmt.posTitle') }}</div><v-chart :option="mgmtComputed.positionOption" style="height: 280px" autoresize /></div></el-col>
        <el-col :span="12"><div class="card"><div class="card-title">{{ t('mgmt.riskTitle') }}</div><el-table :data="mgmtComputed.risk" stripe size="small" style="margin-bottom:16px"><el-table-column prop="risk_level" :label="t('mgmt.colRiskLevel')" width="100" align="center"><template #default="{ row }"><el-tag :type="riskType(row.risk_level)" size="small">{{ row.risk_level }}</el-tag></template></el-table-column><el-table-column prop="exposure_amount" :label="t('mgmt.colExposure')" align="right"><template #default="{ row }">{{ fmt(row.exposure_amount / 100000000) }}B</template></el-table-column><el-table-column prop="default_count" :label="t('mgmt.colDefault')" width="80" align="center" /></el-table></div></el-col>
      </el-row>

      <el-row :gutter="16">
        <el-col :span="12"><div class="card"><div class="card-title">{{ t('mgmt.aumDetailTitle') }}</div><el-table :data="mgmtComputed.aum" stripe size="small"><el-table-column prop="product_type" :label="t('mgmt.colProduct')" width="120" /><el-table-column prop="aum_amount" :label="t('mgmt.colAum')" align="right"><template #default="{ row }">{{ fmt(row.aum_amount / 100000000) }}B</template></el-table-column><el-table-column prop="client_count" :label="t('mgmt.colClients')" width="100" align="center" /><el-table-column prop="yoy_growth" :label="t('mgmt.colYoy')" width="80" align="right"><template #default="{ row }">{{ row.yoy_growth }}%</template></el-table-column></el-table></div></el-col>
        <el-col :span="12"><div class="card"><div class="card-title">{{ t('mgmt.productTitle') }}</div><el-table :data="mgmtComputed.products" stripe size="small"><el-table-column prop="product_name" :label="t('mgmt.colName')" width="130" /><el-table-column prop="sales_amount" :label="t('mgmt.colSales')" align="right" width="120"><template #default="{ row }">{{ fmt(row.sales_amount / 1000000) }}M</template></el-table-column><el-table-column prop="success_rate" :label="t('mgmt.colSuccessRate')" width="80" align="right"><template #default="{ row }">{{ row.success_rate }}%</template></el-table-column><el-table-column prop="rating" :label="t('mgmt.colRating')" width="70" align="center"><template #default="{ row }"><span style="color: #f5a623">⭐ {{ row.rating }}</span></template></el-table-column></el-table></div></el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import VChart from 'vue-echarts'
import { dashboardApi, userApi, managementApi } from '@/api'
import { t } from '@/i18n'
import { registerEchartsBasic } from '@/plugins/registerEchartsBasic'

registerEchartsBasic()

const homeData = ref({ user_stat: {}, log_stat: {}, segment_stat: {}, asset_level_dist: [], log_trend: [] })
const anomalyUsers = ref([])
const mgmt = ref({
  biz: {}, aum: [], risk: [], position: [], products: [], trend: [],
  totalAUM: 0, totalRiskExposure: 0,
})

const fmt = (v) => v == null ? '-' : Number(v).toLocaleString('zh-CN', { maximumFractionDigits: 0 })

const shortcuts = computed(() => [
  { path: '/user', icon: 'User', color: '#409eff', ...t('dashboard.scUser') },
  { path: '/user-analysis?tab=crowd', icon: 'Grid', color: '#67c23a', ...t('dashboard.scSegment') },
  { path: '/user-analysis?tab=behavior', icon: 'TrendCharts', color: '#e6a23c', ...t('dashboard.scBehavior') },
  { path: '/user-tag', icon: 'MagicStick', color: '#f56c6c', ...t('dashboard.scAiTag') },
])

const assetTagType = (level) => ({ 'VIP私行': 'danger', 'VIP钻石': 'warning', 'VIP铂金': '', 'VIP黄金': 'success' }[level] || 'info')
const riskType = (level) => ({ '低': 'success', '中': 'warning', '高': 'danger', '极高': 'danger' }[level] || 'info')

const homeTrendOption = computed(() => {
  const trend = homeData.value.log_trend || []
  return {
    tooltip: { trigger: 'axis' },
    legend: { data: [t('dashboard.legendTotal'), t('dashboard.legendRisk')], top: 0 },
    grid: { left: 40, right: 20, top: 36, bottom: 30 },
    xAxis: { type: 'category', data: trend.map(r => r.date || r.log_date) },
    yAxis: { type: 'value' },
    series: [
      { name: t('dashboard.legendTotal'), type: 'line', smooth: true, data: trend.map(r => r.log_count), areaStyle: { opacity: 0.15 }, lineStyle: { color: '#409eff' }, itemStyle: { color: '#409eff' } },
      { name: t('dashboard.legendRisk'), type: 'bar', data: trend.map(r => r.risk_count), itemStyle: { color: '#f56c6c' } },
    ],
  }
})

const homeAssetOption = computed(() => ({
  tooltip: { trigger: 'item' },
  legend: { bottom: 0, left: 'center' },
  series: [{
    type: 'pie', radius: ['40%', '65%'], center: ['50%', '44%'],
    data: (homeData.value.asset_level_dist || []).map(r => ({ name: r.label, value: r.value })),
    label: { formatter: '{b}: {d}%' }
  }]
}))

const mgmtComputed = computed(() => {
  const aum = mgmt.value.aum || []
  const risk = mgmt.value.risk || []
  return {
    ...mgmt.value,
    totalAUM: aum.reduce((sum, item) => sum + (item.aum_amount || 0), 0),
    totalRiskExposure: risk.reduce((sum, item) => sum + (item.exposure_amount || 0), 0),
    trendOption: {
      tooltip: { trigger: 'axis' },
      legend: { data: [t('mgmt.legRevenue'), t('mgmt.legProfit')], top: 0 },
      grid: { left: 50, right: 20, top: 36, bottom: 30 },
      xAxis: { type: 'category', data: (mgmt.value.trend || []).map(r => r.metric_date) },
      yAxis: { type: 'value' },
      series: [
        { name: t('mgmt.legRevenue'), type: 'line', smooth: true, data: (mgmt.value.trend || []).map(r => r.revenue / 100000000), lineStyle: { color: '#667eea', width: 2 }, areaStyle: { color: '#667eea', opacity: 0.1 } },
        { name: t('mgmt.legProfit'), type: 'line', smooth: true, data: (mgmt.value.trend || []).map(r => r.profit / 100000000), lineStyle: { color: '#f5576c', width: 2 }, areaStyle: { color: '#f5576c', opacity: 0.1 } },
      ]
    },
    aumOption: {
      tooltip: { trigger: 'item' },
      legend: { bottom: 0, left: 'center' },
      series: [{
        type: 'pie', radius: ['35%', '65%'], center: ['50%', '45%'],
        data: aum.map(r => ({ name: r.product_type, value: r.aum_amount })),
        label: { formatter: '{b}: {d}%' }
      }]
    },
    positionOption: {
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: 80, right: 20, top: 20, bottom: 30 },
      xAxis: { type: 'category', data: (mgmt.value.position || []).map(r => r.asset_class) },
      yAxis: { type: 'value' },
      series: [{
        type: 'bar',
        data: (mgmt.value.position || []).map(r => r.position_amount / 100000000),
        itemStyle: { color: '#4facfe' },
        label: { show: true, position: 'top', formatter: '{c}B' }
      }]
    },
  }
})

onMounted(async () => {
  try { homeData.value = await dashboardApi.overview() } catch {}
  userApi.queryWide({ anomaly_flag: 1, page_size: 5 }).then(res => { anomalyUsers.value = res.rows || [] }).catch(() => { anomalyUsers.value = [] })
  try {
    const data = await managementApi.overview()
    mgmt.value = data
  } catch {}
})
</script>

<style scoped>
.management-wrap {
  margin-top: 4px;
}
.quick-card {
  padding: 14px 16px;
}
.quick-entry {
  cursor: pointer;
}
.quick-entry :deep(.el-card__body) {
  min-height: 58px;
  padding: 8px 10px;
  display: flex;
  align-items: center;
  gap: 9px;
  text-align: left;
}
.quick-text {
  min-width: 0;
}
.quick-label {
  font-size: 13px;
  font-weight: 600;
  color: #303133;
  line-height: 1.25;
}
.quick-desc {
  margin-top: 2px;
  font-size: 11px;
  color: #909399;
  line-height: 1.25;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.kpi {
  padding: 20px;
  border-radius: 8px;
  color: #fff;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.kpi-1 { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.kpi-2 { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
.kpi-3 { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
.kpi-4 { background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); }
.kpi-label {
  font-size: 14px;
  opacity: 0.9;
  margin-bottom: 8px;
}
.kpi-value {
  font-size: 28px;
  font-weight: 700;
  margin-bottom: 4px;
}
.kpi-unit {
  font-size: 12px;
  opacity: 0.8;
}
</style>
