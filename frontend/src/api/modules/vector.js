import { http, httpBench, httpFast, httpLong } from '../http'

// ── HASP 向量检索 ────────────────────────────────────────────────
export const vectorApi = {
  init: () => httpLong.post('/vector/init'),   // 20 分钟超时
  clear: () => http.post('/vector/clear'),
  users: () => http.get('/vector/users'),
  labels: () => http.get('/vector/labels'),
  dimLabels: () => http.get('/vector/dim-labels'),
  searchUsers: (data) => http.post('/vector/search/users', data),
  searchLabels: (data) => http.post('/vector/search/labels', data),
  searchHybrid: (data) => http.post('/vector/search/hybrid', data),
  searchByPhoto: (formData) => http.post('/vector/search/by-photo', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  }),
  uploadUser: (formData) => http.post('/vector/users/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  }),
}
