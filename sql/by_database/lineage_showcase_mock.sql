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
  (10005, '2025-04-05', 51.25, 51.25, 51.25, 1, '2025-04-05 09:05:00');

-- Table: lineage_asset
TRUNCATE TABLE `lineage_asset`;
INSERT INTO `lineage_asset` (`asset_id`, `asset_name`, `asset_type`, `domain_id`, `layer_name`, `source_system`, `owner`, `openmetadata_url`, `description`, `refreshed_at`) VALUES
  ('lineage__001', 'Asset 1', 'table', 'product', 'ODS', 'lineage_asset_source_system_1', 'lineage_asset_owner_1', 'http://example.com/lineage_asset/1', 'English mock description for lineage_asset row 1', '2025-04-01 09:01:00'),
  ('lineage__002', 'Asset 2', 'table', 'inventory', 'DWD', 'lineage_asset_source_system_2', 'lineage_asset_owner_2', 'http://example.com/lineage_asset/2', 'English mock description for lineage_asset row 2', '2025-04-02 09:02:00'),
  ('lineage__003', 'Asset 3', 'report', 'order', 'DWS', 'lineage_asset_source_system_3', 'lineage_asset_owner_3', 'http://example.com/lineage_asset/3', 'English mock description for lineage_asset row 3', '2025-04-03 09:03:00'),
  ('lineage__004', 'Asset 4', 'pipeline', 'member', 'ADS', 'lineage_asset_source_system_4', 'lineage_asset_owner_4', 'http://example.com/lineage_asset/4', 'English mock description for lineage_asset row 4', '2025-04-04 09:04:00'),
  ('lineage__005', 'Asset 5', 'table', 'store', 'ETL', 'lineage_asset_source_system_5', 'lineage_asset_owner_5', 'http://example.com/lineage_asset/5', 'English mock description for lineage_asset row 5', '2025-04-05 09:05:00');

-- Table: lineage_domain
TRUNCATE TABLE `lineage_domain`;
INSERT INTO `lineage_domain` (`domain_id`, `domain_name`, `domain_desc`, `owner`, `updated_at`) VALUES
  ('product', 'Domain 1', 'English mock description for lineage_domain row 1', 'lineage_domain_owner_1', '2025-04-01 09:01:00'),
  ('inventory', 'Domain 2', 'English mock description for lineage_domain row 2', 'lineage_domain_owner_2', '2025-04-02 09:02:00'),
  ('order', 'Domain 3', 'English mock description for lineage_domain row 3', 'lineage_domain_owner_3', '2025-04-03 09:03:00'),
  ('member', 'Domain 4', 'English mock description for lineage_domain row 4', 'lineage_domain_owner_4', '2025-04-04 09:04:00'),
  ('store', 'Domain 5', 'English mock description for lineage_domain row 5', 'lineage_domain_owner_5', '2025-04-05 09:05:00');

-- Table: lineage_edge
TRUNCATE TABLE `lineage_edge`;
INSERT INTO `lineage_edge` (`edge_id`, `from_asset_id`, `to_asset_id`, `relation_type`, `weight`, `source_system`, `updated_at`) VALUES
  ('lineage__001', 'lineage__001', 'lineage__001', 'read', 1, 'lineage_edge_source_system_1', '2025-04-01 09:01:00'),
  ('lineage__002', 'lineage__002', 'lineage__002', 'transform', 2, 'lineage_edge_source_system_2', '2025-04-02 09:02:00'),
  ('lineage__003', 'lineage__003', 'lineage__003', 'publish', 3, 'lineage_edge_source_system_3', '2025-04-03 09:03:00'),
  ('lineage__004', 'lineage__004', 'lineage__004', 'derive', 4, 'lineage_edge_source_system_4', '2025-04-04 09:04:00'),
  ('lineage__005', 'lineage__005', 'lineage__005', 'read', 5, 'lineage_edge_source_system_5', '2025-04-05 09:05:00');

-- Table: lineage_impact
TRUNCATE TABLE `lineage_impact`;
INSERT INTO `lineage_impact` (`impact_id`, `asset_id`, `impacted_asset_id`, `impact_level`, `impact_reason`, `updated_at`) VALUES
  ('lineage__001', 'lineage__001', 'lineage__001', 'lineage_impact_impact_level_1', 'lineage_impact_impact_reason_1', '2025-04-01 09:01:00'),
  ('lineage__002', 'lineage__002', 'lineage__002', 'lineage_impact_impact_level_2', 'lineage_impact_impact_reason_2', '2025-04-02 09:02:00'),
  ('lineage__003', 'lineage__003', 'lineage__003', 'lineage_impact_impact_level_3', 'lineage_impact_impact_reason_3', '2025-04-03 09:03:00'),
  ('lineage__004', 'lineage__004', 'lineage__004', 'lineage_impact_impact_level_4', 'lineage_impact_impact_reason_4', '2025-04-04 09:04:00'),
  ('lineage__005', 'lineage__005', 'lineage__005', 'lineage_impact_impact_level_5', 'lineage_impact_impact_reason_5', '2025-04-05 09:05:00');

-- Table: lineage_snapshot
TRUNCATE TABLE `lineage_snapshot`;
INSERT INTO `lineage_snapshot` (`snapshot_id`, `domain_id`, `snapshot_name`, `snapshot_time`, `asset_count`, `edge_count`, `source`) VALUES
  ('lineage__001', 'product', 'Snapshot 1', '2025-04-01 09:01:00', 10, 10, 'lineage_snapshot_source_1'),
  ('lineage__002', 'inventory', 'Snapshot 2', '2025-04-02 09:02:00', 20, 20, 'lineage_snapshot_source_2'),
  ('lineage__003', 'order', 'Snapshot 3', '2025-04-03 09:03:00', 30, 30, 'lineage_snapshot_source_3'),
  ('lineage__004', 'member', 'Snapshot 4', '2025-04-04 09:04:00', 40, 40, 'lineage_snapshot_source_4'),
  ('lineage__005', 'store', 'Snapshot 5', '2025-04-05 09:05:00', 50, 50, 'lineage_snapshot_source_5');

-- Table: lineage_sync_log
TRUNCATE TABLE `lineage_sync_log`;
INSERT INTO `lineage_sync_log` (`log_id`, `sync_time`, `start_date`, `end_date`, `scan_limit`, `scanned`, `synced`, `skipped`, `failed`, `success`, `errors`, `details`, `created_at`) VALUES
  ('lineage__001', '2025-04-01 09:01:00', '2025-04-01', '2025-04-01', 1, 1, 1, 1, 1, 1, 'lineage_sync_log_errors_1', 'lineage_sync_log_details_1', '2025-04-01 09:01:00'),
  ('lineage__002', '2025-04-02 09:02:00', '2025-04-02', '2025-04-02', 2, 2, 2, 2, 2, 2, 'lineage_sync_log_errors_2', 'lineage_sync_log_details_2', '2025-04-02 09:02:00'),
  ('lineage__003', '2025-04-03 09:03:00', '2025-04-03', '2025-04-03', 3, 3, 3, 3, 3, 3, 'lineage_sync_log_errors_3', 'lineage_sync_log_details_3', '2025-04-03 09:03:00'),
  ('lineage__004', '2025-04-04 09:04:00', '2025-04-04', '2025-04-04', 4, 4, 4, 4, 4, 4, 'lineage_sync_log_errors_4', 'lineage_sync_log_details_4', '2025-04-04 09:04:00'),
  ('lineage__005', '2025-04-05 09:05:00', '2025-04-05', '2025-04-05', 5, 5, 5, 5, 5, 5, 'lineage_sync_log_errors_5', 'lineage_sync_log_details_5', '2025-04-05 09:05:00');

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
  (10005, 10005, 'Sku 5', 'Brand 5', 'Operation', 'Operation', 'pim_item_master_season_5', 'pim_item_master_', 'pim_item_master_color_5', 'C0005', '2025-04-05', 'Completed', '2025-04-05 09:05:00');

-- Table: pos_sku_sales_detail
TRUNCATE TABLE `pos_sku_sales_detail`;
INSERT INTO `pos_sku_sales_detail` (`sale_id`, `sale_date`, `store_id`, `sku_id`, `qty`, `gross_amount`, `discount_amount`, `net_amount`, `channel`, `updated_at`) VALUES
  (10001, '2025-04-01', 10001, 10001, 1, 10.25, 10, 10.25, 'Mobile App', '2025-04-01 09:01:00'),
  (10002, '2025-04-02', 10002, 10002, 2, 20.50, 20, 20.50, 'Branch', '2025-04-02 09:02:00'),
  (10003, '2025-04-03', 10003, 10003, 3, 30.75, 30, 30.75, 'Web', '2025-04-03 09:03:00'),
  (10004, '2025-04-04', 10004, 10004, 4, 41.00, 40, 41.00, 'Mini Program', '2025-04-04 09:04:00'),
  (10005, '2025-04-05', 10005, 10005, 5, 51.25, 50, 51.25, 'API', '2025-04-05 09:05:00');
