import { http, httpBench, httpFast, httpLong } from '../http'

// ── 经营管理大屏 ──────────────────────────────────────────────────
export const managementApi = {
  overview: () => http.get('/management'),
}
