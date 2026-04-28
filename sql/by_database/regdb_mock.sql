-- ================================================================
-- Database: regdb
-- Type: English mock data
-- Source: generated from current Doris table metadata.
-- Execute after schema SQL.
-- ================================================================

CREATE DATABASE IF NOT EXISTS regdb;
USE regdb;

-- Table: reg_g01_balance
TRUNCATE TABLE `reg_g01_balance`;
INSERT INTO `reg_g01_balance` (`report_period`, `org_code`, `item_code`, `curr_balance`, `prev_balance`, `currency_code`, `data_source`, `status`) VALUES
  ('reg_g01_ba', 'C0001', 'C0001', 1000.25, 1000.25, 'C0001', 'reg_g01_balance_data_source_1', 'Normal'),
  ('reg_g01_ba', 'C0002', 'C0002', 2000.50, 2000.50, 'C0002', 'reg_g01_balance_data_source_2', 'Running'),
  ('reg_g01_ba', 'C0003', 'C0003', 3000.75, 3000.75, 'C0003', 'reg_g01_balance_data_source_3', 'Success'),
  ('reg_g01_ba', 'C0004', 'C0004', 4001.00, 4001.00, 'C0004', 'reg_g01_balance_data_source_4', 'Active'),
  ('reg_g01_ba', 'C0005', 'C0005', 5001.25, 5001.25, 'C0005', 'reg_g01_balance_data_source_5', 'Completed');

-- Table: reg_g03_capital
TRUNCATE TABLE `reg_g03_capital`;
INSERT INTO `reg_g03_capital` (`report_period`, `org_code`, `cet1_capital`, `at1_capital`, `t2_capital`, `total_capital`, `credit_rwa`, `market_rwa`, `ops_rwa`, `total_rwa`, `cet1_ratio`, `tier1_ratio`, `car_ratio`, `leverage_ratio`, `status`) VALUES
  ('reg_g03_ca', 'C0001', 1, 1, 1, 1, 1, 1, 1, 1, 0.0500, 0.0500, 0.0500, 26, 'Normal'),
  ('reg_g03_ca', 'C0002', 2, 2, 2, 2, 2, 2, 2, 2, 0.1000, 0.1000, 0.1000, 27, 'Running'),
  ('reg_g03_ca', 'C0003', 3, 3, 3, 3, 3, 3, 3, 3, 0.1500, 0.1500, 0.1500, 28, 'Success'),
  ('reg_g03_ca', 'C0004', 4, 4, 4, 4, 4, 4, 4, 4, 0.2000, 0.2000, 0.2000, 29, 'Active'),
  ('reg_g03_ca', 'C0005', 5, 5, 5, 5, 5, 5, 5, 5, 0.2500, 0.2500, 0.2500, 30, 'Completed');

-- Table: reg_g04a_loan
TRUNCATE TABLE `reg_g04a_loan`;
INSERT INTO `reg_g04a_loan` (`report_period`, `org_code`, `loan_type`, `industry_code`, `total_balance`, `normal_balance`, `concern_balance`, `substandard_balance`, `doubtful_balance`, `loss_balance`, `provision_balance`, `npl_balance`, `npl_ratio`, `provision_coverage`) VALUES
  ('reg_g04a_l', 'C0001', 'Retail', 'C0001', 1000.25, 1000.25, 1000.25, 1000.25, 1000.25, 1000.25, 1000.25, 1000.25, 0.0500, 26),
  ('reg_g04a_l', 'C0002', 'Wealth', 'C0002', 2000.50, 2000.50, 2000.50, 2000.50, 2000.50, 2000.50, 2000.50, 2000.50, 0.1000, 27),
  ('reg_g04a_l', 'C0003', 'Credit', 'C0003', 3000.75, 3000.75, 3000.75, 3000.75, 3000.75, 3000.75, 3000.75, 3000.75, 0.1500, 28),
  ('reg_g04a_l', 'C0004', 'Risk', 'C0004', 4001.00, 4001.00, 4001.00, 4001.00, 4001.00, 4001.00, 4001.00, 4001.00, 0.2000, 29),
  ('reg_g04a_l', 'C0005', 'Operation', 'C0005', 5001.25, 5001.25, 5001.25, 5001.25, 5001.25, 5001.25, 5001.25, 5001.25, 0.2500, 30);

-- Table: reg_g11_lcr
TRUNCATE TABLE `reg_g11_lcr`;
INSERT INTO `reg_g11_lcr` (`report_period`, `org_code`, `hqla_l1`, `hqla_l2a`, `hqla_l2b`, `hqla_total`, `outflow_retail`, `outflow_wholesale`, `outflow_interbank`, `outflow_other`, `total_outflow`, `inflow_loans`, `inflow_other`, `net_outflow`, `lcr_ratio`, `nsfr_ratio`, `is_compliant`, `status`) VALUES
  ('reg_g11_lc', 'C0001', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.0500, 0.0500, 1, 'Normal'),
  ('reg_g11_lc', 'C0002', 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0.1000, 0.1000, 0, 'Running'),
  ('reg_g11_lc', 'C0003', 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0.1500, 0.1500, 1, 'Success'),
  ('reg_g11_lc', 'C0004', 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0.2000, 0.2000, 0, 'Active'),
  ('reg_g11_lc', 'C0005', 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0.2500, 0.2500, 1, 'Completed');

-- Table: reg_g21_credit
TRUNCATE TABLE `reg_g21_credit`;
INSERT INTO `reg_g21_credit` (`report_period`, `org_code`, `loan_balance`, `loan_new`, `loan_corp`, `loan_retail`, `loan_bill`, `deposit_balance`, `deposit_corp`, `deposit_retail`, `net_profit_w`, `roa`, `roe`) VALUES
  ('reg_g21_cr', 'C0001', 1000.25, 1, 1, 1, 1, 1000.25, 1, 1, 1000.25, 10.2500, 10.2500),
  ('reg_g21_cr', 'C0002', 2000.50, 2, 2, 2, 2, 2000.50, 2, 2, 2000.50, 20.5000, 20.5000),
  ('reg_g21_cr', 'C0003', 3000.75, 3, 3, 3, 3, 3000.75, 3, 3, 3000.75, 30.7500, 30.7500),
  ('reg_g21_cr', 'C0004', 4001.00, 4, 4, 4, 4, 4001.00, 4, 4, 4001.00, 41.0000, 41.0000),
  ('reg_g21_cr', 'C0005', 5001.25, 5, 5, 5, 5, 5001.25, 5, 5, 5001.25, 51.2500, 51.2500);

-- Table: reg_item_dict
TRUNCATE TABLE `reg_item_dict`;
INSERT INTO `reg_item_dict` (`report_code`, `item_code`, `item_name`, `item_type`, `parent_code`, `sign_flag`, `sort_order`, `is_summary`) VALUES
  ('C0001', 'C0001', 'Item 1', 'Retail', 'C0001', 1, 1, 1),
  ('C0002', 'C0002', 'Item 2', 'Wealth', 'C0002', 0, 2, 0),
  ('C0003', 'C0003', 'Item 3', 'Credit', 'C0003', 1, 3, 1),
  ('C0004', 'C0004', 'Item 4', 'Risk', 'C0004', 0, 4, 0),
  ('C0005', 'C0005', 'Item 5', 'Operation', 'C0005', 1, 5, 1);

-- Table: reg_master
TRUNCATE TABLE `reg_master`;
INSERT INTO `reg_master` (`report_period`, `org_code`, `total_assets_w`, `total_liabilities_w`, `total_equity_w`, `total_loans_w`, `total_deposits_w`, `cet1_ratio`, `tier1_ratio`, `car_ratio`, `leverage_ratio`, `total_rwa_w`, `npl_balance_w`, `npl_ratio`, `provision_coverage`, `loan_provision_rate`, `lcr_ratio`, `nsfr_ratio`, `net_profit_w`, `roa`, `roe`, `is_car_ok`, `is_lcr_ok`, `is_npl_ok`, `is_provision_ok`, `compliance_score`, `g01_status`, `g03_status`, `g04a_status`, `g11_status`, `g21_status`, `process_time`) VALUES
  ('reg_master', 'C0001', 1, 1, 1, 1, 1, 0.0500, 0.0500, 0.0500, 26, 1, 1000.25, 0.0500, 26, 0.0500, 0.0500, 0.0500, 1000.25, 10.2500, 10.2500, 1, 1, 1, 1, 0.05, 'Normal', 'Normal', 'Normal', 'Normal', 'Normal', '2025-04-01 09:01:00'),
  ('reg_master', 'C0002', 2, 2, 2, 2, 2, 0.1000, 0.1000, 0.1000, 27, 2, 2000.50, 0.1000, 27, 0.1000, 0.1000, 0.1000, 2000.50, 20.5000, 20.5000, 0, 0, 0, 0, 0.10, 'Running', 'Running', 'Running', 'Running', 'Running', '2025-04-02 09:02:00'),
  ('reg_master', 'C0003', 3, 3, 3, 3, 3, 0.1500, 0.1500, 0.1500, 28, 3, 3000.75, 0.1500, 28, 0.1500, 0.1500, 0.1500, 3000.75, 30.7500, 30.7500, 1, 1, 1, 1, 0.15, 'Success', 'Success', 'Success', 'Success', 'Success', '2025-04-03 09:03:00'),
  ('reg_master', 'C0004', 4, 4, 4, 4, 4, 0.2000, 0.2000, 0.2000, 29, 4, 4001.00, 0.2000, 29, 0.2000, 0.2000, 0.2000, 4001.00, 41.0000, 41.0000, 0, 0, 0, 0, 0.20, 'Active', 'Active', 'Active', 'Active', 'Active', '2025-04-04 09:04:00'),
  ('reg_master', 'C0005', 5, 5, 5, 5, 5, 0.2500, 0.2500, 0.2500, 30, 5, 5001.25, 0.2500, 30, 0.2500, 0.2500, 0.2500, 5001.25, 51.2500, 51.2500, 1, 1, 1, 1, 0.25, 'Completed', 'Completed', 'Completed', 'Completed', 'Completed', '2025-04-05 09:05:00');

-- Table: reg_submit_log
TRUNCATE TABLE `reg_submit_log`;
INSERT INTO `reg_submit_log` (`log_id`, `report_code`, `report_period`, `org_code`, `action`, `operator`, `action_time`, `qc_score`, `fail_rules`, `remark`) VALUES
  ('reg_subm_001', 'C0001', 'reg_submit', 'C0001', 'reg_submit_log_actio', 'reg_submit_log_operator_1', '2025-04-01 09:01:00', 0.05, 'reg_submit_log_fail_rules_1', 'English mock description for reg_submit_log row 1'),
  ('reg_subm_002', 'C0002', 'reg_submit', 'C0002', 'reg_submit_log_actio', 'reg_submit_log_operator_2', '2025-04-02 09:02:00', 0.10, 'reg_submit_log_fail_rules_2', 'English mock description for reg_submit_log row 2'),
  ('reg_subm_003', 'C0003', 'reg_submit', 'C0003', 'reg_submit_log_actio', 'reg_submit_log_operator_3', '2025-04-03 09:03:00', 0.15, 'reg_submit_log_fail_rules_3', 'English mock description for reg_submit_log row 3'),
  ('reg_subm_004', 'C0004', 'reg_submit', 'C0004', 'reg_submit_log_actio', 'reg_submit_log_operator_4', '2025-04-04 09:04:00', 0.20, 'reg_submit_log_fail_rules_4', 'English mock description for reg_submit_log row 4'),
  ('reg_subm_005', 'C0005', 'reg_submit', 'C0005', 'reg_submit_log_actio', 'reg_submit_log_operator_5', '2025-04-05 09:05:00', 0.25, 'reg_submit_log_fail_rules_5', 'English mock description for reg_submit_log row 5');
