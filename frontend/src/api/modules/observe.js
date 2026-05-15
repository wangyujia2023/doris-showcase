import { http, httpBench, httpFast, httpLong } from '../http'

// ── 日志可观测性 ───────────────────────────────────────────────────
export const observeApi = {
  logs:     (params) => http.get('/observe/logs', { params }),
  stats:    () => http.get('/observe/stats'),
  classify: () => http.post('/observe/classify'),
}
