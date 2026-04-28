import { http, httpBench, httpFast, httpLong } from '../http'

// 监管报送一表通
export const regulatoryApi = {
  init:       () => http.post('/regulatory/init'),
  seed:       () => http.post('/regulatory/seed'),
  process:    () => http.post('/regulatory/process'),
  master:     () => http.get('/regulatory/master'),
  overview:   () => http.get('/regulatory/overview'),
  submitLog:  () => http.get('/regulatory/submit-log'),
  qc:         (period) => http.get('/regulatory/qc', { params: { period } }),
  // 新增接口
  nav:        () => http.get('/regulatory/nav'),
  reportData: (code, period) => http.get(`/regulatory/report/${code}`, { params: { period } }),
  indicators: () => http.get('/regulatory/indicators'),
  calendar:   () => http.get('/regulatory/calendar'),
  history:    () => http.get('/regulatory/history'),
}
