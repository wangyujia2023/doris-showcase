import { http, httpBench, httpFast, httpLong } from '../http'

// ── AI 日志标签分析 ──────────────────────────────────────────────
export const tagAnalysisApi = {
  overview: () => http.get('/tag-analysis/overview'),
  users: (params) => http.get('/tag-analysis/users', { params }),
  risk: () => http.get('/tag-analysis/risk'),
  cross: () => http.get('/tag-analysis/cross'),
  cooccurrence: () => http.get('/tag-analysis/cooccurrence'),
  runClassify: () => http.post('/tag-analysis/run-classify'),
}
