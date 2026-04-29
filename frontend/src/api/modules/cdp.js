import { http } from '../http'

export const cdpApi = {
  tagMeta: () => http.get('/cdp/wide/tag-meta'),
  wideQuery: (data) => http.post('/cdp/wide/query', data),
  wideDistribution: () => http.get('/cdp/wide/distribution'),

  etlSync: () => http.post('/cdp/etl/sync'),
  etlOverview: () => http.get('/cdp/etl/overview'),

  bitmapCompute: (data) => http.post('/cdp/bitmap/compute', data),
  bitmapTwoSet: (data) => http.post('/cdp/bitmap/two-set', data),

  funnel: (data) => http.post('/cdp/behavior/funnel', data),
  retention: (data) => http.post('/cdp/behavior/retention', data),
  path: (topN = 10) => http.get('/cdp/behavior/path', { params: { top_n: topN } }),

  tgi: (data) => http.post('/cdp/portrait/tgi', data),
  cross: (data) => http.post('/cdp/portrait/cross', data),
  geo: (data) => http.post('/cdp/portrait/geo', data),
  targeting: (data) => http.post('/cdp/portrait/targeting', data),

  crowdSave: (data) => http.post('/cdp/crowd/save', data),
  crowdList: () => http.get('/cdp/crowd/list'),
  crowdDelete: (id) => http.delete(`/cdp/crowd/${id}`),
  crowdCompare: (data) => http.post('/cdp/crowd/compare', data),

  tagWeight: (data) => http.post('/cdp/tag/weight', data),
  tagAnomaly: () => http.get('/cdp/tag/anomaly'),
}
