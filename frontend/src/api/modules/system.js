import { http, httpBench, httpFast, httpLong } from '../http'

// ── 系统 ─────────────────────────────────────────────────────────
export const systemApi = {
  health: () => http.get('/system/health'),
  config: () => http.get('/system/config'),
}
