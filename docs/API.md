# API Contract

All frontend requests must go through `frontend/src/api/modules/*` and be re-exported from `frontend/src/api/index.js`.
Views should not create their own axios clients or hard-code `/api/...` paths.

Base URL in development is proxied by Vite:

```text
/api -> http://BACKEND_PROXY_HOST:BACKEND_PORT
```

## Core

| Domain | Method | Path | Purpose |
|---|---:|---|---|
| System | GET | `/api/system/health` | Backend and Doris health |
| System | GET | `/api/system/config` | Runtime public config |
| Dashboard | GET | `/api/dashboard` | Home dashboard data |
| Dashboard | GET | `/api/management` | Management dashboard data |
| User | GET | `/api/user/wide` | User wide-table query |
| Segment | GET | `/api/segment/list` | Saved segments |
| Segment | POST | `/api/segment/count` | Segment count preview |
| Segment | POST | `/api/segment/create` | Save segment |

## User Analysis / CDP

| Domain | Method | Path | Purpose |
|---|---:|---|---|
| Wide Tags | GET | `/api/cdp/wide/tag-meta` | Wide tag metadata |
| Wide Tags | POST | `/api/cdp/wide/query` | Wide table tag query |
| Wide Tags | GET | `/api/cdp/wide/distribution` | Tag hit distribution |
| Bitmap | POST | `/api/cdp/bitmap/compute` | Bitmap crowd compute |
| Bitmap | POST | `/api/cdp/bitmap/two-set` | Bitmap two-set operations |
| Crowd | GET | `/api/cdp/crowd/list` | Crowd packages |
| Crowd | POST | `/api/cdp/crowd/save` | Save crowd package |
| Crowd | DELETE | `/api/cdp/crowd/{crowd_id}` | Delete crowd package |
| Crowd | POST | `/api/cdp/crowd/compare` | Compare two crowds |
| Portrait | POST | `/api/cdp/portrait/tgi` | TGI analysis |
| Portrait | POST | `/api/cdp/portrait/cross` | Cross analysis |
| Portrait | POST | `/api/cdp/portrait/geo` | Geographic distribution |
| Portrait | POST | `/api/cdp/portrait/targeting` | Targeting estimate |
| Behavior | POST | `/api/cdp/behavior/funnel` | Funnel analysis |
| Behavior | POST | `/api/cdp/behavior/retention` | Retention analysis |
| Behavior | GET | `/api/cdp/behavior/path` | Behavior path analysis |

## Feature Modules

| Module | Main API Prefix | Frontend API Module |
|---|---|---|
| Vector Search | `/api/vector/*` | `modules/vector.js` |
| Metrics Platform | `/api/metrics/*` | `modules/metrics.js` |
| Observability | `/api/observe/*`, `/api/trace/*` | `modules/observe.js`, `modules/trace.js` |
| Regulatory | `/api/regulatory/*` | `modules/regulatory.js` |
| Report | `/api/report/*` | `modules/report.js` |
| Benchmark | `/api/benchmark/*` | `modules/benchmark.js` |
| Manufacturing | `/api/manufacturing/*` preferred, `/api/mfg/*` legacy | `modules/mfg.js` |
| Securities | `/api/securities/*` preferred, `/api/sec/*` legacy | `modules/securities.js` |
| Fund | `/api/fund/*` | `modules/fund.js` |
| News AI | `/api/news/*` | `modules/news.js` |
| BJ Metro | `/api/bjmetro/*` | `modules/bj-metro.js` |
| Lineage | `/api/lineage/*` | `modules/lineage.js` |
| Dictionaries | `/api/meta/dictionaries` | `modules/meta.js` |

New integrations should use semantic paths (`/api/manufacturing/*`, `/api/securities/*`). Legacy short paths remain available for compatibility.

## Validation

Basic healthcheck:

```bash
sh healthcheck.sh
```

Full API smoke check:

```bash
FULL_SMOKE=true sh healthcheck.sh
```

Or run directly:

```bash
BACKEND_PORT=27713 python3 scripts/smoke_api.py
```
