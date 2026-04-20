-- ================================================================
-- 服饰零售数据血缘 - ETL 模拟数据
-- 说明：
-- 1. 依赖 retail_lineage 库与 init_retail_lineage.sql
-- 2. 模拟 ETL 任务、任务输入输出、任务与表的血缘关系
-- 3. 让 OpenMetadata 可呈现 Pipeline / Table / Dashboard 关系
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

CREATE TABLE IF NOT EXISTS etl_task (
  task_id VARCHAR(64) NOT NULL,
  task_name VARCHAR(256) NOT NULL,
  domain_id VARCHAR(64) NOT NULL,
  task_type VARCHAR(32) NOT NULL,
  schedule_cron VARCHAR(64) DEFAULT '',
  source_system VARCHAR(128) DEFAULT '',
  owner VARCHAR(128) DEFAULT '',
  openmetadata_url VARCHAR(512) DEFAULT '',
  description VARCHAR(1024) DEFAULT '',
  last_run_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(task_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS etl_task_input (
  id VARCHAR(64) NOT NULL,
  task_id VARCHAR(64) NOT NULL,
  input_asset_id VARCHAR(64) NOT NULL,
  input_role VARCHAR(32) DEFAULT 'source',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS etl_task_output (
  id VARCHAR(64) NOT NULL,
  task_id VARCHAR(64) NOT NULL,
  output_asset_id VARCHAR(64) NOT NULL,
  output_role VARCHAR(32) DEFAULT 'target',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

INSERT INTO etl_task
(task_id, task_name, domain_id, task_type, schedule_cron, source_system, owner, openmetadata_url, description, last_run_at)
VALUES
('task_product_standardize', '商品标准化任务', 'product', 'batch', '0 0 * * *', 'Airflow', '商品数据组', 'http://10.26.20.3:8585/pipeline/task_product_standardize', '将 PIM/ERP 商品信息标准化到 Doris 商品维表', NOW()),
('task_product_sales', '商品销售汇总任务', 'product', 'batch', '0 10 * * *', 'Airflow', '商品数据组', 'http://10.26.20.3:8585/pipeline/task_product_sales', '按商品聚合销售表现', NOW()),
('task_inventory_snapshot', '库存统一快照任务', 'inventory', 'batch', '0 5 * * *', 'Airflow', '供应链数据组', 'http://10.26.20.3:8585/pipeline/task_inventory_snapshot', '汇总仓库与门店库存', NOW()),
('task_inventory_turnover', '库存周转任务', 'inventory', 'batch', '0 7 * * *', 'Airflow', '供应链数据组', 'http://10.26.20.3:8585/pipeline/task_inventory_turnover', '计算库存周转与预警指标', NOW()),
('task_order_fact', '订单统一事实任务', 'order', 'stream', '*/5 * * * *', 'Flink', '交易数据组', 'http://10.26.20.3:8585/pipeline/task_order_fact', '汇聚 POS 与电商订单明细', NOW()),
('task_sales_daily', '销售汇总任务', 'order', 'batch', '0 8 * * *', 'Airflow', '交易数据组', 'http://10.26.20.3:8585/pipeline/task_sales_daily', '生成销售日报与 GMV 看板数据', NOW()),
('task_member_profile', '会员画像同步任务', 'member', 'batch', '0 3 * * *', 'Airflow', '会员数据组', 'http://10.26.20.3:8585/pipeline/task_member_profile', '同步 CRM 会员主档并标准化画像', NOW()),
('task_member_rfm', '会员 RFM 计算任务', 'member', 'batch', '0 4 * * *', 'Airflow', '会员数据组', 'http://10.26.20.3:8585/pipeline/task_member_rfm', '计算会员价值分层与复购能力', NOW()),
('task_campaign_event', '活动事件汇总任务', 'marketing', 'batch', '*/15 * * * *', 'Airflow', '营销数据组', 'http://10.26.20.3:8585/pipeline/task_campaign_event', '汇总活动、券、点击、下单事件', NOW()),
('task_campaign_roi', '营销 ROI 计算任务', 'marketing', 'batch', '0 6 * * *', 'Airflow', '营销数据组', 'http://10.26.20.3:8585/pipeline/task_campaign_roi', '生成活动转化与 ROI 看板数据', NOW()),
('task_store_kpi', '门店 KPI 计算任务', 'store', 'batch', '0 9 * * *', 'Airflow', '门店数据组', 'http://10.26.20.3:8585/pipeline/task_store_kpi', '生成门店经营核心指标', NOW());

INSERT INTO etl_task_input (id, task_id, input_asset_id, input_role, updated_at) VALUES
('ti_001', 'task_product_standardize', 'pim_sku_base', 'source', NOW()),
('ti_002', 'task_product_standardize', 'ods_sku_price', 'source', NOW()),
('ti_003', 'task_product_sales', 'dwd_sku_dim', 'source', NOW()),
('ti_004', 'task_inventory_snapshot', 'wms_stock_daily', 'source', NOW()),
('ti_005', 'task_inventory_snapshot', 'store_stock_daily', 'source', NOW()),
('ti_006', 'task_inventory_turnover', 'dwd_inventory_snapshot', 'source', NOW()),
('ti_007', 'task_order_fact', 'pos_order_detail', 'source', NOW()),
('ti_008', 'task_order_fact', 'ec_order_detail', 'source', NOW()),
('ti_009', 'task_sales_daily', 'dwd_order_fact', 'source', NOW()),
('ti_010', 'task_member_profile', 'crm_member_base', 'source', NOW()),
('ti_011', 'task_member_rfm', 'dwd_member_profile', 'source', NOW()),
('ti_012', 'task_campaign_event', 'mkt_campaign', 'source', NOW()),
('ti_013', 'task_campaign_event', 'mkt_coupon_send', 'source', NOW()),
('ti_014', 'task_campaign_roi', 'dwd_campaign_event', 'source', NOW()),
('ti_015', 'task_store_kpi', 'dws_sales_daily', 'source', NOW());

INSERT INTO etl_task_output (id, task_id, output_asset_id, output_role, updated_at) VALUES
('to_001', 'task_product_standardize', 'dwd_sku_dim', 'target', NOW()),
('to_002', 'task_product_sales', 'dws_product_sales', 'target', NOW()),
('to_003', 'task_inventory_snapshot', 'dwd_inventory_snapshot', 'target', NOW()),
('to_004', 'task_inventory_turnover', 'dws_inventory_turnover', 'target', NOW()),
('to_005', 'task_order_fact', 'dwd_order_fact', 'target', NOW()),
('to_006', 'task_sales_daily', 'dws_sales_daily', 'target', NOW()),
('to_007', 'task_sales_daily', 'ads_sales_report', 'publish', NOW()),
('to_008', 'task_member_profile', 'dwd_member_profile', 'target', NOW()),
('to_009', 'task_member_rfm', 'dws_member_rfm', 'target', NOW()),
('to_010', 'task_member_rfm', 'ads_member_operation', 'publish', NOW()),
('to_011', 'task_member_rfm', 'ads_member_retention', 'publish', NOW()),
('to_012', 'task_campaign_event', 'dwd_campaign_event', 'target', NOW()),
('to_013', 'task_campaign_roi', 'dws_conversion', 'target', NOW()),
('to_014', 'task_campaign_roi', 'ads_campaign_roi', 'publish', NOW()),
('to_015', 'task_store_kpi', 'store_daily_kpi', 'target', NOW()),
('to_016', 'task_store_kpi', 'ads_store_dashboard', 'publish', NOW());

-- 任务与表的血缘边，给 OpenMetadata 直接呈现
INSERT INTO lineage_edge
(edge_id, from_asset_id, to_asset_id, relation_type, weight, source_system, updated_at)
VALUES
('e_t1', 'pim_sku_base', 'task_product_standardize', 'read', 5, 'Airflow', NOW()),
('e_t2', 'ods_sku_price', 'task_product_standardize', 'read', 5, 'Airflow', NOW()),
('e_t3', 'task_product_standardize', 'dwd_sku_dim', 'write', 8, 'Airflow', NOW()),

('e_t4', 'dwd_sku_dim', 'task_product_sales', 'read', 5, 'Airflow', NOW()),
('e_t5', 'task_product_sales', 'dws_product_sales', 'write', 8, 'Airflow', NOW()),
('e_t6', 'dws_product_sales', 'ads_product_rank', 'publish', 7, 'Airflow', NOW()),

('e_t7', 'wms_stock_daily', 'task_inventory_snapshot', 'read', 5, 'Airflow', NOW()),
('e_t8', 'store_stock_daily', 'task_inventory_snapshot', 'read', 5, 'Airflow', NOW()),
('e_t9', 'task_inventory_snapshot', 'dwd_inventory_snapshot', 'write', 8, 'Airflow', NOW()),
('e_t10', 'dwd_inventory_snapshot', 'task_inventory_turnover', 'read', 5, 'Airflow', NOW()),
('e_t11', 'task_inventory_turnover', 'dws_inventory_turnover', 'write', 8, 'Airflow', NOW()),
('e_t12', 'dws_inventory_turnover', 'ads_inventory_alarm', 'publish', 7, 'Airflow', NOW()),

('e_t13', 'pos_order_detail', 'task_order_fact', 'read', 5, 'Flink', NOW()),
('e_t14', 'ec_order_detail', 'task_order_fact', 'read', 5, 'Flink', NOW()),
('e_t15', 'task_order_fact', 'dwd_order_fact', 'write', 9, 'Flink', NOW()),
('e_t16', 'dwd_order_fact', 'task_sales_daily', 'read', 5, 'Airflow', NOW()),
('e_t17', 'task_sales_daily', 'dws_sales_daily', 'write', 8, 'Airflow', NOW()),
('e_t18', 'dws_sales_daily', 'ads_sales_report', 'publish', 8, 'Airflow', NOW()),
('e_t19', 'dws_sales_daily', 'ads_gmv_dashboard', 'publish', 8, 'Airflow', NOW()),

('e_t20', 'crm_member_base', 'task_member_profile', 'read', 5, 'Airflow', NOW()),
('e_t21', 'task_member_profile', 'dwd_member_profile', 'write', 8, 'Airflow', NOW()),
('e_t22', 'dwd_member_profile', 'task_member_rfm', 'read', 5, 'Airflow', NOW()),
('e_t23', 'task_member_rfm', 'dws_member_rfm', 'write', 8, 'Airflow', NOW()),
('e_t24', 'dws_member_rfm', 'ads_member_operation', 'publish', 7, 'Airflow', NOW()),
('e_t25', 'dws_member_rfm', 'ads_member_retention', 'publish', 7, 'Airflow', NOW()),

('e_t26', 'mkt_campaign', 'task_campaign_event', 'read', 5, 'Airflow', NOW()),
('e_t27', 'mkt_coupon_send', 'task_campaign_event', 'read', 4, 'Airflow', NOW()),
('e_t28', 'task_campaign_event', 'dwd_campaign_event', 'write', 8, 'Airflow', NOW()),
('e_t29', 'dwd_campaign_event', 'task_campaign_roi', 'read', 5, 'Airflow', NOW()),
('e_t30', 'task_campaign_roi', 'dws_conversion', 'write', 8, 'Airflow', NOW()),
('e_t31', 'dws_conversion', 'ads_campaign_roi', 'publish', 9, 'Airflow', NOW()),

('e_t32', 'dws_sales_daily', 'task_store_kpi', 'read', 5, 'Airflow', NOW()),
('e_t33', 'task_store_kpi', 'store_daily_kpi', 'write', 8, 'Airflow', NOW()),
('e_t34', 'store_daily_kpi', 'ads_store_dashboard', 'publish', 8, 'Airflow', NOW());

-- 让 OpenMetadata 能把 pipeline 当作节点显示
INSERT INTO lineage_asset
(asset_id, asset_name, asset_type, domain_id, layer_name, source_system, owner, openmetadata_url, description, refreshed_at)
VALUES
('task_product_standardize', '商品标准化任务', 'pipeline', 'product', 'ETL', 'Airflow', '商品数据组', 'http://10.26.20.3:8585/pipeline/task_product_standardize', '把商品主数据和价格快照标准化为 Doris 维表', NOW()),
('task_product_sales', '商品销售汇总任务', 'pipeline', 'product', 'ETL', 'Airflow', '商品数据组', 'http://10.26.20.3:8585/pipeline/task_product_sales', '基于商品维表汇总销售表现', NOW()),
('task_inventory_snapshot', '库存统一快照任务', 'pipeline', 'inventory', 'ETL', 'Airflow', '供应链数据组', 'http://10.26.20.3:8585/pipeline/task_inventory_snapshot', '汇总仓库库存与门店库存', NOW()),
('task_inventory_turnover', '库存周转任务', 'pipeline', 'inventory', 'ETL', 'Airflow', '供应链数据组', 'http://10.26.20.3:8585/pipeline/task_inventory_turnover', '计算周转天数与库存预警', NOW()),
('task_order_fact', '订单统一事实任务', 'pipeline', 'order', 'ETL', 'Flink', '交易数据组', 'http://10.26.20.3:8585/pipeline/task_order_fact', '汇聚 POS 与电商订单明细', NOW()),
('task_sales_daily', '销售汇总任务', 'pipeline', 'order', 'ETL', 'Airflow', '交易数据组', 'http://10.26.20.3:8585/pipeline/task_sales_daily', '生成销售日报', NOW()),
('task_member_profile', '会员画像同步任务', 'pipeline', 'member', 'ETL', 'Airflow', '会员数据组', 'http://10.26.20.3:8585/pipeline/task_member_profile', '同步会员主档', NOW()),
('task_member_rfm', '会员 RFM 计算任务', 'pipeline', 'member', 'ETL', 'Airflow', '会员数据组', 'http://10.26.20.3:8585/pipeline/task_member_rfm', '计算会员分层', NOW()),
('task_campaign_event', '活动事件汇总任务', 'pipeline', 'marketing', 'ETL', 'Airflow', '营销数据组', 'http://10.26.20.3:8585/pipeline/task_campaign_event', '汇总活动和券事件', NOW()),
('task_campaign_roi', '营销 ROI 任务', 'pipeline', 'marketing', 'ETL', 'Airflow', '营销数据组', 'http://10.26.20.3:8585/pipeline/task_campaign_roi', '计算营销归因和 ROI', NOW()),
('task_store_kpi', '门店 KPI 任务', 'pipeline', 'store', 'ETL', 'Airflow', '门店数据组', 'http://10.26.20.3:8585/pipeline/task_store_kpi', '生成门店经营指标', NOW());
