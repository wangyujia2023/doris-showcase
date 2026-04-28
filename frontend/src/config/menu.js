export const menuGroups = [
  {
    key: 'root',
    items: [
      { path: '/dashboard', titleKey: 'menu.dashboard', icon: 'Odometer' },
    ],
  },
  {
    titleKey: 'group.userProfile',
    items: [
      { path: '/user', titleKey: 'menu.userWide', icon: 'User' },
      { path: '/user-analysis', titleKey: 'menu.userAnalysis', icon: 'Grid' },
      { path: '/log-classify', titleKey: 'menu.logClassify', icon: 'Cpu' },
    ],
  },
  {
    titleKey: 'group.hasp',
    items: [
      { path: '/vector', titleKey: 'menu.vector', icon: 'Coin' },
      { path: '/satellite', titleKey: 'menu.satellite', icon: 'Promotion' },
    ],
  },
  {
    titleKey: 'group.dataCapability',
    items: [
      { path: '/regulatory', titleKey: 'menu.regulatory', icon: 'Tickets' },
      { path: '/report', titleKey: 'menu.report', icon: 'Document' },
      { path: '/metrics', titleKey: 'menu.metrics', icon: 'DataAnalysis' },
      { path: '/observe', titleKey: 'menu.observe', icon: 'Monitor' },
      { path: '/log-tag-stats', titleKey: 'menu.logTagStats', icon: 'PriceTag' },
      { path: '/trace', titleKey: 'menu.trace', icon: 'Share' },
      { path: '/benchmark', titleKey: 'menu.benchmark', icon: 'Histogram' },
    ],
  },
  {
    titleKey: 'group.manufacturing',
    items: [{ path: '/manufacturing', titleKey: 'menu.manufacturing', icon: 'SetUp' }],
  },
  {
    titleKey: 'group.traffic',
    items: [{ path: '/bjmetro', titleKey: 'menu.bjmetro', icon: 'DataAnalysis' }],
  },
  {
    titleKey: 'group.securities',
    items: [{ path: '/securities', titleKey: 'menu.securities', icon: 'WalletFilled' }],
  },
  {
    titleKey: 'group.fund',
    items: [
      { path: '/fund', titleKey: 'menu.fund', icon: 'TrendCharts' },
      { path: '/news', titleKey: 'menu.news', icon: 'Cpu' },
      { path: '/lineage', titleKey: 'menu.lineage', icon: 'Share' },
    ],
  },
  {
    titleKey: 'group.system',
    items: [{ path: '/config', titleKey: 'menu.config', icon: 'Setting' }],
  },
]
