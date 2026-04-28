import { http, httpBench, httpFast, httpLong } from '../http'

// ── 智能制造 ─────────────────────────────────────────────────────
export const mfgApi = {
  init:            ()         => http.post('/mfg/init'),
  generate:        ()         => http.post('/mfg/generate'),
  batch:           (steps)    => http.post(`/mfg/batch?steps=${steps}`),
  overview:        ()         => http.get('/mfg/overview'),
  oeeTrend:        ()         => http.get('/mfg/oee-trend'),
  machineStatus:   ()         => http.get('/mfg/machine-status'),
  machineTrend:    (machine_id) => http.get('/mfg/machine-trend', { params: { machine_id } }),
  causal:          ()         => http.get('/mfg/causal'),
  detail:          (limit=60) => http.get('/mfg/detail', { params: { limit } }),
  qualityStats:    ()         => http.get('/mfg/quality-stats'),
  energyStats:     ()         => http.get('/mfg/energy-stats'),
  maintenanceStats:()         => http.get('/mfg/maintenance-stats'),
  processTrend:    ()         => http.get('/mfg/process-trend'),
  reset:           ()         => http.post('/mfg/reset'),
}
