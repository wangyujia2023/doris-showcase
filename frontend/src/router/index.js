import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/',           redirect: '/dashboard' },
  { path: '/dashboard',  component: () => import('@/views/Dashboard.vue'),   meta: { titleKey: 'menu.dashboard' } },
  { path: '/management', redirect: '/dashboard' },
  { path: '/user',       component: () => import('@/views/UserWide.vue'),     meta: { titleKey: 'menu.userWide' } },
  { path: '/user-analysis', component: () => import('@/views/UserTagAnalysis.vue'), meta: { titleKey: 'menu.userAnalysis', defaultTab: 'crowd' } },
  { path: '/segment',    redirect: '/user-analysis?tab=crowd' },
  { path: '/behavior',   redirect: '/user-analysis?tab=behavior' },
  { path: '/user-tag',   redirect: '/user-analysis?tab=taganalysis' },
  { path: '/log-classify',  component: () => import('@/views/LogClassifyAnalysis.vue'), meta: { titleKey: 'menu.logClassify' } },
  { path: '/vector',        component: () => import('@/views/VectorSearch.vue'),        meta: { titleKey: 'menu.vector' } },
  { path: '/report',        component: () => import('@/views/BankReport.vue'),          meta: { titleKey: 'menu.report' } },
  { path: '/metrics',       component: () => import('@/views/MetricsPlatform.vue'),     meta: { titleKey: 'menu.metrics' } },
  { path: '/observe',       component: () => import('@/views/LogObserve.vue'),          meta: { titleKey: 'menu.observe' } },
  { path: '/trace',         component: () => import('@/views/TraceView.vue'),           meta: { titleKey: 'menu.trace' } },
  { path: '/satellite',     component: () => import('@/views/Satellite.vue'),           meta: { titleKey: 'menu.satellite' } },
  { path: '/benchmark',     component: () => import('@/views/Benchmark.vue'),           meta: { titleKey: 'menu.benchmark' } },
  { path: '/manufacturing', component: () => import('@/views/Manufacturing.vue'),       meta: { titleKey: 'menu.manufacturing' } },
  { path: '/securities',    component: () => import('@/views/Securities.vue'),          meta: { titleKey: 'menu.securities' } },
  { path: '/fund',          component: () => import('@/views/Fund.vue'),                meta: { titleKey: 'menu.fund' } },
  { path: '/news',          component: () => import('@/views/NewsInsight.vue'),          meta: { titleKey: 'menu.news' } },
  { path: '/bjmetro',       component: () => import('@/views/BJMetro.vue'),               meta: { titleKey: 'menu.bjmetro' } },
  { path: '/regulatory',    component: () => import('@/views/Regulatory.vue'),             meta: { titleKey: 'menu.regulatory' } },
  { path: '/lineage',       component: () => import('@/views/Lineage.vue'),               meta: { titleKey: 'menu.lineage' } },
  { path: '/init-wizard',   component: () => import('@/views/InitWizard.vue'),           meta: { titleKey: 'menu.initWizard' } },
  { path: '/config',        component: () => import('@/views/SysConfig.vue'),           meta: { titleKey: 'menu.config' } },
]

export default createRouter({
  history: createWebHistory(),
  routes,
})
