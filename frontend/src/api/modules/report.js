import { http, httpBench, httpFast, httpLong } from '../http'

// ── 银行报表 ──────────────────────────────────────────────────────
export const reportApi = {
  overview:    () => http.get('/report/overview'),
  transaction: () => http.get('/report/transaction'),
  risk:        () => http.get('/report/risk'),
}
