import { http, httpBench, httpFast, httpLong } from '../http'

// ── 卫星数据采集 ──────────────────────────────────────────────────
export const satelliteApi = {
  init:     () => http.post('/satellite/init'),
  overview: () => http.get('/satellite/overview'),
  charts:   () => http.get('/satellite/charts'),
  query:    (params) => http.get('/satellite/query', { params }),
}
