import { http, httpBench, httpFast, httpLong } from '../http'

// ── 高并发压测 ────────────────────────────────────────────────────
export const benchmarkApi = {
  run:        (data) => httpBench.post('/benchmark/run', data),
  auditStats: (limit = 300) => http.get('/benchmark/audit-stats', { params: { limit } }),
}
