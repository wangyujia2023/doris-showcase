import { http, httpBench, httpFast, httpLong } from '../http'

// ── 链路追踪 ──────────────────────────────────────────────────────
export const traceApi = {
  list:   (params) => http.get('/trace/list', { params }),
  detail: (id) => http.get(`/trace/${id}`),
}
