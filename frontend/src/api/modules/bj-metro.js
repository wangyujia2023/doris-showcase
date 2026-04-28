import { http, httpBench, httpFast, httpLong } from '../http'

// ── 北京地铁运营分析 ───────────────────────────────────────────────
export const bjMetroApi = {
  init:  () => http.post('/bjmetro/init'),
  seed:  () => http.post('/bjmetro/seed'),

  // 运营总览（合并接口）
  overviewAll:        () => http.get('/bjmetro/overview/all'),
  overviewKpi:        () => http.get('/bjmetro/overview/kpi'),
  overviewFlowTrend:  () => http.get('/bjmetro/overview/flow-trend'),
  overviewLineRanking:() => http.get('/bjmetro/overview/line-ranking'),
  overviewPunctuality:() => http.get('/bjmetro/overview/punctuality'),
  overviewAlerts:     () => http.get('/bjmetro/overview/alerts'),
  overviewLineStatus: () => http.get('/bjmetro/overview/line-status'),

  // 客流分析
  flowHourly:         () => http.get('/bjmetro/flow/hourly'),
  flowHotStations:    () => http.get('/bjmetro/flow/hot-stations'),
  flowOdPairs:        (peakType = 'morning') => http.get('/bjmetro/flow/od-pairs', { params: { peak_type: peakType } }),
  flowTrend:          () => http.get('/bjmetro/flow/trend'),

  // 列车运行
  trainKpi:           () => http.get('/bjmetro/train/kpi'),
  trainPunctTrend:    () => http.get('/bjmetro/train/punctuality-trend'),
  trainFaultTypes:    () => http.get('/bjmetro/train/fault-types'),
  trainList:          () => http.get('/bjmetro/train/list'),

  // 设备安全
  equipKpi:           () => http.get('/bjmetro/equipment/kpi'),
  equipFaultDist:     () => http.get('/bjmetro/equipment/fault-dist'),
  equipFaultByLine:   () => http.get('/bjmetro/equipment/fault-by-line'),
  equipMaintLog:      () => http.get('/bjmetro/equipment/maintenance-log'),

  // 经营收益
  revenueKpi:         () => http.get('/bjmetro/revenue/kpi'),
  revenueTrend:       () => http.get('/bjmetro/revenue/trend'),
  revenueTicketTypes: () => http.get('/bjmetro/revenue/ticket-types'),
  revenueByLine:      () => http.get('/bjmetro/revenue/by-line'),
}
