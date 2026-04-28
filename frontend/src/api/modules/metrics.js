import { http, httpBench, httpFast, httpLong } from '../http'

// ── 指标平台 ──────────────────────────────────────────────────────
export const metricsApi = {
  definitions: ()     => http.get('/metrics/definitions'),
  templates:   ()     => http.get('/metrics/templates'),
  query:       (data) => http.post('/metrics/query', data),
  compare:     (data) => http.post('/metrics/compare', data),
  drilldown:   (data) => http.post('/metrics/drilldown', data),
  saveQuery:   (data) => http.post('/metrics/saved', data),
  listSaved:   ()     => http.get('/metrics/saved'),
  deleteSaved: (id)   => http.delete(`/metrics/saved/${id}`),
  history:     ()     => http.get('/metrics/history'),
}
