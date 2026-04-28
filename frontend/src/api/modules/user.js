import { http, httpBench, httpFast, httpLong } from '../http'

// ── 用户宽表 ─────────────────────────────────────────────────────
export const userApi = {
  queryWide: (params) => http.get('/user/wide', { params }),
  getDetail: (userId) => http.get(`/user/${userId}`),
}
