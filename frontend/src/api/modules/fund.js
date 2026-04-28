import { http, httpBench, httpFast, httpLong } from '../http'

// ── 基金数字沙盘 ──────────────────────────────────────────────────
export const fundApi = {
  init:        ()         => http.post('/fund/init'),
  generate:    ()         => http.post('/fund/generate'),
  batch:       (days)     => http.post(`/fund/batch?days=${days}`),
  reset:       ()         => http.post('/fund/reset'),
  overview:    ()         => http.get('/fund/overview'),
  list:        (params)   => http.get('/fund/list', { params }),
  detail:      (id)       => http.get(`/fund/detail/${id}`),
  nav:         (id, days) => http.get(`/fund/nav/${id}`, { params: { days } }),
  position:    (id)       => http.get(`/fund/position/${id}`),
  manager:     (mgr_id)   => http.get(`/fund/manager/${mgr_id}`),
  peers:       (id)       => http.get(`/fund/peers/${id}`),
  sectorStats: ()         => http.get('/fund/sector-stats'),
}
