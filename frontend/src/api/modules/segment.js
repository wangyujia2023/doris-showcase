import { http, httpBench, httpFast, httpLong } from '../http'

// ── 人群圈选 ─────────────────────────────────────────────────────
export const segmentApi = {
  count: (data) => http.post('/segment/count', data),
  create: (data) => http.post('/segment/create', data),
  list: () => http.get('/segment/list'),
  delete: (id) => http.delete(`/segment/${id}`),
  users: (id, page, size) => http.get(`/segment/${id}/users`, { params: { page, size } }),
  stats: (id) => http.get(`/segment/${id}/stats`),
}
