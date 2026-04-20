# 服饰零售数据血缘与 ETL 任务设计

## 1. 目标
- 模拟真实服饰零售的数据血缘。
- 同时模拟数据表、ETL 加工任务、下游报表。
- 让 OpenMetadata 能呈现出“源系统 -> ETL -> Doris 分层表 -> 报表/指标”的完整链路。

## 2. 业务链路
### 商品链路
- PIM 商品主数据
- ERP 商品价格快照
- ETL：商品标准化任务
- Doris 商品维表
- ETL：商品销售汇总任务
- 热销商品看板

### 库存链路
- WMS 仓库库存
- POS 门店库存
- ETL：库存统一快照任务
- Doris 库存明细快照
- ETL：库存周转任务
- 库存预警看板

### 订单链路
- POS 门店交易明细
- 电商订单明细
- ETL：订单统一事实任务
- Doris 订单事实表
- ETL：销售汇总任务
- 销售日报 / GMV 看板

### 会员链路
- CRM 会员主档
- ETL：会员画像同步任务
- Doris 会员画像维表
- ETL：会员 RFM 计算任务
- 会员运营看板 / 留存分析

### 营销链路
- 活动配置
- 优惠券发放
- ETL：活动事件汇总任务
- Doris 转化汇总表
- 营销 ROI 看板

### 门店链路
- 销售日汇总
- ETL：门店 KPI 计算任务
- Doris 门店日经营指标
- 门店经营看板

## 3. OpenMetadata 呈现方式
- Source Table 节点：PIM / ERP / WMS / POS / CRM / MKT
- Pipeline 节点：ETL 任务
- Target Table 节点：Doris DWD / DWS / ADS 表
- Dashboard 节点：BI 看板
- Edge：`reads`, `transforms`, `publishes`

## 4. 模拟原则
- 一条 ETL 任务至少连接 1~3 个上游表和 1 个下游目标表。
- DWD 任务负责标准化，DWS 任务负责聚合，ADS 任务负责展示。
- 每个业务域至少有 1 条完整链路。

## 5. 可落库对象
- `lineage_asset`
- `lineage_edge`
- `lineage_impact`
- `etl_task`
- `etl_task_input`
- `etl_task_output`

## 6. 后续接 OpenMetadata
- OpenMetadata Pipeline 对应 `etl_task`
- OpenMetadata Table 对应 `lineage_asset`
- OpenMetadata Lineage 对应 `lineage_edge`
- OpenMetadata Dashboard 对应 ADS 看板
