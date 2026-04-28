-- ================================================================
-- Database: regdb
-- Type: schema
-- Source: generated from current Doris SHOW CREATE TABLE output.
-- ================================================================

CREATE DATABASE IF NOT EXISTS regdb;
USE regdb;

-- Table: reg_g01_balance
CREATE TABLE IF NOT EXISTS `reg_g01_balance` (
  `report_period` varchar(10) NOT NULL COMMENT "报告期 2024-03",
  `org_code` varchar(20) NOT NULL COMMENT "机构代码",
  `item_code` varchar(20) NOT NULL COMMENT "科目代码",
  `curr_balance` bigint NULL COMMENT "期末余额（万元）",
  `prev_balance` bigint NULL COMMENT "上期余额（万元）",
  `currency_code` varchar(5) NULL DEFAULT "CNY",
  `data_source` varchar(50) NULL COMMENT "来源系统",
  `status` varchar(20) NULL DEFAULT "draft"
) ENGINE=OLAP
UNIQUE KEY(`report_period`, `org_code`, `item_code`)
DISTRIBUTED BY HASH(`org_code`) BUCKETS 5
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

-- Table: reg_g03_capital
CREATE TABLE IF NOT EXISTS `reg_g03_capital` (
  `report_period` varchar(10) NOT NULL,
  `org_code` varchar(20) NOT NULL,
  `cet1_capital` bigint NULL COMMENT "核心一级资本净额（万元）",
  `at1_capital` bigint NULL COMMENT "其他一级资本",
  `t2_capital` bigint NULL COMMENT "二级资本",
  `total_capital` bigint NULL COMMENT "资本净额合计",
  `credit_rwa` bigint NULL COMMENT "信用风险RWA",
  `market_rwa` bigint NULL COMMENT "市场风险RWA",
  `ops_rwa` bigint NULL COMMENT "操作风险RWA",
  `total_rwa` bigint NULL COMMENT "风险加权资产合计",
  `cet1_ratio` decimal(8,4) NULL COMMENT "核心一级资本充足率",
  `tier1_ratio` decimal(8,4) NULL COMMENT "一级资本充足率",
  `car_ratio` decimal(8,4) NULL COMMENT "资本充足率",
  `leverage_ratio` decimal(8,4) NULL COMMENT "杠杆率",
  `status` varchar(20) NULL DEFAULT "draft"
) ENGINE=OLAP
UNIQUE KEY(`report_period`, `org_code`)
DISTRIBUTED BY HASH(`org_code`) BUCKETS 3
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

-- Table: reg_g04a_loan
CREATE TABLE IF NOT EXISTS `reg_g04a_loan` (
  `report_period` varchar(10) NOT NULL,
  `org_code` varchar(20) NOT NULL,
  `loan_type` varchar(20) NOT NULL COMMENT "CORP/RETAIL/TOTAL",
  `industry_code` varchar(20) NOT NULL COMMENT "行业/ALL",
  `total_balance` bigint NULL COMMENT "贷款总额（万元）",
  `normal_balance` bigint NULL,
  `concern_balance` bigint NULL,
  `substandard_balance` bigint NULL,
  `doubtful_balance` bigint NULL,
  `loss_balance` bigint NULL,
  `provision_balance` bigint NULL,
  `npl_balance` bigint NULL COMMENT "不良贷款=次级+可疑+损失",
  `npl_ratio` decimal(8,4) NULL,
  `provision_coverage` decimal(8,4) NULL COMMENT "拨备覆盖率"
) ENGINE=OLAP
UNIQUE KEY(`report_period`, `org_code`, `loan_type`, `industry_code`)
DISTRIBUTED BY HASH(`org_code`) BUCKETS 5
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

-- Table: reg_g11_lcr
CREATE TABLE IF NOT EXISTS `reg_g11_lcr` (
  `report_period` varchar(10) NOT NULL,
  `org_code` varchar(20) NOT NULL,
  `hqla_l1` bigint NULL COMMENT "一级资产折后值（万元）",
  `hqla_l2a` bigint NULL COMMENT "二级A类折后值",
  `hqla_l2b` bigint NULL COMMENT "二级B类折后值",
  `hqla_total` bigint NULL COMMENT "HQLA合计",
  `outflow_retail` bigint NULL COMMENT "零售存款流出",
  `outflow_wholesale` bigint NULL COMMENT "批发存款流出",
  `outflow_interbank` bigint NULL COMMENT "同业存款流出",
  `outflow_other` bigint NULL,
  `total_outflow` bigint NULL,
  `inflow_loans` bigint NULL,
  `inflow_other` bigint NULL,
  `net_outflow` bigint NULL,
  `lcr_ratio` decimal(8,4) NULL COMMENT "LCR = HQLA/净流出",
  `nsfr_ratio` decimal(8,4) NULL COMMENT "NSFR（单独字段）",
  `is_compliant` tinyint NULL COMMENT "1=达标",
  `status` varchar(20) NULL DEFAULT "draft"
) ENGINE=OLAP
UNIQUE KEY(`report_period`, `org_code`)
DISTRIBUTED BY HASH(`org_code`) BUCKETS 3
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

-- Table: reg_g21_credit
CREATE TABLE IF NOT EXISTS `reg_g21_credit` (
  `report_period` varchar(10) NOT NULL,
  `org_code` varchar(20) NOT NULL,
  `loan_balance` bigint NULL COMMENT "贷款余额（万元）",
  `loan_new` bigint NULL COMMENT "本期新增",
  `loan_corp` bigint NULL COMMENT "企业贷款",
  `loan_retail` bigint NULL COMMENT "个人贷款",
  `loan_bill` bigint NULL COMMENT "票据贴现",
  `deposit_balance` bigint NULL COMMENT "存款余额",
  `deposit_corp` bigint NULL,
  `deposit_retail` bigint NULL,
  `net_profit_w` bigint NULL COMMENT "净利润（万元）",
  `roa` decimal(8,4) NULL COMMENT "资产收益率",
  `roe` decimal(8,4) NULL COMMENT "净资产收益率"
) ENGINE=OLAP
UNIQUE KEY(`report_period`, `org_code`)
DISTRIBUTED BY HASH(`org_code`) BUCKETS 3
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

-- Table: reg_item_dict
CREATE TABLE IF NOT EXISTS `reg_item_dict` (
  `report_code` varchar(10) NOT NULL COMMENT "报表代码",
  `item_code` varchar(20) NOT NULL COMMENT "科目代码",
  `item_name` varchar(100) NOT NULL COMMENT "科目名称",
  `item_type` varchar(20) NULL COMMENT "ASSET/LIABILITY/EQUITY/CAPITAL/LOAN/LIQUIDITY",
  `parent_code` varchar(20) NULL COMMENT "父级科目",
  `sign_flag` tinyint NULL DEFAULT "1" COMMENT "1=正值 -1=减项",
  `sort_order` int NULL DEFAULT "0",
  `is_summary` tinyint NULL DEFAULT "0" COMMENT "1=汇总行"
) ENGINE=OLAP
UNIQUE KEY(`report_code`, `item_code`)
DISTRIBUTED BY HASH(`report_code`) BUCKETS 3
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

-- Table: reg_master
CREATE TABLE IF NOT EXISTS `reg_master` (
  `report_period` varchar(10) NOT NULL COMMENT "报告期（季度）",
  `org_code` varchar(20) NOT NULL,
  `total_assets_w` bigint NULL COMMENT "总资产（万元）",
  `total_liabilities_w` bigint NULL,
  `total_equity_w` bigint NULL,
  `total_loans_w` bigint NULL COMMENT "贷款余额",
  `total_deposits_w` bigint NULL COMMENT "存款余额",
  `cet1_ratio` decimal(8,4) NULL COMMENT "核心一级资本充足率",
  `tier1_ratio` decimal(8,4) NULL,
  `car_ratio` decimal(8,4) NULL COMMENT "资本充足率",
  `leverage_ratio` decimal(8,4) NULL,
  `total_rwa_w` bigint NULL,
  `npl_balance_w` bigint NULL,
  `npl_ratio` decimal(8,4) NULL COMMENT "不良贷款率",
  `provision_coverage` decimal(8,4) NULL COMMENT "拨备覆盖率",
  `loan_provision_rate` decimal(8,4) NULL COMMENT "贷款拨备率",
  `lcr_ratio` decimal(8,4) NULL COMMENT "流动性覆盖率",
  `nsfr_ratio` decimal(8,4) NULL COMMENT "净稳定资金比例",
  `net_profit_w` bigint NULL,
  `roa` decimal(8,4) NULL,
  `roe` decimal(8,4) NULL,
  `is_car_ok` tinyint NULL COMMENT "资本充足率达标",
  `is_lcr_ok` tinyint NULL COMMENT "LCR达标",
  `is_npl_ok` tinyint NULL COMMENT "NPL达标",
  `is_provision_ok` tinyint NULL COMMENT "拨备覆盖率达标",
  `compliance_score` decimal(5,2) NULL COMMENT "综合合规得分",
  `g01_status` varchar(20) NULL DEFAULT "pending",
  `g03_status` varchar(20) NULL DEFAULT "pending",
  `g04a_status` varchar(20) NULL DEFAULT "pending",
  `g11_status` varchar(20) NULL DEFAULT "pending",
  `g21_status` varchar(20) NULL DEFAULT "pending",
  `process_time` datetime NULL COMMENT "一键加工时间"
) ENGINE=OLAP
UNIQUE KEY(`report_period`, `org_code`)
DISTRIBUTED BY HASH(`org_code`) BUCKETS 3
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

-- Table: reg_submit_log
CREATE TABLE IF NOT EXISTS `reg_submit_log` (
  `log_id` varchar(36) NOT NULL COMMENT "UUID",
  `report_code` varchar(10) NOT NULL,
  `report_period` varchar(10) NOT NULL,
  `org_code` varchar(20) NOT NULL,
  `action` varchar(20) NULL COMMENT "draft/qc/submit/accept/reject",
  `operator` varchar(50) NULL,
  `action_time` datetime NULL,
  `qc_score` decimal(5,2) NULL,
  `fail_rules` varchar(1000) NULL COMMENT "JSON失败规则",
  `remark` varchar(500) NULL
) ENGINE=OLAP
UNIQUE KEY(`log_id`)
DISTRIBUTED BY HASH(`log_id`) BUCKETS 5
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
