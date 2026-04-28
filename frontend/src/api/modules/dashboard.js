import { http, httpBench, httpFast, httpLong } from '../http'

// ── 大盘 ─────────────────────────────────────────────────────────
export const dashboardApi = {
  overview: () => httpFast.get('/dashboard'),
}
