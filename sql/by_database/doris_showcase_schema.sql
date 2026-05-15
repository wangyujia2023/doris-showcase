-- ================================================================
-- Database: doris_showcase
-- Type: schema
-- Source: generated from current Doris SHOW CREATE TABLE output.
-- ================================================================

CREATE DATABASE IF NOT EXISTS doris_showcase;
USE doris_showcase;

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
"replication_allocation" = "tag.location.default: 1"
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
"replication_allocation" = "tag.location.default: 1"
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
"replication_allocation" = "tag.location.default: 1"
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
"replication_allocation" = "tag.location.default: 1"
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
"replication_allocation" = "tag.location.default: 1"
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
"replication_allocation" = "tag.location.default: 1"
);


-- Table: t_customer_tags
CREATE TABLE IF NOT EXISTS `t_customer_tags` (
  `tag_id` bigint NOT NULL COMMENT "Tag ID",
  `tag_name` varchar(64) NOT NULL COMMENT "Tag column name",
  `tag_bitmap` bitmap BITMAP_UNION COMMENT "Customer bitmap",
  `update_time` datetime REPLACE COMMENT "Last update time"
) ENGINE=OLAP
AGGREGATE KEY(`tag_id`, `tag_name`)
COMMENT 'Customer tag tall table for bitmap operations'
DISTRIBUTED BY HASH(`tag_id`) BUCKETS 8
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);

-- Table: user_tag_wide
CREATE TABLE IF NOT EXISTS `user_tag_wide` (
  `customer_id` bigint NOT NULL COMMENT "Customer ID",
  `update_time` datetime NULL COMMENT "Update time",
  `male` tinyint NULL DEFAULT '0' COMMENT "男性",
  `female` tinyint NULL DEFAULT '0' COMMENT "女性",
  `age_under_20` tinyint NULL DEFAULT '0' COMMENT "年龄<20",
  `age_20_25` tinyint NULL DEFAULT '0' COMMENT "年龄20-25",
  `age_26_30` tinyint NULL DEFAULT '0' COMMENT "年龄26-30",
  `age_31_35` tinyint NULL DEFAULT '0' COMMENT "年龄31-35",
  `age_36_40` tinyint NULL DEFAULT '0' COMMENT "年龄36-40",
  `age_41_45` tinyint NULL DEFAULT '0' COMMENT "年龄41-45",
  `age_46_50` tinyint NULL DEFAULT '0' COMMENT "年龄46-50",
  `age_51_55` tinyint NULL DEFAULT '0' COMMENT "年龄51-55",
  `age_56_60` tinyint NULL DEFAULT '0' COMMENT "年龄56-60",
  `age_over_60` tinyint NULL DEFAULT '0' COMMENT "年龄>60",
  `married` tinyint NULL DEFAULT '0' COMMENT "已婚",
  `unmarried` tinyint NULL DEFAULT '0' COMMENT "未婚",
  `divorced` tinyint NULL DEFAULT '0' COMMENT "离异",
  `has_child` tinyint NULL DEFAULT '0' COMMENT "有子女",
  `has_house` tinyint NULL DEFAULT '0' COMMENT "有房",
  `has_car` tinyint NULL DEFAULT '0' COMMENT "有车",
  `local_hukou` tinyint NULL DEFAULT '0' COMMENT "本地户籍",
  `has_social_security` tinyint NULL DEFAULT '0' COMMENT "缴纳社保",
  `has_fund` tinyint NULL DEFAULT '0' COMMENT "缴纳公积金",
  `education_bachelor` tinyint NULL DEFAULT '0' COMMENT "本科及以上",
  `education_college` tinyint NULL DEFAULT '0' COMMENT "大专",
  `education_high` tinyint NULL DEFAULT '0' COMMENT "高中及以下",
  `income_under_5k` tinyint NULL DEFAULT '0' COMMENT "月收入<5k",
  `income_5k_1w` tinyint NULL DEFAULT '0' COMMENT "月收入5k-1w",
  `income_1w_2w` tinyint NULL DEFAULT '0' COMMENT "月收入1w-2w",
  `income_2w_5w` tinyint NULL DEFAULT '0' COMMENT "月收入2w-5w",
  `income_over_5w` tinyint NULL DEFAULT '0' COMMENT "月收入>5w",
  `asset_under_10w` tinyint NULL DEFAULT '0' COMMENT "资产<10w",
  `asset_10w_50w` tinyint NULL DEFAULT '0' COMMENT "资产10w-50w",
  `asset_50w_100w` tinyint NULL DEFAULT '0' COMMENT "资产50w-100w",
  `asset_100w_500w` tinyint NULL DEFAULT '0' COMMENT "资产100w-500w",
  `asset_500w_1000w` tinyint NULL DEFAULT '0' COMMENT "资产500w-1000w",
  `asset_over_1000w` tinyint NULL DEFAULT '0' COMMENT "资产>1000w",
  `high_net_worth` tinyint NULL DEFAULT '0' COMMENT "高净值",
  `ultra_high_net` tinyint NULL DEFAULT '0' COMMENT "超高净值",
  `potential_client` tinyint NULL DEFAULT '0' COMMENT "潜力客户",
  `normal_client` tinyint NULL DEFAULT '0' COMMENT "普通客户",
  `has_financial` tinyint NULL DEFAULT '0' COMMENT "持有理财",
  `has_fund_product` tinyint NULL DEFAULT '0' COMMENT "持有基金",
  `has_stock` tinyint NULL DEFAULT '0' COMMENT "持有股票",
  `has_insurance` tinyint NULL DEFAULT '0' COMMENT "持有保险",
  `has_bonds` tinyint NULL DEFAULT '0' COMMENT "持有国债",
  `has_gold` tinyint NULL DEFAULT '0' COMMENT "持有贵金属",
  `has_loan` tinyint NULL DEFAULT '0' COMMENT "有贷款",
  `has_housing_loan` tinyint NULL DEFAULT '0' COMMENT "有房贷",
  `has_car_loan` tinyint NULL DEFAULT '0' COMMENT "有车贷",
  `has_consumer_loan` tinyint NULL DEFAULT '0' COMMENT "有消费贷",
  `active_7d` tinyint NULL DEFAULT '0' COMMENT "7日活跃",
  `active_30d` tinyint NULL DEFAULT '0' COMMENT "30日活跃",
  `inactive_30d` tinyint NULL DEFAULT '0' COMMENT "30日不活跃",
  `trans_high_freq` tinyint NULL DEFAULT '0' COMMENT "高交易频率",
  `big_transactor` tinyint NULL DEFAULT '0' COMMENT "大额交易",
  `mobile_user` tinyint NULL DEFAULT '0' COMMENT "手机银行用户",
  `web_user` tinyint NULL DEFAULT '0' COMMENT "网银用户",
  `high_response` tinyint NULL DEFAULT '0' COMMENT "高响应率",
  `low_response` tinyint NULL DEFAULT '0' COMMENT "低响应率",
  `marketing_sensitive` tinyint NULL DEFAULT '0' COMMENT "营销敏感",
  `apply_loan` tinyint NULL DEFAULT '0' COMMENT "申请贷款",
  `buy_financing` tinyint NULL DEFAULT '0' COMMENT "购买理财",
  `_reserved` tinyint NULL DEFAULT '0' COMMENT "Reserved flag"
) ENGINE=OLAP
DUPLICATE KEY(`customer_id`)
COMMENT 'Customer tag wide table for CDP analysis'
DISTRIBUTED BY HASH(`customer_id`) BUCKETS 8
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);

--sys_logs
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
"replication_allocation" = "tag.location.default: 1"
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
"replication_allocation" = "tag.location.default: 1"
);


-- Table: user_wide
DROP TABLE IF EXISTS `user_wide`;
CREATE TABLE IF NOT EXISTS `user_wide` (
  `user_id` bigint NOT NULL COMMENT "User unique id",
  `update_date` date NOT NULL COMMENT "Data update date",
  `user_name` varchar(64) NULL COMMENT "Masked user name",
  `id_card` varchar(32) NULL COMMENT "Masked identity number",
  `phone` varchar(20) NULL COMMENT "Masked mobile number",
  `gender` tinyint NULL COMMENT "Gender: 1 male, 2 female, 0 unknown",
  `age` int NULL COMMENT "Age",
  `age_group` varchar(16) NULL COMMENT "Age group",
  `city` varchar(32) NULL COMMENT "City",
  `province` varchar(32) NULL COMMENT "Province",
  `education` tinyint NULL COMMENT "Education level",
  `occupation` varchar(32) NULL COMMENT "Occupation",
  `register_date` date NULL COMMENT "Registration date",
  `asset_level` varchar(24) NULL COMMENT "Asset level",
  `aum_total` decimal(20,4) NULL COMMENT "Total AUM in 10k CNY",
  `deposit_amount` decimal(20,4) NULL COMMENT "Deposit balance in 10k CNY",
  `fund_amount` decimal(20,4) NULL COMMENT "Fund holding in 10k CNY",
  `loan_amount` decimal(20,4) NULL COMMENT "Loan balance in 10k CNY",
  `wm_amount` decimal(20,4) NULL COMMENT "Wealth management balance in 10k CNY",
  `insurance_amount` decimal(20,4) NULL COMMENT "Insurance premium in 10k CNY",
  `has_credit_card` tinyint NULL COMMENT "Has credit card",
  `has_debit_card` tinyint NULL COMMENT "Has debit card",
  `has_mortgage` tinyint NULL COMMENT "Has mortgage",
  `product_count` int NULL COMMENT "Product count",
  `credit_score` int NULL COMMENT "Credit score",
  `credit_grade` varchar(8) NULL COMMENT "Credit grade",
  `risk_level` tinyint NULL COMMENT "Risk level",
  `preferred_channel` varchar(16) NULL COMMENT "Preferred channel",
  `app_login_30d` int NULL COMMENT "App logins in last 30 days",
  `app_last_login` date NULL COMMENT "Last app login date",
  `active_level` varchar(16) NULL COMMENT "Activity level",
  `lifecycle_stage` varchar(32) NULL COMMENT "Lifecycle stage",
  `churn_prob` decimal(10,4) NULL COMMENT "Churn probability",
  `clv_score` decimal(20,4) NULL COMMENT "Customer lifetime value score",
  `log_tags` varchar(512) NULL COMMENT "AI log tags JSON",
  `anomaly_flag` tinyint NULL COMMENT "Anomaly flag",
  `created_at` datetime NULL COMMENT "Create time",
  `updated_at` datetime NULL COMMENT "Update time",
  `profile_attr_001` tinyint NULL COMMENT "Binary behavioral feature #001",
  `profile_attr_002` int NULL COMMENT "Numeric profile feature #002",
  `profile_attr_003` decimal(18,4) NULL COMMENT "Financial profile feature #003",
  `profile_attr_004` varchar(32) NULL COMMENT "Categorical profile feature #004",
  `profile_attr_005` date NULL COMMENT "Date profile feature #005",
  `profile_attr_006` varchar(64) NULL COMMENT "Text profile feature #006",
  `profile_attr_007` tinyint NULL COMMENT "Binary behavioral feature #007",
  `profile_attr_008` int NULL COMMENT "Numeric profile feature #008",
  `profile_attr_009` decimal(18,4) NULL COMMENT "Financial profile feature #009",
  `profile_attr_010` varchar(32) NULL COMMENT "Categorical profile feature #010",
  `profile_attr_011` date NULL COMMENT "Date profile feature #011",
  `profile_attr_012` varchar(64) NULL COMMENT "Text profile feature #012",
  `profile_attr_013` tinyint NULL COMMENT "Binary behavioral feature #013",
  `profile_attr_014` int NULL COMMENT "Numeric profile feature #014",
  `profile_attr_015` decimal(18,4) NULL COMMENT "Financial profile feature #015",
  `profile_attr_016` varchar(32) NULL COMMENT "Categorical profile feature #016",
  `profile_attr_017` date NULL COMMENT "Date profile feature #017",
  `profile_attr_018` varchar(64) NULL COMMENT "Text profile feature #018",
  `profile_attr_019` tinyint NULL COMMENT "Binary behavioral feature #019",
  `profile_attr_020` int NULL COMMENT "Numeric profile feature #020",
  `profile_attr_021` decimal(18,4) NULL COMMENT "Financial profile feature #021",
  `profile_attr_022` varchar(32) NULL COMMENT "Categorical profile feature #022",
  `profile_attr_023` date NULL COMMENT "Date profile feature #023",
  `profile_attr_024` varchar(64) NULL COMMENT "Text profile feature #024",
  `profile_attr_025` tinyint NULL COMMENT "Binary behavioral feature #025",
  `profile_attr_026` int NULL COMMENT "Numeric profile feature #026",
  `profile_attr_027` decimal(18,4) NULL COMMENT "Financial profile feature #027",
  `profile_attr_028` varchar(32) NULL COMMENT "Categorical profile feature #028",
  `profile_attr_029` date NULL COMMENT "Date profile feature #029",
  `profile_attr_030` varchar(64) NULL COMMENT "Text profile feature #030",
  `profile_attr_031` tinyint NULL COMMENT "Binary behavioral feature #031",
  `profile_attr_032` int NULL COMMENT "Numeric profile feature #032",
  `profile_attr_033` decimal(18,4) NULL COMMENT "Financial profile feature #033",
  `profile_attr_034` varchar(32) NULL COMMENT "Categorical profile feature #034",
  `profile_attr_035` date NULL COMMENT "Date profile feature #035",
  `profile_attr_036` varchar(64) NULL COMMENT "Text profile feature #036",
  `profile_attr_037` tinyint NULL COMMENT "Binary behavioral feature #037",
  `profile_attr_038` int NULL COMMENT "Numeric profile feature #038",
  `profile_attr_039` decimal(18,4) NULL COMMENT "Financial profile feature #039",
  `profile_attr_040` varchar(32) NULL COMMENT "Categorical profile feature #040",
  `profile_attr_041` date NULL COMMENT "Date profile feature #041",
  `profile_attr_042` varchar(64) NULL COMMENT "Text profile feature #042",
  `profile_attr_043` tinyint NULL COMMENT "Binary behavioral feature #043",
  `profile_attr_044` int NULL COMMENT "Numeric profile feature #044",
  `profile_attr_045` decimal(18,4) NULL COMMENT "Financial profile feature #045",
  `profile_attr_046` varchar(32) NULL COMMENT "Categorical profile feature #046",
  `profile_attr_047` date NULL COMMENT "Date profile feature #047",
  `profile_attr_048` varchar(64) NULL COMMENT "Text profile feature #048",
  `profile_attr_049` tinyint NULL COMMENT "Binary behavioral feature #049",
  `profile_attr_050` int NULL COMMENT "Numeric profile feature #050",
  `profile_attr_051` decimal(18,4) NULL COMMENT "Financial profile feature #051",
  `profile_attr_052` varchar(32) NULL COMMENT "Categorical profile feature #052",
  `profile_attr_053` date NULL COMMENT "Date profile feature #053",
  `profile_attr_054` varchar(64) NULL COMMENT "Text profile feature #054",
  `profile_attr_055` tinyint NULL COMMENT "Binary behavioral feature #055",
  `profile_attr_056` int NULL COMMENT "Numeric profile feature #056",
  `profile_attr_057` decimal(18,4) NULL COMMENT "Financial profile feature #057",
  `profile_attr_058` varchar(32) NULL COMMENT "Categorical profile feature #058",
  `profile_attr_059` date NULL COMMENT "Date profile feature #059",
  `profile_attr_060` varchar(64) NULL COMMENT "Text profile feature #060",
  `profile_attr_061` tinyint NULL COMMENT "Binary behavioral feature #061",
  `profile_attr_062` int NULL COMMENT "Numeric profile feature #062",
  `profile_attr_063` decimal(18,4) NULL COMMENT "Financial profile feature #063",
  `profile_attr_064` varchar(32) NULL COMMENT "Categorical profile feature #064",
  `profile_attr_065` date NULL COMMENT "Date profile feature #065",
  `profile_attr_066` varchar(64) NULL COMMENT "Text profile feature #066",
  `profile_attr_067` tinyint NULL COMMENT "Binary behavioral feature #067",
  `profile_attr_068` int NULL COMMENT "Numeric profile feature #068",
  `profile_attr_069` decimal(18,4) NULL COMMENT "Financial profile feature #069",
  `profile_attr_070` varchar(32) NULL COMMENT "Categorical profile feature #070",
  `profile_attr_071` date NULL COMMENT "Date profile feature #071",
  `profile_attr_072` varchar(64) NULL COMMENT "Text profile feature #072",
  `profile_attr_073` tinyint NULL COMMENT "Binary behavioral feature #073",
  `profile_attr_074` int NULL COMMENT "Numeric profile feature #074",
  `profile_attr_075` decimal(18,4) NULL COMMENT "Financial profile feature #075",
  `profile_attr_076` varchar(32) NULL COMMENT "Categorical profile feature #076",
  `profile_attr_077` date NULL COMMENT "Date profile feature #077",
  `profile_attr_078` varchar(64) NULL COMMENT "Text profile feature #078",
  `profile_attr_079` tinyint NULL COMMENT "Binary behavioral feature #079",
  `profile_attr_080` int NULL COMMENT "Numeric profile feature #080",
  `profile_attr_081` decimal(18,4) NULL COMMENT "Financial profile feature #081",
  `profile_attr_082` varchar(32) NULL COMMENT "Categorical profile feature #082",
  `profile_attr_083` date NULL COMMENT "Date profile feature #083",
  `profile_attr_084` varchar(64) NULL COMMENT "Text profile feature #084",
  `profile_attr_085` tinyint NULL COMMENT "Binary behavioral feature #085",
  `profile_attr_086` int NULL COMMENT "Numeric profile feature #086",
  `profile_attr_087` decimal(18,4) NULL COMMENT "Financial profile feature #087",
  `profile_attr_088` varchar(32) NULL COMMENT "Categorical profile feature #088",
  `profile_attr_089` date NULL COMMENT "Date profile feature #089",
  `profile_attr_090` varchar(64) NULL COMMENT "Text profile feature #090",
  `profile_attr_091` tinyint NULL COMMENT "Binary behavioral feature #091",
  `profile_attr_092` int NULL COMMENT "Numeric profile feature #092",
  `profile_attr_093` decimal(18,4) NULL COMMENT "Financial profile feature #093",
  `profile_attr_094` varchar(32) NULL COMMENT "Categorical profile feature #094",
  `profile_attr_095` date NULL COMMENT "Date profile feature #095",
  `profile_attr_096` varchar(64) NULL COMMENT "Text profile feature #096",
  `profile_attr_097` tinyint NULL COMMENT "Binary behavioral feature #097",
  `profile_attr_098` int NULL COMMENT "Numeric profile feature #098",
  `profile_attr_099` decimal(18,4) NULL COMMENT "Financial profile feature #099",
  `profile_attr_100` varchar(32) NULL COMMENT "Categorical profile feature #100",
  `profile_attr_101` date NULL COMMENT "Date profile feature #101",
  `profile_attr_102` varchar(64) NULL COMMENT "Text profile feature #102",
  `profile_attr_103` tinyint NULL COMMENT "Binary behavioral feature #103",
  `profile_attr_104` int NULL COMMENT "Numeric profile feature #104",
  `profile_attr_105` decimal(18,4) NULL COMMENT "Financial profile feature #105",
  `profile_attr_106` varchar(32) NULL COMMENT "Categorical profile feature #106",
  `profile_attr_107` date NULL COMMENT "Date profile feature #107",
  `profile_attr_108` varchar(64) NULL COMMENT "Text profile feature #108",
  `profile_attr_109` tinyint NULL COMMENT "Binary behavioral feature #109",
  `profile_attr_110` int NULL COMMENT "Numeric profile feature #110",
  `profile_attr_111` decimal(18,4) NULL COMMENT "Financial profile feature #111",
  `profile_attr_112` varchar(32) NULL COMMENT "Categorical profile feature #112",
  `profile_attr_113` date NULL COMMENT "Date profile feature #113",
  `profile_attr_114` varchar(64) NULL COMMENT "Text profile feature #114",
  `profile_attr_115` tinyint NULL COMMENT "Binary behavioral feature #115",
  `profile_attr_116` int NULL COMMENT "Numeric profile feature #116",
  `profile_attr_117` decimal(18,4) NULL COMMENT "Financial profile feature #117",
  `profile_attr_118` varchar(32) NULL COMMENT "Categorical profile feature #118",
  `profile_attr_119` date NULL COMMENT "Date profile feature #119",
  `profile_attr_120` varchar(64) NULL COMMENT "Text profile feature #120",
  `profile_attr_121` tinyint NULL COMMENT "Binary behavioral feature #121",
  `profile_attr_122` int NULL COMMENT "Numeric profile feature #122",
  `profile_attr_123` decimal(18,4) NULL COMMENT "Financial profile feature #123",
  `profile_attr_124` varchar(32) NULL COMMENT "Categorical profile feature #124",
  `profile_attr_125` date NULL COMMENT "Date profile feature #125",
  `profile_attr_126` varchar(64) NULL COMMENT "Text profile feature #126",
  `profile_attr_127` tinyint NULL COMMENT "Binary behavioral feature #127",
  `profile_attr_128` int NULL COMMENT "Numeric profile feature #128",
  `profile_attr_129` decimal(18,4) NULL COMMENT "Financial profile feature #129",
  `profile_attr_130` varchar(32) NULL COMMENT "Categorical profile feature #130",
  `profile_attr_131` date NULL COMMENT "Date profile feature #131",
  `profile_attr_132` varchar(64) NULL COMMENT "Text profile feature #132",
  `profile_attr_133` tinyint NULL COMMENT "Binary behavioral feature #133",
  `profile_attr_134` int NULL COMMENT "Numeric profile feature #134",
  `profile_attr_135` decimal(18,4) NULL COMMENT "Financial profile feature #135",
  `profile_attr_136` varchar(32) NULL COMMENT "Categorical profile feature #136",
  `profile_attr_137` date NULL COMMENT "Date profile feature #137",
  `profile_attr_138` varchar(64) NULL COMMENT "Text profile feature #138",
  `profile_attr_139` tinyint NULL COMMENT "Binary behavioral feature #139",
  `profile_attr_140` int NULL COMMENT "Numeric profile feature #140",
  `profile_attr_141` decimal(18,4) NULL COMMENT "Financial profile feature #141",
  `profile_attr_142` varchar(32) NULL COMMENT "Categorical profile feature #142",
  `profile_attr_143` date NULL COMMENT "Date profile feature #143",
  `profile_attr_144` varchar(64) NULL COMMENT "Text profile feature #144",
  `profile_attr_145` tinyint NULL COMMENT "Binary behavioral feature #145",
  `profile_attr_146` int NULL COMMENT "Numeric profile feature #146",
  `profile_attr_147` decimal(18,4) NULL COMMENT "Financial profile feature #147",
  `profile_attr_148` varchar(32) NULL COMMENT "Categorical profile feature #148",
  `profile_attr_149` date NULL COMMENT "Date profile feature #149",
  `profile_attr_150` varchar(64) NULL COMMENT "Text profile feature #150",
  `profile_attr_151` tinyint NULL COMMENT "Binary behavioral feature #151",
  `profile_attr_152` int NULL COMMENT "Numeric profile feature #152",
  `profile_attr_153` decimal(18,4) NULL COMMENT "Financial profile feature #153",
  `profile_attr_154` varchar(32) NULL COMMENT "Categorical profile feature #154",
  `profile_attr_155` date NULL COMMENT "Date profile feature #155",
  `profile_attr_156` varchar(64) NULL COMMENT "Text profile feature #156",
  `profile_attr_157` tinyint NULL COMMENT "Binary behavioral feature #157",
  `profile_attr_158` int NULL COMMENT "Numeric profile feature #158",
  `profile_attr_159` decimal(18,4) NULL COMMENT "Financial profile feature #159",
  `profile_attr_160` varchar(32) NULL COMMENT "Categorical profile feature #160",
  `profile_attr_161` date NULL COMMENT "Date profile feature #161",
  `profile_attr_162` varchar(64) NULL COMMENT "Text profile feature #162",
  `profile_attr_163` tinyint NULL COMMENT "Binary behavioral feature #163",
  `profile_attr_164` int NULL COMMENT "Numeric profile feature #164",
  `profile_attr_165` decimal(18,4) NULL COMMENT "Financial profile feature #165",
  `profile_attr_166` varchar(32) NULL COMMENT "Categorical profile feature #166",
  `profile_attr_167` date NULL COMMENT "Date profile feature #167",
  `profile_attr_168` varchar(64) NULL COMMENT "Text profile feature #168",
  `profile_attr_169` tinyint NULL COMMENT "Binary behavioral feature #169",
  `profile_attr_170` int NULL COMMENT "Numeric profile feature #170",
  `profile_attr_171` decimal(18,4) NULL COMMENT "Financial profile feature #171",
  `profile_attr_172` varchar(32) NULL COMMENT "Categorical profile feature #172",
  `profile_attr_173` date NULL COMMENT "Date profile feature #173",
  `profile_attr_174` varchar(64) NULL COMMENT "Text profile feature #174",
  `profile_attr_175` tinyint NULL COMMENT "Binary behavioral feature #175",
  `profile_attr_176` int NULL COMMENT "Numeric profile feature #176",
  `profile_attr_177` decimal(18,4) NULL COMMENT "Financial profile feature #177",
  `profile_attr_178` varchar(32) NULL COMMENT "Categorical profile feature #178",
  `profile_attr_179` date NULL COMMENT "Date profile feature #179",
  `profile_attr_180` varchar(64) NULL COMMENT "Text profile feature #180",
  `profile_attr_181` tinyint NULL COMMENT "Binary behavioral feature #181",
  `profile_attr_182` int NULL COMMENT "Numeric profile feature #182",
  `profile_attr_183` decimal(18,4) NULL COMMENT "Financial profile feature #183",
  `profile_attr_184` varchar(32) NULL COMMENT "Categorical profile feature #184",
  `profile_attr_185` date NULL COMMENT "Date profile feature #185",
  `profile_attr_186` varchar(64) NULL COMMENT "Text profile feature #186",
  `profile_attr_187` tinyint NULL COMMENT "Binary behavioral feature #187",
  `profile_attr_188` int NULL COMMENT "Numeric profile feature #188",
  `profile_attr_189` decimal(18,4) NULL COMMENT "Financial profile feature #189",
  `profile_attr_190` varchar(32) NULL COMMENT "Categorical profile feature #190",
  `profile_attr_191` date NULL COMMENT "Date profile feature #191",
  `profile_attr_192` varchar(64) NULL COMMENT "Text profile feature #192",
  `profile_attr_193` tinyint NULL COMMENT "Binary behavioral feature #193",
  `profile_attr_194` int NULL COMMENT "Numeric profile feature #194",
  `profile_attr_195` decimal(18,4) NULL COMMENT "Financial profile feature #195",
  `profile_attr_196` varchar(32) NULL COMMENT "Categorical profile feature #196",
  `profile_attr_197` date NULL COMMENT "Date profile feature #197",
  `profile_attr_198` varchar(64) NULL COMMENT "Text profile feature #198",
  `profile_attr_199` tinyint NULL COMMENT "Binary behavioral feature #199",
  `profile_attr_200` int NULL COMMENT "Numeric profile feature #200",
  `profile_attr_201` decimal(18,4) NULL COMMENT "Financial profile feature #201",
  `profile_attr_202` varchar(32) NULL COMMENT "Categorical profile feature #202",
  `profile_attr_203` date NULL COMMENT "Date profile feature #203",
  `profile_attr_204` varchar(64) NULL COMMENT "Text profile feature #204",
  `profile_attr_205` tinyint NULL COMMENT "Binary behavioral feature #205",
  `profile_attr_206` int NULL COMMENT "Numeric profile feature #206",
  `profile_attr_207` decimal(18,4) NULL COMMENT "Financial profile feature #207",
  `profile_attr_208` varchar(32) NULL COMMENT "Categorical profile feature #208",
  `profile_attr_209` date NULL COMMENT "Date profile feature #209",
  `profile_attr_210` varchar(64) NULL COMMENT "Text profile feature #210",
  `profile_attr_211` tinyint NULL COMMENT "Binary behavioral feature #211",
  `profile_attr_212` int NULL COMMENT "Numeric profile feature #212",
  `profile_attr_213` decimal(18,4) NULL COMMENT "Financial profile feature #213",
  `profile_attr_214` varchar(32) NULL COMMENT "Categorical profile feature #214",
  `profile_attr_215` date NULL COMMENT "Date profile feature #215",
  `profile_attr_216` varchar(64) NULL COMMENT "Text profile feature #216",
  `profile_attr_217` tinyint NULL COMMENT "Binary behavioral feature #217",
  `profile_attr_218` int NULL COMMENT "Numeric profile feature #218",
  `profile_attr_219` decimal(18,4) NULL COMMENT "Financial profile feature #219",
  `profile_attr_220` varchar(32) NULL COMMENT "Categorical profile feature #220",
  `profile_attr_221` date NULL COMMENT "Date profile feature #221",
  `profile_attr_222` varchar(64) NULL COMMENT "Text profile feature #222",
  `profile_attr_223` tinyint NULL COMMENT "Binary behavioral feature #223",
  `profile_attr_224` int NULL COMMENT "Numeric profile feature #224",
  `profile_attr_225` decimal(18,4) NULL COMMENT "Financial profile feature #225",
  `profile_attr_226` varchar(32) NULL COMMENT "Categorical profile feature #226",
  `profile_attr_227` date NULL COMMENT "Date profile feature #227",
  `profile_attr_228` varchar(64) NULL COMMENT "Text profile feature #228",
  `profile_attr_229` tinyint NULL COMMENT "Binary behavioral feature #229",
  `profile_attr_230` int NULL COMMENT "Numeric profile feature #230",
  `profile_attr_231` decimal(18,4) NULL COMMENT "Financial profile feature #231",
  `profile_attr_232` varchar(32) NULL COMMENT "Categorical profile feature #232",
  `profile_attr_233` date NULL COMMENT "Date profile feature #233",
  `profile_attr_234` varchar(64) NULL COMMENT "Text profile feature #234",
  `profile_attr_235` tinyint NULL COMMENT "Binary behavioral feature #235",
  `profile_attr_236` int NULL COMMENT "Numeric profile feature #236",
  `profile_attr_237` decimal(18,4) NULL COMMENT "Financial profile feature #237",
  `profile_attr_238` varchar(32) NULL COMMENT "Categorical profile feature #238",
  `profile_attr_239` date NULL COMMENT "Date profile feature #239",
  `profile_attr_240` varchar(64) NULL COMMENT "Text profile feature #240",
  `profile_attr_241` tinyint NULL COMMENT "Binary behavioral feature #241",
  `profile_attr_242` int NULL COMMENT "Numeric profile feature #242",
  `profile_attr_243` decimal(18,4) NULL COMMENT "Financial profile feature #243",
  `profile_attr_244` varchar(32) NULL COMMENT "Categorical profile feature #244",
  `profile_attr_245` date NULL COMMENT "Date profile feature #245",
  `profile_attr_246` varchar(64) NULL COMMENT "Text profile feature #246",
  `profile_attr_247` tinyint NULL COMMENT "Binary behavioral feature #247",
  `profile_attr_248` int NULL COMMENT "Numeric profile feature #248",
  `profile_attr_249` decimal(18,4) NULL COMMENT "Financial profile feature #249",
  `profile_attr_250` varchar(32) NULL COMMENT "Categorical profile feature #250",
  `profile_attr_251` date NULL COMMENT "Date profile feature #251",
  `profile_attr_252` varchar(64) NULL COMMENT "Text profile feature #252",
  `profile_attr_253` tinyint NULL COMMENT "Binary behavioral feature #253",
  `profile_attr_254` int NULL COMMENT "Numeric profile feature #254",
  `profile_attr_255` decimal(18,4) NULL COMMENT "Financial profile feature #255",
  `profile_attr_256` varchar(32) NULL COMMENT "Categorical profile feature #256",
  `profile_attr_257` date NULL COMMENT "Date profile feature #257",
  `profile_attr_258` varchar(64) NULL COMMENT "Text profile feature #258",
  `profile_attr_259` tinyint NULL COMMENT "Binary behavioral feature #259",
  `profile_attr_260` int NULL COMMENT "Numeric profile feature #260",
  `profile_attr_261` decimal(18,4) NULL COMMENT "Financial profile feature #261",
  `profile_attr_262` varchar(32) NULL COMMENT "Categorical profile feature #262",
  `profile_attr_263` date NULL COMMENT "Date profile feature #263",
  `profile_attr_264` varchar(64) NULL COMMENT "Text profile feature #264",
  `profile_attr_265` tinyint NULL COMMENT "Binary behavioral feature #265",
  `profile_attr_266` int NULL COMMENT "Numeric profile feature #266",
  `profile_attr_267` decimal(18,4) NULL COMMENT "Financial profile feature #267",
  `profile_attr_268` varchar(32) NULL COMMENT "Categorical profile feature #268",
  `profile_attr_269` date NULL COMMENT "Date profile feature #269",
  `profile_attr_270` varchar(64) NULL COMMENT "Text profile feature #270",
  `profile_attr_271` tinyint NULL COMMENT "Binary behavioral feature #271",
  `profile_attr_272` int NULL COMMENT "Numeric profile feature #272",
  `profile_attr_273` decimal(18,4) NULL COMMENT "Financial profile feature #273",
  `profile_attr_274` varchar(32) NULL COMMENT "Categorical profile feature #274",
  `profile_attr_275` date NULL COMMENT "Date profile feature #275",
  `profile_attr_276` varchar(64) NULL COMMENT "Text profile feature #276",
  `profile_attr_277` tinyint NULL COMMENT "Binary behavioral feature #277",
  `profile_attr_278` int NULL COMMENT "Numeric profile feature #278",
  `profile_attr_279` decimal(18,4) NULL COMMENT "Financial profile feature #279",
  `profile_attr_280` varchar(32) NULL COMMENT "Categorical profile feature #280",
  `profile_attr_281` date NULL COMMENT "Date profile feature #281",
  `profile_attr_282` varchar(64) NULL COMMENT "Text profile feature #282",
  `profile_attr_283` tinyint NULL COMMENT "Binary behavioral feature #283",
  `profile_attr_284` int NULL COMMENT "Numeric profile feature #284",
  `profile_attr_285` decimal(18,4) NULL COMMENT "Financial profile feature #285",
  `profile_attr_286` varchar(32) NULL COMMENT "Categorical profile feature #286",
  `profile_attr_287` date NULL COMMENT "Date profile feature #287",
  `profile_attr_288` varchar(64) NULL COMMENT "Text profile feature #288",
  `profile_attr_289` tinyint NULL COMMENT "Binary behavioral feature #289",
  `profile_attr_290` int NULL COMMENT "Numeric profile feature #290",
  `profile_attr_291` decimal(18,4) NULL COMMENT "Financial profile feature #291",
  `profile_attr_292` varchar(32) NULL COMMENT "Categorical profile feature #292",
  `profile_attr_293` date NULL COMMENT "Date profile feature #293",
  `profile_attr_294` varchar(64) NULL COMMENT "Text profile feature #294",
  `profile_attr_295` tinyint NULL COMMENT "Binary behavioral feature #295",
  `profile_attr_296` int NULL COMMENT "Numeric profile feature #296",
  `profile_attr_297` decimal(18,4) NULL COMMENT "Financial profile feature #297",
  `profile_attr_298` varchar(32) NULL COMMENT "Categorical profile feature #298",
  `profile_attr_299` date NULL COMMENT "Date profile feature #299",
  `profile_attr_300` varchar(64) NULL COMMENT "Text profile feature #300",
  `profile_attr_301` tinyint NULL COMMENT "Binary behavioral feature #301",
  `profile_attr_302` int NULL COMMENT "Numeric profile feature #302",
  `profile_attr_303` decimal(18,4) NULL COMMENT "Financial profile feature #303",
  `profile_attr_304` varchar(32) NULL COMMENT "Categorical profile feature #304",
  `profile_attr_305` date NULL COMMENT "Date profile feature #305",
  `profile_attr_306` varchar(64) NULL COMMENT "Text profile feature #306",
  `profile_attr_307` tinyint NULL COMMENT "Binary behavioral feature #307",
  `profile_attr_308` int NULL COMMENT "Numeric profile feature #308",
  `profile_attr_309` decimal(18,4) NULL COMMENT "Financial profile feature #309",
  `profile_attr_310` varchar(32) NULL COMMENT "Categorical profile feature #310",
  `profile_attr_311` date NULL COMMENT "Date profile feature #311",
  `profile_attr_312` varchar(64) NULL COMMENT "Text profile feature #312",
  `profile_attr_313` tinyint NULL COMMENT "Binary behavioral feature #313",
  `profile_attr_314` int NULL COMMENT "Numeric profile feature #314",
  `profile_attr_315` decimal(18,4) NULL COMMENT "Financial profile feature #315",
  `profile_attr_316` varchar(32) NULL COMMENT "Categorical profile feature #316",
  `profile_attr_317` date NULL COMMENT "Date profile feature #317",
  `profile_attr_318` varchar(64) NULL COMMENT "Text profile feature #318",
  `profile_attr_319` tinyint NULL COMMENT "Binary behavioral feature #319",
  `profile_attr_320` int NULL COMMENT "Numeric profile feature #320",
  `profile_attr_321` decimal(18,4) NULL COMMENT "Financial profile feature #321",
  `profile_attr_322` varchar(32) NULL COMMENT "Categorical profile feature #322",
  `profile_attr_323` date NULL COMMENT "Date profile feature #323",
  `profile_attr_324` varchar(64) NULL COMMENT "Text profile feature #324",
  `profile_attr_325` tinyint NULL COMMENT "Binary behavioral feature #325",
  `profile_attr_326` int NULL COMMENT "Numeric profile feature #326",
  `profile_attr_327` decimal(18,4) NULL COMMENT "Financial profile feature #327",
  `profile_attr_328` varchar(32) NULL COMMENT "Categorical profile feature #328",
  `profile_attr_329` date NULL COMMENT "Date profile feature #329",
  `profile_attr_330` varchar(64) NULL COMMENT "Text profile feature #330",
  `profile_attr_331` tinyint NULL COMMENT "Binary behavioral feature #331",
  `profile_attr_332` int NULL COMMENT "Numeric profile feature #332",
  `profile_attr_333` decimal(18,4) NULL COMMENT "Financial profile feature #333",
  `profile_attr_334` varchar(32) NULL COMMENT "Categorical profile feature #334",
  `profile_attr_335` date NULL COMMENT "Date profile feature #335",
  `profile_attr_336` varchar(64) NULL COMMENT "Text profile feature #336",
  `profile_attr_337` tinyint NULL COMMENT "Binary behavioral feature #337",
  `profile_attr_338` int NULL COMMENT "Numeric profile feature #338",
  `profile_attr_339` decimal(18,4) NULL COMMENT "Financial profile feature #339",
  `profile_attr_340` varchar(32) NULL COMMENT "Categorical profile feature #340",
  `profile_attr_341` date NULL COMMENT "Date profile feature #341",
  `profile_attr_342` varchar(64) NULL COMMENT "Text profile feature #342",
  `profile_attr_343` tinyint NULL COMMENT "Binary behavioral feature #343",
  `profile_attr_344` int NULL COMMENT "Numeric profile feature #344",
  `profile_attr_345` decimal(18,4) NULL COMMENT "Financial profile feature #345",
  `profile_attr_346` varchar(32) NULL COMMENT "Categorical profile feature #346",
  `profile_attr_347` date NULL COMMENT "Date profile feature #347",
  `profile_attr_348` varchar(64) NULL COMMENT "Text profile feature #348",
  `profile_attr_349` tinyint NULL COMMENT "Binary behavioral feature #349",
  `profile_attr_350` int NULL COMMENT "Numeric profile feature #350",
  `profile_attr_351` decimal(18,4) NULL COMMENT "Financial profile feature #351",
  `profile_attr_352` varchar(32) NULL COMMENT "Categorical profile feature #352",
  `profile_attr_353` date NULL COMMENT "Date profile feature #353",
  `profile_attr_354` varchar(64) NULL COMMENT "Text profile feature #354",
  `profile_attr_355` tinyint NULL COMMENT "Binary behavioral feature #355",
  `profile_attr_356` int NULL COMMENT "Numeric profile feature #356",
  `profile_attr_357` decimal(18,4) NULL COMMENT "Financial profile feature #357",
  `profile_attr_358` varchar(32) NULL COMMENT "Categorical profile feature #358",
  `profile_attr_359` date NULL COMMENT "Date profile feature #359",
  `profile_attr_360` varchar(64) NULL COMMENT "Text profile feature #360",
  `profile_attr_361` tinyint NULL COMMENT "Binary behavioral feature #361",
  `profile_attr_362` int NULL COMMENT "Numeric profile feature #362",
  `profile_attr_363` decimal(18,4) NULL COMMENT "Financial profile feature #363",
  `profile_attr_364` varchar(32) NULL COMMENT "Categorical profile feature #364",
  `profile_attr_365` date NULL COMMENT "Date profile feature #365",
  `profile_attr_366` varchar(64) NULL COMMENT "Text profile feature #366",
  `profile_attr_367` tinyint NULL COMMENT "Binary behavioral feature #367",
  `profile_attr_368` int NULL COMMENT "Numeric profile feature #368",
  `profile_attr_369` decimal(18,4) NULL COMMENT "Financial profile feature #369",
  `profile_attr_370` varchar(32) NULL COMMENT "Categorical profile feature #370",
  `profile_attr_371` date NULL COMMENT "Date profile feature #371",
  `profile_attr_372` varchar(64) NULL COMMENT "Text profile feature #372",
  `profile_attr_373` tinyint NULL COMMENT "Binary behavioral feature #373",
  `profile_attr_374` int NULL COMMENT "Numeric profile feature #374",
  `profile_attr_375` decimal(18,4) NULL COMMENT "Financial profile feature #375",
  `profile_attr_376` varchar(32) NULL COMMENT "Categorical profile feature #376",
  `profile_attr_377` date NULL COMMENT "Date profile feature #377",
  `profile_attr_378` varchar(64) NULL COMMENT "Text profile feature #378",
  `profile_attr_379` tinyint NULL COMMENT "Binary behavioral feature #379",
  `profile_attr_380` int NULL COMMENT "Numeric profile feature #380",
  `profile_attr_381` decimal(18,4) NULL COMMENT "Financial profile feature #381",
  `profile_attr_382` varchar(32) NULL COMMENT "Categorical profile feature #382",
  `profile_attr_383` date NULL COMMENT "Date profile feature #383",
  `profile_attr_384` varchar(64) NULL COMMENT "Text profile feature #384",
  `profile_attr_385` tinyint NULL COMMENT "Binary behavioral feature #385",
  `profile_attr_386` int NULL COMMENT "Numeric profile feature #386",
  `profile_attr_387` decimal(18,4) NULL COMMENT "Financial profile feature #387",
  `profile_attr_388` varchar(32) NULL COMMENT "Categorical profile feature #388",
  `profile_attr_389` date NULL COMMENT "Date profile feature #389",
  `profile_attr_390` varchar(64) NULL COMMENT "Text profile feature #390",
  `profile_attr_391` tinyint NULL COMMENT "Binary behavioral feature #391",
  `profile_attr_392` int NULL COMMENT "Numeric profile feature #392",
  `profile_attr_393` decimal(18,4) NULL COMMENT "Financial profile feature #393",
  `profile_attr_394` varchar(32) NULL COMMENT "Categorical profile feature #394",
  `profile_attr_395` date NULL COMMENT "Date profile feature #395",
  `profile_attr_396` varchar(64) NULL COMMENT "Text profile feature #396",
  `profile_attr_397` tinyint NULL COMMENT "Binary behavioral feature #397",
  `profile_attr_398` int NULL COMMENT "Numeric profile feature #398",
  `profile_attr_399` decimal(18,4) NULL COMMENT "Financial profile feature #399",
  `profile_attr_400` varchar(32) NULL COMMENT "Categorical profile feature #400",
  `profile_attr_401` date NULL COMMENT "Date profile feature #401",
  `profile_attr_402` varchar(64) NULL COMMENT "Text profile feature #402",
  `profile_attr_403` tinyint NULL COMMENT "Binary behavioral feature #403",
  `profile_attr_404` int NULL COMMENT "Numeric profile feature #404",
  `profile_attr_405` decimal(18,4) NULL COMMENT "Financial profile feature #405",
  `profile_attr_406` varchar(32) NULL COMMENT "Categorical profile feature #406",
  `profile_attr_407` date NULL COMMENT "Date profile feature #407",
  `profile_attr_408` varchar(64) NULL COMMENT "Text profile feature #408",
  `profile_attr_409` tinyint NULL COMMENT "Binary behavioral feature #409",
  `profile_attr_410` int NULL COMMENT "Numeric profile feature #410",
  `profile_attr_411` decimal(18,4) NULL COMMENT "Financial profile feature #411",
  `profile_attr_412` varchar(32) NULL COMMENT "Categorical profile feature #412",
  `profile_attr_413` date NULL COMMENT "Date profile feature #413",
  `profile_attr_414` varchar(64) NULL COMMENT "Text profile feature #414",
  `profile_attr_415` tinyint NULL COMMENT "Binary behavioral feature #415",
  `profile_attr_416` int NULL COMMENT "Numeric profile feature #416",
  `profile_attr_417` decimal(18,4) NULL COMMENT "Financial profile feature #417",
  `profile_attr_418` varchar(32) NULL COMMENT "Categorical profile feature #418",
  `profile_attr_419` date NULL COMMENT "Date profile feature #419",
  `profile_attr_420` varchar(64) NULL COMMENT "Text profile feature #420",
  `profile_attr_421` tinyint NULL COMMENT "Binary behavioral feature #421",
  `profile_attr_422` int NULL COMMENT "Numeric profile feature #422",
  `profile_attr_423` decimal(18,4) NULL COMMENT "Financial profile feature #423",
  `profile_attr_424` varchar(32) NULL COMMENT "Categorical profile feature #424",
  `profile_attr_425` date NULL COMMENT "Date profile feature #425",
  `profile_attr_426` varchar(64) NULL COMMENT "Text profile feature #426",
  `profile_attr_427` tinyint NULL COMMENT "Binary behavioral feature #427",
  `profile_attr_428` int NULL COMMENT "Numeric profile feature #428",
  `profile_attr_429` decimal(18,4) NULL COMMENT "Financial profile feature #429",
  `profile_attr_430` varchar(32) NULL COMMENT "Categorical profile feature #430",
  `profile_attr_431` date NULL COMMENT "Date profile feature #431",
  `profile_attr_432` varchar(64) NULL COMMENT "Text profile feature #432",
  `profile_attr_433` tinyint NULL COMMENT "Binary behavioral feature #433",
  `profile_attr_434` int NULL COMMENT "Numeric profile feature #434",
  `profile_attr_435` decimal(18,4) NULL COMMENT "Financial profile feature #435",
  `profile_attr_436` varchar(32) NULL COMMENT "Categorical profile feature #436",
  `profile_attr_437` date NULL COMMENT "Date profile feature #437",
  `profile_attr_438` varchar(64) NULL COMMENT "Text profile feature #438",
  `profile_attr_439` tinyint NULL COMMENT "Binary behavioral feature #439",
  `profile_attr_440` int NULL COMMENT "Numeric profile feature #440",
  `profile_attr_441` decimal(18,4) NULL COMMENT "Financial profile feature #441",
  `profile_attr_442` varchar(32) NULL COMMENT "Categorical profile feature #442",
  `profile_attr_443` date NULL COMMENT "Date profile feature #443",
  `profile_attr_444` varchar(64) NULL COMMENT "Text profile feature #444",
  `profile_attr_445` tinyint NULL COMMENT "Binary behavioral feature #445",
  `profile_attr_446` int NULL COMMENT "Numeric profile feature #446",
  `profile_attr_447` decimal(18,4) NULL COMMENT "Financial profile feature #447",
  `profile_attr_448` varchar(32) NULL COMMENT "Categorical profile feature #448",
  `profile_attr_449` date NULL COMMENT "Date profile feature #449",
  `profile_attr_450` varchar(64) NULL COMMENT "Text profile feature #450",
  `profile_attr_451` tinyint NULL COMMENT "Binary behavioral feature #451",
  `profile_attr_452` int NULL COMMENT "Numeric profile feature #452",
  `profile_attr_453` decimal(18,4) NULL COMMENT "Financial profile feature #453",
  `profile_attr_454` varchar(32) NULL COMMENT "Categorical profile feature #454",
  `profile_attr_455` date NULL COMMENT "Date profile feature #455",
  `profile_attr_456` varchar(64) NULL COMMENT "Text profile feature #456",
  `profile_attr_457` tinyint NULL COMMENT "Binary behavioral feature #457",
  `profile_attr_458` int NULL COMMENT "Numeric profile feature #458",
  `profile_attr_459` decimal(18,4) NULL COMMENT "Financial profile feature #459",
  `profile_attr_460` varchar(32) NULL COMMENT "Categorical profile feature #460",
  `profile_attr_461` date NULL COMMENT "Date profile feature #461",
  `profile_attr_462` varchar(64) NULL COMMENT "Text profile feature #462"
) ENGINE=OLAP
UNIQUE KEY(`user_id`, `update_date`)
COMMENT 'User wide table - 500-column CDP core profile table'
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
DROP TABLE IF EXISTS `user_wide_point_query`;
CREATE TABLE IF NOT EXISTS `user_wide_point_query` (
  `user_id` bigint NOT NULL COMMENT "User unique id",
  `update_date` date NOT NULL COMMENT "Data update date",
  `user_name` varchar(64) NULL COMMENT "Masked user name",
  `id_card` varchar(32) NULL COMMENT "Masked identity number",
  `phone` varchar(20) NULL COMMENT "Masked mobile number",
  `gender` tinyint NULL COMMENT "Gender: 1 male, 2 female, 0 unknown",
  `age` int NULL COMMENT "Age",
  `age_group` varchar(16) NULL COMMENT "Age group",
  `city` varchar(32) NULL COMMENT "City",
  `province` varchar(32) NULL COMMENT "Province",
  `education` tinyint NULL COMMENT "Education level",
  `occupation` varchar(32) NULL COMMENT "Occupation",
  `register_date` date NULL COMMENT "Registration date",
  `asset_level` varchar(24) NULL COMMENT "Asset level",
  `aum_total` decimal(20,4) NULL COMMENT "Total AUM in 10k CNY",
  `deposit_amount` decimal(20,4) NULL COMMENT "Deposit balance in 10k CNY",
  `fund_amount` decimal(20,4) NULL COMMENT "Fund holding in 10k CNY",
  `loan_amount` decimal(20,4) NULL COMMENT "Loan balance in 10k CNY",
  `wm_amount` decimal(20,4) NULL COMMENT "Wealth management balance in 10k CNY",
  `insurance_amount` decimal(20,4) NULL COMMENT "Insurance premium in 10k CNY",
  `has_credit_card` tinyint NULL COMMENT "Has credit card",
  `has_debit_card` tinyint NULL COMMENT "Has debit card",
  `has_mortgage` tinyint NULL COMMENT "Has mortgage",
  `product_count` int NULL COMMENT "Product count",
  `credit_score` int NULL COMMENT "Credit score",
  `credit_grade` varchar(8) NULL COMMENT "Credit grade",
  `risk_level` tinyint NULL COMMENT "Risk level",
  `preferred_channel` varchar(16) NULL COMMENT "Preferred channel",
  `app_login_30d` int NULL COMMENT "App logins in last 30 days",
  `app_last_login` date NULL COMMENT "Last app login date",
  `active_level` varchar(16) NULL COMMENT "Activity level",
  `lifecycle_stage` varchar(32) NULL COMMENT "Lifecycle stage",
  `churn_prob` decimal(10,4) NULL COMMENT "Churn probability",
  `clv_score` decimal(20,4) NULL COMMENT "Customer lifetime value score",
  `log_tags` varchar(512) NULL COMMENT "AI log tags JSON",
  `anomaly_flag` tinyint NULL COMMENT "Anomaly flag",
  `created_at` datetime NULL COMMENT "Create time",
  `updated_at` datetime NULL COMMENT "Update time",
  `profile_attr_001` tinyint NULL COMMENT "Binary behavioral feature #001",
  `profile_attr_002` int NULL COMMENT "Numeric profile feature #002",
  `profile_attr_003` decimal(18,4) NULL COMMENT "Financial profile feature #003",
  `profile_attr_004` varchar(32) NULL COMMENT "Categorical profile feature #004",
  `profile_attr_005` date NULL COMMENT "Date profile feature #005",
  `profile_attr_006` varchar(64) NULL COMMENT "Text profile feature #006",
  `profile_attr_007` tinyint NULL COMMENT "Binary behavioral feature #007",
  `profile_attr_008` int NULL COMMENT "Numeric profile feature #008",
  `profile_attr_009` decimal(18,4) NULL COMMENT "Financial profile feature #009",
  `profile_attr_010` varchar(32) NULL COMMENT "Categorical profile feature #010",
  `profile_attr_011` date NULL COMMENT "Date profile feature #011",
  `profile_attr_012` varchar(64) NULL COMMENT "Text profile feature #012",
  `profile_attr_013` tinyint NULL COMMENT "Binary behavioral feature #013",
  `profile_attr_014` int NULL COMMENT "Numeric profile feature #014",
  `profile_attr_015` decimal(18,4) NULL COMMENT "Financial profile feature #015",
  `profile_attr_016` varchar(32) NULL COMMENT "Categorical profile feature #016",
  `profile_attr_017` date NULL COMMENT "Date profile feature #017",
  `profile_attr_018` varchar(64) NULL COMMENT "Text profile feature #018",
  `profile_attr_019` tinyint NULL COMMENT "Binary behavioral feature #019",
  `profile_attr_020` int NULL COMMENT "Numeric profile feature #020",
  `profile_attr_021` decimal(18,4) NULL COMMENT "Financial profile feature #021",
  `profile_attr_022` varchar(32) NULL COMMENT "Categorical profile feature #022",
  `profile_attr_023` date NULL COMMENT "Date profile feature #023",
  `profile_attr_024` varchar(64) NULL COMMENT "Text profile feature #024",
  `profile_attr_025` tinyint NULL COMMENT "Binary behavioral feature #025",
  `profile_attr_026` int NULL COMMENT "Numeric profile feature #026",
  `profile_attr_027` decimal(18,4) NULL COMMENT "Financial profile feature #027",
  `profile_attr_028` varchar(32) NULL COMMENT "Categorical profile feature #028",
  `profile_attr_029` date NULL COMMENT "Date profile feature #029",
  `profile_attr_030` varchar(64) NULL COMMENT "Text profile feature #030",
  `profile_attr_031` tinyint NULL COMMENT "Binary behavioral feature #031",
  `profile_attr_032` int NULL COMMENT "Numeric profile feature #032",
  `profile_attr_033` decimal(18,4) NULL COMMENT "Financial profile feature #033",
  `profile_attr_034` varchar(32) NULL COMMENT "Categorical profile feature #034",
  `profile_attr_035` date NULL COMMENT "Date profile feature #035",
  `profile_attr_036` varchar(64) NULL COMMENT "Text profile feature #036",
  `profile_attr_037` tinyint NULL COMMENT "Binary behavioral feature #037",
  `profile_attr_038` int NULL COMMENT "Numeric profile feature #038",
  `profile_attr_039` decimal(18,4) NULL COMMENT "Financial profile feature #039",
  `profile_attr_040` varchar(32) NULL COMMENT "Categorical profile feature #040",
  `profile_attr_041` date NULL COMMENT "Date profile feature #041",
  `profile_attr_042` varchar(64) NULL COMMENT "Text profile feature #042",
  `profile_attr_043` tinyint NULL COMMENT "Binary behavioral feature #043",
  `profile_attr_044` int NULL COMMENT "Numeric profile feature #044",
  `profile_attr_045` decimal(18,4) NULL COMMENT "Financial profile feature #045",
  `profile_attr_046` varchar(32) NULL COMMENT "Categorical profile feature #046",
  `profile_attr_047` date NULL COMMENT "Date profile feature #047",
  `profile_attr_048` varchar(64) NULL COMMENT "Text profile feature #048",
  `profile_attr_049` tinyint NULL COMMENT "Binary behavioral feature #049",
  `profile_attr_050` int NULL COMMENT "Numeric profile feature #050",
  `profile_attr_051` decimal(18,4) NULL COMMENT "Financial profile feature #051",
  `profile_attr_052` varchar(32) NULL COMMENT "Categorical profile feature #052",
  `profile_attr_053` date NULL COMMENT "Date profile feature #053",
  `profile_attr_054` varchar(64) NULL COMMENT "Text profile feature #054",
  `profile_attr_055` tinyint NULL COMMENT "Binary behavioral feature #055",
  `profile_attr_056` int NULL COMMENT "Numeric profile feature #056",
  `profile_attr_057` decimal(18,4) NULL COMMENT "Financial profile feature #057",
  `profile_attr_058` varchar(32) NULL COMMENT "Categorical profile feature #058",
  `profile_attr_059` date NULL COMMENT "Date profile feature #059",
  `profile_attr_060` varchar(64) NULL COMMENT "Text profile feature #060",
  `profile_attr_061` tinyint NULL COMMENT "Binary behavioral feature #061",
  `profile_attr_062` int NULL COMMENT "Numeric profile feature #062",
  `profile_attr_063` decimal(18,4) NULL COMMENT "Financial profile feature #063",
  `profile_attr_064` varchar(32) NULL COMMENT "Categorical profile feature #064",
  `profile_attr_065` date NULL COMMENT "Date profile feature #065",
  `profile_attr_066` varchar(64) NULL COMMENT "Text profile feature #066",
  `profile_attr_067` tinyint NULL COMMENT "Binary behavioral feature #067",
  `profile_attr_068` int NULL COMMENT "Numeric profile feature #068",
  `profile_attr_069` decimal(18,4) NULL COMMENT "Financial profile feature #069",
  `profile_attr_070` varchar(32) NULL COMMENT "Categorical profile feature #070",
  `profile_attr_071` date NULL COMMENT "Date profile feature #071",
  `profile_attr_072` varchar(64) NULL COMMENT "Text profile feature #072",
  `profile_attr_073` tinyint NULL COMMENT "Binary behavioral feature #073",
  `profile_attr_074` int NULL COMMENT "Numeric profile feature #074",
  `profile_attr_075` decimal(18,4) NULL COMMENT "Financial profile feature #075",
  `profile_attr_076` varchar(32) NULL COMMENT "Categorical profile feature #076",
  `profile_attr_077` date NULL COMMENT "Date profile feature #077",
  `profile_attr_078` varchar(64) NULL COMMENT "Text profile feature #078",
  `profile_attr_079` tinyint NULL COMMENT "Binary behavioral feature #079",
  `profile_attr_080` int NULL COMMENT "Numeric profile feature #080",
  `profile_attr_081` decimal(18,4) NULL COMMENT "Financial profile feature #081",
  `profile_attr_082` varchar(32) NULL COMMENT "Categorical profile feature #082",
  `profile_attr_083` date NULL COMMENT "Date profile feature #083",
  `profile_attr_084` varchar(64) NULL COMMENT "Text profile feature #084",
  `profile_attr_085` tinyint NULL COMMENT "Binary behavioral feature #085",
  `profile_attr_086` int NULL COMMENT "Numeric profile feature #086",
  `profile_attr_087` decimal(18,4) NULL COMMENT "Financial profile feature #087",
  `profile_attr_088` varchar(32) NULL COMMENT "Categorical profile feature #088",
  `profile_attr_089` date NULL COMMENT "Date profile feature #089",
  `profile_attr_090` varchar(64) NULL COMMENT "Text profile feature #090",
  `profile_attr_091` tinyint NULL COMMENT "Binary behavioral feature #091",
  `profile_attr_092` int NULL COMMENT "Numeric profile feature #092",
  `profile_attr_093` decimal(18,4) NULL COMMENT "Financial profile feature #093",
  `profile_attr_094` varchar(32) NULL COMMENT "Categorical profile feature #094",
  `profile_attr_095` date NULL COMMENT "Date profile feature #095",
  `profile_attr_096` varchar(64) NULL COMMENT "Text profile feature #096",
  `profile_attr_097` tinyint NULL COMMENT "Binary behavioral feature #097",
  `profile_attr_098` int NULL COMMENT "Numeric profile feature #098",
  `profile_attr_099` decimal(18,4) NULL COMMENT "Financial profile feature #099",
  `profile_attr_100` varchar(32) NULL COMMENT "Categorical profile feature #100",
  `profile_attr_101` date NULL COMMENT "Date profile feature #101",
  `profile_attr_102` varchar(64) NULL COMMENT "Text profile feature #102",
  `profile_attr_103` tinyint NULL COMMENT "Binary behavioral feature #103",
  `profile_attr_104` int NULL COMMENT "Numeric profile feature #104",
  `profile_attr_105` decimal(18,4) NULL COMMENT "Financial profile feature #105",
  `profile_attr_106` varchar(32) NULL COMMENT "Categorical profile feature #106",
  `profile_attr_107` date NULL COMMENT "Date profile feature #107",
  `profile_attr_108` varchar(64) NULL COMMENT "Text profile feature #108",
  `profile_attr_109` tinyint NULL COMMENT "Binary behavioral feature #109",
  `profile_attr_110` int NULL COMMENT "Numeric profile feature #110",
  `profile_attr_111` decimal(18,4) NULL COMMENT "Financial profile feature #111",
  `profile_attr_112` varchar(32) NULL COMMENT "Categorical profile feature #112",
  `profile_attr_113` date NULL COMMENT "Date profile feature #113",
  `profile_attr_114` varchar(64) NULL COMMENT "Text profile feature #114",
  `profile_attr_115` tinyint NULL COMMENT "Binary behavioral feature #115",
  `profile_attr_116` int NULL COMMENT "Numeric profile feature #116",
  `profile_attr_117` decimal(18,4) NULL COMMENT "Financial profile feature #117",
  `profile_attr_118` varchar(32) NULL COMMENT "Categorical profile feature #118",
  `profile_attr_119` date NULL COMMENT "Date profile feature #119",
  `profile_attr_120` varchar(64) NULL COMMENT "Text profile feature #120",
  `profile_attr_121` tinyint NULL COMMENT "Binary behavioral feature #121",
  `profile_attr_122` int NULL COMMENT "Numeric profile feature #122",
  `profile_attr_123` decimal(18,4) NULL COMMENT "Financial profile feature #123",
  `profile_attr_124` varchar(32) NULL COMMENT "Categorical profile feature #124",
  `profile_attr_125` date NULL COMMENT "Date profile feature #125",
  `profile_attr_126` varchar(64) NULL COMMENT "Text profile feature #126",
  `profile_attr_127` tinyint NULL COMMENT "Binary behavioral feature #127",
  `profile_attr_128` int NULL COMMENT "Numeric profile feature #128",
  `profile_attr_129` decimal(18,4) NULL COMMENT "Financial profile feature #129",
  `profile_attr_130` varchar(32) NULL COMMENT "Categorical profile feature #130",
  `profile_attr_131` date NULL COMMENT "Date profile feature #131",
  `profile_attr_132` varchar(64) NULL COMMENT "Text profile feature #132",
  `profile_attr_133` tinyint NULL COMMENT "Binary behavioral feature #133",
  `profile_attr_134` int NULL COMMENT "Numeric profile feature #134",
  `profile_attr_135` decimal(18,4) NULL COMMENT "Financial profile feature #135",
  `profile_attr_136` varchar(32) NULL COMMENT "Categorical profile feature #136",
  `profile_attr_137` date NULL COMMENT "Date profile feature #137",
  `profile_attr_138` varchar(64) NULL COMMENT "Text profile feature #138",
  `profile_attr_139` tinyint NULL COMMENT "Binary behavioral feature #139",
  `profile_attr_140` int NULL COMMENT "Numeric profile feature #140",
  `profile_attr_141` decimal(18,4) NULL COMMENT "Financial profile feature #141",
  `profile_attr_142` varchar(32) NULL COMMENT "Categorical profile feature #142",
  `profile_attr_143` date NULL COMMENT "Date profile feature #143",
  `profile_attr_144` varchar(64) NULL COMMENT "Text profile feature #144",
  `profile_attr_145` tinyint NULL COMMENT "Binary behavioral feature #145",
  `profile_attr_146` int NULL COMMENT "Numeric profile feature #146",
  `profile_attr_147` decimal(18,4) NULL COMMENT "Financial profile feature #147",
  `profile_attr_148` varchar(32) NULL COMMENT "Categorical profile feature #148",
  `profile_attr_149` date NULL COMMENT "Date profile feature #149",
  `profile_attr_150` varchar(64) NULL COMMENT "Text profile feature #150",
  `profile_attr_151` tinyint NULL COMMENT "Binary behavioral feature #151",
  `profile_attr_152` int NULL COMMENT "Numeric profile feature #152",
  `profile_attr_153` decimal(18,4) NULL COMMENT "Financial profile feature #153",
  `profile_attr_154` varchar(32) NULL COMMENT "Categorical profile feature #154",
  `profile_attr_155` date NULL COMMENT "Date profile feature #155",
  `profile_attr_156` varchar(64) NULL COMMENT "Text profile feature #156",
  `profile_attr_157` tinyint NULL COMMENT "Binary behavioral feature #157",
  `profile_attr_158` int NULL COMMENT "Numeric profile feature #158",
  `profile_attr_159` decimal(18,4) NULL COMMENT "Financial profile feature #159",
  `profile_attr_160` varchar(32) NULL COMMENT "Categorical profile feature #160",
  `profile_attr_161` date NULL COMMENT "Date profile feature #161",
  `profile_attr_162` varchar(64) NULL COMMENT "Text profile feature #162",
  `profile_attr_163` tinyint NULL COMMENT "Binary behavioral feature #163",
  `profile_attr_164` int NULL COMMENT "Numeric profile feature #164",
  `profile_attr_165` decimal(18,4) NULL COMMENT "Financial profile feature #165",
  `profile_attr_166` varchar(32) NULL COMMENT "Categorical profile feature #166",
  `profile_attr_167` date NULL COMMENT "Date profile feature #167",
  `profile_attr_168` varchar(64) NULL COMMENT "Text profile feature #168",
  `profile_attr_169` tinyint NULL COMMENT "Binary behavioral feature #169",
  `profile_attr_170` int NULL COMMENT "Numeric profile feature #170",
  `profile_attr_171` decimal(18,4) NULL COMMENT "Financial profile feature #171",
  `profile_attr_172` varchar(32) NULL COMMENT "Categorical profile feature #172",
  `profile_attr_173` date NULL COMMENT "Date profile feature #173",
  `profile_attr_174` varchar(64) NULL COMMENT "Text profile feature #174",
  `profile_attr_175` tinyint NULL COMMENT "Binary behavioral feature #175",
  `profile_attr_176` int NULL COMMENT "Numeric profile feature #176",
  `profile_attr_177` decimal(18,4) NULL COMMENT "Financial profile feature #177",
  `profile_attr_178` varchar(32) NULL COMMENT "Categorical profile feature #178",
  `profile_attr_179` date NULL COMMENT "Date profile feature #179",
  `profile_attr_180` varchar(64) NULL COMMENT "Text profile feature #180",
  `profile_attr_181` tinyint NULL COMMENT "Binary behavioral feature #181",
  `profile_attr_182` int NULL COMMENT "Numeric profile feature #182",
  `profile_attr_183` decimal(18,4) NULL COMMENT "Financial profile feature #183",
  `profile_attr_184` varchar(32) NULL COMMENT "Categorical profile feature #184",
  `profile_attr_185` date NULL COMMENT "Date profile feature #185",
  `profile_attr_186` varchar(64) NULL COMMENT "Text profile feature #186",
  `profile_attr_187` tinyint NULL COMMENT "Binary behavioral feature #187",
  `profile_attr_188` int NULL COMMENT "Numeric profile feature #188",
  `profile_attr_189` decimal(18,4) NULL COMMENT "Financial profile feature #189",
  `profile_attr_190` varchar(32) NULL COMMENT "Categorical profile feature #190",
  `profile_attr_191` date NULL COMMENT "Date profile feature #191",
  `profile_attr_192` varchar(64) NULL COMMENT "Text profile feature #192",
  `profile_attr_193` tinyint NULL COMMENT "Binary behavioral feature #193",
  `profile_attr_194` int NULL COMMENT "Numeric profile feature #194",
  `profile_attr_195` decimal(18,4) NULL COMMENT "Financial profile feature #195",
  `profile_attr_196` varchar(32) NULL COMMENT "Categorical profile feature #196",
  `profile_attr_197` date NULL COMMENT "Date profile feature #197",
  `profile_attr_198` varchar(64) NULL COMMENT "Text profile feature #198",
  `profile_attr_199` tinyint NULL COMMENT "Binary behavioral feature #199",
  `profile_attr_200` int NULL COMMENT "Numeric profile feature #200",
  `profile_attr_201` decimal(18,4) NULL COMMENT "Financial profile feature #201",
  `profile_attr_202` varchar(32) NULL COMMENT "Categorical profile feature #202",
  `profile_attr_203` date NULL COMMENT "Date profile feature #203",
  `profile_attr_204` varchar(64) NULL COMMENT "Text profile feature #204",
  `profile_attr_205` tinyint NULL COMMENT "Binary behavioral feature #205",
  `profile_attr_206` int NULL COMMENT "Numeric profile feature #206",
  `profile_attr_207` decimal(18,4) NULL COMMENT "Financial profile feature #207",
  `profile_attr_208` varchar(32) NULL COMMENT "Categorical profile feature #208",
  `profile_attr_209` date NULL COMMENT "Date profile feature #209",
  `profile_attr_210` varchar(64) NULL COMMENT "Text profile feature #210",
  `profile_attr_211` tinyint NULL COMMENT "Binary behavioral feature #211",
  `profile_attr_212` int NULL COMMENT "Numeric profile feature #212",
  `profile_attr_213` decimal(18,4) NULL COMMENT "Financial profile feature #213",
  `profile_attr_214` varchar(32) NULL COMMENT "Categorical profile feature #214",
  `profile_attr_215` date NULL COMMENT "Date profile feature #215",
  `profile_attr_216` varchar(64) NULL COMMENT "Text profile feature #216",
  `profile_attr_217` tinyint NULL COMMENT "Binary behavioral feature #217",
  `profile_attr_218` int NULL COMMENT "Numeric profile feature #218",
  `profile_attr_219` decimal(18,4) NULL COMMENT "Financial profile feature #219",
  `profile_attr_220` varchar(32) NULL COMMENT "Categorical profile feature #220",
  `profile_attr_221` date NULL COMMENT "Date profile feature #221",
  `profile_attr_222` varchar(64) NULL COMMENT "Text profile feature #222",
  `profile_attr_223` tinyint NULL COMMENT "Binary behavioral feature #223",
  `profile_attr_224` int NULL COMMENT "Numeric profile feature #224",
  `profile_attr_225` decimal(18,4) NULL COMMENT "Financial profile feature #225",
  `profile_attr_226` varchar(32) NULL COMMENT "Categorical profile feature #226",
  `profile_attr_227` date NULL COMMENT "Date profile feature #227",
  `profile_attr_228` varchar(64) NULL COMMENT "Text profile feature #228",
  `profile_attr_229` tinyint NULL COMMENT "Binary behavioral feature #229",
  `profile_attr_230` int NULL COMMENT "Numeric profile feature #230",
  `profile_attr_231` decimal(18,4) NULL COMMENT "Financial profile feature #231",
  `profile_attr_232` varchar(32) NULL COMMENT "Categorical profile feature #232",
  `profile_attr_233` date NULL COMMENT "Date profile feature #233",
  `profile_attr_234` varchar(64) NULL COMMENT "Text profile feature #234",
  `profile_attr_235` tinyint NULL COMMENT "Binary behavioral feature #235",
  `profile_attr_236` int NULL COMMENT "Numeric profile feature #236",
  `profile_attr_237` decimal(18,4) NULL COMMENT "Financial profile feature #237",
  `profile_attr_238` varchar(32) NULL COMMENT "Categorical profile feature #238",
  `profile_attr_239` date NULL COMMENT "Date profile feature #239",
  `profile_attr_240` varchar(64) NULL COMMENT "Text profile feature #240",
  `profile_attr_241` tinyint NULL COMMENT "Binary behavioral feature #241",
  `profile_attr_242` int NULL COMMENT "Numeric profile feature #242",
  `profile_attr_243` decimal(18,4) NULL COMMENT "Financial profile feature #243",
  `profile_attr_244` varchar(32) NULL COMMENT "Categorical profile feature #244",
  `profile_attr_245` date NULL COMMENT "Date profile feature #245",
  `profile_attr_246` varchar(64) NULL COMMENT "Text profile feature #246",
  `profile_attr_247` tinyint NULL COMMENT "Binary behavioral feature #247",
  `profile_attr_248` int NULL COMMENT "Numeric profile feature #248",
  `profile_attr_249` decimal(18,4) NULL COMMENT "Financial profile feature #249",
  `profile_attr_250` varchar(32) NULL COMMENT "Categorical profile feature #250",
  `profile_attr_251` date NULL COMMENT "Date profile feature #251",
  `profile_attr_252` varchar(64) NULL COMMENT "Text profile feature #252",
  `profile_attr_253` tinyint NULL COMMENT "Binary behavioral feature #253",
  `profile_attr_254` int NULL COMMENT "Numeric profile feature #254",
  `profile_attr_255` decimal(18,4) NULL COMMENT "Financial profile feature #255",
  `profile_attr_256` varchar(32) NULL COMMENT "Categorical profile feature #256",
  `profile_attr_257` date NULL COMMENT "Date profile feature #257",
  `profile_attr_258` varchar(64) NULL COMMENT "Text profile feature #258",
  `profile_attr_259` tinyint NULL COMMENT "Binary behavioral feature #259",
  `profile_attr_260` int NULL COMMENT "Numeric profile feature #260",
  `profile_attr_261` decimal(18,4) NULL COMMENT "Financial profile feature #261",
  `profile_attr_262` varchar(32) NULL COMMENT "Categorical profile feature #262",
  `profile_attr_263` date NULL COMMENT "Date profile feature #263",
  `profile_attr_264` varchar(64) NULL COMMENT "Text profile feature #264",
  `profile_attr_265` tinyint NULL COMMENT "Binary behavioral feature #265",
  `profile_attr_266` int NULL COMMENT "Numeric profile feature #266",
  `profile_attr_267` decimal(18,4) NULL COMMENT "Financial profile feature #267",
  `profile_attr_268` varchar(32) NULL COMMENT "Categorical profile feature #268",
  `profile_attr_269` date NULL COMMENT "Date profile feature #269",
  `profile_attr_270` varchar(64) NULL COMMENT "Text profile feature #270",
  `profile_attr_271` tinyint NULL COMMENT "Binary behavioral feature #271",
  `profile_attr_272` int NULL COMMENT "Numeric profile feature #272",
  `profile_attr_273` decimal(18,4) NULL COMMENT "Financial profile feature #273",
  `profile_attr_274` varchar(32) NULL COMMENT "Categorical profile feature #274",
  `profile_attr_275` date NULL COMMENT "Date profile feature #275",
  `profile_attr_276` varchar(64) NULL COMMENT "Text profile feature #276",
  `profile_attr_277` tinyint NULL COMMENT "Binary behavioral feature #277",
  `profile_attr_278` int NULL COMMENT "Numeric profile feature #278",
  `profile_attr_279` decimal(18,4) NULL COMMENT "Financial profile feature #279",
  `profile_attr_280` varchar(32) NULL COMMENT "Categorical profile feature #280",
  `profile_attr_281` date NULL COMMENT "Date profile feature #281",
  `profile_attr_282` varchar(64) NULL COMMENT "Text profile feature #282",
  `profile_attr_283` tinyint NULL COMMENT "Binary behavioral feature #283",
  `profile_attr_284` int NULL COMMENT "Numeric profile feature #284",
  `profile_attr_285` decimal(18,4) NULL COMMENT "Financial profile feature #285",
  `profile_attr_286` varchar(32) NULL COMMENT "Categorical profile feature #286",
  `profile_attr_287` date NULL COMMENT "Date profile feature #287",
  `profile_attr_288` varchar(64) NULL COMMENT "Text profile feature #288",
  `profile_attr_289` tinyint NULL COMMENT "Binary behavioral feature #289",
  `profile_attr_290` int NULL COMMENT "Numeric profile feature #290",
  `profile_attr_291` decimal(18,4) NULL COMMENT "Financial profile feature #291",
  `profile_attr_292` varchar(32) NULL COMMENT "Categorical profile feature #292",
  `profile_attr_293` date NULL COMMENT "Date profile feature #293",
  `profile_attr_294` varchar(64) NULL COMMENT "Text profile feature #294",
  `profile_attr_295` tinyint NULL COMMENT "Binary behavioral feature #295",
  `profile_attr_296` int NULL COMMENT "Numeric profile feature #296",
  `profile_attr_297` decimal(18,4) NULL COMMENT "Financial profile feature #297",
  `profile_attr_298` varchar(32) NULL COMMENT "Categorical profile feature #298",
  `profile_attr_299` date NULL COMMENT "Date profile feature #299",
  `profile_attr_300` varchar(64) NULL COMMENT "Text profile feature #300",
  `profile_attr_301` tinyint NULL COMMENT "Binary behavioral feature #301",
  `profile_attr_302` int NULL COMMENT "Numeric profile feature #302",
  `profile_attr_303` decimal(18,4) NULL COMMENT "Financial profile feature #303",
  `profile_attr_304` varchar(32) NULL COMMENT "Categorical profile feature #304",
  `profile_attr_305` date NULL COMMENT "Date profile feature #305",
  `profile_attr_306` varchar(64) NULL COMMENT "Text profile feature #306",
  `profile_attr_307` tinyint NULL COMMENT "Binary behavioral feature #307",
  `profile_attr_308` int NULL COMMENT "Numeric profile feature #308",
  `profile_attr_309` decimal(18,4) NULL COMMENT "Financial profile feature #309",
  `profile_attr_310` varchar(32) NULL COMMENT "Categorical profile feature #310",
  `profile_attr_311` date NULL COMMENT "Date profile feature #311",
  `profile_attr_312` varchar(64) NULL COMMENT "Text profile feature #312",
  `profile_attr_313` tinyint NULL COMMENT "Binary behavioral feature #313",
  `profile_attr_314` int NULL COMMENT "Numeric profile feature #314",
  `profile_attr_315` decimal(18,4) NULL COMMENT "Financial profile feature #315",
  `profile_attr_316` varchar(32) NULL COMMENT "Categorical profile feature #316",
  `profile_attr_317` date NULL COMMENT "Date profile feature #317",
  `profile_attr_318` varchar(64) NULL COMMENT "Text profile feature #318",
  `profile_attr_319` tinyint NULL COMMENT "Binary behavioral feature #319",
  `profile_attr_320` int NULL COMMENT "Numeric profile feature #320",
  `profile_attr_321` decimal(18,4) NULL COMMENT "Financial profile feature #321",
  `profile_attr_322` varchar(32) NULL COMMENT "Categorical profile feature #322",
  `profile_attr_323` date NULL COMMENT "Date profile feature #323",
  `profile_attr_324` varchar(64) NULL COMMENT "Text profile feature #324",
  `profile_attr_325` tinyint NULL COMMENT "Binary behavioral feature #325",
  `profile_attr_326` int NULL COMMENT "Numeric profile feature #326",
  `profile_attr_327` decimal(18,4) NULL COMMENT "Financial profile feature #327",
  `profile_attr_328` varchar(32) NULL COMMENT "Categorical profile feature #328",
  `profile_attr_329` date NULL COMMENT "Date profile feature #329",
  `profile_attr_330` varchar(64) NULL COMMENT "Text profile feature #330",
  `profile_attr_331` tinyint NULL COMMENT "Binary behavioral feature #331",
  `profile_attr_332` int NULL COMMENT "Numeric profile feature #332",
  `profile_attr_333` decimal(18,4) NULL COMMENT "Financial profile feature #333",
  `profile_attr_334` varchar(32) NULL COMMENT "Categorical profile feature #334",
  `profile_attr_335` date NULL COMMENT "Date profile feature #335",
  `profile_attr_336` varchar(64) NULL COMMENT "Text profile feature #336",
  `profile_attr_337` tinyint NULL COMMENT "Binary behavioral feature #337",
  `profile_attr_338` int NULL COMMENT "Numeric profile feature #338",
  `profile_attr_339` decimal(18,4) NULL COMMENT "Financial profile feature #339",
  `profile_attr_340` varchar(32) NULL COMMENT "Categorical profile feature #340",
  `profile_attr_341` date NULL COMMENT "Date profile feature #341",
  `profile_attr_342` varchar(64) NULL COMMENT "Text profile feature #342",
  `profile_attr_343` tinyint NULL COMMENT "Binary behavioral feature #343",
  `profile_attr_344` int NULL COMMENT "Numeric profile feature #344",
  `profile_attr_345` decimal(18,4) NULL COMMENT "Financial profile feature #345",
  `profile_attr_346` varchar(32) NULL COMMENT "Categorical profile feature #346",
  `profile_attr_347` date NULL COMMENT "Date profile feature #347",
  `profile_attr_348` varchar(64) NULL COMMENT "Text profile feature #348",
  `profile_attr_349` tinyint NULL COMMENT "Binary behavioral feature #349",
  `profile_attr_350` int NULL COMMENT "Numeric profile feature #350",
  `profile_attr_351` decimal(18,4) NULL COMMENT "Financial profile feature #351",
  `profile_attr_352` varchar(32) NULL COMMENT "Categorical profile feature #352",
  `profile_attr_353` date NULL COMMENT "Date profile feature #353",
  `profile_attr_354` varchar(64) NULL COMMENT "Text profile feature #354",
  `profile_attr_355` tinyint NULL COMMENT "Binary behavioral feature #355",
  `profile_attr_356` int NULL COMMENT "Numeric profile feature #356",
  `profile_attr_357` decimal(18,4) NULL COMMENT "Financial profile feature #357",
  `profile_attr_358` varchar(32) NULL COMMENT "Categorical profile feature #358",
  `profile_attr_359` date NULL COMMENT "Date profile feature #359",
  `profile_attr_360` varchar(64) NULL COMMENT "Text profile feature #360",
  `profile_attr_361` tinyint NULL COMMENT "Binary behavioral feature #361",
  `profile_attr_362` int NULL COMMENT "Numeric profile feature #362",
  `profile_attr_363` decimal(18,4) NULL COMMENT "Financial profile feature #363",
  `profile_attr_364` varchar(32) NULL COMMENT "Categorical profile feature #364",
  `profile_attr_365` date NULL COMMENT "Date profile feature #365",
  `profile_attr_366` varchar(64) NULL COMMENT "Text profile feature #366",
  `profile_attr_367` tinyint NULL COMMENT "Binary behavioral feature #367",
  `profile_attr_368` int NULL COMMENT "Numeric profile feature #368",
  `profile_attr_369` decimal(18,4) NULL COMMENT "Financial profile feature #369",
  `profile_attr_370` varchar(32) NULL COMMENT "Categorical profile feature #370",
  `profile_attr_371` date NULL COMMENT "Date profile feature #371",
  `profile_attr_372` varchar(64) NULL COMMENT "Text profile feature #372",
  `profile_attr_373` tinyint NULL COMMENT "Binary behavioral feature #373",
  `profile_attr_374` int NULL COMMENT "Numeric profile feature #374",
  `profile_attr_375` decimal(18,4) NULL COMMENT "Financial profile feature #375",
  `profile_attr_376` varchar(32) NULL COMMENT "Categorical profile feature #376",
  `profile_attr_377` date NULL COMMENT "Date profile feature #377",
  `profile_attr_378` varchar(64) NULL COMMENT "Text profile feature #378",
  `profile_attr_379` tinyint NULL COMMENT "Binary behavioral feature #379",
  `profile_attr_380` int NULL COMMENT "Numeric profile feature #380",
  `profile_attr_381` decimal(18,4) NULL COMMENT "Financial profile feature #381",
  `profile_attr_382` varchar(32) NULL COMMENT "Categorical profile feature #382",
  `profile_attr_383` date NULL COMMENT "Date profile feature #383",
  `profile_attr_384` varchar(64) NULL COMMENT "Text profile feature #384",
  `profile_attr_385` tinyint NULL COMMENT "Binary behavioral feature #385",
  `profile_attr_386` int NULL COMMENT "Numeric profile feature #386",
  `profile_attr_387` decimal(18,4) NULL COMMENT "Financial profile feature #387",
  `profile_attr_388` varchar(32) NULL COMMENT "Categorical profile feature #388",
  `profile_attr_389` date NULL COMMENT "Date profile feature #389",
  `profile_attr_390` varchar(64) NULL COMMENT "Text profile feature #390",
  `profile_attr_391` tinyint NULL COMMENT "Binary behavioral feature #391",
  `profile_attr_392` int NULL COMMENT "Numeric profile feature #392",
  `profile_attr_393` decimal(18,4) NULL COMMENT "Financial profile feature #393",
  `profile_attr_394` varchar(32) NULL COMMENT "Categorical profile feature #394",
  `profile_attr_395` date NULL COMMENT "Date profile feature #395",
  `profile_attr_396` varchar(64) NULL COMMENT "Text profile feature #396",
  `profile_attr_397` tinyint NULL COMMENT "Binary behavioral feature #397",
  `profile_attr_398` int NULL COMMENT "Numeric profile feature #398",
  `profile_attr_399` decimal(18,4) NULL COMMENT "Financial profile feature #399",
  `profile_attr_400` varchar(32) NULL COMMENT "Categorical profile feature #400",
  `profile_attr_401` date NULL COMMENT "Date profile feature #401",
  `profile_attr_402` varchar(64) NULL COMMENT "Text profile feature #402",
  `profile_attr_403` tinyint NULL COMMENT "Binary behavioral feature #403",
  `profile_attr_404` int NULL COMMENT "Numeric profile feature #404",
  `profile_attr_405` decimal(18,4) NULL COMMENT "Financial profile feature #405",
  `profile_attr_406` varchar(32) NULL COMMENT "Categorical profile feature #406",
  `profile_attr_407` date NULL COMMENT "Date profile feature #407",
  `profile_attr_408` varchar(64) NULL COMMENT "Text profile feature #408",
  `profile_attr_409` tinyint NULL COMMENT "Binary behavioral feature #409",
  `profile_attr_410` int NULL COMMENT "Numeric profile feature #410",
  `profile_attr_411` decimal(18,4) NULL COMMENT "Financial profile feature #411",
  `profile_attr_412` varchar(32) NULL COMMENT "Categorical profile feature #412",
  `profile_attr_413` date NULL COMMENT "Date profile feature #413",
  `profile_attr_414` varchar(64) NULL COMMENT "Text profile feature #414",
  `profile_attr_415` tinyint NULL COMMENT "Binary behavioral feature #415",
  `profile_attr_416` int NULL COMMENT "Numeric profile feature #416",
  `profile_attr_417` decimal(18,4) NULL COMMENT "Financial profile feature #417",
  `profile_attr_418` varchar(32) NULL COMMENT "Categorical profile feature #418",
  `profile_attr_419` date NULL COMMENT "Date profile feature #419",
  `profile_attr_420` varchar(64) NULL COMMENT "Text profile feature #420",
  `profile_attr_421` tinyint NULL COMMENT "Binary behavioral feature #421",
  `profile_attr_422` int NULL COMMENT "Numeric profile feature #422",
  `profile_attr_423` decimal(18,4) NULL COMMENT "Financial profile feature #423",
  `profile_attr_424` varchar(32) NULL COMMENT "Categorical profile feature #424",
  `profile_attr_425` date NULL COMMENT "Date profile feature #425",
  `profile_attr_426` varchar(64) NULL COMMENT "Text profile feature #426",
  `profile_attr_427` tinyint NULL COMMENT "Binary behavioral feature #427",
  `profile_attr_428` int NULL COMMENT "Numeric profile feature #428",
  `profile_attr_429` decimal(18,4) NULL COMMENT "Financial profile feature #429",
  `profile_attr_430` varchar(32) NULL COMMENT "Categorical profile feature #430",
  `profile_attr_431` date NULL COMMENT "Date profile feature #431",
  `profile_attr_432` varchar(64) NULL COMMENT "Text profile feature #432",
  `profile_attr_433` tinyint NULL COMMENT "Binary behavioral feature #433",
  `profile_attr_434` int NULL COMMENT "Numeric profile feature #434",
  `profile_attr_435` decimal(18,4) NULL COMMENT "Financial profile feature #435",
  `profile_attr_436` varchar(32) NULL COMMENT "Categorical profile feature #436",
  `profile_attr_437` date NULL COMMENT "Date profile feature #437",
  `profile_attr_438` varchar(64) NULL COMMENT "Text profile feature #438",
  `profile_attr_439` tinyint NULL COMMENT "Binary behavioral feature #439",
  `profile_attr_440` int NULL COMMENT "Numeric profile feature #440",
  `profile_attr_441` decimal(18,4) NULL COMMENT "Financial profile feature #441",
  `profile_attr_442` varchar(32) NULL COMMENT "Categorical profile feature #442",
  `profile_attr_443` date NULL COMMENT "Date profile feature #443",
  `profile_attr_444` varchar(64) NULL COMMENT "Text profile feature #444",
  `profile_attr_445` tinyint NULL COMMENT "Binary behavioral feature #445",
  `profile_attr_446` int NULL COMMENT "Numeric profile feature #446",
  `profile_attr_447` decimal(18,4) NULL COMMENT "Financial profile feature #447",
  `profile_attr_448` varchar(32) NULL COMMENT "Categorical profile feature #448",
  `profile_attr_449` date NULL COMMENT "Date profile feature #449",
  `profile_attr_450` varchar(64) NULL COMMENT "Text profile feature #450",
  `profile_attr_451` tinyint NULL COMMENT "Binary behavioral feature #451",
  `profile_attr_452` int NULL COMMENT "Numeric profile feature #452",
  `profile_attr_453` decimal(18,4) NULL COMMENT "Financial profile feature #453",
  `profile_attr_454` varchar(32) NULL COMMENT "Categorical profile feature #454",
  `profile_attr_455` date NULL COMMENT "Date profile feature #455",
  `profile_attr_456` varchar(64) NULL COMMENT "Text profile feature #456",
  `profile_attr_457` tinyint NULL COMMENT "Binary behavioral feature #457",
  `profile_attr_458` int NULL COMMENT "Numeric profile feature #458",
  `profile_attr_459` decimal(18,4) NULL COMMENT "Financial profile feature #459",
  `profile_attr_460` varchar(32) NULL COMMENT "Categorical profile feature #460",
  `profile_attr_461` date NULL COMMENT "Date profile feature #461",
  `profile_attr_462` varchar(64) NULL COMMENT "Text profile feature #462"
) ENGINE=OLAP
UNIQUE KEY(`user_id`)
COMMENT 'User wide table - 500-column point-query optimized table'
DISTRIBUTED BY HASH(`user_id`) BUCKETS 10
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
