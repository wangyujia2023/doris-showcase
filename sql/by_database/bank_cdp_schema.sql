-- ================================================================
-- Database: bank_cdp
-- Type: schema
-- Source: generated from current Doris SHOW CREATE TABLE output.
-- ================================================================

CREATE DATABASE IF NOT EXISTS bank_cdp;
USE bank_cdp;

-- Table: aum_metrics
CREATE TABLE IF NOT EXISTS `aum_metrics` (
  `metric_date` date NOT NULL COMMENT "日期",
  `product_type` varchar(32) NULL COMMENT "产品类型(股票/债券/货基/混合)",
  `aum_amount` decimal(18,2) NULL COMMENT "AUM金额",
  `client_count` int NULL COMMENT "客户数",
  `avg_holding` decimal(18,2) NULL COMMENT "平均持仓",
  `inflow` decimal(18,2) NULL COMMENT "净流入",
  `yoy_growth` decimal(5,2) NULL COMMENT "同比增长%",
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`metric_date`, `product_type`)
COMMENT 'AUM资产规模表'
DISTRIBUTED BY HASH(`metric_date`) BUCKETS 16
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

-- Table: avatar_label
CREATE TABLE IF NOT EXISTS `avatar_label` (
  `label_id` bigint NOT NULL COMMENT "标签ID",
  `label_name` varchar(64) NULL COMMENT "标签名",
  `category` varchar(32) NULL COMMENT "标签分类",
  `color` varchar(16) NULL COMMENT "展示颜色",
  `label_desc` varchar(256) NULL COMMENT "标签描述",
  `label_embedding` array<float> NULL COMMENT "标签特征向量(8维)",
  `user_count` int NULL COMMENT "关联用户数",
  `create_time` datetime NULL COMMENT "创建时间"
) ENGINE=OLAP
DUPLICATE KEY(`label_id`)
DISTRIBUTED BY HASH(`label_id`) BUCKETS 4
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

-- Table: bank_system_log
CREATE TABLE IF NOT EXISTS `bank_system_log` (
  `log_id` bigint NOT NULL COMMENT "日志ID",
  `log_date` date NOT NULL COMMENT "日志日期（分区键）",
  `log_time` datetime NOT NULL COMMENT "精确时间",
  `user_id` varchar(32) NULL COMMENT "用户ID",
  `user_name` varchar(64) NULL COMMENT "用户名（脱敏）",
  `session_id` varchar(64) NULL COMMENT "会话ID",
  `log_source` varchar(32) NULL COMMENT "来源系统：APP/WEB/ATM/BRANCH",
  `log_level` varchar(8) NULL COMMENT "日志级别：INFO/WARN/ERROR",
  `operation` varchar(64) NULL COMMENT "操作类型：LOGIN/REGISTER/TRANSFER/PAYMENT",
  `ip_address` varchar(64) NULL COMMENT "客户端IP",
  `device_info` varchar(128) NULL COMMENT "设备信息",
  `amount` decimal(20,4) NULL COMMENT "涉及金额（元），无金额为NULL",
  `result_code` varchar(8) NULL COMMENT "结果码：0000=成功，非0=失败",
  `error_msg` varchar(256) NULL COMMENT "错误信息（成功时为NULL）",
  `risk_score` decimal(5,2) NULL COMMENT "风控评分 0-100，>70触发预警",
  `log_content` text NULL COMMENT "完整日志内容（供AI分析）",
  `created_at` datetime NULL COMMENT "入库时间"
) ENGINE=OLAP
DUPLICATE KEY(`log_id`, `log_date`)
COMMENT '银行系统原始日志表（AI_CLASSIFY 数据源）'
PARTITION BY RANGE(`log_date`)
(PARTITION p2025_03 VALUES [('0000-01-01'), ('2025-04-01')),
PARTITION p2025_04 VALUES [('2025-04-01'), ('2025-05-01')),
PARTITION p2025_05 VALUES [('2025-05-01'), ('2025-06-01')),
PARTITION p_future VALUES [('2025-06-01'), (MAXVALUE)))
DISTRIBUTED BY HASH(`log_id`) BUCKETS 16
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

-- Table: bank_system_log_ai_result
CREATE TABLE IF NOT EXISTS `bank_system_log_ai_result` (
  `log_id` bigint NULL,
  `log_content` varchar(4096) NULL,
  `ai_tag` varchar(128) NULL
) ENGINE=OLAP
DUPLICATE KEY(`log_id`)
DISTRIBUTED BY HASH(`log_id`) BUCKETS 1
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

-- Table: bank_system_log_bak
CREATE TABLE IF NOT EXISTS `bank_system_log_bak` (
  `log_id` bigint NOT NULL,
  `log_time` datetime NOT NULL,
  `log_level` varchar(16) NOT NULL,
  `system_module` varchar(64) NOT NULL,
  `log_content` varchar(4096) NOT NULL,
  `ip_addr` varchar(64) NULL,
  `device_info` varchar(256) NULL,
  `ai_tag` varchar(128) NULL
) ENGINE=OLAP
DUPLICATE KEY(`log_id`, `log_time`)
DISTRIBUTED BY HASH(`log_id`) BUCKETS 1
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

-- Table: bank_system_log_tagged
CREATE TABLE IF NOT EXISTS `bank_system_log_tagged` (
  `log_id` bigint NOT NULL COMMENT "关联原始日志ID",
  `log_date` date NOT NULL COMMENT "日志日期（分区键）",
  `log_time` datetime NULL COMMENT "日志时间",
  `user_id` varchar(32) NULL COMMENT "用户ID",
  `user_name` varchar(64) NULL COMMENT "用户名（脱敏）",
  `log_source` varchar(32) NULL COMMENT "来源系统",
  `operation` varchar(64) NULL COMMENT "原始操作类型",
  `amount` decimal(20,4) NULL COMMENT "涉及金额",
  `risk_score` decimal(5,2) NULL COMMENT "风控评分",
  `log_content` text NULL COMMENT "原始日志内容",
  `ai_tag` varchar(32) NULL COMMENT "AI分类标签：登录成功/登录异常/注册成功/注册失败/交易成功/交易失败/支付成功/支付失败/风险预警",
  `ai_tag_group` varchar(16) NULL COMMENT "AI标签大类：登录/注册/交易/支付/风险",
  `is_exception` tinyint NULL COMMENT "是否异常：1是 0否（从ai_tag派生）",
  `is_risk` tinyint NULL COMMENT "是否风险：1是 0否",
  `classify_time` datetime NULL COMMENT "AI分类执行时间",
  `classify_method` varchar(16) NULL COMMENT "分类方式：AI_CLASSIFY/FALLBACK"
) ENGINE=OLAP
UNIQUE KEY(`log_id`, `log_date`)
COMMENT '银行日志AI分类结果表（AI_CLASSIFY输出）'
PARTITION BY RANGE(`log_date`)
(PARTITION p2025_03 VALUES [('0000-01-01'), ('2025-04-01')),
PARTITION p2025_04 VALUES [('2025-04-01'), ('2025-05-01')),
PARTITION p2025_05 VALUES [('2025-05-01'), ('2025-06-01')),
PARTITION p_future VALUES [('2025-06-01'), (MAXVALUE)))
DISTRIBUTED BY HASH(`log_id`) BUCKETS 16
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"store_row_column" = "true",
"row_store_page_size" = "16384",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);

-- Table: bank_system_log_with_ai
CREATE TABLE IF NOT EXISTS `bank_system_log_with_ai` (
  `log_id` bigint NULL,
  `log_time` datetime NULL,
  `log_level` varchar(16) NULL,
  `system_module` varchar(64) NULL,
  `log_content` varchar(4096) NULL,
  `ai_tag` varchar(128) NULL
) ENGINE=OLAP
DUPLICATE KEY(`log_id`, `log_time`)
DISTRIBUTED BY HASH(`log_id`) BUCKETS 1
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

-- Table: biz_metrics
CREATE TABLE IF NOT EXISTS `biz_metrics` (
  `metric_date` date NOT NULL COMMENT "日期",
  `metric_type` varchar(32) NULL COMMENT "指标类型(收入/成本/利润)",
  `amount` decimal(18,2) NULL COMMENT "金额",
  `yoy_growth` decimal(5,2) NULL COMMENT "同比增长%",
  `mom_growth` decimal(5,2) NULL COMMENT "环比增长%",
  `target_amount` decimal(18,2) NULL COMMENT "目标金额",
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`metric_date`, `metric_type`)
COMMENT '经营指标表'
DISTRIBUTED BY HASH(`metric_date`) BUCKETS 16
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

-- Table: db_call_log
CREATE TABLE IF NOT EXISTS `db_call_log` (
  `trace_id` varchar(64) NOT NULL,
  `span_id` varchar(64) NOT NULL,
  `call_time` datetime NOT NULL,
  `operation` varchar(16) NOT NULL,
  `table_name` varchar(64) NULL,
  `sql_text` varchar(1024) NULL,
  `duration_ms` int NOT NULL,
  `rows_returned` int NULL DEFAULT "0",
  `offset_ms` int NULL DEFAULT "0",
  `error_message` varchar(512) NULL,
  INDEX idx_trace (`trace_id`) USING INVERTED,
  INDEX idx_call_time (`call_time`) USING INVERTED
) ENGINE=OLAP
DUPLICATE KEY(`trace_id`, `span_id`)
DISTRIBUTED BY HASH(`trace_id`) BUCKETS 4
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

-- Table: fund_basic
CREATE TABLE IF NOT EXISTS `fund_basic` (
  `fund_id` varchar(10) NOT NULL,
  `fund_name` varchar(50) NULL,
  `fund_type` varchar(20) NULL,
  `sector_tag` varchar(20) NULL,
  `manager_id` varchar(10) NULL,
  `risk_level` int NULL,
  `fee_rate` float NULL,
  `inception_date` date NULL,
  `nav_yesterday` double NULL COMMENT "昨日单位净值",
  `cumulative_nav` double NULL COMMENT "累计净值",
  `realtime_iopv` double NULL COMMENT "盘中实时估值",
  `iopv_deviation` double NULL COMMENT "IOPV偏离度%",
  `capital_inflow` double NULL COMMENT "今日资金流入(万)",
  `capital_outflow` double NULL COMMENT "今日资金流出(万)",
  `capital_net` double NULL COMMENT "净流入(万)",
  `trade_status` varchar(10) NULL,
  `ret_1m` float NULL,
  `ret_3m` float NULL,
  `ret_6m` float NULL,
  `ret_1y` float NULL,
  `ret_inception` float NULL,
  `sharpe` float NULL,
  `sortino` float NULL,
  `alpha` float NULL,
  `beta` float NULL,
  `max_drawdown` float NULL,
  `volatility` float NULL,
  `update_ts` datetime NULL
) ENGINE=OLAP
DUPLICATE KEY(`fund_id`)
DISTRIBUTED BY HASH(`fund_id`) BUCKETS 4
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

-- Table: fund_manager
CREATE TABLE IF NOT EXISTS `fund_manager` (
  `manager_id` varchar(10) NOT NULL,
  `name` varchar(20) NULL,
  `tenure_years` float NULL,
  `aum_bn` float NULL COMMENT "在管规模(亿)",
  `style_tag` varchar(20) NULL,
  `turnover_rate` float NULL COMMENT "年均换手率",
  `avg_alpha` float NULL,
  `total_return` float NULL,
  `max_drawdown` float NULL,
  `sharpe` float NULL
) ENGINE=OLAP
DUPLICATE KEY(`manager_id`)
DISTRIBUTED BY HASH(`manager_id`) BUCKETS 2
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

-- Table: fund_nav_history
CREATE TABLE IF NOT EXISTS `fund_nav_history` (
  `trade_date` date NOT NULL,
  `fund_id` varchar(10) NOT NULL,
  `nav` double NULL,
  `cumulative_nav` double NULL,
  `daily_return` float NULL,
  `benchmark_ret` float NULL,
  `excess_ret` float NULL,
  `drawdown` float NULL,
  `rolling_sharpe` float NULL,
  `rolling_alpha` float NULL,
  `script_name` varchar(20) NULL,
  `script_color` varchar(10) NULL
) ENGINE=OLAP
DUPLICATE KEY(`trade_date`, `fund_id`)
DISTRIBUTED BY HASH(`fund_id`) BUCKETS 4
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

-- Table: fund_position
CREATE TABLE IF NOT EXISTS `fund_position` (
  `fund_id` varchar(10) NOT NULL,
  `report_date` date NOT NULL,
  `stock_code` varchar(10) NULL,
  `stock_name` varchar(20) NULL,
  `sector_l1` varchar(20) NULL,
  `weight_pct` float NULL,
  `market_value_mn` float NULL COMMENT "市值(百万)",
  `price_contrib` float NULL COMMENT "价格贡献度%",
  `alpha_contrib` float NULL
) ENGINE=OLAP
DUPLICATE KEY(`fund_id`, `report_date`)
DISTRIBUTED BY HASH(`fund_id`) BUCKETS 4
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

-- Table: ground_station
CREATE TABLE IF NOT EXISTS `ground_station` (
  `station_id` int NOT NULL,
  `station_name` varchar(50) NULL,
  `location` varchar(50) NULL,
  `latitude` float NULL,
  `longitude` float NULL,
  `station_type` varchar(20) NULL,
  `status` varchar(10) NULL,
  `antenna_count` int NULL,
  `coverage_radius_km` int NULL,
  `daily_contacts` int NULL,
  `uptime_pct` float NULL
) ENGINE=OLAP
DUPLICATE KEY(`station_id`)
DISTRIBUTED BY HASH(`station_id`) BUCKETS 1
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

-- Table: mdm_jfmat
CREATE TABLE IF NOT EXISTS `mdm_jfmat` (
  `code` varchar(128) NOT NULL COMMENT "物料唯一编码（主键）",
  `active` boolean NULL DEFAULT "true" COMMENT "是否有效：true-有效，false-失效",
  `property_full` text NOT NULL COMMENT "物料完整属性（KV格式，核心检索字段）",
  `material_name` varchar(512) NULL COMMENT "物料名称（冗余字段，便于检索）",
  `thread_spec` varchar(32) NULL COMMENT "螺纹规格（M24/M18/M14等）",
  `performance_grade` varchar(32) NULL COMMENT "性能等级（8/8.8/A2-70等）",
  `standard_code` varchar(64) NULL COMMENT "标准代号（ISO 4032/GB/T 6170等）",
  INDEX idx_property (`property_full`) USING INVERTED PROPERTIES("lower_case" = "true", "parser" = "ik", "support_phrase" = "true") COMMENT "物料属性中文分词索引",
  INDEX idx_thread (`thread_spec`) USING INVERTED COMMENT "螺纹规格精准索引",
  INDEX idx_grade (`performance_grade`) USING INVERTED COMMENT "性能等级精准索引"
) ENGINE=OLAP
DUPLICATE KEY(`code`)
DISTRIBUTED BY HASH(`code`) BUCKETS 3
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

-- Table: mfg_metrics_v2
CREATE TABLE IF NOT EXISTS `mfg_metrics_v2` (
  `ts` datetime NULL COMMENT "采集时间",
  `machine_id` varchar(20) NULL COMMENT "设备编号",
  `line_id` varchar(10) NULL COMMENT "产线",
  `machine_type` varchar(20) NULL COMMENT "设备类型",
  `script_name` varchar(20) NULL COMMENT "剧本状态",
  `script_color` varchar(10) NULL COMMENT "状态色",
  `temperature` float NULL COMMENT "主轴温度°C",
  `bearing_temp` float NULL COMMENT "轴承温度°C",
  `coolant_temp` float NULL COMMENT "冷却液温度°C",
  `vibration` float NULL COMMENT "震动mm/s",
  `noise_level` float NULL COMMENT "噪音dB",
  `spindle_speed` int NULL COMMENT "主轴转速rpm",
  `feed_rate` float NULL COMMENT "进给速率mm/min",
  `cutting_force` float NULL COMMENT "切削力N",
  `torque` float NULL COMMENT "扭矩N·m",
  `motor_current` float NULL COMMENT "电机电流A",
  `power_kw` float NULL COMMENT "实时功耗kW",
  `hydraulic_bar` float NULL COMMENT "液压bar",
  `air_pressure` float NULL COMMENT "气压MPa",
  `coolant_flow` float NULL COMMENT "冷却液流量L/min",
  `tool_wear_pct` float NULL COMMENT "刀具磨损%",
  `oee` float NULL COMMENT "综合设备效率",
  `availability` float NULL COMMENT "可用率",
  `performance_rate` float NULL COMMENT "性能率",
  `quality_rate` float NULL COMMENT "质量率",
  `output_count` int NULL COMMENT "实际产出件",
  `planned_output` int NULL COMMENT "计划产出件",
  `defect_count` int NULL COMMENT "缺陷件",
  `scrap_count` int NULL COMMENT "报废件",
  `rework_count` int NULL COMMENT "返工件",
  `cycle_time_s` float NULL COMMENT "实际节拍s",
  `plan_cycle_s` float NULL COMMENT "计划节拍s",
  `run_hours` float NULL COMMENT "累计运行h",
  `yield_rate` float NULL COMMENT "综合良品率",
  `first_pass_yield` float NULL COMMENT "首次通过率",
  `scrap_rate` float NULL COMMENT "废品率",
  `rework_rate` float NULL COMMENT "返工率",
  `cpk_value` float NULL COMMENT "过程能力Cpk",
  `ppm_value` int NULL COMMENT "百万缺陷PPM",
  `surface_roughness` float NULL COMMENT "表面粗糙度Ra μm",
  `dimensional_error` float NULL COMMENT "尺寸偏差μm",
  `hardness_hrc` float NULL COMMENT "硬度HRC",
  `tensile_strength` float NULL COMMENT "抗拉强度MPa",
  `energy_kwh` float NULL COMMENT "单步能耗kWh",
  `energy_per_unit` float NULL COMMENT "单件能耗kWh",
  `co2_kg` float NULL COMMENT "碳排放kg",
  `env_temp` float NULL COMMENT "环境温度°C",
  `env_humidity` float NULL COMMENT "环境湿度%",
  `coolant_consumed_l` float NULL COMMENT "冷却液消耗L",
  `compressed_air_m3` float NULL COMMENT "压缩空气m³",
  `water_l` float NULL COMMENT "用水L",
  `tool_change_cnt` int NULL COMMENT "换刀次数",
  `alarm_count` int NULL COMMENT "告警次数",
  `unplanned_down_min` float NULL COMMENT "非计划停机min",
  `planned_down_min` float NULL COMMENT "计划停机min",
  `mtbf_h` float NULL COMMENT "平均故障间隔h"
) ENGINE=OLAP
DUPLICATE KEY(`ts`, `machine_id`)
DISTRIBUTED BY HASH(`machine_id`) BUCKETS 4
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

-- Table: mfg_production_metrics
CREATE TABLE IF NOT EXISTS `mfg_production_metrics` (
  `ts` datetime NULL,
  `machine_id` varchar(20) NULL,
  `line_id` varchar(10) NULL,
  `temperature` float NULL,
  `vibration` float NULL,
  `output_count` int NULL,
  `defect_count` int NULL,
  `oee` float NULL,
  `yield_rate` float NULL,
  `script_name` varchar(20) NULL,
  `script_color` varchar(10) NULL
) ENGINE=OLAP
DUPLICATE KEY(`ts`, `machine_id`)
DISTRIBUTED BY HASH(`machine_id`) BUCKETS 4
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

-- Table: news_article
CREATE TABLE IF NOT EXISTS `news_article` (
  `article_id` varchar(1000) NULL,
  `publish_ts` datetime NOT NULL,
  `title` varchar(300) NULL,
  `content` text NULL,
  `source` varchar(50) NULL,
  `sector_tag` varchar(30) NULL,
  `ai_summary` varchar(1000) NULL,
  `summarized` tinyint NULL DEFAULT "0",
  `ai_sentiment` varchar(20) NULL,
  `sentiment_score` int NULL,
  `sentiment_done` tinyint NULL DEFAULT "0",
  `ai_extract` varchar(2000) NULL,
  `extracted` tinyint NULL DEFAULT "0",
  `ai_method` varchar(20) NULL DEFAULT "PENDING"
) ENGINE=OLAP
UNIQUE KEY(`article_id`, `publish_ts`)
DISTRIBUTED BY HASH(`article_id`) BUCKETS 4
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

-- Table: position_metrics
CREATE TABLE IF NOT EXISTS `position_metrics` (
  `metric_date` date NOT NULL COMMENT "日期",
  `asset_class` varchar(32) NULL COMMENT "资产类别(股票/债券/衍生品/现金)",
  `position_amount` decimal(18,2) NULL COMMENT "头寸金额",
  `position_ratio` decimal(5,2) NULL COMMENT "占比%",
  `market_value` decimal(18,2) NULL COMMENT "市值",
  `profit_loss` decimal(18,2) NULL COMMENT "浮盈亏",
  `pl_ratio` decimal(5,2) NULL COMMENT "收益率%",
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`metric_date`, `asset_class`)
COMMENT '头寸管理表'
DISTRIBUTED BY HASH(`metric_date`) BUCKETS 16
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

-- Table: product_marketing
CREATE TABLE IF NOT EXISTS `product_marketing` (
  `metric_date` date NOT NULL COMMENT "日期",
  `product_name` varchar(64) NULL COMMENT "产品名称",
  `category` varchar(32) NULL COMMENT "产品类别",
  `sales_amount` decimal(18,2) NULL COMMENT "销售金额",
  `sales_count` int NULL COMMENT "销售笔数",
  `success_rate` decimal(5,2) NULL COMMENT "成功率%",
  `customer_acquisition` int NULL COMMENT "新增客户",
  `repurchase_rate` decimal(5,2) NULL COMMENT "复购率%",
  `rating` decimal(3,1) NULL COMMENT "评分",
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`metric_date`, `product_name`)
COMMENT '产品营销表'
DISTRIBUTED BY HASH(`metric_date`) BUCKETS 16
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

-- Table: risk_metrics
CREATE TABLE IF NOT EXISTS `risk_metrics` (
  `metric_date` date NOT NULL COMMENT "日期",
  `risk_level` varchar(16) NULL COMMENT "风险等级(低/中/高/极高)",
  `exposure_amount` decimal(18,2) NULL COMMENT "风险敞口",
  `default_count` int NULL COMMENT "违约数",
  `default_rate` decimal(5,4) NULL COMMENT "违约率%",
  `coverage_ratio` decimal(5,2) NULL COMMENT "覆盖率%",
  `overdue_amount` decimal(18,2) NULL COMMENT "逾期金额",
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`metric_date`, `risk_level`)
COMMENT '风控指标表'
DISTRIBUTED BY HASH(`metric_date`) BUCKETS 16
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

-- Table: satellite_collect_data
CREATE TABLE IF NOT EXISTS `satellite_collect_data` (
  `id` bigint NULL,
  `satellite_id` varchar(64) NULL,
  `satellite_name` varchar(64) NULL,
  `satellite_type` varchar(32) NULL,
  `sensor_id` varchar(64) NULL,
  `collect_time` bigint NULL,
  `data_type` varchar(32) NULL,
  `target_id` varchar(64) NULL,
  `target_type` varchar(32) NULL,
  `longitude` decimal(12,6) NULL,
  `latitude` decimal(12,6) NULL,
  `data_quality` int NULL,
  `data_size` bigint NULL,
  `status` varchar(16) NULL,
  `task_id` varchar(64) NULL,
  `created_at` bigint NULL
) ENGINE=OLAP
DUPLICATE KEY(`id`)
DISTRIBUTED BY HASH(`id`) BUCKETS 16
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

-- Table: satellite_info
CREATE TABLE IF NOT EXISTS `satellite_info` (
  `satellite_id` int NOT NULL,
  `satellite_name` varchar(50) NOT NULL,
  `satellite_type` varchar(20) NULL,
  `orbit_type` varchar(10) NULL,
  `launch_date` date NULL,
  `status` varchar(10) NULL,
  `operator` varchar(60) NULL,
  `country` varchar(20) NULL,
  `altitude_km` float NULL,
  `inclination_deg` float NULL,
  `period_min` float NULL,
  `payload_type` varchar(60) NULL,
  `mass_kg` float NULL
) ENGINE=OLAP
DUPLICATE KEY(`satellite_id`)
DISTRIBUTED BY HASH(`satellite_id`) BUCKETS 4
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

-- Table: satellite_task
CREATE TABLE IF NOT EXISTS `satellite_task` (
  `task_id` bigint NOT NULL,
  `satellite_id` int NULL,
  `task_type` varchar(20) NULL,
  `task_time` datetime NULL,
  `target_area` varchar(50) NULL,
  `priority` int NULL,
  `status` varchar(10) NULL,
  `duration_min` int NULL,
  `data_volume_gb` float NULL,
  `resolution_m` float NULL,
  `coverage_km2` float NULL
) ENGINE=OLAP
DUPLICATE KEY(`task_id`)
DISTRIBUTED BY HASH(`task_id`) BUCKETS 8
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

-- Table: satellite_telemetry
CREATE TABLE IF NOT EXISTS `satellite_telemetry` (
  `record_id` bigint NOT NULL,
  `satellite_id` int NULL,
  `record_time` datetime NULL,
  `battery_pct` float NULL,
  `solar_power_w` float NULL,
  `cpu_temp_c` float NULL,
  `signal_strength_db` float NULL,
  `orbit_altitude_km` float NULL,
  `attitude_roll` float NULL,
  `attitude_pitch` float NULL,
  `attitude_yaw` float NULL,
  `anomaly_flag` int NULL DEFAULT "0"
) ENGINE=OLAP
DUPLICATE KEY(`record_id`)
DISTRIBUTED BY HASH(`record_id`) BUCKETS 8
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

-- Table: satellite_telemetry_hf
CREATE TABLE IF NOT EXISTS `satellite_telemetry_hf` (
  `record_id` bigint NOT NULL,
  `satellite_id` int NOT NULL,
  `record_time` datetime NOT NULL,
  `battery_pct` float NULL COMMENT "电池电量%",
  `solar_power_w` float NULL COMMENT "太阳能功率W",
  `cpu_temp_c` float NULL COMMENT "CPU温度℃",
  `thermal_payload_c` float NULL COMMENT "载荷温度℃",
  `signal_strength_db` float NULL COMMENT "信号强度dB",
  `link_snr_db` float NULL COMMENT "链路信噪比dB",
  `orbit_altitude_km` float NULL COMMENT "轨道高度km",
  `attitude_error_deg` float NULL COMMENT "姿态误差°",
  `data_buffer_pct` float NULL COMMENT "星上存储占用%",
  `anomaly_flag` int NULL DEFAULT "0"
) ENGINE=OLAP
DUPLICATE KEY(`record_id`)
DISTRIBUTED BY HASH(`satellite_id`) BUCKETS 8
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

-- Table: sec_account_snapshot
CREATE TABLE IF NOT EXISTS `sec_account_snapshot` (
  `account_id` varchar(20) NULL,
  `client_name` varchar(20) NULL,
  `branch_id` varchar(10) NULL,
  `branch_name` varchar(50) NULL,
  `rm_name` varchar(20) NULL,
  `client_tier` varchar(20) NULL,
  `risk_level` int NULL,
  `total_asset` double NULL,
  `cash_amt` double NULL,
  `market_value` double NULL,
  `unrealized_pnl` double NULL,
  `pnl_pct` double NULL,
  `margin_debt` double NULL,
  `maintenance_ratio` double NULL,
  `concentration_pct` double NULL,
  `position_count` int NULL,
  `trade_count_today` int NULL,
  `turnover_today` double NULL,
  `last_trade_ts` datetime NULL,
  `update_ts` datetime NULL
) ENGINE=OLAP
UNIQUE KEY(`account_id`)
DISTRIBUTED BY HASH(`account_id`) BUCKETS 4
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

-- Table: sec_branch_metrics
CREATE TABLE IF NOT EXISTS `sec_branch_metrics` (
  `ts` datetime NULL,
  `branch_id` varchar(10) NULL,
  `branch_name` varchar(50) NULL,
  `turnover_amt` double NULL,
  `commission_amt` double NULL,
  `buy_amt` double NULL,
  `sell_amt` double NULL,
  `net_inflow_amt` double NULL,
  `active_clients` int NULL,
  `margin_clients` int NULL,
  `avg_maintenance` double NULL,
  `phase_name` varchar(20) NULL
) ENGINE=OLAP
UNIQUE KEY(`ts`, `branch_id`)
DISTRIBUTED BY HASH(`branch_id`) BUCKETS 4
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

-- Table: sec_market_minute
CREATE TABLE IF NOT EXISTS `sec_market_minute` (
  `ts` datetime NULL,
  `symbol` varchar(10) NULL,
  `security_name` varchar(30) NULL,
  `sector_name` varchar(30) NULL,
  `last_price` double NULL,
  `change_pct` double NULL,
  `volume_lot` bigint NULL,
  `turnover_amt` double NULL,
  `net_inflow_amt` double NULL,
  `phase_name` varchar(20) NULL
) ENGINE=OLAP
UNIQUE KEY(`ts`, `symbol`)
DISTRIBUTED BY HASH(`symbol`) BUCKETS 4
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

-- Table: sec_position_snapshot
CREATE TABLE IF NOT EXISTS `sec_position_snapshot` (
  `account_id` varchar(20) NULL,
  `symbol` varchar(10) NULL,
  `security_name` varchar(30) NULL,
  `sector_name` varchar(30) NULL,
  `branch_id` varchar(10) NULL,
  `branch_name` varchar(50) NULL,
  `qty` bigint NULL,
  `available_qty` bigint NULL,
  `avg_cost` double NULL,
  `last_price` double NULL,
  `market_value` double NULL,
  `cost_amount` double NULL,
  `unrealized_pnl` double NULL,
  `pnl_pct` double NULL,
  `weight_pct` double NULL,
  `update_ts` datetime NULL
) ENGINE=OLAP
UNIQUE KEY(`account_id`, `symbol`)
DISTRIBUTED BY HASH(`account_id`) BUCKETS 4
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

-- Table: sec_risk_snapshot
CREATE TABLE IF NOT EXISTS `sec_risk_snapshot` (
  `alert_id` varchar(40) NULL,
  `account_id` varchar(20) NULL,
  `client_name` varchar(20) NULL,
  `branch_id` varchar(10) NULL,
  `branch_name` varchar(50) NULL,
  `alert_type` varchar(40) NULL,
  `risk_level` varchar(10) NULL,
  `metric_value` double NULL,
  `threshold_value` double NULL,
  `position_symbol` varchar(10) NULL,
  `position_name` varchar(30) NULL,
  `suggestion` varchar(100) NULL,
  `status` varchar(20) NULL,
  `update_ts` datetime NULL
) ENGINE=OLAP
UNIQUE KEY(`alert_id`)
DISTRIBUTED BY HASH(`alert_id`) BUCKETS 4
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

-- Table: sec_trade_detail
CREATE TABLE IF NOT EXISTS `sec_trade_detail` (
  `trade_id` varchar(40) NULL,
  `ts` datetime NULL,
  `account_id` varchar(20) NULL,
  `client_name` varchar(20) NULL,
  `branch_id` varchar(10) NULL,
  `branch_name` varchar(50) NULL,
  `rm_name` varchar(20) NULL,
  `symbol` varchar(10) NULL,
  `security_name` varchar(30) NULL,
  `sector_name` varchar(30) NULL,
  `side` varchar(10) NULL,
  `price` double NULL,
  `qty` bigint NULL,
  `amount` double NULL,
  `fee` double NULL,
  `channel` varchar(20) NULL,
  `phase_name` varchar(20) NULL
) ENGINE=OLAP
UNIQUE KEY(`trade_id`)
DISTRIBUTED BY HASH(`trade_id`) BUCKETS 4
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

-- Table: service_log
CREATE TABLE IF NOT EXISTS `service_log` (
  `trace_id` varchar(64) NOT NULL,
  `span_id` varchar(64) NOT NULL,
  `request_time` datetime NOT NULL,
  `method` varchar(16) NOT NULL,
  `path` varchar(255) NOT NULL,
  `status_code` int NOT NULL,
  `duration_ms` int NOT NULL,
  `ip_address` varchar(32) NULL,
  `user_agent` varchar(256) NULL,
  `error_message` varchar(512) NULL,
  `tags` varchar(128) NULL,
  INDEX idx_trace (`trace_id`) USING INVERTED,
  INDEX idx_time (`request_time`) USING INVERTED
) ENGINE=OLAP
DUPLICATE KEY(`trace_id`, `span_id`)
DISTRIBUTED BY HASH(`trace_id`) BUCKETS 4
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

-- Table: sys_logs
CREATE TABLE IF NOT EXISTS `sys_logs` (
  `trace_id` varchar(32) NULL,
  `log_time` datetime(3) NULL,
  `level` varchar(10) NULL,
  `service` varchar(60) NULL,
  `method` varchar(10) NULL,
  `path` varchar(500) NULL,
  `status_code` int NULL,
  `duration_ms` double NULL,
  `db_time_ms` double NULL,
  `message` varchar(2000) NULL,
  `log_tag` varchar(50) NULL
) ENGINE=OLAP
UNIQUE KEY(`trace_id`, `log_time`)
DISTRIBUTED BY HASH(`trace_id`) BUCKETS 4
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

-- Table: sys_spans
CREATE TABLE IF NOT EXISTS `sys_spans` (
  `trace_id` varchar(32) NULL,
  `span_id` varchar(32) NULL,
  `parent_span_id` varchar(32) NULL,
  `span_time` datetime(3) NULL,
  `service` varchar(60) NULL,
  `operation` varchar(200) NULL,
  `offset_ms` double NULL,
  `duration_ms` double NULL,
  `status` varchar(10) NULL,
  `db_query` varchar(500) NULL
) ENGINE=OLAP
DUPLICATE KEY(`trace_id`, `span_id`)
DISTRIBUTED BY HASH(`trace_id`) BUCKETS 4
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

-- Table: tag_dict
CREATE TABLE IF NOT EXISTS `tag_dict` (
  `tag_id` bigint NOT NULL COMMENT "标签ID",
  `tag_category` varchar(32) NOT NULL COMMENT "标签大类：BASIC/ASSET/BEHAVIOR/LOG_AI/CUSTOM",
  `tag_name` varchar(64) NOT NULL COMMENT "标签名称（英文key）",
  `tag_label` varchar(128) NOT NULL COMMENT "标签显示名（中文）",
  `tag_desc` varchar(512) NULL COMMENT "标签说明",
  `value_type` varchar(16) NULL COMMENT "值类型：ENUM/RANGE/BOOLEAN/TEXT",
  `value_options` text NULL COMMENT "枚举值选项（JSON数组）",
  `source_table` varchar(64) NULL COMMENT "来源表",
  `source_field` varchar(64) NULL COMMENT "来源字段",
  `is_ai_tag` tinyint NULL COMMENT "是否AI标签：1是 0否",
  `enable_bitmap` tinyint NULL COMMENT "是否支持Bitmap圈选：1是 0否",
  `status` tinyint NULL COMMENT "状态：1启用 0停用",
  `sort_order` int NULL COMMENT "排序",
  `created_at` datetime NULL COMMENT "创建时间"
) ENGINE=OLAP
UNIQUE KEY(`tag_id`)
COMMENT '标签字典表'
DISTRIBUTED BY HASH(`tag_id`) BUCKETS 4
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

-- Table: user_avatar
CREATE TABLE IF NOT EXISTS `user_avatar` (
  `user_id` bigint NOT NULL COMMENT "用户ID",
  `user_name` varchar(64) NULL COMMENT "用户名",
  `avatar_style` varchar(32) NULL COMMENT "头像风格标识",
  `description` varchar(256) NULL COMMENT "角色描述",
  `photo_embedding` array<float> NULL COMMENT "照片特征向量(8维)",
  `labels` varchar(256) NULL COMMENT "标签JSON",
  `create_time` datetime NULL COMMENT "创建时间"
) ENGINE=OLAP
UNIQUE KEY(`user_id`)
DISTRIBUTED BY HASH(`user_id`) BUCKETS 4
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

-- Table: user_avatar_bak
CREATE TABLE IF NOT EXISTS `user_avatar_bak` (
  `user_id` bigint NOT NULL COMMENT "用户ID",
  `user_name` varchar(64) NULL COMMENT "用户名",
  `avatar_style` varchar(32) NULL COMMENT "头像风格标识",
  `description` varchar(256) NULL COMMENT "角色描述",
  `photo_embedding` array<float> NULL COMMENT "照片特征向量(8维)",
  `labels` varchar(256) NULL COMMENT "标签JSON",
  `create_time` datetime NULL COMMENT "创建时间"
) ENGINE=OLAP
DUPLICATE KEY(`user_id`)
DISTRIBUTED BY HASH(`user_id`) BUCKETS 4
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

-- Table: user_avatar_photo
CREATE TABLE IF NOT EXISTS `user_avatar_photo` (
  `user_id` bigint NOT NULL COMMENT "用户ID",
  `photo_url` text NULL COMMENT "头像图片dataURL",
  `create_time` datetime NULL COMMENT "创建时间"
) ENGINE=OLAP
DUPLICATE KEY(`user_id`)
DISTRIBUTED BY HASH(`user_id`) BUCKETS 4
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

-- Table: user_base
CREATE TABLE IF NOT EXISTS `user_base` (
  `user_id` varchar(32) NOT NULL COMMENT "用户ID",
  `user_name` varchar(64) NULL COMMENT "卡通用户名",
  `id_card_mask` varchar(64) NULL COMMENT "脱敏身份证",
  `auth_status` tinyint NULL DEFAULT "0" COMMENT "认证状态 0=未认证 1=已认证",
  `avatar_url` varchar(256) NULL COMMENT "卡通头像URL",
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=OLAP
DUPLICATE KEY(`user_id`)
DISTRIBUTED BY HASH(`user_id`) BUCKETS 2
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

-- Table: user_behavior
CREATE TABLE IF NOT EXISTS `user_behavior` (
  `event_id` bigint NOT NULL COMMENT "事件ID",
  `user_id` bigint NOT NULL COMMENT "用户ID",
  `event_date` date NOT NULL COMMENT "事件日期（分区键）",
  `event_time` datetime NOT NULL COMMENT "事件时间",
  `event_type` varchar(64) NOT NULL COMMENT "事件类型",
  `event_category` varchar(32) NULL COMMENT "事件分类：LOGIN/TRANSACTION/BROWSE/APPLY",
  `channel` varchar(32) NULL COMMENT "渠道：APP/H5/WEB/BRANCH",
  `product_code` varchar(32) NULL COMMENT "产品代码",
  `amount` decimal(20,4) NULL COMMENT "金额（元）",
  `result_code` varchar(16) NULL COMMENT "结果：SUCCESS/FAIL/CANCEL",
  `session_id` varchar(128) NULL COMMENT "会话ID",
  `device_type` varchar(16) NULL COMMENT "设备类型：iOS/Android/PC",
  `ip_address` varchar(64) NULL COMMENT "IP地址（脱敏）",
  `extra_props` varchar(2048) NULL COMMENT "扩展属性JSON"
) ENGINE=OLAP
DUPLICATE KEY(`event_id`, `user_id`, `event_date`)
COMMENT '用户行为事件明细表'
PARTITION BY RANGE(`event_date`)
(PARTITION p2025_01 VALUES [('0000-01-01'), ('2025-02-01')),
PARTITION p2025_02 VALUES [('2025-02-01'), ('2025-03-01')),
PARTITION p2025_03 VALUES [('2025-03-01'), ('2025-04-01')),
PARTITION p2025_04 VALUES [('2025-04-01'), ('2025-05-01')),
PARTITION p2025_05 VALUES [('2025-05-01'), ('2025-06-01')),
PARTITION p2025_06 VALUES [('2025-06-01'), ('2025-07-01')),
PARTITION p_future VALUES [('2025-07-01'), (MAXVALUE)))
DISTRIBUTED BY HASH(`user_id`) BUCKETS 64
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

-- Table: user_log_raw
CREATE TABLE IF NOT EXISTS `user_log_raw` (
  `log_id` bigint NOT NULL COMMENT "日志ID",
  `log_date` date NOT NULL COMMENT "日志日期（分区键）",
  `log_time` datetime NOT NULL COMMENT "日志时间",
  `user_id` bigint NULL COMMENT "用户ID（可为空：未登录用户）",
  `session_id` varchar(128) NULL COMMENT "会话ID",
  `log_level` varchar(16) NULL COMMENT "日志级别：INFO/WARN/ERROR",
  `log_source` varchar(32) NULL COMMENT "日志来源：APP/CORE_BANK/ATM/BRANCH",
  `log_content` text NULL COMMENT "日志内容（原始）",
  `operation_type` varchar(64) NULL COMMENT "操作类型（初步分类）",
  `ip_address` varchar(64) NULL COMMENT "IP地址",
  `user_region` varchar(64) NULL COMMENT "用户历史所在地区",
  `device_info` varchar(256) NULL COMMENT "设备信息",
  `response_code` varchar(16) NULL COMMENT "响应码",
  `response_time` int NULL COMMENT "响应时长（毫秒）",
  `filebeat_host` varchar(64) NULL COMMENT "FileBeat采集节点",
  `raw_json` text NULL COMMENT "原始JSON（FileBeat推送）",
  `created_at` datetime NULL COMMENT "入库时间"
) ENGINE=OLAP
DUPLICATE KEY(`log_id`, `log_date`)
COMMENT '日志原始表 - FileBeat采集（Doris 4.0 HASP高效写入）'
PARTITION BY RANGE(`log_date`)
(PARTITION p2025_01 VALUES [('0000-01-01'), ('2025-02-01')),
PARTITION p2025_02 VALUES [('2025-02-01'), ('2025-03-01')),
PARTITION p2025_03 VALUES [('2025-03-01'), ('2025-04-01')),
PARTITION p2025_04 VALUES [('2025-04-01'), ('2025-05-01')),
PARTITION p2025_05 VALUES [('2025-05-01'), ('2025-06-01')),
PARTITION p2025_06 VALUES [('2025-06-01'), ('2025-07-01')),
PARTITION p_future VALUES [('2025-07-01'), (MAXVALUE)))
DISTRIBUTED BY HASH(`log_id`) BUCKETS 64
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

-- Table: user_log_tag
CREATE TABLE IF NOT EXISTS `user_log_tag` (
  `log_id` bigint NOT NULL COMMENT "关联日志ID",
  `log_date` date NOT NULL COMMENT "日志日期（分区键）",
  `user_id` bigint NULL COMMENT "用户ID",
  `log_time` datetime NULL COMMENT "日志时间",
  `log_type` varchar(32) NULL COMMENT "AI标签：登录日志/交易日志/查询日志/转账日志/异常日志",
  `intent_tag` varchar(64) NULL COMMENT "操作意图：查询余额/转账汇款/购买理财/申请贷款/账户设置/其他",
  `anomaly_tag` varchar(32) NULL COMMENT "异常标签：正常/异地登录/大额转账/频繁操作/可疑账户",
  `risk_level` varchar(16) NULL COMMENT "风险等级：低风险/中风险/高风险",
  `ai_raw_result` text NULL COMMENT "AI原始返回结果（JSON）",
  `tag_source` varchar(16) NULL COMMENT "标签来源：AI_AUTO/PYTHON_API/MANUAL",
  `manual_label` varchar(64) NULL COMMENT "人工标注（覆盖AI结果）",
  `created_at` datetime NULL COMMENT "打标时间"
) ENGINE=OLAP
UNIQUE KEY(`log_id`, `log_date`)
COMMENT '日志AI标签表'
PARTITION BY RANGE(`log_date`)
(PARTITION p2025_01 VALUES [('0000-01-01'), ('2025-02-01')),
PARTITION p2025_02 VALUES [('2025-02-01'), ('2025-03-01')),
PARTITION p2025_03 VALUES [('2025-03-01'), ('2025-04-01')),
PARTITION p2025_04 VALUES [('2025-04-01'), ('2025-05-01')),
PARTITION p2025_05 VALUES [('2025-05-01'), ('2025-06-01')),
PARTITION p2025_06 VALUES [('2025-06-01'), ('2025-07-01')),
PARTITION p_future VALUES [('2025-07-01'), (MAXVALUE)))
DISTRIBUTED BY HASH(`log_id`) BUCKETS 32
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

-- Table: user_segment
CREATE TABLE IF NOT EXISTS `user_segment` (
  `segment_id` bigint NOT NULL COMMENT "人群包ID",
  `segment_name` varchar(128) NOT NULL COMMENT "人群包名称",
  `segment_desc` varchar(512) NULL COMMENT "描述",
  `rule_config` varchar(8191) NULL COMMENT "圈选规则JSON",
  `segment_type` varchar(16) NULL COMMENT "类型：RULE/BITMAP/ML",
  `snap_date` date NULL COMMENT "快照日期",
  `status` tinyint NULL COMMENT "状态：1生效 0失效",
  `created_by` varchar(64) NULL COMMENT "创建人",
  `created_at` datetime NULL COMMENT "创建时间",
  `updated_at` datetime NULL COMMENT "更新时间",
  `segment_bitmap` bitmap BITMAP_UNION NOT NULL DEFAULT BITMAP_EMPTY COMMENT "人群用户Bitmap",
  `user_count` bigint SUM NULL COMMENT "人群规模"
) ENGINE=OLAP
AGGREGATE KEY(`segment_id`, `segment_name`, `segment_desc`, `rule_config`, `segment_type`, `snap_date`, `status`, `created_by`, `created_at`, `updated_at`)
COMMENT '人群包表 - Bitmap存储'
DISTRIBUTED BY HASH(`segment_id`) BUCKETS 8
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

-- Table: user_tag
CREATE TABLE IF NOT EXISTS `user_tag` (
  `tag_date` date NOT NULL COMMENT "标签日期（分区键）",
  `tag_category` varchar(32) NOT NULL COMMENT "标签大类：BASIC/ASSET/BEHAVIOR/LOG_AI",
  `tag_name` varchar(64) NOT NULL COMMENT "标签名称",
  `tag_value` varchar(128) NOT NULL COMMENT "标签值",
  `user_bitmap` bitmap BITMAP_UNION NOT NULL DEFAULT BITMAP_EMPTY COMMENT "用户ID的Bitmap集合",
  `user_count` bigint SUM NULL COMMENT "用户数量",
  `updated_at` datetime REPLACE NULL COMMENT "更新时间"
) ENGINE=OLAP
AGGREGATE KEY(`tag_date`, `tag_category`, `tag_name`, `tag_value`)
COMMENT '用户标签Bitmap表 - 支持亿级人群快速圈选'
PARTITION BY RANGE(`tag_date`)
(PARTITION p2025_q1 VALUES [('0000-01-01'), ('2025-04-01')),
PARTITION p2025_q2 VALUES [('2025-04-01'), ('2025-07-01')),
PARTITION p2025_q3 VALUES [('2025-07-01'), ('2025-10-01')),
PARTITION p2025_q4 VALUES [('2025-10-01'), ('2026-01-01')),
PARTITION p_future VALUES [('2026-01-01'), (MAXVALUE)))
DISTRIBUTED BY HASH(`tag_name`, `tag_value`) BUCKETS 32
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

-- Table: user_wide
CREATE TABLE IF NOT EXISTS `user_wide` (
  `user_id` bigint NOT NULL COMMENT "用户唯一ID",
  `update_date` date NOT NULL COMMENT "数据更新日期（分区键）",
  `user_name` varchar(64) NULL COMMENT "用户姓名（脱敏：张*明）",
  `id_card` varchar(32) NULL COMMENT "身份证号（脱敏：110***8881）",
  `phone` varchar(20) NULL COMMENT "手机号（脱敏：138****8888）",
  `gender` tinyint NULL COMMENT "性别：1男 2女 0未知",
  `age` int NULL COMMENT "年龄",
  `age_group` varchar(16) NULL COMMENT "年龄段：18-25/26-35/36-45/46-55/55+",
  `city` varchar(32) NULL COMMENT "城市",
  `province` varchar(16) NULL COMMENT "省份",
  `education` tinyint NULL COMMENT "学历：1小学 2初中 3高中 4大专 5本科 6硕士 7博士",
  `occupation` varchar(32) NULL COMMENT "职业",
  `register_date` date NULL COMMENT "注册日期",
  `asset_level` varchar(16) NULL COMMENT "资产等级：VIP私行/VIP钻石/VIP铂金/VIP黄金/普通",
  `aum_total` decimal(20,4) NULL COMMENT "总AUM资产（万元）",
  `deposit_amount` decimal(20,4) NULL COMMENT "存款余额（万元）",
  `fund_amount` decimal(20,4) NULL COMMENT "基金持有额（万元）",
  `loan_amount` decimal(20,4) NULL COMMENT "贷款余额（万元）",
  `wm_amount` decimal(20,4) NULL COMMENT "理财余额（万元）",
  `insurance_amount` decimal(20,4) NULL COMMENT "保险保费（万元）",
  `has_credit_card` tinyint NULL COMMENT "是否持有信用卡：1是 0否",
  `has_debit_card` tinyint NULL COMMENT "是否持有借记卡：1是 0否",
  `has_mortgage` tinyint NULL COMMENT "是否有房贷：1是 0否",
  `product_count` int NULL COMMENT "持有产品总数",
  `credit_score` int NULL COMMENT "综合信用评分 300-900",
  `credit_grade` varchar(8) NULL COMMENT "信用等级：AAA/AA/A/B/C",
  `risk_level` tinyint NULL COMMENT "风险等级：1保守 2稳健 3平衡 4进取 5激进",
  `preferred_channel` varchar(16) NULL COMMENT "偏好渠道：APP/网点/小程序/网银",
  `app_login_30d` int NULL COMMENT "APP近30天登录次数",
  `app_last_login` date NULL COMMENT "APP最后登录日期",
  `active_level` varchar(16) NULL COMMENT "活跃等级：高活/中活/低活/沉睡",
  `lifecycle_stage` varchar(32) NULL COMMENT "生命周期：新客/成长/成熟/沉睡/流失预警",
  `churn_prob` decimal(10,4) NULL COMMENT "流失概率（%，模型输出）",
  `clv_score` decimal(20,4) NULL COMMENT "客户终身价值分",
  `log_tags` varchar(512) NULL COMMENT "AI日志标签（JSON数组）",
  `anomaly_flag` tinyint NULL COMMENT "异常行为标记：1是 0否",
  `created_at` datetime NULL COMMENT "创建时间",
  `updated_at` datetime NULL COMMENT "最后更新时间"
) ENGINE=OLAP
UNIQUE KEY(`user_id`, `update_date`)
COMMENT '用户宽表 - CDP核心标签表（Doris 4.0 HASP）'
PARTITION BY RANGE(`update_date`)
(PARTITION p2024_q1 VALUES [('0000-01-01'), ('2024-04-01')),
PARTITION p2024_q2 VALUES [('2024-04-01'), ('2024-07-01')),
PARTITION p2024_q3 VALUES [('2024-07-01'), ('2024-10-01')),
PARTITION p2024_q4 VALUES [('2024-10-01'), ('2025-01-01')),
PARTITION p2025_q1 VALUES [('2025-01-01'), ('2025-04-01')),
PARTITION p2025_q2 VALUES [('2025-04-01'), ('2025-07-01')),
PARTITION p2025_q3 VALUES [('2025-07-01'), ('2025-10-01')),
PARTITION p2025_q4 VALUES [('2025-10-01'), ('2026-01-01')),
PARTITION p_future VALUES [('2026-01-01'), (MAXVALUE)))
DISTRIBUTED BY HASH(`user_id`) BUCKETS 64
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

-- Table: user_wide_point_query
CREATE TABLE IF NOT EXISTS `user_wide_point_query` (
  `user_id` bigint NOT NULL COMMENT "用户唯一ID",
  `update_date` date NOT NULL COMMENT "数据更新日期",
  `user_name` varchar(64) NULL COMMENT "用户姓名（脱敏）",
  `id_card` varchar(32) NULL COMMENT "身份证号（脱敏）",
  `phone` varchar(20) NULL COMMENT "手机号（脱敏）",
  `gender` tinyint NULL COMMENT "性别：1男 2女 0未知",
  `age` int NULL COMMENT "年龄",
  `age_group` varchar(16) NULL COMMENT "年龄段",
  `city` varchar(32) NULL COMMENT "城市",
  `province` varchar(16) NULL COMMENT "省份",
  `education` tinyint NULL COMMENT "学历",
  `occupation` varchar(32) NULL COMMENT "职业",
  `register_date` date NULL COMMENT "注册日期",
  `asset_level` varchar(16) NULL COMMENT "资产等级",
  `aum_total` decimal(20,4) NULL COMMENT "总AUM资产（万元）",
  `deposit_amount` decimal(20,4) NULL COMMENT "存款余额（万元）",
  `fund_amount` decimal(20,4) NULL COMMENT "基金持有额（万元）",
  `loan_amount` decimal(20,4) NULL COMMENT "贷款余额（万元）",
  `wm_amount` decimal(20,4) NULL COMMENT "理财余额（万元）",
  `insurance_amount` decimal(20,4) NULL COMMENT "保险保费（万元）",
  `has_credit_card` tinyint NULL COMMENT "是否持有信用卡",
  `has_debit_card` tinyint NULL COMMENT "是否持有借记卡",
  `has_mortgage` tinyint NULL COMMENT "是否有房贷",
  `product_count` int NULL COMMENT "持有产品总数",
  `credit_score` int NULL COMMENT "综合信用评分",
  `credit_grade` varchar(8) NULL COMMENT "信用等级",
  `risk_level` tinyint NULL COMMENT "风险等级",
  `preferred_channel` varchar(16) NULL COMMENT "偏好渠道",
  `app_login_30d` int NULL COMMENT "APP近30天登录次数",
  `app_last_login` date NULL COMMENT "APP最后登录日期",
  `active_level` varchar(16) NULL COMMENT "活跃等级",
  `lifecycle_stage` varchar(32) NULL COMMENT "生命周期",
  `churn_prob` decimal(10,4) NULL COMMENT "流失概率",
  `clv_score` decimal(20,4) NULL COMMENT "客户终身价值分",
  `log_tags` varchar(512) NULL COMMENT "AI日志标签（JSON数组）",
  `anomaly_flag` tinyint NULL COMMENT "异常行为标记",
  `created_at` datetime NULL COMMENT "创建时间",
  `updated_at` datetime NULL COMMENT "最后更新时间"
) ENGINE=OLAP
UNIQUE KEY(`user_id`)
COMMENT '用户宽表 - 主键点查优化版（行存，无分区）'
DISTRIBUTED BY HASH(`user_id`) BUCKETS 10
PROPERTIES (
"replication_allocation" = "tag.location.default: 1",
"min_load_replica_num" = "-1",
"is_being_synced" = "false",
"storage_medium" = "hdd",
"storage_format" = "V2",
"inverted_index_storage_format" = "V3",
"enable_unique_key_merge_on_write" = "true",
"light_schema_change" = "true",
"row_store_columns" = "user_id,update_date,user_name,asset_level,aum_total,log_tags",
"row_store_page_size" = "4096",
"disable_auto_compaction" = "false",
"enable_single_replica_compaction" = "false",
"group_commit_interval_ms" = "10000",
"group_commit_data_bytes" = "134217728",
"enable_mow_light_delete" = "false"
);
