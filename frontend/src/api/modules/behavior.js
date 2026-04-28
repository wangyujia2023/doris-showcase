import { http, httpBench, httpFast, httpLong } from '../http'

// ── 行为分析 ─────────────────────────────────────────────────────
export const behaviorApi = {
  funnel: (data) => http.post('/behavior/funnel', data),
  retention: (data) => http.post('/behavior/retention', data),
  transaction: (params) => http.get('/behavior/transaction', { params }),
  rfm: () => http.get('/behavior/rfm'),
}
