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
