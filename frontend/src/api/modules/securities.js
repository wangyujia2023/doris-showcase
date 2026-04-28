import { http, httpBench, httpFast, httpLong } from '../http'

// ── 证券实时数仓 ────────────────────────────────────────────────
export const securitiesApi = {
  init:       () => http.post('/sec/init'),
  generate:   () => http.post('/sec/generate'),
  batch:      (steps) => http.post(`/sec/batch?steps=${steps}`),
  reset:      () => http.post('/sec/reset'),
  overview:   () => http.get('/sec/overview'),
  trend:      () => http.get('/sec/trend'),
  trades:     (limit = 60) => http.get('/sec/trades', { params: { limit } }),
  accounts:   () => http.get('/sec/accounts'),
  positions:  () => http.get('/sec/positions'),
  sectorHeat: () => http.get('/sec/sector-heat'),
  riskAlerts: () => http.get('/sec/risk-alerts'),
  branches:   () => http.get('/sec/branches'),
}
