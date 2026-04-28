-- ================================================================
-- Database: retail_lineage
-- Type: mock data
-- Description: Retail lineage assets, ETL task mappings and insert-select mock data.
-- Execute after retail_lineage_schema.sql.
-- Execute: mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_mock.sql
-- ================================================================

-- ================================================================
-- Fashion retail lineage mock initialization data
-- Notes:
-- 1. Requires the retail_lineage database and schema tables.
-- 2. This script inserts mock assets, lineage edges, snapshots and impact analysis data.
-- 3. Use it to validate the frontend before connecting real OpenMetadata lineage.
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

-- ------------------------
-- Business domains
-- ------------------------
INSERT INTO lineage_domain (domain_id, domain_name, domain_desc, owner, updated_at) VALUES
('product',    'Product Domain',   'Product master data, SKU, price, launch and category analysis', 'Product Data Team', NOW()),
('inventory',  'Inventory Domain',   'Warehouse stock, store stock, transfer, replenishment and alerts',   'Supply Chain Data Team', NOW()),
('order',      'Order Domain',   'POS transactions, e-commerce orders, payment, refund and GMV',    'Transaction Data Team', NOW()),
('member',     'Member Domain',   'Registration, tier, tags, repurchase and RFM profile',      'Member Data Team', NOW()),
('store',      'Store Domain',   'Store operation, efficiency, sales assistant and sales report',         'Store Data Team', NOW()),
('marketing',  'Marketing Domain',   'Campaign, coupon, delivery, conversion attribution and ROI',      'Marketing Data Team', NOW());

-- ------------------------
-- Asset nodes
-- ------------------------
INSERT INTO lineage_asset
(asset_id, asset_name, asset_type, domain_id, layer_name, source_system, owner, openmetadata_url, description, refreshed_at)
VALUES
-- Product lineage
('pim_sku_base',         'Product Master Data',       'table',  'product',   'ODS', 'PIM',   'Product Data Team', 'http://10.26.20.3:8585/assets/pim_sku_base', 'Fashion product base info, brand, category, season and list price', NOW()),
('ods_sku_price',        'Product Price Snapshot',     'table',  'product',   'ODS', 'ERP',   'Product Data Team', 'http://10.26.20.3:8585/assets/ods_sku_price', 'Daily SKU price snapshot', NOW()),
('dwd_sku_dim',          'Product Dimension',         'table',  'product',   'DWD', 'Doris', 'Product Data Team', 'http://10.26.20.3:8585/assets/dwd_sku_dim', 'Standardized product dimension', NOW()),
('dws_product_sales',    'Product Sales Summary',     'table',  'product',   'DWS', 'Doris', 'Product Data Team', 'http://10.26.20.3:8585/assets/dws_product_sales', 'Product-level aggregated sales metrics', NOW()),
('ads_product_rank',     'Hot Product Dashboard',     'report', 'product',   'ADS', 'BI',    'Product Data Team', 'http://10.26.20.3:8585/assets/ads_product_rank', 'Hot product ranking and trend dashboard', NOW()),

-- Inventory lineage
('wms_stock_daily',      'Warehouse Stock Snapshot',     'table',  'inventory', 'ODS', 'WMS',   'Supply Chain Data Team', 'http://10.26.20.3:8585/assets/wms_stock_daily', 'Daily warehouse stock snapshot', NOW()),
('store_stock_daily',    'Store Stock Snapshot',     'table',  'inventory', 'ODS', 'POS',   'Supply Chain Data Team', 'http://10.26.20.3:8585/assets/store_stock_daily', 'Daily store stock snapshot', NOW()),
('dwd_inventory_snapshot','Inventory Detail Snapshot',    'table',  'inventory', 'DWD', 'Doris', 'Supply Chain Data Team', 'http://10.26.20.3:8585/assets/dwd_inventory_snapshot', 'Unified inventory detail layer', NOW()),
('dws_inventory_turnover','Inventory Turnover Summary',    'table',  'inventory', 'DWS', 'Doris', 'Supply Chain Data Team', 'http://10.26.20.3:8585/assets/dws_inventory_turnover', 'Inventory turnover and turnover days', NOW()),
('ads_inventory_alarm',  'Inventory Alert Dashboard',     'report', 'inventory', 'ADS', 'BI',    'Supply Chain Data Team', 'http://10.26.20.3:8585/assets/ads_inventory_alarm', 'Slow-moving, out-of-stock and transfer alerts', NOW()),

-- Order lineage
('pos_order_detail',     'Store Transaction Detail',     'table',  'order',     'ODS', 'POS',   'Transaction Data Team', 'http://10.26.20.3:8585/assets/pos_order_detail', 'Store POS transaction stream', NOW()),
('ec_order_detail',      'E-commerce Order Detail',     'table',  'order',     'ODS', 'EC',    'Transaction Data Team', 'http://10.26.20.3:8585/assets/ec_order_detail', 'E-commerce order stream', NOW()),
('dwd_order_fact',       'Unified Order Fact',   'table',  'order',     'DWD', 'Doris', 'Transaction Data Team', 'http://10.26.20.3:8585/assets/dwd_order_fact', 'Unified order fact layer', NOW()),
('dws_sales_daily',      'Daily Sales Summary',       'table',  'order',     'DWS', 'Doris', 'Transaction Data Team', 'http://10.26.20.3:8585/assets/dws_sales_daily', 'Daily sales amount, quantity and ATV summary', NOW()),
('ads_sales_report',     'Sales Daily Report',         'report', 'store',     'ADS', 'BI',    'Store Data Team', 'http://10.26.20.3:8585/assets/ads_sales_report', 'Store sales daily report and operation dashboard', NOW()),
('ads_gmv_dashboard',    'GMV Dashboard',         'report', 'order',     'ADS', 'BI',    'Transaction Data Team', 'http://10.26.20.3:8585/assets/ads_gmv_dashboard', 'Omni-channel GMV and refund rate dashboard', NOW()),

-- Member lineage
('crm_member_base',      'Member Master',         'table',  'member',    'ODS', 'CRM',   'Member Data Team', 'http://10.26.20.3:8585/assets/crm_member_base', 'Member registration and base profile', NOW()),
('dwd_member_profile',   'Member Profile Dimension',     'table',  'member',    'DWD', 'Doris', 'Member Data Team', 'http://10.26.20.3:8585/assets/dwd_member_profile', 'Standardized member profile', NOW()),
('dws_member_rfm',       'Member RFM Summary',    'table',  'member',    'DWS', 'Doris', 'Member Data Team', 'http://10.26.20.3:8585/assets/dws_member_rfm', 'Member repurchase and value segmentation', NOW()),
('ads_member_operation', 'Member Operation Dashboard',     'report', 'member',    'ADS', 'BI',    'Member Data Team', 'http://10.26.20.3:8585/assets/ads_member_operation', 'Acquisition, activation and repurchase dashboard', NOW()),
('ads_member_retention', 'Member Retention Analysis',     'report', 'member',    'ADS', 'BI',    'Member Data Team', 'http://10.26.20.3:8585/assets/ads_member_retention', 'Retention and churn warning dashboard', NOW()),

-- Marketing lineage
('mkt_campaign',         'Campaign Config',       'table',  'marketing', 'ODS', 'MKT',   'Marketing Data Team', 'http://10.26.20.3:8585/assets/mkt_campaign', 'Campaign base config', NOW()),
('mkt_coupon_send',      'Coupon Delivery',     'table',  'marketing', 'ODS', 'MKT',   'Marketing Data Team', 'http://10.26.20.3:8585/assets/mkt_coupon_send', 'Coupon delivery and claim records', NOW()),
('dwd_campaign_event',   'Campaign Event Detail',     'table',  'marketing', 'DWD', 'Doris', 'Marketing Data Team', 'http://10.26.20.3:8585/assets/dwd_campaign_event', 'Unified campaign behavior detail', NOW()),
('dws_conversion',       'Conversion Summary',       'table',  'marketing', 'DWS', 'Doris', 'Marketing Data Team', 'http://10.26.20.3:8585/assets/dws_conversion', 'Campaign conversion, click and order summary', NOW()),
('ads_campaign_roi',     'Marketing ROI Dashboard',    'report', 'marketing', 'ADS', 'BI',    'Marketing Data Team', 'http://10.26.20.3:8585/assets/ads_campaign_roi', 'Marketing delivery effect and ROI dashboard', NOW()),

-- Store lineage
('store_daily_kpi',      'Store Daily KPI',   'table',  'store',     'DWS', 'Doris', 'Store Data Team', 'http://10.26.20.3:8585/assets/store_daily_kpi', 'Store sales, traffic, area efficiency and conversion rate', NOW()),
('ads_store_dashboard',  'Store Operation Dashboard',     'report', 'store',     'ADS', 'BI',    'Store Data Team', 'http://10.26.20.3:8585/assets/ads_store_dashboard', 'Store operation overview dashboard', NOW());

-- ------------------------
-- Lineage edges
-- ------------------------
INSERT INTO lineage_edge
(edge_id, from_asset_id, to_asset_id, relation_type, weight, source_system, updated_at)
VALUES
-- Product lineage
('e_p1', 'pim_sku_base',   'dwd_sku_dim',        'upstream', 5, 'OpenMetadata', NOW()),
('e_p2', 'ods_sku_price',   'dwd_sku_dim',        'upstream', 4, 'OpenMetadata', NOW()),
('e_p3', 'dwd_sku_dim',     'dws_product_sales',   'transform', 8, 'OpenMetadata', NOW()),
('e_p4', 'dws_product_sales','ads_product_rank',   'transform', 7, 'OpenMetadata', NOW()),

-- Inventory lineage
('e_i1', 'wms_stock_daily',   'dwd_inventory_snapshot', 'upstream', 5, 'OpenMetadata', NOW()),
('e_i2', 'store_stock_daily', 'dwd_inventory_snapshot', 'upstream', 5, 'OpenMetadata', NOW()),
('e_i3', 'dwd_inventory_snapshot', 'dws_inventory_turnover', 'transform', 8, 'OpenMetadata', NOW()),
('e_i4', 'dws_inventory_turnover', 'ads_inventory_alarm', 'transform', 7, 'OpenMetadata', NOW()),

-- Order lineage
('e_o1', 'pos_order_detail', 'dwd_order_fact',     'upstream', 6, 'OpenMetadata', NOW()),
('e_o2', 'ec_order_detail',  'dwd_order_fact',     'upstream', 6, 'OpenMetadata', NOW()),
('e_o3', 'dwd_order_fact',   'dws_sales_daily',    'transform', 9, 'OpenMetadata', NOW()),
('e_o4', 'dws_sales_daily',   'ads_sales_report',   'transform', 8, 'OpenMetadata', NOW()),
('e_o5', 'dws_sales_daily',   'ads_gmv_dashboard',  'transform', 8, 'OpenMetadata', NOW()),

-- Member lineage
('e_m1', 'crm_member_base',   'dwd_member_profile', 'upstream', 5, 'OpenMetadata', NOW()),
('e_m2', 'dwd_member_profile','dws_member_rfm',     'transform', 8, 'OpenMetadata', NOW()),
('e_m3', 'dws_member_rfm',    'ads_member_operation','transform', 7, 'OpenMetadata', NOW()),
('e_m4', 'dws_member_rfm',    'ads_member_retention','transform', 7, 'OpenMetadata', NOW()),

-- Marketing lineage
('e_c1', 'mkt_campaign',      'dwd_campaign_event', 'upstream', 5, 'OpenMetadata', NOW()),
('e_c2', 'mkt_coupon_send',   'dwd_campaign_event', 'upstream', 4, 'OpenMetadata', NOW()),
('e_c3', 'dwd_campaign_event','dws_conversion',     'transform', 8, 'OpenMetadata', NOW()),
('e_c4', 'dws_conversion',    'ads_campaign_roi',   'transform', 9, 'OpenMetadata', NOW()),

-- Store lineage
('e_s1', 'dws_sales_daily',    'store_daily_kpi',   'transform', 7, 'OpenMetadata', NOW()),
('e_s2', 'store_daily_kpi',    'ads_store_dashboard','transform', 8, 'OpenMetadata', NOW()),
('e_s3', 'ads_sales_report',   'ads_store_dashboard','downstream', 5, 'OpenMetadata', NOW());

-- ------------------------
-- Snapshots
-- ------------------------
INSERT INTO lineage_snapshot
(snapshot_id, domain_id, snapshot_name, snapshot_time, asset_count, edge_count, source)
VALUES
('snap_product_001',   'product',   'Product domain initial lineage snapshot',   NOW(), 5, 4, 'mock'),
('snap_inventory_001', 'inventory', 'Inventory domain initial lineage snapshot',   NOW(), 5, 4, 'mock'),
('snap_order_001',     'order',     'Order domain initial lineage snapshot',   NOW(), 6, 5, 'mock'),
('snap_member_001',    'member',    'Member domain initial lineage snapshot',   NOW(), 5, 4, 'mock'),
('snap_marketing_001', 'marketing', 'Marketing domain initial lineage snapshot',   NOW(), 5, 4, 'mock'),
('snap_store_001',     'store',     'Store domain initial lineage snapshot',   NOW(), 2, 3, 'mock');

-- ------------------------
-- Impact analysis
-- ------------------------
INSERT INTO lineage_impact
(impact_id, asset_id, impacted_asset_id, impact_level, impact_reason, updated_at)
VALUES
('imp_001', 'dwd_order_fact',       'dws_sales_daily',      'high',   'Order fact changes directly affect sales summary and daily report', NOW()),
('imp_002', 'dwd_order_fact',       'ads_gmv_dashboard',    'high',   'Order metric changes affect GMV dashboard', NOW()),
('imp_003', 'dwd_inventory_snapshot','ads_inventory_alarm',   'high',   'Inventory snapshot changes affect stockout and slow-moving alerts', NOW()),
('imp_004', 'dwd_member_profile',    'ads_member_operation', 'medium', 'Member profile changes affect operation segmentation', NOW()),
('imp_005', 'dwd_member_profile',    'ads_member_retention', 'medium', 'Member profile changes affect retention analysis', NOW()),
('imp_006', 'dwd_campaign_event',    'ads_campaign_roi',     'high',   'Campaign event metric changes affect ROI attribution', NOW()),
('imp_007', 'dwd_sku_dim',           'ads_product_rank',     'medium', 'Product dimension changes affect hot product ranking', NOW()),
('imp_008', 'store_daily_kpi',       'ads_store_dashboard',  'high',   'Store KPI changes affect operation dashboard', NOW());

-- ================================================================
-- Optional checks
-- ================================================================
-- SELECT COUNT(*) FROM lineage_domain;
-- SELECT COUNT(*) FROM lineage_asset;
-- SELECT COUNT(*) FROM lineage_edge;
-- SELECT COUNT(*) FROM lineage_snapshot;
-- SELECT COUNT(*) FROM lineage_impact;


-- ================================================================
-- ETL task metadata mock data
-- ================================================================

INSERT INTO etl_task
(task_id, task_name, domain_id, task_type, schedule_cron, source_system, owner, openmetadata_url, description, last_run_at)
VALUES
('task_product_standardize', 'Product Standardization Job', 'product', 'batch', '0 0 * * *', 'Airflow', 'Product Data Team', 'http://10.26.20.3:8585/pipeline/task_product_standardize', 'Standardize PIM/ERP product data into Doris product dimension', NOW()),
('task_product_sales', 'Product Sales Summary Job', 'product', 'batch', '0 10 * * *', 'Airflow', 'Product Data Team', 'http://10.26.20.3:8585/pipeline/task_product_sales', 'Aggregate product sales performance', NOW()),
('task_inventory_snapshot', 'Inventory Snapshot Job', 'inventory', 'batch', '0 5 * * *', 'Airflow', 'Supply Chain Data Team', 'http://10.26.20.3:8585/pipeline/task_inventory_snapshot', 'Aggregate warehouse and store inventory', NOW()),
('task_inventory_turnover', 'Inventory Turnover Job', 'inventory', 'batch', '0 7 * * *', 'Airflow', 'Supply Chain Data Team', 'http://10.26.20.3:8585/pipeline/task_inventory_turnover', 'Calculate inventory turnover and alert metrics', NOW()),
('task_order_fact', 'Unified Order Fact Job', 'order', 'stream', '*/5 * * * *', 'Flink', 'Transaction Data Team', 'http://10.26.20.3:8585/pipeline/task_order_fact', 'Combine POS and e-commerce order details', NOW()),
('task_sales_daily', 'Sales Summary Job', 'order', 'batch', '0 8 * * *', 'Airflow', 'Transaction Data Team', 'http://10.26.20.3:8585/pipeline/task_sales_daily', 'Generate sales daily report and GMV dashboard data', NOW()),
('task_member_profile', 'Member Profile Sync Job', 'member', 'batch', '0 3 * * *', 'Airflow', 'Member Data Team', 'http://10.26.20.3:8585/pipeline/task_member_profile', 'Sync CRM member master and standardize profile', NOW()),
('task_member_rfm', 'Member RFM Job', 'member', 'batch', '0 4 * * *', 'Airflow', 'Member Data Team', 'http://10.26.20.3:8585/pipeline/task_member_rfm', 'Calculate member value segmentation and repurchase ability', NOW()),
('task_campaign_event', 'Campaign Event Job', 'marketing', 'batch', '*/15 * * * *', 'Airflow', 'Marketing Data Team', 'http://10.26.20.3:8585/pipeline/task_campaign_event', 'Aggregate campaign, coupon, click and order events', NOW()),
('task_campaign_roi', 'Marketing ROI Job', 'marketing', 'batch', '0 6 * * *', 'Airflow', 'Marketing Data Team', 'http://10.26.20.3:8585/pipeline/task_campaign_roi', 'Generate campaign conversion and ROI dashboard data', NOW()),
('task_store_kpi', 'Store KPI Job', 'store', 'batch', '0 9 * * *', 'Airflow', 'Store Data Team', 'http://10.26.20.3:8585/pipeline/task_store_kpi', 'Generate store core operation metrics', NOW());

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

-- Task-table lineage edges for OpenMetadata
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

-- Register pipeline nodes for OpenMetadata
INSERT INTO lineage_asset
(asset_id, asset_name, asset_type, domain_id, layer_name, source_system, owner, openmetadata_url, description, refreshed_at)
VALUES
('task_product_standardize', 'Product Standardization Job', 'pipeline', 'product', 'ETL', 'Airflow', 'Product Data Team', 'http://10.26.20.3:8585/pipeline/task_product_standardize', 'Standardize product master and price snapshot into Doris dimension', NOW()),
('task_product_sales', 'Product Sales Summary Job', 'pipeline', 'product', 'ETL', 'Airflow', 'Product Data Team', 'http://10.26.20.3:8585/pipeline/task_product_sales', 'Aggregate sales performance based on product dimension', NOW()),
('task_inventory_snapshot', 'Inventory Snapshot Job', 'pipeline', 'inventory', 'ETL', 'Airflow', 'Supply Chain Data Team', 'http://10.26.20.3:8585/pipeline/task_inventory_snapshot', 'Aggregate warehouse stock and store stock', NOW()),
('task_inventory_turnover', 'Inventory Turnover Job', 'pipeline', 'inventory', 'ETL', 'Airflow', 'Supply Chain Data Team', 'http://10.26.20.3:8585/pipeline/task_inventory_turnover', 'Calculate turnover days and inventory alerts', NOW()),
('task_order_fact', 'Unified Order Fact Job', 'pipeline', 'order', 'ETL', 'Flink', 'Transaction Data Team', 'http://10.26.20.3:8585/pipeline/task_order_fact', 'Combine POS and e-commerce order details', NOW()),
('task_sales_daily', 'Sales Summary Job', 'pipeline', 'order', 'ETL', 'Airflow', 'Transaction Data Team', 'http://10.26.20.3:8585/pipeline/task_sales_daily', 'Generate daily sales report', NOW()),
('task_member_profile', 'Member Profile Sync Job', 'pipeline', 'member', 'ETL', 'Airflow', 'Member Data Team', 'http://10.26.20.3:8585/pipeline/task_member_profile', 'Sync member master', NOW()),
('task_member_rfm', 'Member RFM Job', 'pipeline', 'member', 'ETL', 'Airflow', 'Member Data Team', 'http://10.26.20.3:8585/pipeline/task_member_rfm', 'Calculate member segmentation', NOW()),
('task_campaign_event', 'Campaign Event Job', 'pipeline', 'marketing', 'ETL', 'Airflow', 'Marketing Data Team', 'http://10.26.20.3:8585/pipeline/task_campaign_event', 'Aggregate campaign and coupon events', NOW()),
('task_campaign_roi', 'Marketing ROI Job', 'pipeline', 'marketing', 'ETL', 'Airflow', 'Marketing Data Team', 'http://10.26.20.3:8585/pipeline/task_campaign_roi', 'Calculate marketing attribution and ROI', NOW()),
('task_store_kpi', 'Store KPI Job', 'pipeline', 'store', 'ETL', 'Airflow', 'Store Data Team', 'http://10.26.20.3:8585/pipeline/task_store_kpi', 'Generate store operation metrics', NOW());


-- ================================================================
-- Product real ETL mock source data and insert-select jobs
-- ================================================================
USE retail_lineage;

INSERT INTO pim_item_master
(sku_id, spu_id, sku_name, brand_name, category_lv1, category_lv2, season, gender, color, size_code, launch_date, status, updated_at)
VALUES
(10001, 20001, 'AW Wool Coat Ivory S', 'AURA', 'Outerwear', 'Coat', '2025AW', 'Female', 'Ivory', 'S', '2025-09-10', 'ACTIVE', NOW()),
(10002, 20001, 'AW Wool Coat Ivory M', 'AURA', 'Outerwear', 'Coat', '2025AW', 'Female', 'Ivory', 'M', '2025-09-10', 'ACTIVE', NOW()),
(10003, 20002, 'Light Down Jacket Black L', 'URBAN', 'Outerwear', 'Down Jacket', '2025AW', 'Female', 'Black', 'L', '2025-10-01', 'ACTIVE', NOW()),
(10004, 20003, 'Casual Knitwear Gray M', 'BASIC', 'Top', 'Knitwear', '2025AW', 'Male', 'Gray', 'M', '2025-08-18', 'ACTIVE', NOW());

INSERT INTO erp_sku_price_snapshot
(sku_id, price_date, list_price, sale_price, cost_price, promo_flag, updated_at)
VALUES
(10001, '2025-10-01', 1299.00, 999.00, 520.00, 1, NOW()),
(10002, '2025-10-01', 1299.00, 999.00, 520.00, 1, NOW()),
(10003, '2025-10-01', 1699.00, 1399.00, 710.00, 0, NOW()),
(10004, '2025-10-01', 699.00, 499.00, 210.00, 1, NOW());

INSERT INTO pos_sku_sales_detail
(sale_id, sale_date, store_id, sku_id, qty, gross_amount, discount_amount, net_amount, channel, updated_at)
VALUES
(50001, '2025-10-01', 101, 10001, 12, 15588.00, 3600.00, 11988.00, 'POS', NOW()),
(50002, '2025-10-01', 101, 10002, 8, 10392.00, 2400.00, 7992.00, 'POS', NOW()),
(50003, '2025-10-01', 102, 10003, 6, 10194.00, 1800.00, 8394.00, 'POS', NOW()),
(50004, '2025-10-01', 103, 10004, 20, 13980.00, 3980.00, 10000.00, 'POS', NOW());

INSERT INTO mkt_product_tag_rule
(rule_id, sku_id, tag_name, tag_value, updated_at)
VALUES
(90001, 10001, 'Style', 'Commuter', NOW()),
(90002, 10002, 'Style', 'Commuter', NOW()),
(90003, 10003, 'Style', 'Functional', NOW()),
(90004, 10004, 'Style', 'Basic', NOW());

-- ------------------------
-- 5. ETL 1: Product standardization
-- ------------------------
INSERT INTO dwd_sku_dim
(
  sku_id, spu_id, sku_name, brand_name, category_lv1, category_lv2, season, gender, color, size_code,
  launch_date, status, list_price, sale_price, cost_price, promo_flag, price_date, updated_at
)
SELECT
  p.sku_id,
  p.spu_id,
  p.sku_name,
  p.brand_name,
  p.category_lv1,
  p.category_lv2,
  p.season,
  p.gender,
  p.color,
  p.size_code,
  p.launch_date,
  p.status,
  COALESCE(e.list_price, 0) AS list_price,
  COALESCE(e.sale_price, 0) AS sale_price,
  COALESCE(e.cost_price, 0) AS cost_price,
  COALESCE(e.promo_flag, 0) AS promo_flag,
  e.price_date,
  NOW()
FROM pim_item_master p
LEFT JOIN erp_sku_price_snapshot e
  ON p.sku_id = e.sku_id
 AND e.price_date = '2025-10-01';

-- ------------------------
-- 6. ETL 2: Product sales summary
-- ------------------------
INSERT INTO dws_product_sales
(
  sale_date, sku_id, sku_name, brand_name, category_lv1,
  qty_total, gross_amount_total, discount_amount_total, net_amount_total, avg_price, updated_at
)
SELECT
  s.sale_date,
  d.sku_id,
  d.sku_name,
  d.brand_name,
  d.category_lv1,
  SUM(s.qty) AS qty_total,
  SUM(s.gross_amount) AS gross_amount_total,
  SUM(s.discount_amount) AS discount_amount_total,
  SUM(s.net_amount) AS net_amount_total,
  ROUND(SUM(s.net_amount) / NULLIF(SUM(s.qty), 0), 2) AS avg_price,
  NOW()
FROM pos_sku_sales_detail s
JOIN dwd_sku_dim d
  ON s.sku_id = d.sku_id
WHERE s.sale_date = '2025-10-01'
GROUP BY s.sale_date, d.sku_id, d.sku_name, d.brand_name, d.category_lv1;

-- ------------------------
-- 7. ETL 3: Hot product dashboard
-- ------------------------
INSERT INTO ads_product_rank
(
  stat_date, sku_id, sku_name, brand_name, net_amount_total, qty_total, rank_no, updated_at
)
SELECT
  sale_date AS stat_date,
  sku_id,
  sku_name,
  brand_name,
  net_amount_total,
  qty_total,
  ROW_NUMBER() OVER (PARTITION BY sale_date ORDER BY net_amount_total DESC, qty_total DESC, sku_id ASC) AS rank_no,
  NOW()
FROM dws_product_sales
WHERE sale_date = '2025-10-01';

-- ------------------------
-- 8. OpenMetadata visible lineage edges
-- ------------------------
INSERT INTO lineage_asset
(asset_id, asset_name, asset_type, domain_id, layer_name, source_system, owner, openmetadata_url, description, refreshed_at)
VALUES
('pim_item_master', 'PIM Product Master', 'table', 'product', 'ODS', 'PIM', 'Product Data Team', 'http://10.26.20.3:8585/table/pim_item_master', 'Fashion product master source table', NOW()),
('erp_sku_price_snapshot', 'ERP Product Price Snapshot', 'table', 'product', 'ODS', 'ERP', 'Product Data Team', 'http://10.26.20.3:8585/table/erp_sku_price_snapshot', 'SKU price source table', NOW()),
('pos_sku_sales_detail', 'POS Product Sales Detail', 'table', 'product', 'ODS', 'POS', 'Transaction Data Team', 'http://10.26.20.3:8585/table/pos_sku_sales_detail', 'POS sales source table', NOW()),
('mkt_product_tag_rule', 'Product Tag Rule', 'table', 'product', 'ODS', 'MKT', 'Marketing Data Team', 'http://10.26.20.3:8585/table/mkt_product_tag_rule', 'Marketing tag rule source table', NOW()),
('dwd_sku_dim', 'Product Dimension', 'table', 'product', 'DWD', 'Doris', 'Product Data Team', 'http://10.26.20.3:8585/table/dwd_sku_dim', 'Product standardized result table', NOW()),
('dws_product_sales', 'Product Sales Summary', 'table', 'product', 'DWS', 'Doris', 'Product Data Team', 'http://10.26.20.3:8585/table/dws_product_sales', 'Product sales aggregated result table', NOW()),
('ads_product_rank', 'Hot Product Dashboard', 'report', 'product', 'ADS', 'BI', 'Product Data Team', 'http://10.26.20.3:8585/dashboard/ads_product_rank', 'Product hot ranking dashboard', NOW());

INSERT INTO lineage_edge
(edge_id, from_asset_id, to_asset_id, relation_type, weight, source_system, updated_at)
VALUES
('rl_001', 'pim_item_master', 'dwd_sku_dim', 'read', 5, 'OpenMetadata', NOW()),
('rl_002', 'erp_sku_price_snapshot', 'dwd_sku_dim', 'read', 5, 'OpenMetadata', NOW()),
('rl_003', 'dwd_sku_dim', 'dws_product_sales', 'transform', 8, 'OpenMetadata', NOW()),
('rl_004', 'pos_sku_sales_detail', 'dws_product_sales', 'read', 5, 'OpenMetadata', NOW()),
('rl_005', 'dws_product_sales', 'ads_product_rank', 'publish', 9, 'OpenMetadata', NOW()),
('rl_006', 'mkt_product_tag_rule', 'dwd_sku_dim', 'read', 3, 'OpenMetadata', NOW());

INSERT INTO lineage_snapshot
(snapshot_id, domain_id, snapshot_name, snapshot_time, asset_count, edge_count, source)
VALUES
('snap_product_real_001', 'product', 'Product domain real ETL lineage snapshot', NOW(), 7, 6, 'mock-real-etl');



-- ================================================================
-- Complex ETL mock source data and insert-select jobs
-- ================================================================
USE retail_lineage;

INSERT INTO stg_member_profile VALUES
('M0001','Emma Lin','F','VIP','Shanghai','2023-01-02','2024-04-18',1,NOW()),
('M0002','Tony Zhou','M','GOLD','Hangzhou','2022-11-15','2024-04-20',1,NOW()),
('M0003','Cathy Chen','F','SILVER','Beijing','2024-02-12','2024-04-19',1,NOW()),
('M0004','Mia Zhao','F','VIP','Guangzhou','2021-08-08','2024-04-17',1,NOW());

INSERT INTO stg_stock_snapshot VALUES
('SKU1001','SHOP01',120,80,'NORMAL','2024-04-20',NOW()),
('SKU1002','SHOP01',18,60,'LOW','2024-04-20',NOW()),
('SKU1003','SHOP02',0,50,'OUT','2024-04-20',NOW()),
('SKU1004','SHOP02',95,70,'NORMAL','2024-04-20',NOW());

INSERT INTO stg_promo_rule VALUES
('P0001','SKU1001','Full Reduction',0.8800,'2024-04-01','2024-04-30',1,NOW()),
('P0002','SKU1002','Discount',0.7500,'2024-04-10','2024-04-25',1,NOW()),
('P0003','SKU1003','Flash Sale',0.6200,'2024-04-18','2024-04-21',1,NOW()),
('P0004','SKU1004','None',1.0000,'2024-01-01','2024-12-31',1,NOW());

INSERT INTO stg_order_fact VALUES
('O0001','2024-04-20','M0001','SKU1001','SHOP01',2,398.00,350.24,'PAID','APP',NOW()),
('O0002','2024-04-20','M0001','SKU1002','SHOP01',1,199.00,149.25,'PAID','APP',NOW()),
('O0003','2024-04-20','M0002','SKU1001','SHOP01',1,199.00,175.12,'PAID','MINIAPP',NOW()),
('O0004','2024-04-20','M0003','SKU1003','SHOP02',3,597.00,369.54,'PAID','APP',NOW()),
('O0005','2024-04-20','M0004','SKU1004','SHOP02',1,299.00,299.00,'PAID','STORE',NOW());

INSERT INTO dwd_retail_order_enriched
SELECT
    o.order_dt,
    o.order_id,
    o.member_id,
    m.level_name AS member_level,
    m.city,
    o.sku_id,
    o.shop_id,
    o.qty,
    o.sales_amt,
    o.pay_amt,
    s.stock_qty,
    s.stock_status,
    p.promo_id,
    p.promo_type,
    p.discount_rate,
    ROW_NUMBER() OVER (PARTITION BY o.member_id ORDER BY o.order_dt DESC, o.order_id DESC) AS member_day_rank,
    ROW_NUMBER() OVER (PARTITION BY o.member_id, DATE_FORMAT(o.order_dt, '%Y-%m') ORDER BY o.pay_amt DESC, o.order_id DESC) AS member_month_rank,
    CASE WHEN o.pay_amt >= 300 THEN 1 ELSE 0 END AS is_big_order,
    NOW() AS updated_at
FROM stg_order_fact o
LEFT JOIN stg_member_profile m
    ON o.member_id = m.member_id
LEFT JOIN stg_stock_snapshot s
    ON o.sku_id = s.sku_id
   AND o.shop_id = s.shop_id
   AND o.order_dt = s.snapshot_date
LEFT JOIN stg_promo_rule p
    ON o.sku_id = p.sku_id
   AND o.order_dt BETWEEN p.start_date AND p.end_date
   AND p.is_enabled = 1
WHERE o.order_status = 'PAID'
  AND o.order_dt >= '2024-04-20'
  AND o.channel IN ('APP', 'MINIAPP', 'STORE');

INSERT INTO dws_retail_member_sales
SELECT
    order_dt AS stat_dt,
    member_id,
    member_level,
    city,
    COUNT(DISTINCT order_id) AS order_cnt,
    COUNT(DISTINCT sku_id) AS sku_cnt,
    SUM(qty) AS qty_total,
    SUM(sales_amt) AS sales_total,
    SUM(pay_amt) AS pay_total,
    ROUND(SUM(pay_amt) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS avg_order_amt,
    RANK() OVER (ORDER BY SUM(pay_amt) DESC) AS member_sales_rank,
    MAX(order_dt) AS last_order_dt,
    NOW() AS updated_at
FROM dwd_retail_order_enriched
WHERE is_big_order = 0
  AND member_level IN ('VIP', 'GOLD', 'SILVER')
GROUP BY order_dt, member_id, member_level, city;

INSERT INTO ads_retail_top_sku
SELECT
    d.order_dt AS stat_dt,
    d.sku_id,
    d.shop_id,
    COUNT(DISTINCT d.order_id) AS order_cnt,
    SUM(d.qty) AS qty_total,
    SUM(d.sales_amt) AS sales_total,
    SUM(d.pay_amt) AS pay_total,
    AVG(s.stock_qty) AS stock_qty_avg,
    CASE
        WHEN AVG(s.stock_qty) < 20 OR SUM(d.qty) >= 5 THEN 1
        ELSE 0
    END AS stock_risk_flag,
    ROW_NUMBER() OVER (
        PARTITION BY d.order_dt, d.shop_id
        ORDER BY SUM(d.pay_amt) DESC, SUM(d.qty) DESC, d.sku_id ASC
    ) AS sku_rank,
    NOW() AS updated_at
FROM dwd_retail_order_enriched d
LEFT JOIN stg_stock_snapshot s
    ON d.sku_id = s.sku_id
   AND d.shop_id = s.shop_id
   AND d.order_dt = s.snapshot_date
WHERE d.order_dt = '2024-04-20'
  AND d.pay_amt >= 100
  AND d.stock_status IN ('NORMAL', 'LOW', 'OUT')
GROUP BY d.order_dt, d.sku_id, d.shop_id;
