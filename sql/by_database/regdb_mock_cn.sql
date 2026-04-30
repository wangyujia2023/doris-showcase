-- ================================================================
-- Database: regdb
-- Type: Chinese mock data
-- Source: generated from current Doris table metadata.
-- Execute after schema SQL.
-- ================================================================

CREATE DATABASE IF NOT EXISTS regdb;
USE regdb;

-- Table: reg_g01_balance
TRUNCATE TABLE `reg_g01_balance`;
INSERT INTO `reg_g01_balance`(`report_period`, `org_code`, `item_code`, `curr_balance`, `prev_balance`, `currency_code`, `data_source`, `status`) VALUES
  ('2025-04', 'C0001', 'C0001', 1000.25, 1000.25, 'C0001', '核心系统', '正常'),
  ('2025-04', 'C0002', 'C0002', 2000.50, 2000.50, 'C0002', '数据中台', '运行中'),
  ('2025-04', 'C0003', 'C0003', 3000.75, 3000.75, 'C0003', '营销平台', '已成功'),
  ('2025-04', 'C0004', 'C0004', 4001.00, 4001.00, 'C0004', '监管平台', '已生效'),
  ('2025-04', 'C0005', 'C0005', 5001.25, 5001.25, 'C0005', 'OpenMetadata', '已完成');

-- Table: reg_g03_capital
TRUNCATE TABLE `reg_g03_capital`;
INSERT INTO `reg_g03_capital`(`report_period`, `org_code`, `cet1_capital`, `at1_capital`, `t2_capital`, `total_capital`, `credit_rwa`, `market_rwa`, `ops_rwa`, `total_rwa`, `cet1_ratio`, `tier1_ratio`, `car_ratio`, `leverage_ratio`, `status`) VALUES
  ('2025-04', 'C0001', 1, 1, 1, 1, 1, 1, 1, 1, 0.0500, 0.0500, 0.0500, 26, '正常'),
  ('2025-04', 'C0002', 2, 2, 2, 2, 2, 2, 2, 2, 0.1000, 0.1000, 0.1000, 27, '运行中'),
  ('2025-04', 'C0003', 3, 3, 3, 3, 3, 3, 3, 3, 0.1500, 0.1500, 0.1500, 28, '已成功'),
  ('2025-04', 'C0004', 4, 4, 4, 4, 4, 4, 4, 4, 0.2000, 0.2000, 0.2000, 29, '已生效'),
  ('2025-04', 'C0005', 5, 5, 5, 5, 5, 5, 5, 5, 0.2500, 0.2500, 0.2500, 30, '已完成');

-- Table: reg_g04a_loan
TRUNCATE TABLE `reg_g04a_loan`;
INSERT INTO `reg_g04a_loan`(`report_period`, `org_code`, `loan_type`, `industry_code`, `total_balance`, `normal_balance`, `concern_balance`, `substandard_balance`, `doubtful_balance`, `loss_balance`, `provision_balance`, `npl_balance`, `npl_ratio`, `provision_coverage`) VALUES
  ('2025-04', 'C0001', '个人住房贷款', 'C0001', 1000.25, 1000.25, 1000.25, 1000.25, 1000.25, 1000.25, 1000.25, 1000.25, 0.0500, 26),
  ('2025-04', 'C0002', '小微经营贷', 'C0002', 2000.50, 2000.50, 2000.50, 2000.50, 2000.50, 2000.50, 2000.50, 2000.50, 0.1000, 27),
  ('2025-04', 'C0003', '信用消费贷', 'C0003', 3000.75, 3000.75, 3000.75, 3000.75, 3000.75, 3000.75, 3000.75, 3000.75, 0.1500, 28),
  ('2025-04', 'C0004', '票据融资', 'C0004', 4001.00, 4001.00, 4001.00, 4001.00, 4001.00, 4001.00, 4001.00, 4001.00, 0.2000, 29),
  ('2025-04', 'C0005', '流动资金贷款', 'C0005', 5001.25, 5001.25, 5001.25, 5001.25, 5001.25, 5001.25, 5001.25, 5001.25, 0.2500, 30);

-- Table: reg_g11_lcr
TRUNCATE TABLE `reg_g11_lcr`;
INSERT INTO `reg_g11_lcr`(`report_period`, `org_code`, `hqla_l1`, `hqla_l2a`, `hqla_l2b`, `hqla_total`, `outflow_retail`, `outflow_wholesale`, `outflow_interbank`, `outflow_other`, `total_outflow`, `inflow_loans`, `inflow_other`, `net_outflow`, `lcr_ratio`, `nsfr_ratio`, `is_compliant`, `status`) VALUES
  ('2025-04', 'C0001', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.0500, 0.0500, 1, '正常'),
  ('2025-04', 'C0002', 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0.1000, 0.1000, 0, '运行中'),
  ('2025-04', 'C0003', 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0.1500, 0.1500, 1, '已成功'),
  ('2025-04', 'C0004', 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0.2000, 0.2000, 0, '已生效'),
  ('2025-04', 'C0005', 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0.2500, 0.2500, 1, '已完成');

-- Table: reg_g21_credit
TRUNCATE TABLE `reg_g21_credit`;
INSERT INTO `reg_g21_credit`(`report_period`, `org_code`, `loan_balance`, `loan_new`, `loan_corp`, `loan_retail`, `loan_bill`, `deposit_balance`, `deposit_corp`, `deposit_retail`, `net_profit_w`, `roa`, `roe`) VALUES
  ('2025-04', 'C0001', 1000.25, 1, 1, 1, 1, 1000.25, 1, 1, 1000.25, 10.2500, 10.2500),
  ('2025-04', 'C0002', 2000.50, 2, 2, 2, 2, 2000.50, 2, 2, 2000.50, 20.5000, 20.5000),
  ('2025-04', 'C0003', 3000.75, 3, 3, 3, 3, 3000.75, 3, 3, 3000.75, 30.7500, 30.7500),
  ('2025-04', 'C0004', 4001.00, 4, 4, 4, 4, 4001.00, 4, 4, 4001.00, 41.0000, 41.0000),
  ('2025-04', 'C0005', 5001.25, 5, 5, 5, 5, 5001.25, 5, 5, 5001.25, 51.2500, 51.2500);

-- Table: reg_item_dict
TRUNCATE TABLE `reg_item_dict`;
INSERT INTO `reg_item_dict`(`report_code`, `item_code`, `item_name`, `item_type`, `parent_code`, `sign_flag`, `sort_order`, `is_summary`) VALUES
  ('C0001', 'C0001', '资产总额', '零售', 'C0001', 1, 1, 1),
  ('C0002', 'C0002', '资本充足率', '财富', 'C0002', 0, 2, 0),
  ('C0003', 'C0003', '贷款余额', '信贷', 'C0003', 1, 3, 1),
  ('C0004', 'C0004', '流动性覆盖率', '风险', 'C0004', 0, 4, 0),
  ('C0005', 'C0005', '不良贷款率', '运营', 'C0005', 1, 5, 1);

-- Table: reg_master
TRUNCATE TABLE `reg_master`;
INSERT INTO `reg_master`(`report_period`, `org_code`, `total_assets_w`, `total_liabilities_w`, `total_equity_w`, `total_loans_w`, `total_deposits_w`, `cet1_ratio`, `tier1_ratio`, `car_ratio`, `leverage_ratio`, `total_rwa_w`, `npl_balance_w`, `npl_ratio`, `provision_coverage`, `loan_provision_rate`, `lcr_ratio`, `nsfr_ratio`, `net_profit_w`, `roa`, `roe`, `is_car_ok`, `is_lcr_ok`, `is_npl_ok`, `is_provision_ok`, `compliance_score`, `g01_status`, `g03_status`, `g04a_status`, `g11_status`, `g21_status`, `process_time`) VALUES
  ('2025-04', 'C0001', 1, 1, 1, 1, 1, 0.0500, 0.0500, 0.0500, 26, 1, 1000.25, 0.0500, 26, 0.0500, 0.0500, 0.0500, 1000.25, 10.2500, 10.2500, 1, 1, 1, 1, 0.05, '正常', '正常', '正常', '正常', '正常', '2025-04-01 09:01:00'),
  ('2025-04', 'C0002', 2, 2, 2, 2, 2, 0.1000, 0.1000, 0.1000, 27, 2, 2000.50, 0.1000, 27, 0.1000, 0.1000, 0.1000, 2000.50, 20.5000, 20.5000, 0, 0, 0, 0, 0.10, '运行中', '运行中', '运行中', '运行中', '运行中', '2025-04-02 09:02:00'),
  ('2025-04', 'C0003', 3, 3, 3, 3, 3, 0.1500, 0.1500, 0.1500, 28, 3, 3000.75, 0.1500, 28, 0.1500, 0.1500, 0.1500, 3000.75, 30.7500, 30.7500, 1, 1, 1, 1, 0.15, '已成功', '已成功', '已成功', '已成功', '已成功', '2025-04-03 09:03:00'),
  ('2025-04', 'C0004', 4, 4, 4, 4, 4, 0.2000, 0.2000, 0.2000, 29, 4, 4001.00, 0.2000, 29, 0.2000, 0.2000, 0.2000, 4001.00, 41.0000, 41.0000, 0, 0, 0, 0, 0.20, '已生效', '已生效', '已生效', '已生效', '已生效', '2025-04-04 09:04:00'),
  ('2025-04', 'C0005', 5, 5, 5, 5, 5, 0.2500, 0.2500, 0.2500, 30, 5, 5001.25, 0.2500, 30, 0.2500, 0.2500, 0.2500, 5001.25, 51.2500, 51.2500, 1, 1, 1, 1, 0.25, '已完成', '已完成', '已完成', '已完成', '已完成', '2025-04-05 09:05:00');

-- Table: reg_submit_log
TRUNCATE TABLE `reg_submit_log`;
INSERT INTO `reg_submit_log`(`log_id`, `report_code`, `report_period`, `org_code`, `action`, `operator`, `action_time`, `qc_score`, `fail_rules`, `remark`) VALUES
  ('reg_subm_001', 'C0001', '2025-04', 'C0001', '提交', '张审核', '2025-04-01 09:01:00', 0.05, '监管报送校验通过', '监管报送校验通过'),
  ('reg_subm_002', 'C0002', '2025-04', 'C0002', '复核', '李复核', '2025-04-02 09:02:00', 0.10, '监管报送口径复核', '监管报送口径复核'),
  ('reg_subm_003', 'C0003', '2025-04', 'C0003', '退回', '王运营', '2025-04-03 09:03:00', 0.15, '监管报送数据退回', '监管报送数据退回'),
  ('reg_subm_004', 'C0004', '2025-04', 'C0004', '重报', '陈风控', '2025-04-04 09:04:00', 0.20, '监管报送重报完成', '监管报送重报完成'),
  ('reg_subm_005', 'C0005', '2025-04', 'C0005', '归档', '赵经理', '2025-04-05 09:05:00', 0.25, '监管报送归档确认', '监管报送归档确认');
