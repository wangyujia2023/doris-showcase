# 服饰零售数据血缘设计方案

## 1. 目标
- 构建服饰零售场景的数据血缘功能。
- 从商品、库存、订单、会员、门店、营销六个业务域展示端到端血缘。
- 对接 OpenMetadata，支持元数据详情、Owner、Tag、Lineage 反查。
- 在 Doris 中沉淀血缘快照与影响分析结果，保证前端交互性能。

## 2. 场景范围
- 商品上新链路
- 库存补货链路
- 订单交易链路
- 会员运营链路
- 门店经营链路
- 营销归因链路

## 3. 业务主链路
### 3.1 商品链路
商品主数据 -> SKU 价格 -> 上新任务 -> 商品维表 -> 商品分析报表

### 3.2 库存链路
仓库库存 -> 门店库存 -> 调拨/补货 -> 库存快照 -> 库存周转分析

### 3.3 订单链路
POS/电商订单 -> 支付流水 -> 退款退货 -> 销售明细 -> 销售日报/GMV 看板

### 3.4 会员链路
会员注册 -> 会员等级 -> 会员标签 -> 复购分析 -> RFM/运营看板

### 3.5 营销链路
活动配置 -> 优惠券 -> 投放渠道 -> 转化归因 -> 活动效果看板

## 4. 功能模块
### 4.1 血缘总览
- 业务域树
- 血缘图谱
- 上下游展开
- 层级切换

### 4.2 资产详情
- 资产类型
- 所属业务域
- Owner
- OpenMetadata 链接
- 字段列表
- 最近刷新时间

### 4.3 影响分析
- 改表影响
- 改字段影响
- 指标影响范围

### 4.4 元数据联动
- 资产详情联动 OpenMetadata
- 展示 Tag、Domain、Owner、Description、Lineage

## 5. Doris 设计
### 5.1 数据库
- 新建数据库：`retail_lineage`

### 5.2 表
- `lineage_asset`
- `lineage_edge`
- `lineage_snapshot`
- `lineage_impact`
- `lineage_domain`

## 6. 后端接口
- `GET /api/lineage/domains`
- `GET /api/lineage/graph?domain=order&depth=2`
- `GET /api/lineage/assets?keyword=`
- `GET /api/lineage/asset/{asset_id}`
- `POST /api/lineage/sync`
- `GET /api/lineage/impact?asset_id=`

## 7. 前端页面
- 菜单入口：数据血缘
- 页面结构：
  - 左侧业务域
  - 中间血缘图
  - 右侧详情抽屉
  - 顶部搜索与筛选

## 8. 接入 OpenMetadata
- OpenMetadata 基地址：`http://10.26.20.3:8585`
- 后端统一代理 OpenMetadata API
- 定时同步元数据到 Doris
- 前端不直连 OpenMetadata

## 9. MVP 范围
- 业务域列表
- 服饰零售主链路图
- 资产详情
- 上下游查询
- OpenMetadata 跳转

## 10. 后续迭代
- 变更影响评分
- 字段级血缘
- 质量监控
- 责任人联动
- 血缘快照版本对比
