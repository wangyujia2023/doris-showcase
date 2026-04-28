-- ================================================================
-- Database: retail_lineage
-- Type: mock data
-- Description: Retail lineage assets, ETL task mappings and insert-select mock data.
-- Execute after retail_lineage_schema.sql.
-- Execute: mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_mock.sql
-- ================================================================

-- ================================================================
-- 服饰零售数据血缘 - 模拟初始化数据
-- 说明：
-- 1. 依赖 retail_lineage 库与基础表 init_retail_lineage.sql
-- 2. 这份脚本只负责灌入模拟资产、血缘边、快照、影响分析
-- 3. 适合无真实 OpenMetadata 数据时先跑通前端展示
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

-- ------------------------
-- 业务域
-- ------------------------
INSERT INTO lineage_domain (domain_id, domain_name, domain_desc, owner, updated_at) VALUES
('product',    '商品域',   '商品主数据、SKU、价格、上新、品类分析', '商品数据组', NOW()),
('inventory',  '库存域',   '仓库库存、门店库存、调拨、补货、预警',   '供应链数据组', NOW()),
('order',      '订单域',   'POS 交易、电商订单、支付、退款、GMV',    '交易数据组', NOW()),
('member',     '会员域',   '注册、等级、标签、复购、RFM 画像',      '会员数据组', NOW()),
('store',      '门店域',   '门店经营、坪效、导购、销售日报',         '门店数据组', NOW()),
('marketing',  '营销域',   '活动、优惠券、投放、转化归因、ROI',      '营销数据组', NOW());

-- ------------------------
-- 资产节点
-- ------------------------
INSERT INTO lineage_asset
(asset_id, asset_name, asset_type, domain_id, layer_name, source_system, owner, openmetadata_url, description, refreshed_at)
VALUES
-- 商品链路
('pim_sku_base',         '商品主数据',       'table',  'product',   'ODS', 'PIM',   '商品数据组', 'http://10.26.20.3:8585/assets/pim_sku_base', '服饰商品基础信息、品牌、类目、季节、吊牌价', NOW()),
('ods_sku_price',        '商品价格快照',     'table',  'product',   'ODS', 'ERP',   '商品数据组', 'http://10.26.20.3:8585/assets/ods_sku_price', 'SKU 日级价格快照', NOW()),
('dwd_sku_dim',          '商品维表',         'table',  'product',   'DWD', 'Doris', '商品数据组', 'http://10.26.20.3:8585/assets/dwd_sku_dim', '标准化商品维表', NOW()),
('dws_product_sales',    '商品销售汇总',     'table',  'product',   'DWS', 'Doris', '商品数据组', 'http://10.26.20.3:8585/assets/dws_product_sales', '按商品聚合的销售指标', NOW()),
('ads_product_rank',     '热销商品看板',     'report', 'product',   'ADS', 'BI',    '商品数据组', 'http://10.26.20.3:8585/assets/ads_product_rank', '热销商品排行与趋势看板', NOW()),

-- 库存链路
('wms_stock_daily',      '仓库库存快照',     'table',  'inventory', 'ODS', 'WMS',   '供应链数据组', 'http://10.26.20.3:8585/assets/wms_stock_daily', '仓库日库存快照', NOW()),
('store_stock_daily',    '门店库存快照',     'table',  'inventory', 'ODS', 'POS',   '供应链数据组', 'http://10.26.20.3:8585/assets/store_stock_daily', '门店日库存快照', NOW()),
('dwd_inventory_snapshot','库存明细快照',    'table',  'inventory', 'DWD', 'Doris', '供应链数据组', 'http://10.26.20.3:8585/assets/dwd_inventory_snapshot', '统一库存明细层', NOW()),
('dws_inventory_turnover','库存周转汇总',    'table',  'inventory', 'DWS', 'Doris', '供应链数据组', 'http://10.26.20.3:8585/assets/dws_inventory_turnover', '库存周转与周转天数', NOW()),
('ads_inventory_alarm',  '库存预警看板',     'report', 'inventory', 'ADS', 'BI',    '供应链数据组', 'http://10.26.20.3:8585/assets/ads_inventory_alarm', '滞销、缺货、调拨预警', NOW()),

-- 订单链路
('pos_order_detail',     '门店交易明细',     'table',  'order',     'ODS', 'POS',   '交易数据组', 'http://10.26.20.3:8585/assets/pos_order_detail', '门店 POS 交易流水', NOW()),
('ec_order_detail',      '电商订单明细',     'table',  'order',     'ODS', 'EC',    '交易数据组', 'http://10.26.20.3:8585/assets/ec_order_detail', '电商平台订单流水', NOW()),
('dwd_order_fact',       '统一订单事实表',   'table',  'order',     'DWD', 'Doris', '交易数据组', 'http://10.26.20.3:8585/assets/dwd_order_fact', '统一订单事实层', NOW()),
('dws_sales_daily',      '销售日汇总',       'table',  'order',     'DWS', 'Doris', '交易数据组', 'http://10.26.20.3:8585/assets/dws_sales_daily', '日销售额、件数、客单价汇总', NOW()),
('ads_sales_report',     '销售日报',         'report', 'store',     'ADS', 'BI',    '门店数据组', 'http://10.26.20.3:8585/assets/ads_sales_report', '门店销售日报与经营看板', NOW()),
('ads_gmv_dashboard',    'GMV 看板',         'report', 'order',     'ADS', 'BI',    '交易数据组', 'http://10.26.20.3:8585/assets/ads_gmv_dashboard', '全渠道 GMV 与退款率看板', NOW()),

-- 会员链路
('crm_member_base',      '会员主档',         'table',  'member',    'ODS', 'CRM',   '会员数据组', 'http://10.26.20.3:8585/assets/crm_member_base', '会员注册与基础画像', NOW()),
('dwd_member_profile',   '会员画像维表',     'table',  'member',    'DWD', 'Doris', '会员数据组', 'http://10.26.20.3:8585/assets/dwd_member_profile', '会员标准化画像', NOW()),
('dws_member_rfm',       '会员 RFM 汇总',    'table',  'member',    'DWS', 'Doris', '会员数据组', 'http://10.26.20.3:8585/assets/dws_member_rfm', '会员复购与价值分层', NOW()),
('ads_member_operation', '会员运营看板',     'report', 'member',    'ADS', 'BI',    '会员数据组', 'http://10.26.20.3:8585/assets/ads_member_operation', '拉新、促活、复购看板', NOW()),
('ads_member_retention', '会员留存分析',     'report', 'member',    'ADS', 'BI',    '会员数据组', 'http://10.26.20.3:8585/assets/ads_member_retention', '留存与流失预警看板', NOW()),

-- 营销链路
('mkt_campaign',         '活动配置表',       'table',  'marketing', 'ODS', 'MKT',   '营销数据组', 'http://10.26.20.3:8585/assets/mkt_campaign', '营销活动基础配置', NOW()),
('mkt_coupon_send',      '优惠券发放表',     'table',  'marketing', 'ODS', 'MKT',   '营销数据组', 'http://10.26.20.3:8585/assets/mkt_coupon_send', '优惠券发放与领取记录', NOW()),
('dwd_campaign_event',   '活动事件明细',     'table',  'marketing', 'DWD', 'Doris', '营销数据组', 'http://10.26.20.3:8585/assets/dwd_campaign_event', '活动行为统一明细', NOW()),
('dws_conversion',       '转化汇总表',       'table',  'marketing', 'DWS', 'Doris', '营销数据组', 'http://10.26.20.3:8585/assets/dws_conversion', '活动转化、点击、下单汇总', NOW()),
('ads_campaign_roi',     '营销 ROI 看板',    'report', 'marketing', 'ADS', 'BI',    '营销数据组', 'http://10.26.20.3:8585/assets/ads_campaign_roi', '营销投放效果与 ROI 看板', NOW()),

-- 门店链路
('store_daily_kpi',      '门店日经营指标',   'table',  'store',     'DWS', 'Doris', '门店数据组', 'http://10.26.20.3:8585/assets/store_daily_kpi', '门店销售、客流、坪效、转化率', NOW()),
('ads_store_dashboard',  '门店经营看板',     'report', 'store',     'ADS', 'BI',    '门店数据组', 'http://10.26.20.3:8585/assets/ads_store_dashboard', '门店经营综合看板', NOW());

-- ------------------------
-- 血缘边
-- ------------------------
INSERT INTO lineage_edge
(edge_id, from_asset_id, to_asset_id, relation_type, weight, source_system, updated_at)
VALUES
-- 商品链路
('e_p1', 'pim_sku_base',   'dwd_sku_dim',        'upstream', 5, 'OpenMetadata', NOW()),
('e_p2', 'ods_sku_price',   'dwd_sku_dim',        'upstream', 4, 'OpenMetadata', NOW()),
('e_p3', 'dwd_sku_dim',     'dws_product_sales',   'transform', 8, 'OpenMetadata', NOW()),
('e_p4', 'dws_product_sales','ads_product_rank',   'transform', 7, 'OpenMetadata', NOW()),

-- 库存链路
('e_i1', 'wms_stock_daily',   'dwd_inventory_snapshot', 'upstream', 5, 'OpenMetadata', NOW()),
('e_i2', 'store_stock_daily', 'dwd_inventory_snapshot', 'upstream', 5, 'OpenMetadata', NOW()),
('e_i3', 'dwd_inventory_snapshot', 'dws_inventory_turnover', 'transform', 8, 'OpenMetadata', NOW()),
('e_i4', 'dws_inventory_turnover', 'ads_inventory_alarm', 'transform', 7, 'OpenMetadata', NOW()),

-- 订单链路
('e_o1', 'pos_order_detail', 'dwd_order_fact',     'upstream', 6, 'OpenMetadata', NOW()),
('e_o2', 'ec_order_detail',  'dwd_order_fact',     'upstream', 6, 'OpenMetadata', NOW()),
('e_o3', 'dwd_order_fact',   'dws_sales_daily',    'transform', 9, 'OpenMetadata', NOW()),
('e_o4', 'dws_sales_daily',   'ads_sales_report',   'transform', 8, 'OpenMetadata', NOW()),
('e_o5', 'dws_sales_daily',   'ads_gmv_dashboard',  'transform', 8, 'OpenMetadata', NOW()),

-- 会员链路
('e_m1', 'crm_member_base',   'dwd_member_profile', 'upstream', 5, 'OpenMetadata', NOW()),
('e_m2', 'dwd_member_profile','dws_member_rfm',     'transform', 8, 'OpenMetadata', NOW()),
('e_m3', 'dws_member_rfm',    'ads_member_operation','transform', 7, 'OpenMetadata', NOW()),
('e_m4', 'dws_member_rfm',    'ads_member_retention','transform', 7, 'OpenMetadata', NOW()),

-- 营销链路
('e_c1', 'mkt_campaign',      'dwd_campaign_event', 'upstream', 5, 'OpenMetadata', NOW()),
('e_c2', 'mkt_coupon_send',   'dwd_campaign_event', 'upstream', 4, 'OpenMetadata', NOW()),
('e_c3', 'dwd_campaign_event','dws_conversion',     'transform', 8, 'OpenMetadata', NOW()),
('e_c4', 'dws_conversion',    'ads_campaign_roi',   'transform', 9, 'OpenMetadata', NOW()),

-- 门店链路
('e_s1', 'dws_sales_daily',    'store_daily_kpi',   'transform', 7, 'OpenMetadata', NOW()),
('e_s2', 'store_daily_kpi',    'ads_store_dashboard','transform', 8, 'OpenMetadata', NOW()),
('e_s3', 'ads_sales_report',   'ads_store_dashboard','downstream', 5, 'OpenMetadata', NOW());

-- ------------------------
-- 快照
-- ------------------------
INSERT INTO lineage_snapshot
(snapshot_id, domain_id, snapshot_name, snapshot_time, asset_count, edge_count, source)
VALUES
('snap_product_001',   'product',   '商品域首版血缘快照',   NOW(), 5, 4, 'mock'),
('snap_inventory_001', 'inventory', '库存域首版血缘快照',   NOW(), 5, 4, 'mock'),
('snap_order_001',     'order',     '订单域首版血缘快照',   NOW(), 6, 5, 'mock'),
('snap_member_001',    'member',    '会员域首版血缘快照',   NOW(), 5, 4, 'mock'),
('snap_marketing_001', 'marketing', '营销域首版血缘快照',   NOW(), 5, 4, 'mock'),
('snap_store_001',     'store',     '门店域首版血缘快照',   NOW(), 2, 3, 'mock');

-- ------------------------
-- 影响分析
-- ------------------------
INSERT INTO lineage_impact
(impact_id, asset_id, impacted_asset_id, impact_level, impact_reason, updated_at)
VALUES
('imp_001', 'dwd_order_fact',       'dws_sales_daily',      'high',   '订单事实表变更会直接影响销售汇总与日报', NOW()),
('imp_002', 'dwd_order_fact',       'ads_gmv_dashboard',    'high',   '订单口径变化会影响 GMV 看板', NOW()),
('imp_003', 'dwd_inventory_snapshot','ads_inventory_alarm',   'high',   '库存快照变化会影响缺货与滞销预警', NOW()),
('imp_004', 'dwd_member_profile',    'ads_member_operation', 'medium', '会员画像变更会影响运营分层', NOW()),
('imp_005', 'dwd_member_profile',    'ads_member_retention', 'medium', '会员画像变更会影响留存分析', NOW()),
('imp_006', 'dwd_campaign_event',    'ads_campaign_roi',     'high',   '活动事件口径变更会影响 ROI 归因', NOW()),
('imp_007', 'dwd_sku_dim',           'ads_product_rank',     'medium', '商品维表变更会影响热销排行展示', NOW()),
('imp_008', 'store_daily_kpi',       'ads_store_dashboard',  'high',   '门店 KPI 变更会影响经营看板', NOW());

-- ================================================================
-- 可选检查
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


-- ================================================================
-- Product real ETL mock source data and insert-select jobs
-- ================================================================
USE retail_lineage;

INSERT INTO pim_item_master
(sku_id, spu_id, sku_name, brand_name, category_lv1, category_lv2, season, gender, color, size_code, launch_date, status, updated_at)
VALUES
(10001, 20001, '秋冬羊毛大衣-米白-S', 'AURA', '外套', '大衣', '2025AW', '女', '米白', 'S', '2025-09-10', 'ACTIVE', NOW()),
(10002, 20001, '秋冬羊毛大衣-米白-M', 'AURA', '外套', '大衣', '2025AW', '女', '米白', 'M', '2025-09-10', 'ACTIVE', NOW()),
(10003, 20002, '轻羽绒短款-黑色-L', 'URBAN', '外套', '羽绒服', '2025AW', '女', '黑色', 'L', '2025-10-01', 'ACTIVE', NOW()),
(10004, 20003, '休闲针织衫-灰色-M', 'BASIC', '上衣', '针织衫', '2025AW', '男', '灰色', 'M', '2025-08-18', 'ACTIVE', NOW());

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
(90001, 10001, '风格', '通勤', NOW()),
(90002, 10002, '风格', '通勤', NOW()),
(90003, 10003, '风格', '机能', NOW()),
(90004, 10004, '风格', '基础', NOW());

-- ------------------------
-- 5. ETL 一：商品标准化
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
-- 6. ETL 二：商品销售汇总
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
-- 7. ETL 三：热销商品看板
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
-- 8. OpenMetadata 可见的血缘补边
-- ------------------------
INSERT INTO lineage_asset
(asset_id, asset_name, asset_type, domain_id, layer_name, source_system, owner, openmetadata_url, description, refreshed_at)
VALUES
('pim_item_master', 'PIM 商品主数据', 'table', 'product', 'ODS', 'PIM', '商品数据组', 'http://10.26.20.3:8585/table/pim_item_master', '服饰商品主数据源表', NOW()),
('erp_sku_price_snapshot', 'ERP 商品价格快照', 'table', 'product', 'ODS', 'ERP', '商品数据组', 'http://10.26.20.3:8585/table/erp_sku_price_snapshot', 'SKU 价格源表', NOW()),
('pos_sku_sales_detail', 'POS 商品销售明细', 'table', 'product', 'ODS', 'POS', '交易数据组', 'http://10.26.20.3:8585/table/pos_sku_sales_detail', 'POS 销售源表', NOW()),
('mkt_product_tag_rule', '商品标签规则', 'table', 'product', 'ODS', 'MKT', '营销数据组', 'http://10.26.20.3:8585/table/mkt_product_tag_rule', '营销标签规则源表', NOW()),
('dwd_sku_dim', '商品维表', 'table', 'product', 'DWD', 'Doris', '商品数据组', 'http://10.26.20.3:8585/table/dwd_sku_dim', '商品标准化结果表', NOW()),
('dws_product_sales', '商品销售汇总', 'table', 'product', 'DWS', 'Doris', '商品数据组', 'http://10.26.20.3:8585/table/dws_product_sales', '商品销售聚合结果表', NOW()),
('ads_product_rank', '热销商品看板', 'report', 'product', 'ADS', 'BI', '商品数据组', 'http://10.26.20.3:8585/dashboard/ads_product_rank', '商品热销排行看板', NOW());

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
('snap_product_real_001', 'product', '商品域真实 ETL 血缘快照', NOW(), 7, 6, 'mock-real-etl');



-- ================================================================
-- Complex ETL mock source data and insert-select jobs
-- ================================================================
USE retail_lineage;

INSERT INTO stg_member_profile VALUES
('M0001','林雨','F','VIP','上海','2023-01-02','2024-04-18',1,NOW()),
('M0002','周涛','M','GOLD','杭州','2022-11-15','2024-04-20',1,NOW()),
('M0003','陈晨','F','SILVER','北京','2024-02-12','2024-04-19',1,NOW()),
('M0004','赵敏','F','VIP','广州','2021-08-08','2024-04-17',1,NOW());

INSERT INTO stg_stock_snapshot VALUES
('SKU1001','SHOP01',120,80,'NORMAL','2024-04-20',NOW()),
('SKU1002','SHOP01',18,60,'LOW','2024-04-20',NOW()),
('SKU1003','SHOP02',0,50,'OUT','2024-04-20',NOW()),
('SKU1004','SHOP02',95,70,'NORMAL','2024-04-20',NOW());

INSERT INTO stg_promo_rule VALUES
('P0001','SKU1001','满减',0.8800,'2024-04-01','2024-04-30',1,NOW()),
('P0002','SKU1002','折扣',0.7500,'2024-04-10','2024-04-25',1,NOW()),
('P0003','SKU1003','秒杀',0.6200,'2024-04-18','2024-04-21',1,NOW()),
('P0004','SKU1004','无',1.0000,'2024-01-01','2024-12-31',1,NOW());

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

