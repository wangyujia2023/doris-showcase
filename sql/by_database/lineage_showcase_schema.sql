-- ================================================================
-- Database: lineage_showcase
-- Type: schema
-- Source: generated from current Doris SHOW CREATE TABLE output.
-- ================================================================

CREATE DATABASE IF NOT EXISTS lineage_showcase;
USE lineage_showcase;

-- Table: ads_product_rank
CREATE TABLE IF NOT EXISTS `ads_product_rank` (
  `stat_date` date NOT NULL,
  `sku_id` bigint NOT NULL,
  `sku_name` varchar(128) NOT NULL,
  `brand_name` varchar(64) NULL DEFAULT "",
  `net_amount_total` decimal(12,2) NULL DEFAULT "0",
  `qty_total` int NULL DEFAULT "0",
  `rank_no` int NULL DEFAULT "0",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`stat_date`, `sku_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: dwd_sku_dim
CREATE TABLE IF NOT EXISTS `dwd_sku_dim` (
  `sku_id` bigint NOT NULL,
  `spu_id` bigint NOT NULL,
  `sku_name` varchar(128) NOT NULL,
  `brand_name` varchar(64) NULL DEFAULT "",
  `category_lv1` varchar(64) NULL DEFAULT "",
  `category_lv2` varchar(64) NULL DEFAULT "",
  `season` varchar(32) NULL DEFAULT "",
  `gender` varchar(16) NULL DEFAULT "",
  `color` varchar(32) NULL DEFAULT "",
  `size_code` varchar(32) NULL DEFAULT "",
  `launch_date` date NULL,
  `status` varchar(16) NULL DEFAULT "ACTIVE",
  `list_price` decimal(10,2) NULL DEFAULT "0",
  `sale_price` decimal(10,2) NULL DEFAULT "0",
  `cost_price` decimal(10,2) NULL DEFAULT "0",
  `promo_flag` tinyint NULL DEFAULT "0",
  `price_date` date NULL,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`sku_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: dws_product_sales
CREATE TABLE IF NOT EXISTS `dws_product_sales` (
  `sale_date` date NOT NULL,
  `sku_id` bigint NOT NULL,
  `sku_name` varchar(128) NOT NULL,
  `brand_name` varchar(64) NULL DEFAULT "",
  `category_lv1` varchar(64) NULL DEFAULT "",
  `qty_total` int NULL DEFAULT "0",
  `gross_amount_total` decimal(12,2) NULL DEFAULT "0",
  `discount_amount_total` decimal(12,2) NULL DEFAULT "0",
  `net_amount_total` decimal(12,2) NULL DEFAULT "0",
  `avg_price` decimal(12,2) NULL DEFAULT "0",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`sale_date`, `sku_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: erp_sku_price_snapshot
CREATE TABLE IF NOT EXISTS `erp_sku_price_snapshot` (
  `sku_id` bigint NOT NULL,
  `price_date` date NOT NULL,
  `list_price` decimal(10,2) NULL DEFAULT "0",
  `sale_price` decimal(10,2) NULL DEFAULT "0",
  `cost_price` decimal(10,2) NULL DEFAULT "0",
  `promo_flag` tinyint NULL DEFAULT "0",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`sku_id`, `price_date`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: lineage_asset
CREATE TABLE IF NOT EXISTS `lineage_asset` (
  `asset_id` varchar(64) NOT NULL,
  `asset_name` varchar(256) NOT NULL,
  `asset_type` varchar(32) NOT NULL,
  `domain_id` varchar(64) NOT NULL,
  `layer_name` varchar(32) NULL DEFAULT "",
  `source_system` varchar(128) NULL DEFAULT "",
  `owner` varchar(128) NULL DEFAULT "",
  `openmetadata_url` varchar(512) NULL DEFAULT "",
  `description` varchar(1024) NULL DEFAULT "",
  `refreshed_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`asset_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: lineage_domain
CREATE TABLE IF NOT EXISTS `lineage_domain` (
  `domain_id` varchar(64) NOT NULL,
  `domain_name` varchar(128) NOT NULL,
  `domain_desc` varchar(512) NULL DEFAULT "",
  `owner` varchar(128) NULL DEFAULT "",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`domain_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: lineage_edge
CREATE TABLE IF NOT EXISTS `lineage_edge` (
  `edge_id` varchar(64) NOT NULL,
  `from_asset_id` varchar(64) NOT NULL,
  `to_asset_id` varchar(64) NOT NULL,
  `relation_type` varchar(32) NOT NULL,
  `weight` int NULL DEFAULT "1",
  `source_system` varchar(128) NULL DEFAULT "",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`edge_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: lineage_impact
CREATE TABLE IF NOT EXISTS `lineage_impact` (
  `impact_id` varchar(64) NOT NULL,
  `asset_id` varchar(64) NOT NULL,
  `impacted_asset_id` varchar(64) NOT NULL,
  `impact_level` varchar(32) NOT NULL,
  `impact_reason` varchar(512) NULL DEFAULT "",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`impact_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: lineage_snapshot
CREATE TABLE IF NOT EXISTS `lineage_snapshot` (
  `snapshot_id` varchar(64) NOT NULL,
  `domain_id` varchar(64) NOT NULL,
  `snapshot_name` varchar(128) NOT NULL,
  `snapshot_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `asset_count` int NULL DEFAULT "0",
  `edge_count` int NULL DEFAULT "0",
  `source` varchar(64) NULL DEFAULT "openmetadata"
) ENGINE=OLAP
DUPLICATE KEY(`snapshot_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: lineage_sync_log
CREATE TABLE IF NOT EXISTS `lineage_sync_log` (
  `log_id` varchar(64) NOT NULL,
  `sync_time` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  `start_date` varchar(32) NULL DEFAULT "",
  `end_date` varchar(32) NULL DEFAULT "",
  `scan_limit` int NULL DEFAULT "0",
  `scanned` int NULL DEFAULT "0",
  `synced` int NULL DEFAULT "0",
  `skipped` int NULL DEFAULT "0",
  `failed` int NULL DEFAULT "0",
  `success` tinyint NULL DEFAULT "0",
  `errors` text NULL,
  `details` text NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`log_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: mkt_product_tag_rule
CREATE TABLE IF NOT EXISTS `mkt_product_tag_rule` (
  `rule_id` bigint NOT NULL,
  `sku_id` bigint NOT NULL,
  `tag_name` varchar(64) NOT NULL,
  `tag_value` varchar(64) NOT NULL,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`rule_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: om_pipeline_asset
CREATE TABLE IF NOT EXISTS `om_pipeline_asset` (
  `pipeline_id` varchar(64) NOT NULL,
  `pipeline_name` varchar(128) NOT NULL,
  `domain_id` varchar(64) NOT NULL,
  `owner` varchar(128) NULL DEFAULT "",
  `description` varchar(512) NULL DEFAULT "",
  `openmetadata_url` varchar(512) NULL DEFAULT "",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`pipeline_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: pim_item_master
CREATE TABLE IF NOT EXISTS `pim_item_master` (
  `sku_id` bigint NOT NULL,
  `spu_id` bigint NOT NULL,
  `sku_name` varchar(128) NOT NULL,
  `brand_name` varchar(64) NULL DEFAULT "",
  `category_lv1` varchar(64) NULL DEFAULT "",
  `category_lv2` varchar(64) NULL DEFAULT "",
  `season` varchar(32) NULL DEFAULT "",
  `gender` varchar(16) NULL DEFAULT "",
  `color` varchar(32) NULL DEFAULT "",
  `size_code` varchar(32) NULL DEFAULT "",
  `launch_date` date NULL,
  `status` varchar(16) NULL DEFAULT "ACTIVE",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`sku_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);

-- Table: pos_sku_sales_detail
CREATE TABLE IF NOT EXISTS `pos_sku_sales_detail` (
  `sale_id` bigint NOT NULL,
  `sale_date` date NOT NULL,
  `store_id` bigint NOT NULL,
  `sku_id` bigint NOT NULL,
  `qty` int NULL DEFAULT "0",
  `gross_amount` decimal(12,2) NULL DEFAULT "0",
  `discount_amount` decimal(12,2) NULL DEFAULT "0",
  `net_amount` decimal(12,2) NULL DEFAULT "0",
  `channel` varchar(32) NULL DEFAULT "POS",
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`sale_id`)
DISTRIBUTED BY RANDOM BUCKETS AUTO
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728"
);
