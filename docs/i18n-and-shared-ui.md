# Internationalization and Shared UI Architecture

## Goal
Keep Vue pages small and make new languages easy to add.

## Layers
- Frontend i18n: fixed UI copy, such as menus, buttons, titles, placeholders, and empty states.
- Backend dictionaries: business labels that change with domains, such as user tags, metric dimensions, lifecycle values, vector labels, and lineage layers.
- Shared frontend assets: layout CSS, menu config, common composables, and label helpers.

## Add A New Language
1. Add a new language key in `frontend/src/i18n/messages.js`.
2. Add alias and option in `frontend/src/i18n/index.js`.
3. Add the same locale labels in `backend/service/dictionary_service.py`.
4. Pages should use `t('module.key')` for fixed UI and `dictLabel(type, code)` for business values.

## File Responsibilities
- `frontend/src/i18n/index.js`: locale runtime, fallback, interpolation.
- `frontend/src/i18n/messages.js`: fixed UI message packs.
- `backend/service/dictionary_service.py`: business dictionary source.
- `frontend/src/store/dictionary.js`: dictionary cache and locale reload.
- `frontend/src/utils/label.js`: lightweight label helpers.
- `frontend/src/config/menu.js`: sidebar menu config.
- `frontend/src/styles/app.css`: application shell styles.
- `frontend/src/styles/layout.css`: reusable page/card/grid/table styles.

## Page Rule
Do not put large enum maps or repeated layout CSS inside `.vue` pages. Put stable UI copy in i18n, put business dictionaries in the backend dictionary service, and put repeated page behavior in composables.

## Current Refactor Status
- API calls are split under `frontend/src/api/modules/`; `frontend/src/api/index.js` remains a compatibility facade.
- Shared Axios clients live in `frontend/src/api/http.js`.
- ECharts DOM lifecycle is centralized in `frontend/src/composables/useChart.js`.
- `MetricsPlatform`, `VectorSearch`, and `UserWide` now use backend dictionaries for core business labels.

## Next Page Migration Pattern
1. Keep the page import unchanged if it uses `@/api`; move API definitions only inside `frontend/src/api/modules/`.
2. Replace local enum maps with `useDictionaryStore().label(type, code, fallback)`.
3. Replace direct `echarts.init(...)` and repeated `resize` listeners with `useDomChart().renderChart(id, option)`.
