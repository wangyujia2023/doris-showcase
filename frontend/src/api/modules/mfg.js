import { http, httpBench, httpFast, httpLong } from '../http'

// ── 智能制造 ─────────────────────────────────────────────────────
export const mfgApi = {
  init:            ()         => http.post('/manufacturing/init'),
  generate:        ()         => http.post('/manufacturing/generate'),
  batch:           (steps)    => http.post(`/manufacturing/batch?steps=${steps}`),
  overview:        ()         => http.get('/manufacturing/overview'),
  oeeTrend:        ()         => http.get('/manufacturing/oee-trend'),
  machineStatus:   ()         => http.get('/manufacturing/machine-status'),
  machineTrend:    (machine_id) => http.get('/manufacturing/machine-trend', { params: { machine_id } }),
  causal:          ()         => http.get('/manufacturing/causal'),
  detail:          (limit=60) => http.get('/manufacturing/detail', { params: { limit } }),
  qualityStats:    ()         => http.get('/manufacturing/quality-stats'),
  energyStats:     ()         => http.get('/manufacturing/energy-stats'),
  maintenanceStats:()         => http.get('/manufacturing/maintenance-stats'),
  processTrend:    ()         => http.get('/manufacturing/process-trend'),
  reset:           ()         => http.post('/manufacturing/reset'),
}
