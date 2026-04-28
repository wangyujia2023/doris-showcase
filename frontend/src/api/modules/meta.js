import { http, httpBench, httpFast, httpLong } from '../http'

// ── 元数据字典 ──────────────────────────────────────────────────────
export const metaApi = {
  dictionaries: (locale = '') => http.get('/meta/dictionaries', { params: { locale } }),
  dictionary: (name, locale = '') => http.get(`/meta/dictionaries/${name}`, { params: { locale } }),
}
