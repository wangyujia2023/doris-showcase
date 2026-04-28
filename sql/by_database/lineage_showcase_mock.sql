-- ================================================================
-- Database: lineage_showcase
-- Type: English mock data
-- Source: generated from current Doris table metadata.
-- Execute after schema SQL.
-- ================================================================

CREATE DATABASE IF NOT EXISTS lineage_showcase;
USE lineage_showcase;

-- Table: ads_product_rank
TRUNCATE TABLE `ads_product_rank`;
INSERT INTO `ads_product_rank` (`stat_date`, `sku_id`, `sku_name`, `brand_name`, `net_amount_total`, `qty_total`, `rank_no`, `updated_at`) VALUES
  ('2025-04-01', 10001, 'Sku 1', 'Brand 1', 10.25, 1, 1, '2025-04-01 09:01:00'),
  ('2025-04-02', 10002, 'Sku 2', 'Brand 2', 20.50, 2, 2, '2025-04-02 09:02:00'),
  ('2025-04-03', 10003, 'Sku 3', 'Brand 3', 30.75, 3, 3, '2025-04-03 09:03:00'),
  ('2025-04-04', 10004, 'Sku 4', 'Brand 4', 41.00, 4, 4, '2025-04-04 09:04:00'),
  ('2025-04-05', 10005, 'Sku 5', 'Brand 5', 51.25, 5, 5, '2025-04-05 09:05:00');

-- Table: dwd_sku_dim
TRUNCATE TABLE `dwd_sku_dim`;
INSERT INTO `dwd_sku_dim` (`sku_id`, `spu_id`, `sku_name`, `brand_name`, `category_lv1`, `category_lv2`, `season`, `gender`, `color`, `size_code`, `launch_date`, `status`, `list_price`, `sale_price`, `cost_price`, `promo_flag`, `price_date`, `updated_at`) VALUES
  (10001, 10001, 'Sku 1', 'Brand 1', 'Retail', 'Retail', 'dwd_sku_dim_season_1', 'dwd_sku_dim_gend', 'dwd_sku_dim_color_1', 'C0001', '2025-04-01', 'Normal', 10.25, 10.25, 10.25, 1, '2025-04-01', '2025-04-01 09:01:00'),
  (10002, 10002, 'Sku 2', 'Brand 2', 'Wealth', 'Wealth', 'dwd_sku_dim_season_2', 'dwd_sku_dim_gend', 'dwd_sku_dim_color_2', 'C0002', '2025-04-02', 'Running', 20.50, 20.50, 20.50, 0, '2025-04-02', '2025-04-02 09:02:00'),
  (10003, 10003, 'Sku 3', 'Brand 3', 'Credit', 'Credit', 'dwd_sku_dim_season_3', 'dwd_sku_dim_gend', 'dwd_sku_dim_color_3', 'C0003', '2025-04-03', 'Success', 30.75, 30.75, 30.75, 1, '2025-04-03', '2025-04-03 09:03:00'),
  (10004, 10004, 'Sku 4', 'Brand 4', 'Risk', 'Risk', 'dwd_sku_dim_season_4', 'dwd_sku_dim_gend', 'dwd_sku_dim_color_4', 'C0004', '2025-04-04', 'Active', 41.00, 41.00, 41.00, 0, '2025-04-04', '2025-04-04 09:04:00'),
  (10005, 10005, 'Sku 5', 'Brand 5', 'Operation', 'Operation', 'dwd_sku_dim_season_5', 'dwd_sku_dim_gend', 'dwd_sku_dim_color_5', 'C0005', '2025-04-05', 'Completed', 51.25, 51.25, 51.25, 1, '2025-04-05', '2025-04-05 09:05:00');

-- Table: dws_product_sales
TRUNCATE TABLE `dws_product_sales`;
INSERT INTO `dws_product_sales` (`sale_date`, `sku_id`, `sku_name`, `brand_name`, `category_lv1`, `qty_total`, `gross_amount_total`, `discount_amount_total`, `net_amount_total`, `avg_price`, `updated_at`) VALUES
  ('2025-04-01', 10001, 'Sku 1', 'Brand 1', 'Retail', 1, 10.25, 10, 10.25, 10.25, '2025-04-01 09:01:00'),
  ('2025-04-02', 10002, 'Sku 2', 'Brand 2', 'Wealth', 2, 20.50, 20, 20.50, 20.50, '2025-04-02 09:02:00'),
  ('2025-04-03', 10003, 'Sku 3', 'Brand 3', 'Credit', 3, 30.75, 30, 30.75, 30.75, '2025-04-03 09:03:00'),
  ('2025-04-04', 10004, 'Sku 4', 'Brand 4', 'Risk', 4, 41.00, 40, 41.00, 41.00, '2025-04-04 09:04:00'),
  ('2025-04-05', 10005, 'Sku 5', 'Brand 5', 'Operation', 5, 51.25, 50, 51.25, 51.25, '2025-04-05 09:05:00');

-- Table: erp_sku_price_snapshot
TRUNCATE TABLE `erp_sku_price_snapshot`;
INSERT INTO `erp_sku_price_snapshot` (`sku_id`, `price_date`, `list_price`, `sale_price`, `cost_price`, `promo_flag`, `updated_at`) VALUES
  (10001, '2025-04-01', 10.25, 10.25, 10.25, 1, '2025-04-01 09:01:00'),
  (10002, '2025-04-02', 20.50, 20.50, 20.50, 0, '2025-04-02 09:02:00'),
  (10003, '2025-04-03', 30.75, 30.75, 30.75, 1, '2025-04-03 09:03:00'),
  (10004, '2025-04-04', 41.00, 41.00, 41.00, 0, '2025-04-04 09:04:00'),
  (10005, '2025-04-05', 51.25, 51.25, 51.25, 1, '2025-04-05 09:05:00'),
  (20001, '2026-04-22', 399.00, 329.00, 168.00, 1, '2026-04-22 08:10:00'),
  (20002, '2026-04-23', 599.00, 529.00, 286.00, 1, '2026-04-23 08:10:00'),
  (20003, '2026-04-24', 259.00, 219.00, 112.00, 0, '2026-04-24 08:10:00'),
  (20004, '2026-04-25', 899.00, 799.00, 430.00, 1, '2026-04-25 08:10:00'),
  (20005, '2026-04-26', 199.00, 169.00, 78.00, 0, '2026-04-26 08:10:00');

-- Table: lineage_asset
TRUNCATE TABLE `lineage_asset`;
INSERT INTO `lineage_asset` (`asset_id`, `asset_name`, `asset_type`, `domain_id`, `layer_name`, `source_system`, `owner`, `openmetadata_url`, `description`, `refreshed_at`) VALUES
  ('pim_item_master', 'Product master data', 'table', 'product', 'ODS', 'PIM', 'product_data_team', 'http://10.26.20.3:8585/table/pim_item_master', 'Raw product master table from PIM, including SKU, SPU, brand, category, season, gender, color and size.', '2026-04-28 08:00:00'),
  ('erp_sku_price_snapshot', 'SKU price snapshot', 'table', 'product', 'ODS', 'ERP', 'pricing_data_team', 'http://10.26.20.3:8585/table/erp_sku_price_snapshot', 'Daily SKU price snapshot from ERP, including list price, sale price, cost price and promotion flag.', '2026-04-28 08:10:00'),
  ('pos_sku_sales_detail', 'POS SKU sales detail', 'table', 'order', 'ODS', 'POS', 'retail_ops_team', 'http://10.26.20.3:8585/table/pos_sku_sales_detail', 'Store and online transaction detail table at SKU granularity, including quantity, gross amount, discount and net amount.', '2026-04-28 21:10:00'),
  ('dwd_sku_dim', 'SKU dimension wide table', 'table', 'product', 'DWD', 'Doris ETL', 'data_warehouse_team', 'http://10.26.20.3:8585/table/dwd_sku_dim', 'Cleaned SKU dimension generated from product master and ERP price snapshots.', '2026-04-28 22:00:00'),
  ('dws_product_sales', 'Product sales aggregate', 'table', 'order', 'DWS', 'Doris ETL', 'data_warehouse_team', 'http://10.26.20.3:8585/table/dws_product_sales', 'Daily product sales aggregate built from POS sales detail and SKU dimension.', '2026-04-28 22:10:00'),
  ('ads_product_rank', 'Product sales ranking', 'table', 'product', 'ADS', 'Doris ETL', 'analytics_team', 'http://10.26.20.3:8585/table/ads_product_rank', 'Analytics-facing product ranking table for sales leaderboard and product performance analysis.', '2026-04-28 22:20:00');

-- Table: lineage_domain
TRUNCATE TABLE `lineage_domain`;
INSERT INTO `lineage_domain` (`domain_id`, `domain_name`, `domain_desc`, `owner`, `updated_at`) VALUES
  ('product', 'Product Domain', 'Retail product, SKU, category, price and product performance data domain.', 'product_data_team', '2026-04-28 08:00:00'),
  ('order', 'Order Domain', 'Retail sales transaction and product sales aggregation data domain.', 'retail_ops_team', '2026-04-28 08:00:00'),
  ('inventory', 'Inventory Domain', 'Store and warehouse stock monitoring data domain.', 'supply_chain_team', '2026-04-28 08:00:00'),
  ('member', 'Member Domain', 'Retail member profile and customer behavior data domain.', 'crm_data_team', '2026-04-28 08:00:00'),
  ('store', 'Store Domain', 'Store operation and channel performance data domain.', 'store_ops_team', '2026-04-28 08:00:00');

-- Table: lineage_edge
TRUNCATE TABLE `lineage_edge`;
INSERT INTO `lineage_edge` (`edge_id`, `from_asset_id`, `to_asset_id`, `relation_type`, `weight`, `source_system`, `updated_at`) VALUES
  ('edge_pim_to_dwd_sku', 'pim_item_master', 'dwd_sku_dim', 'transform', 90, 'Doris Audit SQL', '2026-04-28 22:00:00'),
  ('edge_price_to_dwd_sku', 'erp_sku_price_snapshot', 'dwd_sku_dim', 'transform', 85, 'Doris Audit SQL', '2026-04-28 22:00:00'),
  ('edge_pos_to_dws_sales', 'pos_sku_sales_detail', 'dws_product_sales', 'aggregate', 95, 'Doris Audit SQL', '2026-04-28 22:10:00'),
  ('edge_dwd_to_dws_sales', 'dwd_sku_dim', 'dws_product_sales', 'lookup', 80, 'Doris Audit SQL', '2026-04-28 22:10:00'),
  ('edge_dws_to_ads_rank', 'dws_product_sales', 'ads_product_rank', 'publish', 75, 'Doris Audit SQL', '2026-04-28 22:20:00');

-- Table: lineage_impact
TRUNCATE TABLE `lineage_impact`;
INSERT INTO `lineage_impact` (`impact_id`, `asset_id`, `impacted_asset_id`, `impact_level`, `impact_reason`, `updated_at`) VALUES
  ('impact_pim_dwd', 'pim_item_master', 'dwd_sku_dim', 'high', 'Product master changes affect SKU attributes and downstream sales aggregation dimensions.', '2026-04-28 22:00:00'),
  ('impact_price_dwd', 'erp_sku_price_snapshot', 'dwd_sku_dim', 'medium', 'Price snapshot changes affect list price, sale price, cost price and promotion fields.', '2026-04-28 22:00:00'),
  ('impact_pos_dws', 'pos_sku_sales_detail', 'dws_product_sales', 'high', 'Sales detail changes affect quantity, gross amount, discount amount and net amount aggregates.', '2026-04-28 22:10:00'),
  ('impact_dwd_dws', 'dwd_sku_dim', 'dws_product_sales', 'medium', 'SKU dimension changes affect product display fields in DWS sales aggregates.', '2026-04-28 22:10:00'),
  ('impact_dws_ads', 'dws_product_sales', 'ads_product_rank', 'high', 'Sales aggregate changes directly affect product ranking and leaderboard results.', '2026-04-28 22:20:00');

-- Table: lineage_snapshot
TRUNCATE TABLE `lineage_snapshot`;
INSERT INTO `lineage_snapshot` (`snapshot_id`, `domain_id`, `snapshot_name`, `snapshot_time`, `asset_count`, `edge_count`, `source`) VALUES
  ('snapshot_product_20260428', 'product', 'Product lineage snapshot 2026-04-28', '2026-04-28 22:30:00', 4, 4, 'Doris Showcase Mock'),
  ('snapshot_order_20260428', 'order', 'Order lineage snapshot 2026-04-28', '2026-04-28 22:30:00', 2, 2, 'Doris Showcase Mock');

-- Table: lineage_sync_log
TRUNCATE TABLE `lineage_sync_log`;

-- Table: mkt_product_tag_rule
TRUNCATE TABLE `mkt_product_tag_rule`;
INSERT INTO `mkt_product_tag_rule` (`rule_id`, `sku_id`, `tag_name`, `tag_value`, `updated_at`) VALUES
  (10001, 10001, 'Tag 1', 'mkt_product_tag_rule_tag_value_1', '2025-04-01 09:01:00'),
  (10002, 10002, 'Tag 2', 'mkt_product_tag_rule_tag_value_2', '2025-04-02 09:02:00'),
  (10003, 10003, 'Tag 3', 'mkt_product_tag_rule_tag_value_3', '2025-04-03 09:03:00'),
  (10004, 10004, 'Tag 4', 'mkt_product_tag_rule_tag_value_4', '2025-04-04 09:04:00'),
  (10005, 10005, 'Tag 5', 'mkt_product_tag_rule_tag_value_5', '2025-04-05 09:05:00');

-- Table: om_pipeline_asset
TRUNCATE TABLE `om_pipeline_asset`;
INSERT INTO `om_pipeline_asset` (`pipeline_id`, `pipeline_name`, `domain_id`, `owner`, `description`, `openmetadata_url`, `updated_at`) VALUES
  ('om_pipel_001', 'Pipeline 1', 'product', 'om_pipeline_asset_owner_1', 'English mock description for om_pipeline_asset row 1', 'http://example.com/om_pipeline_asset/1', '2025-04-01 09:01:00'),
  ('om_pipel_002', 'Pipeline 2', 'inventory', 'om_pipeline_asset_owner_2', 'English mock description for om_pipeline_asset row 2', 'http://example.com/om_pipeline_asset/2', '2025-04-02 09:02:00'),
  ('om_pipel_003', 'Pipeline 3', 'order', 'om_pipeline_asset_owner_3', 'English mock description for om_pipeline_asset row 3', 'http://example.com/om_pipeline_asset/3', '2025-04-03 09:03:00'),
  ('om_pipel_004', 'Pipeline 4', 'member', 'om_pipeline_asset_owner_4', 'English mock description for om_pipeline_asset row 4', 'http://example.com/om_pipeline_asset/4', '2025-04-04 09:04:00'),
  ('om_pipel_005', 'Pipeline 5', 'store', 'om_pipeline_asset_owner_5', 'English mock description for om_pipeline_asset row 5', 'http://example.com/om_pipeline_asset/5', '2025-04-05 09:05:00');

-- Table: pim_item_master
TRUNCATE TABLE `pim_item_master`;
INSERT INTO `pim_item_master` (`sku_id`, `spu_id`, `sku_name`, `brand_name`, `category_lv1`, `category_lv2`, `season`, `gender`, `color`, `size_code`, `launch_date`, `status`, `updated_at`) VALUES
  (10001, 10001, 'Sku 1', 'Brand 1', 'Retail', 'Retail', 'pim_item_master_season_1', 'pim_item_master_', 'pim_item_master_color_1', 'C0001', '2025-04-01', 'Normal', '2025-04-01 09:01:00'),
  (10002, 10002, 'Sku 2', 'Brand 2', 'Wealth', 'Wealth', 'pim_item_master_season_2', 'pim_item_master_', 'pim_item_master_color_2', 'C0002', '2025-04-02', 'Running', '2025-04-02 09:02:00'),
  (10003, 10003, 'Sku 3', 'Brand 3', 'Credit', 'Credit', 'pim_item_master_season_3', 'pim_item_master_', 'pim_item_master_color_3', 'C0003', '2025-04-03', 'Success', '2025-04-03 09:03:00'),
  (10004, 10004, 'Sku 4', 'Brand 4', 'Risk', 'Risk', 'pim_item_master_season_4', 'pim_item_master_', 'pim_item_master_color_4', 'C0004', '2025-04-04', 'Active', '2025-04-04 09:04:00'),
  (10005, 10005, 'Sku 5', 'Brand 5', 'Operation', 'Operation', 'pim_item_master_season_5', 'pim_item_master_', 'pim_item_master_color_5', 'C0005', '2025-04-05', 'Completed', '2025-04-05 09:05:00'),
  (20001, 20001, 'Linen Relaxed Shirt', 'NorthRiver', 'Apparel', 'Shirts', 'Spring 2026', 'Unisex', 'Ivory', 'M', '2026-03-15', 'Normal', '2026-04-22 08:00:00'),
  (20002, 20002, 'Urban Light Trench Coat', 'Aster & Co', 'Apparel', 'Outerwear', 'Spring 2026', 'Women', 'Khaki', 'S', '2026-03-18', 'Running', '2026-04-23 08:00:00'),
  (20003, 20003, 'Performance Jogger Pants', 'MotionLab', 'Apparel', 'Pants', 'Spring 2026', 'Men', 'Black', 'L', '2026-03-20', 'Active', '2026-04-24 08:00:00'),
  (20004, 20004, 'Premium Wool Blazer', 'Maison Vale', 'Apparel', 'Blazers', 'Spring 2026', 'Women', 'Navy', 'M', '2026-03-28', 'Normal', '2026-04-25 08:00:00'),
  (20005, 20005, 'Everyday Cotton Tee', 'NorthRiver', 'Apparel', 'T-Shirts', 'Spring 2026', 'Unisex', 'White', 'XL', '2026-04-01', 'Running', '2026-04-26 08:00:00');

-- Table: pos_sku_sales_detail
TRUNCATE TABLE `pos_sku_sales_detail`;
INSERT INTO `pos_sku_sales_detail` (`sale_id`, `sale_date`, `store_id`, `sku_id`, `qty`, `gross_amount`, `discount_amount`, `net_amount`, `channel`, `updated_at`) VALUES
  (10001, '2025-04-01', 10001, 10001, 1, 10.25, 10, 10.25, 'Mobile App', '2025-04-01 09:01:00'),
  (10002, '2025-04-02', 10002, 10002, 2, 20.50, 20, 20.50, 'Branch', '2025-04-02 09:02:00'),
  (10003, '2025-04-03', 10003, 10003, 3, 30.75, 30, 30.75, 'Web', '2025-04-03 09:03:00'),
  (10004, '2025-04-04', 10004, 10004, 4, 41.00, 40, 41.00, 'Mini Program', '2025-04-04 09:04:00'),
  (10005, '2025-04-05', 10005, 10005, 5, 51.25, 50, 51.25, 'API', '2025-04-05 09:05:00'),
  (20001, '2026-04-22', 3101, 20001, 12, 4788.00, 840.00, 3948.00, 'Store POS', '2026-04-22 21:10:00'),
  (20002, '2026-04-23', 3102, 20002, 6, 3594.00, 420.00, 3174.00, 'Mini Program', '2026-04-23 21:10:00'),
  (20003, '2026-04-24', 3101, 20003, 18, 4662.00, 720.00, 3942.00, 'Mobile App', '2026-04-24 21:10:00'),
  (20004, '2026-04-25', 3103, 20004, 4, 3596.00, 400.00, 3196.00, 'Store POS', '2026-04-25 21:10:00'),
  (20005, '2026-04-26', 3102, 20005, 30, 5970.00, 900.00, 5070.00, 'Marketplace', '2026-04-26 21:10:00');
