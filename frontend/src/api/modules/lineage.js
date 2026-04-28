import { http, httpBench, httpFast, httpLong } from '../http'

// ── 数据血缘 ────────────────────────────────────────────────────
export const lineageApi = {
  domains: () => http.get('/lineage/domains'),
  assets: (keyword = '') => http.get('/lineage/assets', { params: { keyword } }),
  asset: (assetId) => http.get(`/lineage/asset/${assetId}`),
  graph: (domain = '', depth = 2) => http.get('/lineage/graph', { params: { domain, depth } }),
  impact: (assetId) => http.get('/lineage/impact', { params: { asset_id: assetId } }),
  syncFromAudit: ({ start_date = '', end_date = '', limit = 0 } = {}) =>
    http.post('/lineage/sync-from-audit', null, { params: { start_date, end_date, limit } }),
  syncLogs: (limit = 50) => http.get('/lineage/sync-logs', { params: { limit } }),
  omLineage: (tableName) => http.get('/lineage/om-lineage', { params: { table_name: tableName } }),
  fieldLineage: (tableName) => http.get('/lineage/field-lineage', { params: { table_name: tableName } }),
}
