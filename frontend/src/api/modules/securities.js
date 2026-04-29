import { http, httpBench, httpFast, httpLong } from '../http'

// ── 证券实时数仓 ────────────────────────────────────────────────
export const securitiesApi = {
  init:       () => http.post('/securities/init'),
  generate:   () => http.post('/securities/generate'),
  batch:      (steps) => http.post(`/securities/batch?steps=${steps}`),
  reset:      () => http.post('/securities/reset'),
  overview:   () => http.get('/securities/overview'),
  trend:      () => http.get('/securities/trend'),
  trades:     (limit = 60) => http.get('/securities/trades', { params: { limit } }),
  accounts:   () => http.get('/securities/accounts'),
  positions:  () => http.get('/securities/positions'),
  sectorHeat: () => http.get('/securities/securitiestor-heat'),
  riskAlerts: () => http.get('/securities/risk-alerts'),
  branches:   () => http.get('/securities/branches'),
}
