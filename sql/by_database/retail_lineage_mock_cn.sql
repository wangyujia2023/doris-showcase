-- ================================================================
-- Database: retail_lineage
-- Type: Chinese mock data
-- Source: generated from current Doris table metadata.
-- Execute after schema SQL.
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

-- Table: ads_product_rank
TRUNCATE TABLE `ads_product_rank`;
INSERT INTO `ads_product_rank`(`stat_date`, `sku_id`, `sku_name`, `brand_name`, `net_amount_total`, `qty_total`, `rank_no`, `updated_at`) VALUES
  ('2025-04-01', 10001, '春季轻薄夹克', '青禾', 10.25, 1, 1, '2025-04-01 09:01:00'),
  ('2025-04-02', 10002, '城市通勤双肩包', '北辰', 20.50, 2, 2, '2025-04-02 09:02:00'),
  ('2025-04-03', 10003, '舒适跑步鞋', '云岚', 30.75, 3, 3, '2025-04-03 09:03:00'),
  ('2025-04-04', 10004, '纯棉基础T恤', '序章', 41.00, 4, 4, '2025-04-04 09:04:00'),
  ('2025-04-05', 10005, '防晒户外帽', '山海', 51.25, 5, 5, '2025-04-05 09:05:00');

-- Table: dwd_sku_dim
TRUNCATE TABLE `dwd_sku_dim`;
INSERT INTO `dwd_sku_dim`(`sku_id`, `spu_id`, `sku_name`, `brand_name`, `category_lv1`, `category_lv2`, `season`, `gender`, `color`, `size_code`, `launch_date`, `status`, `list_price`, `sale_price`, `cost_price`, `promo_flag`, `price_date`, `updated_at`) VALUES
  (10001, 10001, '春季轻薄夹克', '青禾', '服饰', '外套', '春季', '男', '米白', 'C0001', '2025-04-01', '正常', 10.25, 10.25, 10.25, 1, '2025-04-01', '2025-04-01 09:01:00'),
  (10002, 10002, '城市通勤双肩包', '北辰', '箱包', '背包', '夏季', '女', '藏蓝', 'C0002', '2025-04-02', '运行中', 20.50, 20.50, 20.50, 0, '2025-04-02', '2025-04-02 09:02:00'),
  (10003, 10003, '舒适跑步鞋', '云岚', '鞋靴', '跑鞋', '秋季', '未知', '墨绿', 'C0003', '2025-04-03', '已成功', 30.75, 30.75, 30.75, 1, '2025-04-03', '2025-04-03 09:03:00'),
  (10004, 10004, '纯棉基础T恤', '序章', '家居', 'T恤', '冬季', '男', '浅灰', 'C0004', '2025-04-04', '已生效', 41.00, 41.00, 41.00, 0, '2025-04-04', '2025-04-04 09:04:00'),
  (10005, 10005, '防晒户外帽', '山海', '户外', '帽子', '全年', '女', '酒红', 'C0005', '2025-04-05', '已完成', 51.25, 51.25, 51.25, 1, '2025-04-05', '2025-04-05 09:05:00');

-- Table: dws_product_sales
TRUNCATE TABLE `dws_product_sales`;
INSERT INTO `dws_product_sales`(`sale_date`, `sku_id`, `sku_name`, `brand_name`, `category_lv1`, `qty_total`, `gross_amount_total`, `discount_amount_total`, `net_amount_total`, `avg_price`, `updated_at`) VALUES
  ('2025-04-01', 10001, '春季轻薄夹克', '青禾', '服饰', 1, 10.25, 10, 10.25, 10.25, '2025-04-01 09:01:00'),
  ('2025-04-02', 10002, '城市通勤双肩包', '北辰', '箱包', 2, 20.50, 20, 20.50, 20.50, '2025-04-02 09:02:00'),
  ('2025-04-03', 10003, '舒适跑步鞋', '云岚', '鞋靴', 3, 30.75, 30, 30.75, 30.75, '2025-04-03 09:03:00'),
  ('2025-04-04', 10004, '纯棉基础T恤', '序章', '家居', 4, 41.00, 40, 41.00, 41.00, '2025-04-04 09:04:00'),
  ('2025-04-05', 10005, '防晒户外帽', '山海', '户外', 5, 51.25, 50, 51.25, 51.25, '2025-04-05 09:05:00');

-- Table: erp_sku_price_snapshot
TRUNCATE TABLE `erp_sku_price_snapshot`;
INSERT INTO `erp_sku_price_snapshot`(`sku_id`, `price_date`, `list_price`, `sale_price`, `cost_price`, `promo_flag`, `updated_at`) VALUES
  (10001, '2025-04-01', 10.25, 10.25, 10.25, 1, '2025-04-01 09:01:00'),
  (10002, '2025-04-02', 20.50, 20.50, 20.50, 0, '2025-04-02 09:02:00'),
  (10003, '2025-04-03', 30.75, 30.75, 30.75, 1, '2025-04-03 09:03:00'),
  (10004, '2025-04-04', 41.00, 41.00, 41.00, 0, '2025-04-04 09:04:00'),
  (10005, '2025-04-05', 51.25, 51.25, 51.25, 1, '2025-04-05 09:05:00');

-- Table: lineage_asset
TRUNCATE TABLE `lineage_asset`;
INSERT INTO `lineage_asset`(`asset_id`, `asset_name`, `asset_type`, `domain_id`, `layer_name`, `source_system`, `owner`, `openmetadata_url`, `description`, `refreshed_at`) VALUES
  ('lineage__001', '商品主数据表', 'table', 'product', 'ODS', '核心系统', '数据平台组', 'http://example.com/lineage_asset/1', '商品数据链路每日同步样例', '2025-04-01 09:01:00'),
  ('lineage__002', '库存快照表', 'table', 'inventory', 'DWD', '数据中台', '零售运营组', 'http://example.com/lineage_asset/2', '库存数据链路每日同步样例', '2025-04-02 09:02:00'),
  ('lineage__003', '订单汇总报表', 'report', 'order', 'DWS', '营销平台', '风控分析组', 'http://example.com/lineage_asset/3', '订单数据链路每日同步样例', '2025-04-03 09:03:00'),
  ('lineage__004', '会员画像任务', 'pipeline', 'member', 'ADS', '监管平台', '客户经营组', 'http://example.com/lineage_asset/4', '会员数据链路每日同步样例', '2025-04-04 09:04:00'),
  ('lineage__005', '门店销售看板', 'table', 'store', 'ETL', 'OpenMetadata', '监管报送组', 'http://example.com/lineage_asset/5', '门店数据链路每日同步样例', '2025-04-05 09:05:00');

-- Table: lineage_domain
TRUNCATE TABLE `lineage_domain`;
INSERT INTO `lineage_domain`(`domain_id`, `domain_name`, `domain_desc`, `owner`, `updated_at`) VALUES
  ('product', '业务域1', '商品数据链路每日同步样例', '数据平台组', '2025-04-01 09:01:00'),
  ('inventory', '业务域2', '库存数据链路每日同步样例', '零售运营组', '2025-04-02 09:02:00'),
  ('order', '业务域3', '订单数据链路每日同步样例', '风控分析组', '2025-04-03 09:03:00'),
  ('member', '业务域4', '会员数据链路每日同步样例', '客户经营组', '2025-04-04 09:04:00'),
  ('store', '业务域5', '门店数据链路每日同步样例', '监管报送组', '2025-04-05 09:05:00');

-- Table: lineage_edge
TRUNCATE TABLE `lineage_edge`;
INSERT INTO `lineage_edge`(`edge_id`, `from_asset_id`, `to_asset_id`, `relation_type`, `weight`, `source_system`, `updated_at`) VALUES
  ('lineage__001', 'lineage__001', 'lineage__001', '读取', 1, '核心系统', '2025-04-01 09:01:00'),
  ('lineage__002', 'lineage__002', 'lineage__002', '加工', 2, '数据中台', '2025-04-02 09:02:00'),
  ('lineage__003', 'lineage__003', 'lineage__003', '发布', 3, '营销平台', '2025-04-03 09:03:00'),
  ('lineage__004', 'lineage__004', 'lineage__004', '派生', 4, '监管平台', '2025-04-04 09:04:00'),
  ('lineage__005', 'lineage__005', 'lineage__005', '校验', 5, 'OpenMetadata', '2025-04-05 09:05:00');

-- Table: lineage_impact
TRUNCATE TABLE `lineage_impact`;
INSERT INTO `lineage_impact`(`impact_id`, `asset_id`, `impacted_asset_id`, `impact_level`, `impact_reason`, `updated_at`) VALUES
  ('lineage__001', 'lineage__001', 'lineage__001', '低', '商品数据链路每日同步样例', '2025-04-01 09:01:00'),
  ('lineage__002', 'lineage__002', 'lineage__002', '中', '库存数据链路每日同步样例', '2025-04-02 09:02:00'),
  ('lineage__003', 'lineage__003', 'lineage__003', '高', '订单数据链路每日同步样例', '2025-04-03 09:03:00'),
  ('lineage__004', 'lineage__004', 'lineage__004', '严重', '会员数据链路每日同步样例', '2025-04-04 09:04:00'),
  ('lineage__005', 'lineage__005', 'lineage__005', '提示', '门店数据链路每日同步样例', '2025-04-05 09:05:00');

-- Table: lineage_snapshot
TRUNCATE TABLE `lineage_snapshot`;
INSERT INTO `lineage_snapshot`(`snapshot_id`, `domain_id`, `snapshot_name`, `snapshot_time`, `asset_count`, `edge_count`, `source`) VALUES
  ('lineage__001', 'product', '商品链路快照', '2025-04-01 09:01:00', 10, 10, '核心系统'),
  ('lineage__002', 'inventory', '库存链路快照', '2025-04-02 09:02:00', 20, 20, '数据中台'),
  ('lineage__003', 'order', '订单链路快照', '2025-04-03 09:03:00', 30, 30, '营销平台'),
  ('lineage__004', 'member', '会员链路快照', '2025-04-04 09:04:00', 40, 40, '监管平台'),
  ('lineage__005', 'store', '门店链路快照', '2025-04-05 09:05:00', 50, 50, 'OpenMetadata');

-- Table: lineage_sync_log
TRUNCATE TABLE `lineage_sync_log`;
INSERT INTO `lineage_sync_log`(`log_id`, `sync_time`, `start_date`, `end_date`, `scan_limit`, `scanned`, `synced`, `skipped`, `failed`, `success`, `errors`, `details`, `created_at`) VALUES
  ('lineage__001', '2025-04-01 09:01:00', '2025-04-01', '2025-04-01', 1, 1, 1, 1, 1, 1, '商品数据链路每日同步样例', '商品数据链路每日同步样例', '2025-04-01 09:01:00'),
  ('lineage__002', '2025-04-02 09:02:00', '2025-04-02', '2025-04-02', 2, 2, 2, 2, 2, 2, '库存数据链路每日同步样例', '库存数据链路每日同步样例', '2025-04-02 09:02:00'),
  ('lineage__003', '2025-04-03 09:03:00', '2025-04-03', '2025-04-03', 3, 3, 3, 3, 3, 3, '订单数据链路每日同步样例', '订单数据链路每日同步样例', '2025-04-03 09:03:00'),
  ('lineage__004', '2025-04-04 09:04:00', '2025-04-04', '2025-04-04', 4, 4, 4, 4, 4, 4, '会员数据链路每日同步样例', '会员数据链路每日同步样例', '2025-04-04 09:04:00'),
  ('lineage__005', '2025-04-05 09:05:00', '2025-04-05', '2025-04-05', 5, 5, 5, 5, 5, 5, '门店数据链路每日同步样例', '门店数据链路每日同步样例', '2025-04-05 09:05:00');

-- Table: mkt_product_tag_rule
TRUNCATE TABLE `mkt_product_tag_rule`;
INSERT INTO `mkt_product_tag_rule`(`rule_id`, `sku_id`, `tag_name`, `tag_value`, `updated_at`) VALUES
  (10001, 10001, '热销', '近7日销量领先', '2025-04-01 09:01:00'),
  (10002, 10002, '新品', '上市30天内', '2025-04-02 09:02:00'),
  (10003, 10003, '高毛利', '毛利率高于35%', '2025-04-03 09:03:00'),
  (10004, 10004, '会员偏好', '会员复购偏好', '2025-04-04 09:04:00'),
  (10005, 10005, '清仓', '库存周转偏慢', '2025-04-05 09:05:00');

-- Table: om_pipeline_asset
TRUNCATE TABLE `om_pipeline_asset`;
INSERT INTO `om_pipeline_asset`(`pipeline_id`, `pipeline_name`, `domain_id`, `owner`, `description`, `openmetadata_url`, `updated_at`) VALUES
  ('om_pipel_001', '商品维表同步', 'product', '数据平台组', '商品数据链路每日同步样例', 'http://example.com/om_pipeline_asset/1', '2025-04-01 09:01:00'),
  ('om_pipel_002', '库存日结加工', 'inventory', '零售运营组', '库存数据链路每日同步样例', 'http://example.com/om_pipeline_asset/2', '2025-04-02 09:02:00'),
  ('om_pipel_003', '订单汇总发布', 'order', '风控分析组', '订单数据链路每日同步样例', 'http://example.com/om_pipeline_asset/3', '2025-04-03 09:03:00'),
  ('om_pipel_004', '会员标签刷新', 'member', '客户经营组', '会员数据链路每日同步样例', 'http://example.com/om_pipeline_asset/4', '2025-04-04 09:04:00'),
  ('om_pipel_005', '门店销售汇聚', 'store', '监管报送组', '门店数据链路每日同步样例', 'http://example.com/om_pipeline_asset/5', '2025-04-05 09:05:00');

-- Table: pim_item_master
TRUNCATE TABLE `pim_item_master`;
INSERT INTO `pim_item_master`(`sku_id`, `spu_id`, `sku_name`, `brand_name`, `category_lv1`, `category_lv2`, `season`, `gender`, `color`, `size_code`, `launch_date`, `status`, `updated_at`) VALUES
  (10001, 10001, '春季轻薄夹克', '青禾', '服饰', '外套', '春季', '男', '米白', 'C0001', '2025-04-01', '正常', '2025-04-01 09:01:00'),
  (10002, 10002, '城市通勤双肩包', '北辰', '箱包', '背包', '夏季', '女', '藏蓝', 'C0002', '2025-04-02', '运行中', '2025-04-02 09:02:00'),
  (10003, 10003, '舒适跑步鞋', '云岚', '鞋靴', '跑鞋', '秋季', '未知', '墨绿', 'C0003', '2025-04-03', '已成功', '2025-04-03 09:03:00'),
  (10004, 10004, '纯棉基础T恤', '序章', '家居', 'T恤', '冬季', '男', '浅灰', 'C0004', '2025-04-04', '已生效', '2025-04-04 09:04:00'),
  (10005, 10005, '防晒户外帽', '山海', '户外', '帽子', '全年', '女', '酒红', 'C0005', '2025-04-05', '已完成', '2025-04-05 09:05:00');

-- Table: pos_sku_sales_detail
TRUNCATE TABLE `pos_sku_sales_detail`;
INSERT INTO `pos_sku_sales_detail`(`sale_id`, `sale_date`, `store_id`, `sku_id`, `qty`, `gross_amount`, `discount_amount`, `net_amount`, `channel`, `updated_at`) VALUES
  (10001, '2025-04-01', 10001, 10001, 1, 10.25, 10, 10.25, '手机银行', '2025-04-01 09:01:00'),
  (10002, '2025-04-02', 10002, 10002, 2, 20.50, 20, 20.50, '网点柜面', '2025-04-02 09:02:00'),
  (10003, '2025-04-03', 10003, 10003, 3, 30.75, 30, 30.75, '网上银行', '2025-04-03 09:03:00'),
  (10004, '2025-04-04', 10004, 10004, 4, 41.00, 40, 41.00, '微信小程序', '2025-04-04 09:04:00'),
  (10005, '2025-04-05', 10005, 10005, 5, 51.25, 50, 51.25, '开放接口', '2025-04-05 09:05:00');
