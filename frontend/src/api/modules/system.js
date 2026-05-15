import { http, httpBench, httpFast, httpLong } from '../http'

// ── 系统 ─────────────────────────────────────────────────────────
export const systemApi = {
  health: () => http.get('/system/health'),
  config: () => http.get('/system/config'),
  saveInitConfig: (data) => http.post('/system/init/config', data),
  testInitConfig: (data) => http.post('/system/init/test', data),
  testInitLlm: (data) => httpLong.post('/system/init/llm-test', data),
  initDatabase: (mode) => httpLong.post('/system/init/database', { mode }),
}
