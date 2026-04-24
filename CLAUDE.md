# Project: Doris + Python FastAPI + Vue3 Big Data Analysis Demo
## Claude Code Best Practices Full Constraints

### 1. Project Position
This is **ONLY DEMO SHOWCASE**, NOT FOR PRODUCTION.
Architecture:
- OLAP Database: Apache Doris
- Backend: Python FastAPI
- Frontend: Vue3 + Vite + ECharts
- Purpose: Architecture display, multi-dimensional analysis demo, data dashboard demonstration.

### 2. Hard Rules You Must Follow
1. No production-level design, no cluster deployment, no high availability, no HA, no backup, no data synchronization.
2. Minimal architecture, no redundant middleware, no unnecessary service splitting.
3. No complex authentication, no login system, no RBAC permission control.
4. Keep code simple, readable, easy to demonstrate and run.
5. Follow Doris OLAP best query practices, avoid bad SQL.
6. One-click start script required, low deployment cost.
7. Do not refactor blindly, do not add useless functions.
8. All layers decoupled: Doris layer → Python API layer → Frontend display layer.

### 3. Tech Stack Details
- Doris: Single instance standalone, local test environment
- Python: FastAPI, pymysql/doris driver, data aggregation encapsulation
- Frontend: Vue3, Vite, Element Plus, ECharts for chart dashboard
- Network: Default ports, no complex port mapping

### 4. Development Workflow (Official Best Practice)
1. First understand requirements → then plan structure → finally write code.
2. Document first: keep README, SQL comments, API comments complete.
3. Implement Doris DDL first, then test data, then backend API, then frontend page.
4. Modify code locally only, do not change unrelated files.
5. Keep atomic commits, clear function logic.

### 5. Doris SQL Best Practices
- Use Unique Key model for demo table.
- Optimize aggregate query: sum, count, group by, time dimension statistics.
- Avoid join in large amount, demo only simple dimension analysis.
- Reasonable partition & bucket setting for demo.
- No complex UDF, no external table, no stream load for demo.

### 6. Backend Python Rules
- Unified Doris connection configuration.
- RESTful simple API interface.
- Exception capture simplified, demo only.
- No log system, no monitor, no scheduler.

### 7. Frontend Rules
- Simple data dashboard page only.
- Total sales, trend chart, category analysis, regional statistics.
- Beautiful display, no complex interaction, no user management.

### 8. Prohibited Behaviors
- Do not add Docker, Kubernetes deployment.
- Do not add Redis, MQ, ES, extra middleware.
- Do not implement user login, token, security strategy.
- Do not optimize for massive data pressure.
- Do not over-engineering.