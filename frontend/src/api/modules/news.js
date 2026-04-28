import { http, httpBench, httpFast, httpLong } from '../http'

// ── 基金资讯 AI Function ──────────────────────────────────────────
export const newsApi = {
  init:        ()         => http.post('/news/init'),
  import:      ()         => http.post('/news/import'),
  addManual:   (title, content, source, sector) => http.post('/news/add-manual', { title, content, source, sector }),
  list:        (params)   => http.get('/news/list', { params }),
  detail:      (id)       => http.get(`/news/detail/${id}`),
  stats:       ()         => http.get('/news/stats'),
  summarize:   (ids)      => http.post('/news/summarize',  { article_ids: ids || null }),
  sentiment:   (ids)      => http.post('/news/sentiment',  { article_ids: ids || null }),
  extract:     (ids)      => http.post('/news/extract',    { article_ids: ids || null }),
  runAllAI:    ()         => http.post('/news/run-all-ai'),  // 3合1：同时执行 SUMMARIZE + SENTIMENT + EXTRACT
  tagAnalysis:    ()      => http.get('/news/tag-analysis'),
  sectorMetrics:  ()      => http.get('/news/sector-metrics'),
  signals:        ()      => http.get('/news/signals'),
  hotCompanies:   ()      => http.get('/news/hot-companies'),
}
