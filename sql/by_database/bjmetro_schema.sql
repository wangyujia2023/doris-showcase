-- ================================================================
-- Database: bjmetro
-- Type: schema
-- Source: generated from current Doris SHOW CREATE TABLE output.
-- ================================================================

CREATE DATABASE IF NOT EXISTS bjmetro;
USE bjmetro;

-- Table: bj_metro_daily_flow
CREATE TABLE IF NOT EXISTS `bj_metro_daily_flow` (
  `flow_date` date NOT NULL,
  `station_id` varchar(20) NOT NULL,
  `line_id` varchar(10) NOT NULL,
  `inbound_count` bigint NULL,
  `outbound_count` bigint NULL,
  `peak_inbound` bigint NULL
) ENGINE=OLAP
UNIQUE KEY(`flow_date`, `station_id`, `line_id`)
DISTRIBUTED BY HASH(`station_id`) BUCKETS 5
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);

-- Table: bj_metro_fault_log
CREATE TABLE IF NOT EXISTS `bj_metro_fault_log` (
  `fault_id` varchar(30) NOT NULL,
  `fault_time` datetime NOT NULL,
  `line_id` varchar(10) NULL,
  `station_id` varchar(20) NULL,
  `device_type` varchar(30) NULL,
  `fault_type` varchar(50) NULL,
  `severity` varchar(20) NULL,
  `description` varchar(200) NULL,
  `resolve_time` datetime NULL,
  `resolve_min` int NULL,
  `status` varchar(20) NULL,
  `handler` varchar(30) NULL,
  INDEX idx_fault_type (`fault_type`) USING INVERTED,
  INDEX idx_severity (`severity`) USING INVERTED,
  INDEX idx_device_type (`device_type`) USING INVERTED
) ENGINE=OLAP
DUPLICATE KEY(`fault_id`, `fault_time`)
DISTRIBUTED BY HASH(`fault_id`) BUCKETS 5
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

-- Table: bj_metro_hourly_flow
CREATE TABLE IF NOT EXISTS `bj_metro_hourly_flow` (
  `flow_date` date NOT NULL,
  `flow_hour` tinyint NOT NULL,
  `line_id` varchar(10) NOT NULL,
  `total_passengers` bigint NULL,
  `overcapacity_cnt` int NULL
) ENGINE=OLAP
UNIQUE KEY(`flow_date`, `flow_hour`, `line_id`)
DISTRIBUTED BY HASH(`line_id`) BUCKETS 5
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);

-- Table: bj_metro_lines
CREATE TABLE IF NOT EXISTS `bj_metro_lines` (
  `line_id` varchar(10) NOT NULL,
  `line_name` varchar(50) NOT NULL,
  `line_color` varchar(10) NULL,
  `total_stations` int NULL,
  `total_length_km` decimal(8,2) NULL,
  `open_year` int NULL,
  `daily_capacity_w` int NULL COMMENT "日运能（万人次）",
  `peak_interval_s` int NULL COMMENT "高峰行车间隔（秒）",
  `offpeak_interval_s` int NULL COMMENT "平峰行车间隔（秒）",
  `status` varchar(20) NULL
) ENGINE=OLAP
UNIQUE KEY(`line_id`)
DISTRIBUTED BY HASH(`line_id`) BUCKETS 3
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);

-- Table: bj_metro_od_flow
CREATE TABLE IF NOT EXISTS `bj_metro_od_flow` (
  `flow_date` date NOT NULL,
  `origin_id` varchar(20) NOT NULL,
  `dest_id` varchar(20) NOT NULL,
  `peak_type` varchar(10) NOT NULL COMMENT "morning/evening/off",
  `flow_count` bigint NULL
) ENGINE=OLAP
UNIQUE KEY(`flow_date`, `origin_id`, `dest_id`, `peak_type`)
DISTRIBUTED BY HASH(`origin_id`) BUCKETS 5
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);

-- Table: bj_metro_revenue
CREATE TABLE IF NOT EXISTS `bj_metro_revenue` (
  `revenue_date` date NOT NULL,
  `line_id` varchar(10) NOT NULL,
  `ticket_revenue` bigint NULL,
  `subsidy_amount` bigint NULL,
  `ticket_count` bigint NULL,
  `ad_revenue` bigint NULL,
  `commercial_revenue` bigint NULL
) ENGINE=OLAP
UNIQUE KEY(`revenue_date`, `line_id`)
DISTRIBUTED BY HASH(`line_id`) BUCKETS 3
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);

-- Table: bj_metro_stations
CREATE TABLE IF NOT EXISTS `bj_metro_stations` (
  `station_id` varchar(20) NOT NULL,
  `station_name` varchar(50) NOT NULL,
  `line_id` varchar(10) NOT NULL,
  `sequence_no` int NULL,
  `district` varchar(20) NULL,
  `daily_capacity` int NULL,
  `is_interchange` tinyint NULL DEFAULT "0",
  `interchange_lines` varchar(100) NULL,
  `is_terminal` tinyint NULL DEFAULT "0"
) ENGINE=OLAP
UNIQUE KEY(`station_id`, `station_name`)
DISTRIBUTED BY HASH(`station_id`) BUCKETS 5
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);

-- Table: bj_metro_train_ops
CREATE TABLE IF NOT EXISTS `bj_metro_train_ops` (
  `ops_date` date NOT NULL,
  `line_id` varchar(10) NOT NULL,
  `planned_trains` int NULL,
  `actual_trains` int NULL,
  `punctuality_rate` decimal(6,4) NULL,
  `delay_count` int NULL,
  `max_delay_sec` int NULL,
  `total_mileage_km` decimal(10,2) NULL,
  `fault_count` int NULL
) ENGINE=OLAP
UNIQUE KEY(`ops_date`, `line_id`)
DISTRIBUTED BY HASH(`line_id`) BUCKETS 3
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);
