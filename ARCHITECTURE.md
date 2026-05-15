# Bank-CDP 项目架构和依赖图

## 项目结构概览

```
bank-cdp-doris4/
├── frontend/                    # Vue 3 前端应用
│   ├── src/
│   │   ├── views/              # 23个业务页面
│   │   ├── components/         # UI组件
│   │   ├── stores/             # Pinia 状态管理
│   │   ├── api/                # API调用
│   │   ├── i18n/               # 国际化 (zh/en)
│   │   └── App.vue
│   ├── package.json
│   └── vite.config.js
│
├── backend/                     # FastAPI 后端应用
│   ├── app.py                  # 主入口
│   ├── settings.py             # 配置管理
│   ├── context.py              # 上下文
│   ├── api/                    # API路由层
│   │   ├── routes.py           # 路由聚合
│   │   ├── *_routes.py         # 各模块路由 (11个)
│   │   └── core_routes.py      # 核心路由
│   ├── service/                # 业务逻辑层
│   │   ├── *_service.py        # 各模块服务 (20+个)
│   │   └── dashboard_service.py # 仪表板服务
│   ├── doris/                  # 数据库层
│   │   └── connect.py          # Doris 连接池
│   ├── middleware/             # 中间件
│   │   └── request_logger.py   # 请求日志
│   ├── telemetry/              # 遥测
│   │   └── collector.py        # 数据收集
│   └── requirements.txt        # 依赖
│
├── .env                        # 环境配置
├── .env.example                # 配置模板
├── init.sh                     # 初始化脚本
├── start_all.sh                # 启动脚本
├── diagnose.sh                 # 诊断脚本
└── QUICKSTART.md               # 快速启动指南
```

---

## 后端依赖关系图

### 核心架构层级

```
【应用层】
    app.py (FastAPI 主应用)
    ↓
【路由层】routes.py (路由聚合中心)
    ↓ 包含 ↓
【API 层】(11 个模块路由)
  ├─ cdp_routes.py          (CDP 相关)
  ├─ core_routes.py         (核心接口)
  ├─ dashboard_routes.py    (仪表板)
  ├─ lineage_routes.py      (数据血缘)
  ├─ news_routes.py         (新闻分析)
  ├─ vector_routes.py       (向量分析)
  ├─ tag_analysis_routes.py (标签分析)
  ├─ user_routes.py         (用户管理)
  ├─ bjmetro_routes.py      (北京地铁)
  ├─ satellite_routes.py    (卫星数据)
  └─ ... (其他域特定路由)
    ↓ 调用 ↓
【服务层】(业务逻辑)
  ├─ dashboard_service.py   (仪表板逻辑)
  ├─ cdp_service.py         (CDP逻辑)
  ├─ lineage_service.py     (血缘分析)
  ├─ vector_service.py      (向量计算)
  ├─ tag_analysis_service.py(标签分析)
  ├─ news_service.py        (新闻处理)
  ├─ user_service.py        (用户服务)
  └─ ... (20+ 个服务)
    ↓ 使用 ↓
【数据层】
  └─ doris/connect.py (Doris 数据库连接池)
    ├─ execute_query()      (执行查询)
    ├─ execute_one()        (单条查询)
    └─ get_pool()           (获取连接)
```

---

## 前端依赖关系图

### 页面层级关系

```
【主应用】App.vue
    ↓
【路由层】vue-router
    ├─ Dashboard        (仪表板)
    ├─ UserProfile      (用户详情)
    ├─ Lineage          (数据血缘)
    ├─ NewsInsight      (新闻分析)
    ├─ VectorAnalysis   (向量分析)
    ├─ TagAnalysis      (标签分析)
    ├─ BJMetro          (北京地铁)
    ├─ Satellite        (卫星数据)
    ├─ NewsInsight      (新闻洞察)
    └─ ... (23 个视图页面)
        ↓
【组件层】components/
    ├─ bjmetro/         (地铁组件)
    ├─ lineage/         (血缘组件)
    ├─ news/            (新闻组件)
    └─ ... (其他UI组件)
        ↓
【API 层】api/index.js
    ├─ userApi          (用户API)
    ├─ dashboardApi     (仪表板API)
    ├─ lineageApi       (血缘API)
    ├─ newsApi          (新闻API)
    └─ ... (各模块API客户端)
        ↓
【状态管理】stores/ (Pinia)
    ├─ userStore
    ├─ appStore
    └─ ... (业务状态)
        ↓
【国际化】i18n/index.js (zh/en)
    └─ messages (全局翻译字典)
```

---

## 关键依赖链

### 数据流向

```
前端请求
  ↓
API 路由 (routes.py)
  ↓
业务服务 (service/*.py)
  ↓
数据库查询 (doris/connect.py)
  ↓
Doris 数据库
  ↓
返回数据
  ↓
前端渲染
```

### 启动流程

```
start_all.sh
  ├─ 后端启动
  │   ├─ 创建虚拟环境 (.venv)
  │   ├─ 加载 .env 配置
  │   ├─ 初始化 Doris 连接池
  │   ├─ 启动 FastAPI (端口 27713)
  │   └─ 加载中间件和路由
  │
  └─ 前端启动
      ├─ npm install (node_modules)
      ├─ 启动 Vite 开发服务器 (端口 5173)
      ├─ 加载 i18n 配置
      └─ 编译 Vue 组件
```

---

## 模块依赖关系

### 高频依赖（被多个模块使用）

```
【doris/connect.py】         (数据库连接)
  ↑ 被以下服务依赖 ↑
  ├─ dashboard_service.py
  ├─ cdp_service.py
  ├─ lineage_service.py
  ├─ vector_service.py
  ├─ tag_analysis_service.py
  ├─ news_service.py
  └─ ... (所有服务都依赖)

【settings.py】             (配置管理)
  ↑ 被以下依赖 ↑
  ├─ app.py
  ├─ doris/connect.py
  ├─ telemetry/collector.py
  └─ 所有服务

【middleware/request_logger.py】 (请求日志)
  ↑ 被 app.py 引用 ↑

【i18n/index.js】           (国际化)
  ↑ 被所有 Vue 组件依赖 ↑
```

---

## API 路由树

```
/api/
├─ /dashboard              (仪表板)
├─ /user/                  (用户)
│  ├─ /wide               (宽表)
│  └─ /...
├─ /lineage/              (数据血缘)
│  ├─ /import-records
│  ├─ /sync
│  └─ /query-lineage
├─ /news/                 (新闻分析)
│  ├─ /import
│  ├─ /articles
│  └─ /ai-function
├─ /vector/               (向量分析)
├─ /tag-analysis/         (标签分析)
├─ /segment/              (客户分群)
├─ /bjmetro/              (北京地铁Demo)
├─ /satellite/            (卫星数据Demo)
├─ /system/               (系统)
│  └─ /health
└─ /docs                  (API文档)
```

---

## 关键配置文件

| 文件 | 作用 | 依赖 |
|------|------|------|
| `.env` | 环境变量 | 数据库、服务端口 |
| `settings.py` | 配置加载 | .env, os 环境变量 |
| `app.py` | FastAPI 应用 | settings, 路由, 中间件 |
| `routes.py` | 路由聚合 | 所有 *_routes.py |
| `connect.py` | 数据库连接 | settings, pymysql |
| `package.json` | 前端依赖 | npm packages |
| `vite.config.js` | Vite 配置 | @vitejs/plugin-vue |
| `i18n/index.js` | 国际化 | messages (zh/en) |

---

## 部署依赖

```
系统环境
  ├─ Python 3.8+
  │  ├─ FastAPI
  │  ├─ Uvicorn
  │  ├─ PyMySQL
  │  └─ ... (requirements.txt)
  │
  ├─ Node.js 14+
  │  ├─ Vue 3
  │  ├─ Vite
  │  ├─ Element Plus
  │  ├─ Pinia
  │  ├─ Axios
  │  └─ ... (package.json)
  │
  └─ 外部服务
     ├─ Doris 数据库 (DORIS_HOST:19030)
     ├─ OpenMetadata (可选)
     └─ 网络连接
```

---

## 已知依赖问题

### ✅ 已修复
1. **dashboard_service.py (第 124 行)**
   - 错误: `log_time AS date` 在 GROUP BY 中不合法
   - 修复: 改为 `DATE(log_time) AS date`
   - 影响: /api/dashboard 响应

### ⚠️ 需要关注
1. **数据库连接超时** - 检查 DORIS_HOST/PORT
2. **虚拟环境激活** - 确保用 .venv/bin/python
3. **端口冲突** - 27713 (后端) 和 5173 (前端)

---

## 扩展点

### 新增 API 模块步骤

```
1. 创建 backend/api/new_module_routes.py
   ├─ 定义路由
   └─ 导入服务
2. 创建 backend/service/new_module_service.py
   ├─ 实现业务逻辑
   └─ 调用 doris/connect.py
3. 在 backend/api/routes.py 中引入
   └─ include_router(new_module_routes.router)
4. 前端创建 src/views/NewModule.vue
   └─ 调用 API
```

### 新增前端页面步骤

```
1. 创建 frontend/src/views/NewPage.vue
   ├─ 使用组件
   └─ 调用 API
2. 在 i18n/index.js 中添加翻译
3. 在路由配置中注册
4. 创建 frontend/src/components/NewComponent.vue (可选)
```

---

## 性能关键路径

```
关键路径: 数据查询性能
  ├─ SQL 语句优化 (service 层)
  ├─ 连接池效率 (doris/connect.py)
  └─ 网络延迟 (前后端通信)

优化建议:
  1. 查看 backend.log 中的查询时间
  2. 检查 Doris 表的索引和分区
  3. 使用 ./check_status.sh 监控资源
```

---

## 快速查询参考

```bash
# 查看后端所有 API
grep -r "^@.*\.get\|^@.*\.post" backend/api/

# 查看前端所有页面
ls frontend/src/views/

# 查看数据库查询
grep -r "SELECT\|INSERT\|UPDATE" backend/service/

# 查看依赖链
grep -r "from backend\." backend/ | grep "import"

# 查看配置
cat .env | grep -v "^#"
```

