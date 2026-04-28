-- ================================================================
-- Database: bank_cdp
-- Type: English mock data
-- Source: generated from current Doris table metadata.
-- Execute after schema SQL.
-- ================================================================

CREATE DATABASE IF NOT EXISTS bank_cdp;
USE bank_cdp;

-- Table: aum_metrics
TRUNCATE TABLE `aum_metrics`;
INSERT INTO `aum_metrics` (`metric_date`, `product_type`, `aum_amount`, `client_count`, `avg_holding`, `inflow`, `yoy_growth`, `created_at`) VALUES
  ('2025-04-01', 'Retail', 10.25, 10, 10.25, 10.25, 0.05, '2025-04-01 09:01:00'),
  ('2025-04-02', 'Wealth', 20.50, 20, 20.50, 20.50, 0.10, '2025-04-02 09:02:00'),
  ('2025-04-03', 'Credit', 30.75, 30, 30.75, 30.75, 0.15, '2025-04-03 09:03:00'),
  ('2025-04-04', 'Risk', 41.00, 40, 41.00, 41.00, 0.20, '2025-04-04 09:04:00'),
  ('2025-04-05', 'Operation', 51.25, 50, 51.25, 51.25, 0.25, '2025-04-05 09:05:00');

-- Table: avatar_label
TRUNCATE TABLE `avatar_label`;
INSERT INTO `avatar_label` (`label_id`, `label_name`, `category`, `color`, `label_desc`, `label_embedding`, `user_count`, `create_time`) VALUES
  (10001, 'Label 1', 'Retail', 'avatar_label_col', 'English mock description for avatar_label row 1', [0.10, 0.20, 0.30, 0.40], 10, '2025-04-01 09:01:00'),
  (10002, 'Label 2', 'Wealth', 'avatar_label_col', 'English mock description for avatar_label row 2', [0.20, 0.30, 0.40, 0.50], 20, '2025-04-02 09:02:00'),
  (10003, 'Label 3', 'Credit', 'avatar_label_col', 'English mock description for avatar_label row 3', [0.30, 0.40, 0.50, 0.60], 30, '2025-04-03 09:03:00'),
  (10004, 'Label 4', 'Risk', 'avatar_label_col', 'English mock description for avatar_label row 4', [0.40, 0.50, 0.60, 0.70], 40, '2025-04-04 09:04:00'),
  (10005, 'Label 5', 'Operation', 'avatar_label_col', 'English mock description for avatar_label row 5', [0.50, 0.60, 0.70, 0.80], 50, '2025-04-05 09:05:00');

-- Table: bank_system_log
TRUNCATE TABLE `bank_system_log`;
INSERT INTO `bank_system_log` (`log_id`, `log_date`, `log_time`, `user_id`, `user_name`, `session_id`, `log_source`, `log_level`, `operation`, `ip_address`, `device_info`, `amount`, `result_code`, `error_msg`, `risk_score`, `log_content`, `created_at`) VALUES
  (10001, '2025-04-01', '2025-04-01 09:01:00', 'bank_sys_001', 'User 1', 'bank_sys_001', 'bank_system_log_log_source_1', 'L1', 'bank_system_log_operation_1', 'bank_system_log_ip_address_1', 'bank_system_log_device_info_1', 10.2500, 'C0001', 'bank_system_log_error_msg_1', 0.05, 'English mock description for bank_system_log row 1', '2025-04-01 09:01:00'),
  (10002, '2025-04-02', '2025-04-02 09:02:00', 'bank_sys_002', 'User 2', 'bank_sys_002', 'bank_system_log_log_source_2', 'L2', 'bank_system_log_operation_2', 'bank_system_log_ip_address_2', 'bank_system_log_device_info_2', 20.5000, 'C0002', 'bank_system_log_error_msg_2', 0.10, 'English mock description for bank_system_log row 2', '2025-04-02 09:02:00'),
  (10003, '2025-04-03', '2025-04-03 09:03:00', 'bank_sys_003', 'User 3', 'bank_sys_003', 'bank_system_log_log_source_3', 'L3', 'bank_system_log_operation_3', 'bank_system_log_ip_address_3', 'bank_system_log_device_info_3', 30.7500, 'C0003', 'bank_system_log_error_msg_3', 0.15, 'English mock description for bank_system_log row 3', '2025-04-03 09:03:00'),
  (10004, '2025-04-04', '2025-04-04 09:04:00', 'bank_sys_004', 'User 4', 'bank_sys_004', 'bank_system_log_log_source_4', 'L4', 'bank_system_log_operation_4', 'bank_system_log_ip_address_4', 'bank_system_log_device_info_4', 41.0000, 'C0004', 'bank_system_log_error_msg_4', 0.20, 'English mock description for bank_system_log row 4', '2025-04-04 09:04:00'),
  (10005, '2025-04-05', '2025-04-05 09:05:00', 'bank_sys_005', 'User 5', 'bank_sys_005', 'bank_system_log_log_source_5', 'L5', 'bank_system_log_operation_5', 'bank_system_log_ip_address_5', 'bank_system_log_device_info_5', 51.2500, 'C0005', 'bank_system_log_error_msg_5', 0.25, 'English mock description for bank_system_log row 5', '2025-04-05 09:05:00');

-- Table: bank_system_log_ai_result
TRUNCATE TABLE `bank_system_log_ai_result`;
INSERT INTO `bank_system_log_ai_result` (`log_id`, `log_content`, `ai_tag`) VALUES
  (10001, 'English mock description for bank_system_log_ai_result row 1', 'bank_system_log_ai_result_ai_tag_1'),
  (10002, 'English mock description for bank_system_log_ai_result row 2', 'bank_system_log_ai_result_ai_tag_2'),
  (10003, 'English mock description for bank_system_log_ai_result row 3', 'bank_system_log_ai_result_ai_tag_3'),
  (10004, 'English mock description for bank_system_log_ai_result row 4', 'bank_system_log_ai_result_ai_tag_4'),
  (10005, 'English mock description for bank_system_log_ai_result row 5', 'bank_system_log_ai_result_ai_tag_5');

-- Table: bank_system_log_bak
TRUNCATE TABLE `bank_system_log_bak`;
INSERT INTO `bank_system_log_bak` (`log_id`, `log_time`, `log_level`, `system_module`, `log_content`, `ip_addr`, `device_info`, `ai_tag`) VALUES
  (10001, '2025-04-01 09:01:00', 'L1', 'bank_system_log_bak_system_module_1', 'English mock description for bank_system_log_bak row 1', 'bank_system_log_bak_ip_addr_1', 'bank_system_log_bak_device_info_1', 'bank_system_log_bak_ai_tag_1'),
  (10002, '2025-04-02 09:02:00', 'L2', 'bank_system_log_bak_system_module_2', 'English mock description for bank_system_log_bak row 2', 'bank_system_log_bak_ip_addr_2', 'bank_system_log_bak_device_info_2', 'bank_system_log_bak_ai_tag_2'),
  (10003, '2025-04-03 09:03:00', 'L3', 'bank_system_log_bak_system_module_3', 'English mock description for bank_system_log_bak row 3', 'bank_system_log_bak_ip_addr_3', 'bank_system_log_bak_device_info_3', 'bank_system_log_bak_ai_tag_3'),
  (10004, '2025-04-04 09:04:00', 'L4', 'bank_system_log_bak_system_module_4', 'English mock description for bank_system_log_bak row 4', 'bank_system_log_bak_ip_addr_4', 'bank_system_log_bak_device_info_4', 'bank_system_log_bak_ai_tag_4'),
  (10005, '2025-04-05 09:05:00', 'L5', 'bank_system_log_bak_system_module_5', 'English mock description for bank_system_log_bak row 5', 'bank_system_log_bak_ip_addr_5', 'bank_system_log_bak_device_info_5', 'bank_system_log_bak_ai_tag_5');

-- Table: bank_system_log_tagged
TRUNCATE TABLE `bank_system_log_tagged`;
INSERT INTO `bank_system_log_tagged` (`log_id`, `log_date`, `log_time`, `user_id`, `user_name`, `log_source`, `operation`, `amount`, `risk_score`, `log_content`, `ai_tag`, `ai_tag_group`, `is_exception`, `is_risk`, `classify_time`, `classify_method`) VALUES
  (10001, '2025-04-01', '2025-04-01 09:01:00', 'bank_sys_001', 'User 1', 'bank_system_log_tagged_log_sourc', 'bank_system_log_tagged_operation_1', 10.2500, 0.05, 'English mock description for bank_system_log_tagged row 1', 'bank_system_log_tagged_ai_tag_1', 'bank_system_log_', 1, 1, '2025-04-01 09:01:00', 'bank_system_log_'),
  (10002, '2025-04-02', '2025-04-02 09:02:00', 'bank_sys_002', 'User 2', 'bank_system_log_tagged_log_sourc', 'bank_system_log_tagged_operation_2', 20.5000, 0.10, 'English mock description for bank_system_log_tagged row 2', 'bank_system_log_tagged_ai_tag_2', 'bank_system_log_', 0, 0, '2025-04-02 09:02:00', 'bank_system_log_'),
  (10003, '2025-04-03', '2025-04-03 09:03:00', 'bank_sys_003', 'User 3', 'bank_system_log_tagged_log_sourc', 'bank_system_log_tagged_operation_3', 30.7500, 0.15, 'English mock description for bank_system_log_tagged row 3', 'bank_system_log_tagged_ai_tag_3', 'bank_system_log_', 1, 1, '2025-04-03 09:03:00', 'bank_system_log_'),
  (10004, '2025-04-04', '2025-04-04 09:04:00', 'bank_sys_004', 'User 4', 'bank_system_log_tagged_log_sourc', 'bank_system_log_tagged_operation_4', 41.0000, 0.20, 'English mock description for bank_system_log_tagged row 4', 'bank_system_log_tagged_ai_tag_4', 'bank_system_log_', 0, 0, '2025-04-04 09:04:00', 'bank_system_log_'),
  (10005, '2025-04-05', '2025-04-05 09:05:00', 'bank_sys_005', 'User 5', 'bank_system_log_tagged_log_sourc', 'bank_system_log_tagged_operation_5', 51.2500, 0.25, 'English mock description for bank_system_log_tagged row 5', 'bank_system_log_tagged_ai_tag_5', 'bank_system_log_', 1, 1, '2025-04-05 09:05:00', 'bank_system_log_');

-- Table: bank_system_log_with_ai
TRUNCATE TABLE `bank_system_log_with_ai`;
INSERT INTO `bank_system_log_with_ai` (`log_id`, `log_time`, `log_level`, `system_module`, `log_content`, `ai_tag`) VALUES
  (10001, '2025-04-01 09:01:00', 'L1', 'bank_system_log_with_ai_system_module_1', 'English mock description for bank_system_log_with_ai row 1', 'bank_system_log_with_ai_ai_tag_1'),
  (10002, '2025-04-02 09:02:00', 'L2', 'bank_system_log_with_ai_system_module_2', 'English mock description for bank_system_log_with_ai row 2', 'bank_system_log_with_ai_ai_tag_2'),
  (10003, '2025-04-03 09:03:00', 'L3', 'bank_system_log_with_ai_system_module_3', 'English mock description for bank_system_log_with_ai row 3', 'bank_system_log_with_ai_ai_tag_3'),
  (10004, '2025-04-04 09:04:00', 'L4', 'bank_system_log_with_ai_system_module_4', 'English mock description for bank_system_log_with_ai row 4', 'bank_system_log_with_ai_ai_tag_4'),
  (10005, '2025-04-05 09:05:00', 'L5', 'bank_system_log_with_ai_system_module_5', 'English mock description for bank_system_log_with_ai row 5', 'bank_system_log_with_ai_ai_tag_5');

-- Table: biz_metrics
TRUNCATE TABLE `biz_metrics`;
INSERT INTO `biz_metrics` (`metric_date`, `metric_type`, `amount`, `yoy_growth`, `mom_growth`, `target_amount`, `created_at`) VALUES
  ('2025-04-01', 'Revenue', 10.25, 0.05, 0.05, 10.25, '2025-04-01 09:01:00'),
  ('2025-04-02', 'Cost', 20.50, 0.10, 0.10, 20.50, '2025-04-02 09:02:00'),
  ('2025-04-03', 'Profit', 30.75, 0.15, 0.15, 30.75, '2025-04-03 09:03:00'),
  ('2025-04-04', 'GMV', 41.00, 0.20, 0.20, 41.00, '2025-04-04 09:04:00'),
  ('2025-04-05', 'Fee', 51.25, 0.25, 0.25, 51.25, '2025-04-05 09:05:00');

-- Table: bj_metro_daily_flow
TRUNCATE TABLE `bj_metro_daily_flow`;
INSERT INTO `bj_metro_daily_flow` (`flow_date`, `station_id`, `line_id`, `inbound_count`, `outbound_count`, `peak_inbound`) VALUES
  ('2025-04-01', 'bj_metro_001', 'bj_metro_0', 10, 10, 1),
  ('2025-04-02', 'bj_metro_002', 'bj_metro_0', 20, 20, 2),
  ('2025-04-03', 'bj_metro_003', 'bj_metro_0', 30, 30, 3),
  ('2025-04-04', 'bj_metro_004', 'bj_metro_0', 40, 40, 4),
  ('2025-04-05', 'bj_metro_005', 'bj_metro_0', 50, 50, 5);

-- Table: bj_metro_fault_log
TRUNCATE TABLE `bj_metro_fault_log`;
INSERT INTO `bj_metro_fault_log` (`fault_id`, `fault_time`, `line_id`, `station_id`, `device_type`, `fault_type`, `severity`, `description`, `resolve_time`, `resolve_min`, `status`, `handler`) VALUES
  ('bj_metro_001', '2025-04-01 09:01:00', 'bj_metro_0', 'bj_metro_001', 'Retail', 'Retail', 'bj_metro_fault_log_s', 'English mock description for bj_metro_fault_log row 1', '2025-04-01 09:01:00', 1, 'Normal', 'bj_metro_fault_log_handler_1'),
  ('bj_metro_002', '2025-04-02 09:02:00', 'bj_metro_0', 'bj_metro_002', 'Wealth', 'Wealth', 'bj_metro_fault_log_s', 'English mock description for bj_metro_fault_log row 2', '2025-04-02 09:02:00', 2, 'Running', 'bj_metro_fault_log_handler_2'),
  ('bj_metro_003', '2025-04-03 09:03:00', 'bj_metro_0', 'bj_metro_003', 'Credit', 'Credit', 'bj_metro_fault_log_s', 'English mock description for bj_metro_fault_log row 3', '2025-04-03 09:03:00', 3, 'Success', 'bj_metro_fault_log_handler_3'),
  ('bj_metro_004', '2025-04-04 09:04:00', 'bj_metro_0', 'bj_metro_004', 'Risk', 'Risk', 'bj_metro_fault_log_s', 'English mock description for bj_metro_fault_log row 4', '2025-04-04 09:04:00', 4, 'Active', 'bj_metro_fault_log_handler_4'),
  ('bj_metro_005', '2025-04-05 09:05:00', 'bj_metro_0', 'bj_metro_005', 'Operation', 'Operation', 'bj_metro_fault_log_s', 'English mock description for bj_metro_fault_log row 5', '2025-04-05 09:05:00', 5, 'Completed', 'bj_metro_fault_log_handler_5');

-- Table: bj_metro_hourly_flow
TRUNCATE TABLE `bj_metro_hourly_flow`;
INSERT INTO `bj_metro_hourly_flow` (`flow_date`, `flow_hour`, `line_id`, `total_passengers`, `overcapacity_cnt`) VALUES
  ('2025-04-01', 1, 'bj_metro_0', 1, 10),
  ('2025-04-02', 2, 'bj_metro_0', 2, 20),
  ('2025-04-03', 3, 'bj_metro_0', 3, 30),
  ('2025-04-04', 4, 'bj_metro_0', 4, 40),
  ('2025-04-05', 5, 'bj_metro_0', 5, 50);

-- Table: bj_metro_lines
TRUNCATE TABLE `bj_metro_lines`;
INSERT INTO `bj_metro_lines` (`line_id`, `line_name`, `line_color`, `total_stations`, `total_length_km`, `open_year`, `daily_capacity_w`, `peak_interval_s`, `offpeak_interval_s`, `status`) VALUES
  ('bj_metro_0', 'Line 1', 'bj_metro_l', 1, 10.25, 1, 1, 1, 1, 'Normal'),
  ('bj_metro_0', 'Line 2', 'bj_metro_l', 2, 20.50, 2, 2, 2, 2, 'Running'),
  ('bj_metro_0', 'Line 3', 'bj_metro_l', 3, 30.75, 3, 3, 3, 3, 'Success'),
  ('bj_metro_0', 'Line 4', 'bj_metro_l', 4, 41.00, 4, 4, 4, 4, 'Active'),
  ('bj_metro_0', 'Line 5', 'bj_metro_l', 5, 51.25, 5, 5, 5, 5, 'Completed');

-- Table: bj_metro_train_ops
TRUNCATE TABLE `bj_metro_train_ops`;
INSERT INTO `bj_metro_train_ops` (`ops_date`, `line_id`, `planned_trains`, `actual_trains`, `punctuality_rate`, `delay_count`, `max_delay_sec`, `total_mileage_km`, `fault_count`) VALUES
  ('2025-04-01', 'bj_metro_0', 1, 1, 0.0500, 10, 1, 26, 10),
  ('2025-04-02', 'bj_metro_0', 2, 2, 0.1000, 20, 2, 27, 20),
  ('2025-04-03', 'bj_metro_0', 3, 3, 0.1500, 30, 3, 28, 30),
  ('2025-04-04', 'bj_metro_0', 4, 4, 0.2000, 40, 4, 29, 40),
  ('2025-04-05', 'bj_metro_0', 5, 5, 0.2500, 50, 5, 30, 50);

-- Table: db_call_log
TRUNCATE TABLE `db_call_log`;
INSERT INTO `db_call_log` (`trace_id`, `span_id`, `call_time`, `operation`, `table_name`, `sql_text`, `duration_ms`, `rows_returned`, `offset_ms`, `error_message`) VALUES
  ('db_call__001', 'db_call__001', '2025-04-01 09:01:00', 'db_call_log_oper', 'Table 1', 'INSERT INTO target_table SELECT * FROM source_table', 0.0500, 1, 1, 'English mock description for db_call_log row 1'),
  ('db_call__002', 'db_call__002', '2025-04-02 09:02:00', 'db_call_log_oper', 'Table 2', 'INSERT INTO target_table SELECT * FROM source_table', 0.1000, 2, 2, 'English mock description for db_call_log row 2'),
  ('db_call__003', 'db_call__003', '2025-04-03 09:03:00', 'db_call_log_oper', 'Table 3', 'INSERT INTO target_table SELECT * FROM source_table', 0.1500, 3, 3, 'English mock description for db_call_log row 3'),
  ('db_call__004', 'db_call__004', '2025-04-04 09:04:00', 'db_call_log_oper', 'Table 4', 'INSERT INTO target_table SELECT * FROM source_table', 0.2000, 4, 4, 'English mock description for db_call_log row 4'),
  ('db_call__005', 'db_call__005', '2025-04-05 09:05:00', 'db_call_log_oper', 'Table 5', 'INSERT INTO target_table SELECT * FROM source_table', 0.2500, 5, 5, 'English mock description for db_call_log row 5');

-- Table: fund_basic
TRUNCATE TABLE `fund_basic`;
INSERT INTO `fund_basic` (`fund_id`, `fund_name`, `fund_type`, `sector_tag`, `manager_id`, `risk_level`, `fee_rate`, `inception_date`, `nav_yesterday`, `cumulative_nav`, `realtime_iopv`, `iopv_deviation`, `capital_inflow`, `capital_outflow`, `capital_net`, `trade_status`, `ret_1m`, `ret_3m`, `ret_6m`, `ret_1y`, `ret_inception`, `sharpe`, `sortino`, `alpha`, `beta`, `max_drawdown`, `volatility`, `update_ts`) VALUES
  ('fund_bas_0', 'Fund 1', 'Retail', 'fund_basic_sector_ta', 'fund_bas_0', 1, 0.0500, '2025-04-01', 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 'Normal', 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, '2025-04-01 09:01:00'),
  ('fund_bas_0', 'Fund 2', 'Wealth', 'fund_basic_sector_ta', 'fund_bas_0', 2, 0.1000, '2025-04-02', 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 'Running', 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, '2025-04-02 09:02:00'),
  ('fund_bas_0', 'Fund 3', 'Credit', 'fund_basic_sector_ta', 'fund_bas_0', 3, 0.1500, '2025-04-03', 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 'Success', 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, '2025-04-03 09:03:00'),
  ('fund_bas_0', 'Fund 4', 'Risk', 'fund_basic_sector_ta', 'fund_bas_0', 4, 0.2000, '2025-04-04', 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 'Active', 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, '2025-04-04 09:04:00'),
  ('fund_bas_0', 'Fund 5', 'Operation', 'fund_basic_sector_ta', 'fund_bas_0', 5, 0.2500, '2025-04-05', 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 'Completed', 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, '2025-04-05 09:05:00');

-- Table: fund_manager
TRUNCATE TABLE `fund_manager`;
INSERT INTO `fund_manager` (`manager_id`, `name`, `tenure_years`, `aum_bn`, `style_tag`, `turnover_rate`, `avg_alpha`, `total_return`, `max_drawdown`, `sharpe`) VALUES
  ('fund_man_0', 'Fund Manager 1', 1.1100, 1000.25, 'fund_manager_style_t', 0.0500, 1.1100, 1.1100, 1.1100, 1.1100),
  ('fund_man_0', 'Fund Manager 2', 2.2200, 2000.50, 'fund_manager_style_t', 0.1000, 2.2200, 2.2200, 2.2200, 2.2200),
  ('fund_man_0', 'Fund Manager 3', 3.3300, 3000.75, 'fund_manager_style_t', 0.1500, 3.3300, 3.3300, 3.3300, 3.3300),
  ('fund_man_0', 'Fund Manager 4', 4.4400, 4001.00, 'fund_manager_style_t', 0.2000, 4.4400, 4.4400, 4.4400, 4.4400),
  ('fund_man_0', 'Fund Manager 5', 5.5500, 5001.25, 'fund_manager_style_t', 0.2500, 5.5500, 5.5500, 5.5500, 5.5500);

-- Table: fund_nav_history
TRUNCATE TABLE `fund_nav_history`;
INSERT INTO `fund_nav_history` (`trade_date`, `fund_id`, `nav`, `cumulative_nav`, `daily_return`, `benchmark_ret`, `excess_ret`, `drawdown`, `rolling_sharpe`, `rolling_alpha`, `script_name`, `script_color`) VALUES
  ('2025-04-01', 'fund_nav_0', 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 'Script 1', 'fund_nav_h'),
  ('2025-04-02', 'fund_nav_0', 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 'Script 2', 'fund_nav_h'),
  ('2025-04-03', 'fund_nav_0', 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 'Script 3', 'fund_nav_h'),
  ('2025-04-04', 'fund_nav_0', 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 'Script 4', 'fund_nav_h'),
  ('2025-04-05', 'fund_nav_0', 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 'Script 5', 'fund_nav_h');

-- Table: fund_position
TRUNCATE TABLE `fund_position`;
INSERT INTO `fund_position` (`fund_id`, `report_date`, `stock_code`, `stock_name`, `sector_l1`, `weight_pct`, `market_value_mn`, `price_contrib`, `alpha_contrib`) VALUES
  ('fund_pos_0', '2025-04-01', 'C0001', 'Stock 1', 'fund_position_sector', 0.0500, 1.1100, 1000.25, 1.1100),
  ('fund_pos_0', '2025-04-02', 'C0002', 'Stock 2', 'fund_position_sector', 0.1000, 2.2200, 2000.50, 2.2200),
  ('fund_pos_0', '2025-04-03', 'C0003', 'Stock 3', 'fund_position_sector', 0.1500, 3.3300, 3000.75, 3.3300),
  ('fund_pos_0', '2025-04-04', 'C0004', 'Stock 4', 'fund_position_sector', 0.2000, 4.4400, 4001.00, 4.4400),
  ('fund_pos_0', '2025-04-05', 'C0005', 'Stock 5', 'fund_position_sector', 0.2500, 5.5500, 5001.25, 5.5500);

-- Table: ground_station
TRUNCATE TABLE `ground_station`;
INSERT INTO `ground_station` (`station_id`, `station_name`, `location`, `latitude`, `longitude`, `station_type`, `status`, `antenna_count`, `coverage_radius_km`, `daily_contacts`, `uptime_pct`) VALUES
  (10001, 'Station 1', 'ground_station_location_1', 1.1100, 1.1100, 'Retail', 'Normal', 10, 26, 1, 0.0500),
  (10002, 'Station 2', 'ground_station_location_2', 2.2200, 2.2200, 'Wealth', 'Running', 20, 27, 2, 0.1000),
  (10003, 'Station 3', 'ground_station_location_3', 3.3300, 3.3300, 'Credit', 'Success', 30, 28, 3, 0.1500),
  (10004, 'Station 4', 'ground_station_location_4', 4.4400, 4.4400, 'Risk', 'Active', 40, 29, 4, 0.2000),
  (10005, 'Station 5', 'ground_station_location_5', 5.5500, 5.5500, 'Operation', 'Completed', 50, 30, 5, 0.2500);

-- Table: mdm_jfmat
TRUNCATE TABLE `mdm_jfmat`;
INSERT INTO `mdm_jfmat` (`code`, `active`, `property_full`, `material_name`, `thread_spec`, `performance_grade`, `standard_code`) VALUES
  ('C0001', 1, 'mdm_jfmat_property_full_1', 'Material 1', 'mdm_jfmat_thread_spec_1', 'mdm_jfmat_performance_grade_1', 'C0001'),
  ('C0002', 2, 'mdm_jfmat_property_full_2', 'Material 2', 'mdm_jfmat_thread_spec_2', 'mdm_jfmat_performance_grade_2', 'C0002'),
  ('C0003', 3, 'mdm_jfmat_property_full_3', 'Material 3', 'mdm_jfmat_thread_spec_3', 'mdm_jfmat_performance_grade_3', 'C0003'),
  ('C0004', 4, 'mdm_jfmat_property_full_4', 'Material 4', 'mdm_jfmat_thread_spec_4', 'mdm_jfmat_performance_grade_4', 'C0004'),
  ('C0005', 5, 'mdm_jfmat_property_full_5', 'Material 5', 'mdm_jfmat_thread_spec_5', 'mdm_jfmat_performance_grade_5', 'C0005');

-- Table: mfg_metrics_v2
TRUNCATE TABLE `mfg_metrics_v2`;
INSERT INTO `mfg_metrics_v2` (`ts`, `machine_id`, `line_id`, `machine_type`, `script_name`, `script_color`, `temperature`, `bearing_temp`, `coolant_temp`, `vibration`, `noise_level`, `spindle_speed`, `feed_rate`, `cutting_force`, `torque`, `motor_current`, `power_kw`, `hydraulic_bar`, `air_pressure`, `coolant_flow`, `tool_wear_pct`, `oee`, `availability`, `performance_rate`, `quality_rate`, `output_count`, `planned_output`, `defect_count`, `scrap_count`, `rework_count`, `cycle_time_s`, `plan_cycle_s`, `run_hours`, `yield_rate`, `first_pass_yield`, `scrap_rate`, `rework_rate`, `cpk_value`, `ppm_value`, `surface_roughness`, `dimensional_error`, `hardness_hrc`, `tensile_strength`, `energy_kwh`, `energy_per_unit`, `co2_kg`, `env_temp`, `env_humidity`, `coolant_consumed_l`, `compressed_air_m3`, `water_l`, `tool_change_cnt`, `alarm_count`, `unplanned_down_min`, `planned_down_min`, `mtbf_h`) VALUES
  ('2025-04-01 09:01:00', 'mfg_metr_001', 'mfg_metr_0', 'Retail', 'Script 1', 'mfg_metric', 1.1100, 1.1100, 1.1100, 0.0500, 1, 1, 0.0500, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 0.0500, 1.1100, 1.1100, 0.0500, 0.0500, 10, 1, 10, 10, 10, 1.1100, 1.1100, 1.1100, 0.0500, 1.1100, 0.0500, 0.0500, 1.1100, 1, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 10, 10, 1.1100, 1.1100, 1.1100),
  ('2025-04-02 09:02:00', 'mfg_metr_002', 'mfg_metr_0', 'Wealth', 'Script 2', 'mfg_metric', 2.2200, 2.2200, 2.2200, 0.1000, 2, 2, 0.1000, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 0.1000, 2.2200, 2.2200, 0.1000, 0.1000, 20, 2, 20, 20, 20, 2.2200, 2.2200, 2.2200, 0.1000, 2.2200, 0.1000, 0.1000, 2.2200, 2, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 20, 20, 2.2200, 2.2200, 2.2200),
  ('2025-04-03 09:03:00', 'mfg_metr_003', 'mfg_metr_0', 'Credit', 'Script 3', 'mfg_metric', 3.3300, 3.3300, 3.3300, 0.1500, 3, 3, 0.1500, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 0.1500, 3.3300, 3.3300, 0.1500, 0.1500, 30, 3, 30, 30, 30, 3.3300, 3.3300, 3.3300, 0.1500, 3.3300, 0.1500, 0.1500, 3.3300, 3, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 30, 30, 3.3300, 3.3300, 3.3300),
  ('2025-04-04 09:04:00', 'mfg_metr_004', 'mfg_metr_0', 'Risk', 'Script 4', 'mfg_metric', 4.4400, 4.4400, 4.4400, 0.2000, 4, 4, 0.2000, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 0.2000, 4.4400, 4.4400, 0.2000, 0.2000, 40, 4, 40, 40, 40, 4.4400, 4.4400, 4.4400, 0.2000, 4.4400, 0.2000, 0.2000, 4.4400, 4, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 40, 40, 4.4400, 4.4400, 4.4400),
  ('2025-04-05 09:05:00', 'mfg_metr_005', 'mfg_metr_0', 'Operation', 'Script 5', 'mfg_metric', 5.5500, 5.5500, 5.5500, 0.2500, 5, 5, 0.2500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 0.2500, 5.5500, 5.5500, 0.2500, 0.2500, 50, 5, 50, 50, 50, 5.5500, 5.5500, 5.5500, 0.2500, 5.5500, 0.2500, 0.2500, 5.5500, 5, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 50, 50, 5.5500, 5.5500, 5.5500);

-- Table: mfg_production_metrics
TRUNCATE TABLE `mfg_production_metrics`;
INSERT INTO `mfg_production_metrics` (`ts`, `machine_id`, `line_id`, `temperature`, `vibration`, `output_count`, `defect_count`, `oee`, `yield_rate`, `script_name`, `script_color`) VALUES
  ('2025-04-01 09:01:00', 'mfg_prod_001', 'mfg_prod_0', 1.1100, 0.0500, 10, 10, 1.1100, 0.0500, 'Script 1', 'mfg_produc'),
  ('2025-04-02 09:02:00', 'mfg_prod_002', 'mfg_prod_0', 2.2200, 0.1000, 20, 20, 2.2200, 0.1000, 'Script 2', 'mfg_produc'),
  ('2025-04-03 09:03:00', 'mfg_prod_003', 'mfg_prod_0', 3.3300, 0.1500, 30, 30, 3.3300, 0.1500, 'Script 3', 'mfg_produc'),
  ('2025-04-04 09:04:00', 'mfg_prod_004', 'mfg_prod_0', 4.4400, 0.2000, 40, 40, 4.4400, 0.2000, 'Script 4', 'mfg_produc'),
  ('2025-04-05 09:05:00', 'mfg_prod_005', 'mfg_prod_0', 5.5500, 0.2500, 50, 50, 5.5500, 0.2500, 'Script 5', 'mfg_produc');

-- Table: news_article
TRUNCATE TABLE `news_article`;
INSERT INTO `news_article` (`article_id`, `publish_ts`, `title`, `content`, `source`, `sector_tag`, `ai_summary`, `summarized`, `ai_sentiment`, `sentiment_score`, `sentiment_done`, `ai_extract`, `extracted`, `ai_method`) VALUES
  ('news_art_001', '2025-04-01 09:01:00', 'Title 1', 'English mock description for news_article row 1', 'news_article_source_1', 'news_article_sector_tag_1', 'news_article_ai_summary_1', 1, '2025-04-01', 1, 1, 'news_article_ai_extract_1', 1, 'news_article_ai_meth'),
  ('news_art_002', '2025-04-02 09:02:00', 'Title 2', 'English mock description for news_article row 2', 'news_article_source_2', 'news_article_sector_tag_2', 'news_article_ai_summary_2', 2, '2025-04-02', 2, 2, 'news_article_ai_extract_2', 2, 'news_article_ai_meth'),
  ('news_art_003', '2025-04-03 09:03:00', 'Title 3', 'English mock description for news_article row 3', 'news_article_source_3', 'news_article_sector_tag_3', 'news_article_ai_summary_3', 3, '2025-04-03', 3, 3, 'news_article_ai_extract_3', 3, 'news_article_ai_meth'),
  ('news_art_004', '2025-04-04 09:04:00', 'Title 4', 'English mock description for news_article row 4', 'news_article_source_4', 'news_article_sector_tag_4', 'news_article_ai_summary_4', 4, '2025-04-04', 4, 4, 'news_article_ai_extract_4', 4, 'news_article_ai_meth'),
  ('news_art_005', '2025-04-05 09:05:00', 'Title 5', 'English mock description for news_article row 5', 'news_article_source_5', 'news_article_sector_tag_5', 'news_article_ai_summary_5', 5, '2025-04-05', 5, 5, 'news_article_ai_extract_5', 5, 'news_article_ai_meth');

-- Table: position_metrics
TRUNCATE TABLE `position_metrics`;
INSERT INTO `position_metrics` (`metric_date`, `asset_class`, `position_amount`, `position_ratio`, `market_value`, `profit_loss`, `pl_ratio`, `created_at`) VALUES
  ('2025-04-01', 'position_metrics_asset_class_1', 10.25, 0.05, 10.25, 10.25, 0.05, '2025-04-01 09:01:00'),
  ('2025-04-02', 'position_metrics_asset_class_2', 20.50, 0.10, 20.50, 20.50, 0.10, '2025-04-02 09:02:00'),
  ('2025-04-03', 'position_metrics_asset_class_3', 30.75, 0.15, 30.75, 30.75, 0.15, '2025-04-03 09:03:00'),
  ('2025-04-04', 'position_metrics_asset_class_4', 41.00, 0.20, 41.00, 41.00, 0.20, '2025-04-04 09:04:00'),
  ('2025-04-05', 'position_metrics_asset_class_5', 51.25, 0.25, 51.25, 51.25, 0.25, '2025-04-05 09:05:00');

-- Table: product_marketing
TRUNCATE TABLE `product_marketing`;
INSERT INTO `product_marketing` (`metric_date`, `product_name`, `category`, `sales_amount`, `sales_count`, `success_rate`, `customer_acquisition`, `repurchase_rate`, `rating`, `created_at`) VALUES
  ('2025-04-01', 'Product 1', 'Retail', 10.25, 10, 0.05, 1, 0.05, 10.2, '2025-04-01 09:01:00'),
  ('2025-04-02', 'Product 2', 'Wealth', 20.50, 20, 0.10, 2, 0.10, 20.5, '2025-04-02 09:02:00'),
  ('2025-04-03', 'Product 3', 'Credit', 30.75, 30, 0.15, 3, 0.15, 30.8, '2025-04-03 09:03:00'),
  ('2025-04-04', 'Product 4', 'Risk', 41.00, 40, 0.20, 4, 0.20, 41.0, '2025-04-04 09:04:00'),
  ('2025-04-05', 'Product 5', 'Operation', 51.25, 50, 0.25, 5, 0.25, 51.2, '2025-04-05 09:05:00');

-- Table: risk_metrics
TRUNCATE TABLE `risk_metrics`;
INSERT INTO `risk_metrics` (`metric_date`, `risk_level`, `exposure_amount`, `default_count`, `default_rate`, `coverage_ratio`, `overdue_amount`, `created_at`) VALUES
  ('2025-04-01', 'Low', 10.25, 10, 0.0500, 26, 10.25, '2025-04-01 09:01:00'),
  ('2025-04-02', 'Medium', 20.50, 20, 0.1000, 27, 20.50, '2025-04-02 09:02:00'),
  ('2025-04-03', 'High', 30.75, 30, 0.1500, 28, 30.75, '2025-04-03 09:03:00'),
  ('2025-04-04', 'Critical', 41.00, 40, 0.2000, 29, 41.00, '2025-04-04 09:04:00'),
  ('2025-04-05', 'Low', 51.25, 50, 0.2500, 30, 51.25, '2025-04-05 09:05:00');

-- Table: satellite_collect_data
TRUNCATE TABLE `satellite_collect_data`;
INSERT INTO `satellite_collect_data` (`id`, `satellite_id`, `satellite_name`, `satellite_type`, `sensor_id`, `collect_time`, `data_type`, `target_id`, `target_type`, `longitude`, `latitude`, `data_quality`, `data_size`, `status`, `task_id`, `created_at`) VALUES
  (10001, 'satellit_001', 'Satellite 1', 'Retail', 'satellit_001', 1, 'Retail', 'satellit_001', 'Retail', 10.250000, 10.250000, 1, 1, 'Normal', 'satellit_001', 1),
  (10002, 'satellit_002', 'Satellite 2', 'Wealth', 'satellit_002', 2, 'Wealth', 'satellit_002', 'Wealth', 20.500000, 20.500000, 2, 2, 'Running', 'satellit_002', 2),
  (10003, 'satellit_003', 'Satellite 3', 'Credit', 'satellit_003', 3, 'Credit', 'satellit_003', 'Credit', 30.750000, 30.750000, 3, 3, 'Success', 'satellit_003', 3),
  (10004, 'satellit_004', 'Satellite 4', 'Risk', 'satellit_004', 4, 'Risk', 'satellit_004', 'Risk', 41.000000, 41.000000, 4, 4, 'Active', 'satellit_004', 4),
  (10005, 'satellit_005', 'Satellite 5', 'Operation', 'satellit_005', 5, 'Operation', 'satellit_005', 'Operation', 51.250000, 51.250000, 5, 5, 'Completed', 'satellit_005', 5);

-- Table: satellite_info
TRUNCATE TABLE `satellite_info`;
INSERT INTO `satellite_info` (`satellite_id`, `satellite_name`, `satellite_type`, `orbit_type`, `launch_date`, `status`, `operator`, `country`, `altitude_km`, `inclination_deg`, `period_min`, `payload_type`, `mass_kg`) VALUES
  (10001, 'Satellite 1', 'Retail', 'Retail', '2025-04-01', 'Normal', 'satellite_info_operator_1', 'satellite_info_count', 1.1100, 1.1100, 1.1100, 'Retail', 1.1100),
  (10002, 'Satellite 2', 'Wealth', 'Wealth', '2025-04-02', 'Running', 'satellite_info_operator_2', 'satellite_info_count', 2.2200, 2.2200, 2.2200, 'Wealth', 2.2200),
  (10003, 'Satellite 3', 'Credit', 'Credit', '2025-04-03', 'Success', 'satellite_info_operator_3', 'satellite_info_count', 3.3300, 3.3300, 3.3300, 'Credit', 3.3300),
  (10004, 'Satellite 4', 'Risk', 'Risk', '2025-04-04', 'Active', 'satellite_info_operator_4', 'satellite_info_count', 4.4400, 4.4400, 4.4400, 'Risk', 4.4400),
  (10005, 'Satellite 5', 'Operation', 'Operation', '2025-04-05', 'Completed', 'satellite_info_operator_5', 'satellite_info_count', 5.5500, 5.5500, 5.5500, 'Operation', 5.5500);

-- Table: satellite_task
TRUNCATE TABLE `satellite_task`;
INSERT INTO `satellite_task` (`task_id`, `satellite_id`, `task_type`, `task_time`, `target_area`, `priority`, `status`, `duration_min`, `data_volume_gb`, `resolution_m`, `coverage_km2`) VALUES
  (10001, 10001, 'Retail', '2025-04-01 09:01:00', 'satellite_task_target_area_1', 1, 'Normal', 0.0500, 1.1100, 1.1100, 26),
  (10002, 10002, 'Wealth', '2025-04-02 09:02:00', 'satellite_task_target_area_2', 2, 'Running', 0.1000, 2.2200, 2.2200, 27),
  (10003, 10003, 'Credit', '2025-04-03 09:03:00', 'satellite_task_target_area_3', 3, 'Success', 0.1500, 3.3300, 3.3300, 28),
  (10004, 10004, 'Risk', '2025-04-04 09:04:00', 'satellite_task_target_area_4', 4, 'Active', 0.2000, 4.4400, 4.4400, 29),
  (10005, 10005, 'Operation', '2025-04-05 09:05:00', 'satellite_task_target_area_5', 5, 'Completed', 0.2500, 5.5500, 5.5500, 30);

-- Table: satellite_telemetry
TRUNCATE TABLE `satellite_telemetry`;
INSERT INTO `satellite_telemetry` (`record_id`, `satellite_id`, `record_time`, `battery_pct`, `solar_power_w`, `cpu_temp_c`, `signal_strength_db`, `orbit_altitude_km`, `attitude_roll`, `attitude_pitch`, `attitude_yaw`, `anomaly_flag`) VALUES
  (10001, 10001, '2025-04-01 09:01:00', 0.0500, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1),
  (10002, 10002, '2025-04-02 09:02:00', 0.1000, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 0),
  (10003, 10003, '2025-04-03 09:03:00', 0.1500, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 1),
  (10004, 10004, '2025-04-04 09:04:00', 0.2000, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 0),
  (10005, 10005, '2025-04-05 09:05:00', 0.2500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 1);

-- Table: satellite_telemetry_hf
TRUNCATE TABLE `satellite_telemetry_hf`;
INSERT INTO `satellite_telemetry_hf` (`record_id`, `satellite_id`, `record_time`, `battery_pct`, `solar_power_w`, `cpu_temp_c`, `thermal_payload_c`, `signal_strength_db`, `link_snr_db`, `orbit_altitude_km`, `attitude_error_deg`, `data_buffer_pct`, `anomaly_flag`) VALUES
  (10001, 10001, '2025-04-01 09:01:00', 0.0500, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 0.0500, 1),
  (10002, 10002, '2025-04-02 09:02:00', 0.1000, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 0.1000, 0),
  (10003, 10003, '2025-04-03 09:03:00', 0.1500, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 0.1500, 1),
  (10004, 10004, '2025-04-04 09:04:00', 0.2000, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 0.2000, 0),
  (10005, 10005, '2025-04-05 09:05:00', 0.2500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 0.2500, 1);

-- Table: sec_account_snapshot
TRUNCATE TABLE `sec_account_snapshot`;
INSERT INTO `sec_account_snapshot` (`account_id`, `client_name`, `branch_id`, `branch_name`, `rm_name`, `client_tier`, `risk_level`, `total_asset`, `cash_amt`, `market_value`, `unrealized_pnl`, `pnl_pct`, `margin_debt`, `maintenance_ratio`, `concentration_pct`, `position_count`, `trade_count_today`, `turnover_today`, `last_trade_ts`, `update_ts`) VALUES
  ('sec_acco_001', 'Client 1', 'sec_acco_0', 'Branch 1', 'Rm 1', 'sec_account_snapshot', 1, 1.1100, 1.1100, 1.1100, 1.1100, 0.0500, 1.1100, 0.0500, 0.0500, 10, 10, 1.1100, '2025-04-01 09:01:00', '2025-04-01 09:01:00'),
  ('sec_acco_002', 'Client 2', 'sec_acco_0', 'Branch 2', 'Rm 2', 'sec_account_snapshot', 2, 2.2200, 2.2200, 2.2200, 2.2200, 0.1000, 2.2200, 0.1000, 0.1000, 20, 20, 2.2200, '2025-04-02 09:02:00', '2025-04-02 09:02:00'),
  ('sec_acco_003', 'Client 3', 'sec_acco_0', 'Branch 3', 'Rm 3', 'sec_account_snapshot', 3, 3.3300, 3.3300, 3.3300, 3.3300, 0.1500, 3.3300, 0.1500, 0.1500, 30, 30, 3.3300, '2025-04-03 09:03:00', '2025-04-03 09:03:00'),
  ('sec_acco_004', 'Client 4', 'sec_acco_0', 'Branch 4', 'Rm 4', 'sec_account_snapshot', 4, 4.4400, 4.4400, 4.4400, 4.4400, 0.2000, 4.4400, 0.2000, 0.2000, 40, 40, 4.4400, '2025-04-04 09:04:00', '2025-04-04 09:04:00'),
  ('sec_acco_005', 'Client 5', 'sec_acco_0', 'Branch 5', 'Rm 5', 'sec_account_snapshot', 5, 5.5500, 5.5500, 5.5500, 5.5500, 0.2500, 5.5500, 0.2500, 0.2500, 50, 50, 5.5500, '2025-04-05 09:05:00', '2025-04-05 09:05:00');

-- Table: sec_branch_metrics
TRUNCATE TABLE `sec_branch_metrics`;
INSERT INTO `sec_branch_metrics` (`ts`, `branch_id`, `branch_name`, `turnover_amt`, `commission_amt`, `buy_amt`, `sell_amt`, `net_inflow_amt`, `active_clients`, `margin_clients`, `avg_maintenance`, `phase_name`) VALUES
  ('2025-04-01 09:01:00', 'sec_bran_0', 'Branch 1', 1.1100, 1.1100, 1.1100, 1.1100, 1.1100, 1, 1, 1.1100, 'Phase 1'),
  ('2025-04-02 09:02:00', 'sec_bran_0', 'Branch 2', 2.2200, 2.2200, 2.2200, 2.2200, 2.2200, 2, 2, 2.2200, 'Phase 2'),
  ('2025-04-03 09:03:00', 'sec_bran_0', 'Branch 3', 3.3300, 3.3300, 3.3300, 3.3300, 3.3300, 3, 3, 3.3300, 'Phase 3'),
  ('2025-04-04 09:04:00', 'sec_bran_0', 'Branch 4', 4.4400, 4.4400, 4.4400, 4.4400, 4.4400, 4, 4, 4.4400, 'Phase 4'),
  ('2025-04-05 09:05:00', 'sec_bran_0', 'Branch 5', 5.5500, 5.5500, 5.5500, 5.5500, 5.5500, 5, 5, 5.5500, 'Phase 5');

-- Table: sec_market_minute
TRUNCATE TABLE `sec_market_minute`;
INSERT INTO `sec_market_minute` (`ts`, `symbol`, `security_name`, `sector_name`, `last_price`, `change_pct`, `volume_lot`, `turnover_amt`, `net_inflow_amt`, `phase_name`) VALUES
  ('2025-04-01 09:01:00', 'C0001', 'Security 1', 'Sector 1', 1000.25, 0.0500, 1, 1.1100, 1.1100, 'Phase 1'),
  ('2025-04-02 09:02:00', 'C0002', 'Security 2', 'Sector 2', 2000.50, 0.1000, 2, 2.2200, 2.2200, 'Phase 2'),
  ('2025-04-03 09:03:00', 'C0003', 'Security 3', 'Sector 3', 3000.75, 0.1500, 3, 3.3300, 3.3300, 'Phase 3'),
  ('2025-04-04 09:04:00', 'C0004', 'Security 4', 'Sector 4', 4001.00, 0.2000, 4, 4.4400, 4.4400, 'Phase 4'),
  ('2025-04-05 09:05:00', 'C0005', 'Security 5', 'Sector 5', 5001.25, 0.2500, 5, 5.5500, 5.5500, 'Phase 5');

-- Table: sec_position_snapshot
TRUNCATE TABLE `sec_position_snapshot`;
INSERT INTO `sec_position_snapshot` (`account_id`, `symbol`, `security_name`, `sector_name`, `branch_id`, `branch_name`, `qty`, `available_qty`, `avg_cost`, `last_price`, `market_value`, `cost_amount`, `unrealized_pnl`, `pnl_pct`, `weight_pct`, `update_ts`) VALUES
  ('sec_posi_001', 'C0001', 'Security 1', 'Sector 1', 'sec_posi_0', 'Branch 1', 1, 1, 1000.25, 1000.25, 1.1100, 1000.25, 1.1100, 0.0500, 0.0500, '2025-04-01 09:01:00'),
  ('sec_posi_002', 'C0002', 'Security 2', 'Sector 2', 'sec_posi_0', 'Branch 2', 2, 2, 2000.50, 2000.50, 2.2200, 2000.50, 2.2200, 0.1000, 0.1000, '2025-04-02 09:02:00'),
  ('sec_posi_003', 'C0003', 'Security 3', 'Sector 3', 'sec_posi_0', 'Branch 3', 3, 3, 3000.75, 3000.75, 3.3300, 3000.75, 3.3300, 0.1500, 0.1500, '2025-04-03 09:03:00'),
  ('sec_posi_004', 'C0004', 'Security 4', 'Sector 4', 'sec_posi_0', 'Branch 4', 4, 4, 4001.00, 4001.00, 4.4400, 4001.00, 4.4400, 0.2000, 0.2000, '2025-04-04 09:04:00'),
  ('sec_posi_005', 'C0005', 'Security 5', 'Sector 5', 'sec_posi_0', 'Branch 5', 5, 5, 5001.25, 5001.25, 5.5500, 5001.25, 5.5500, 0.2500, 0.2500, '2025-04-05 09:05:00');

-- Table: sec_risk_snapshot
TRUNCATE TABLE `sec_risk_snapshot`;
INSERT INTO `sec_risk_snapshot` (`alert_id`, `account_id`, `client_name`, `branch_id`, `branch_name`, `alert_type`, `risk_level`, `metric_value`, `threshold_value`, `position_symbol`, `position_name`, `suggestion`, `status`, `update_ts`) VALUES
  ('sec_risk_001', 'sec_risk_001', 'Client 1', 'sec_risk_0', 'Branch 1', 'Retail', 'Low', 1.1100, 1.1100, 'C0001', 'Position 1', 'sec_risk_snapshot_suggestion_1', 'Normal', '2025-04-01 09:01:00'),
  ('sec_risk_002', 'sec_risk_002', 'Client 2', 'sec_risk_0', 'Branch 2', 'Wealth', 'Medium', 2.2200, 2.2200, 'C0002', 'Position 2', 'sec_risk_snapshot_suggestion_2', 'Running', '2025-04-02 09:02:00'),
  ('sec_risk_003', 'sec_risk_003', 'Client 3', 'sec_risk_0', 'Branch 3', 'Credit', 'High', 3.3300, 3.3300, 'C0003', 'Position 3', 'sec_risk_snapshot_suggestion_3', 'Success', '2025-04-03 09:03:00'),
  ('sec_risk_004', 'sec_risk_004', 'Client 4', 'sec_risk_0', 'Branch 4', 'Risk', 'Critical', 4.4400, 4.4400, 'C0004', 'Position 4', 'sec_risk_snapshot_suggestion_4', 'Active', '2025-04-04 09:04:00'),
  ('sec_risk_005', 'sec_risk_005', 'Client 5', 'sec_risk_0', 'Branch 5', 'Operation', 'Low', 5.5500, 5.5500, 'C0005', 'Position 5', 'sec_risk_snapshot_suggestion_5', 'Completed', '2025-04-05 09:05:00');

-- Table: sec_trade_detail
TRUNCATE TABLE `sec_trade_detail`;
INSERT INTO `sec_trade_detail` (`trade_id`, `ts`, `account_id`, `client_name`, `branch_id`, `branch_name`, `rm_name`, `symbol`, `security_name`, `sector_name`, `side`, `price`, `qty`, `amount`, `fee`, `channel`, `phase_name`) VALUES
  ('sec_trad_001', '2025-04-01 09:01:00', 'sec_trad_001', 'Client 1', 'sec_trad_0', 'Branch 1', 'Rm 1', 'C0001', 'Security 1', 'Sector 1', 'sec_trade_', 1000.25, 1, 1000.25, 1.1100, 'Mobile App', 'Phase 1'),
  ('sec_trad_002', '2025-04-02 09:02:00', 'sec_trad_002', 'Client 2', 'sec_trad_0', 'Branch 2', 'Rm 2', 'C0002', 'Security 2', 'Sector 2', 'sec_trade_', 2000.50, 2, 2000.50, 2.2200, 'Branch', 'Phase 2'),
  ('sec_trad_003', '2025-04-03 09:03:00', 'sec_trad_003', 'Client 3', 'sec_trad_0', 'Branch 3', 'Rm 3', 'C0003', 'Security 3', 'Sector 3', 'sec_trade_', 3000.75, 3, 3000.75, 3.3300, 'Web', 'Phase 3'),
  ('sec_trad_004', '2025-04-04 09:04:00', 'sec_trad_004', 'Client 4', 'sec_trad_0', 'Branch 4', 'Rm 4', 'C0004', 'Security 4', 'Sector 4', 'sec_trade_', 4001.00, 4, 4001.00, 4.4400, 'Mini Program', 'Phase 4'),
  ('sec_trad_005', '2025-04-05 09:05:00', 'sec_trad_005', 'Client 5', 'sec_trad_0', 'Branch 5', 'Rm 5', 'C0005', 'Security 5', 'Sector 5', 'sec_trade_', 5001.25, 5, 5001.25, 5.5500, 'API', 'Phase 5');

-- Table: service_log
TRUNCATE TABLE `service_log`;
INSERT INTO `service_log` (`trace_id`, `span_id`, `request_time`, `method`, `path`, `status_code`, `duration_ms`, `ip_address`, `user_agent`, `error_message`, `tags`) VALUES
  ('service__001', 'service__001', '2025-04-01 09:01:00', 'service_log_meth', 'service_log_path_1', 1, 0.0500, 'service_log_ip_address_1', 'service_log_user_agent_1', 'English mock description for service_log row 1', '["demo","english","mock"]'),
  ('service__002', 'service__002', '2025-04-02 09:02:00', 'service_log_meth', 'service_log_path_2', 2, 0.1000, 'service_log_ip_address_2', 'service_log_user_agent_2', 'English mock description for service_log row 2', '["demo","english","mock"]'),
  ('service__003', 'service__003', '2025-04-03 09:03:00', 'service_log_meth', 'service_log_path_3', 3, 0.1500, 'service_log_ip_address_3', 'service_log_user_agent_3', 'English mock description for service_log row 3', '["demo","english","mock"]'),
  ('service__004', 'service__004', '2025-04-04 09:04:00', 'service_log_meth', 'service_log_path_4', 4, 0.2000, 'service_log_ip_address_4', 'service_log_user_agent_4', 'English mock description for service_log row 4', '["demo","english","mock"]'),
  ('service__005', 'service__005', '2025-04-05 09:05:00', 'service_log_meth', 'service_log_path_5', 5, 0.2500, 'service_log_ip_address_5', 'service_log_user_agent_5', 'English mock description for service_log row 5', '["demo","english","mock"]');

-- Table: sys_logs
TRUNCATE TABLE `sys_logs`;
INSERT INTO `sys_logs` (`trace_id`, `log_time`, `level`, `service`, `method`, `path`, `status_code`, `duration_ms`, `db_time_ms`, `message`, `log_tag`) VALUES
  ('sys_logs_001', '2025-04-01 09:01:00.000', 'L1', 'sys_logs_service_1', 'sys_logs_m', 'sys_logs_path_1', 1, 0.0500, 1.1100, 'English mock description for sys_logs row 1', 'sys_logs_log_tag_1'),
  ('sys_logs_002', '2025-04-02 09:02:00.000', 'L2', 'sys_logs_service_2', 'sys_logs_m', 'sys_logs_path_2', 2, 0.1000, 2.2200, 'English mock description for sys_logs row 2', 'sys_logs_log_tag_2'),
  ('sys_logs_003', '2025-04-03 09:03:00.000', 'L3', 'sys_logs_service_3', 'sys_logs_m', 'sys_logs_path_3', 3, 0.1500, 3.3300, 'English mock description for sys_logs row 3', 'sys_logs_log_tag_3'),
  ('sys_logs_004', '2025-04-04 09:04:00.000', 'L4', 'sys_logs_service_4', 'sys_logs_m', 'sys_logs_path_4', 4, 0.2000, 4.4400, 'English mock description for sys_logs row 4', 'sys_logs_log_tag_4'),
  ('sys_logs_005', '2025-04-05 09:05:00.000', 'L5', 'sys_logs_service_5', 'sys_logs_m', 'sys_logs_path_5', 5, 0.2500, 5.5500, 'English mock description for sys_logs row 5', 'sys_logs_log_tag_5');

-- Table: sys_spans
TRUNCATE TABLE `sys_spans`;
INSERT INTO `sys_spans` (`trace_id`, `span_id`, `parent_span_id`, `span_time`, `service`, `operation`, `offset_ms`, `duration_ms`, `status`, `db_query`) VALUES
  ('sys_span_001', 'sys_span_001', 'sys_span_001', '2025-04-01 09:01:00.000', 'sys_spans_service_1', 'sys_spans_operation_1', 1.1100, 0.0500, 'Normal', 'sys_spans_db_query_1'),
  ('sys_span_002', 'sys_span_002', 'sys_span_002', '2025-04-02 09:02:00.000', 'sys_spans_service_2', 'sys_spans_operation_2', 2.2200, 0.1000, 'Running', 'sys_spans_db_query_2'),
  ('sys_span_003', 'sys_span_003', 'sys_span_003', '2025-04-03 09:03:00.000', 'sys_spans_service_3', 'sys_spans_operation_3', 3.3300, 0.1500, 'Success', 'sys_spans_db_query_3'),
  ('sys_span_004', 'sys_span_004', 'sys_span_004', '2025-04-04 09:04:00.000', 'sys_spans_service_4', 'sys_spans_operation_4', 4.4400, 0.2000, 'Active', 'sys_spans_db_query_4'),
  ('sys_span_005', 'sys_span_005', 'sys_span_005', '2025-04-05 09:05:00.000', 'sys_spans_service_5', 'sys_spans_operation_5', 5.5500, 0.2500, 'Completed', 'sys_spans_db_query_5');

-- Table: tag_dict
TRUNCATE TABLE `tag_dict`;
INSERT INTO `tag_dict` (`tag_id`, `tag_category`, `tag_name`, `tag_label`, `tag_desc`, `value_type`, `value_options`, `source_table`, `source_field`, `is_ai_tag`, `enable_bitmap`, `status`, `sort_order`, `created_at`) VALUES
  (10001, 'Retail', 'Tag 1', 'tag_dict_tag_label_1', 'English mock description for tag_dict row 1', 'Retail', 'tag_dict_value_options_1', 'tag_dict_source_table_1', 'tag_dict_source_field_1', 1, 1, 1, 1, '2025-04-01 09:01:00'),
  (10002, 'Wealth', 'Tag 2', 'tag_dict_tag_label_2', 'English mock description for tag_dict row 2', 'Wealth', 'tag_dict_value_options_2', 'tag_dict_source_table_2', 'tag_dict_source_field_2', 0, 2, 2, 2, '2025-04-02 09:02:00'),
  (10003, 'Credit', 'Tag 3', 'tag_dict_tag_label_3', 'English mock description for tag_dict row 3', 'Credit', 'tag_dict_value_options_3', 'tag_dict_source_table_3', 'tag_dict_source_field_3', 1, 3, 3, 3, '2025-04-03 09:03:00'),
  (10004, 'Risk', 'Tag 4', 'tag_dict_tag_label_4', 'English mock description for tag_dict row 4', 'Risk', 'tag_dict_value_options_4', 'tag_dict_source_table_4', 'tag_dict_source_field_4', 0, 4, 4, 4, '2025-04-04 09:04:00'),
  (10005, 'Operation', 'Tag 5', 'tag_dict_tag_label_5', 'English mock description for tag_dict row 5', 'Operation', 'tag_dict_value_options_5', 'tag_dict_source_table_5', 'tag_dict_source_field_5', 1, 5, 5, 5, '2025-04-05 09:05:00');

-- Table: user_avatar
TRUNCATE TABLE `user_avatar`;
INSERT INTO `user_avatar` (`user_id`, `user_name`, `avatar_style`, `description`, `photo_embedding`, `labels`, `create_time`) VALUES
  (10001, 'User 1', 'user_avatar_avatar_style_1', 'English mock description for user_avatar row 1', [0.10, 0.20, 0.30, 0.40], 'user_avatar_labels_1', '2025-04-01 09:01:00'),
  (10002, 'User 2', 'user_avatar_avatar_style_2', 'English mock description for user_avatar row 2', [0.20, 0.30, 0.40, 0.50], 'user_avatar_labels_2', '2025-04-02 09:02:00'),
  (10003, 'User 3', 'user_avatar_avatar_style_3', 'English mock description for user_avatar row 3', [0.30, 0.40, 0.50, 0.60], 'user_avatar_labels_3', '2025-04-03 09:03:00'),
  (10004, 'User 4', 'user_avatar_avatar_style_4', 'English mock description for user_avatar row 4', [0.40, 0.50, 0.60, 0.70], 'user_avatar_labels_4', '2025-04-04 09:04:00'),
  (10005, 'User 5', 'user_avatar_avatar_style_5', 'English mock description for user_avatar row 5', [0.50, 0.60, 0.70, 0.80], 'user_avatar_labels_5', '2025-04-05 09:05:00');

-- Table: user_avatar_bak
TRUNCATE TABLE `user_avatar_bak`;
INSERT INTO `user_avatar_bak` (`user_id`, `user_name`, `avatar_style`, `description`, `photo_embedding`, `labels`, `create_time`) VALUES
  (10001, 'User 1', 'user_avatar_bak_avatar_style_1', 'English mock description for user_avatar_bak row 1', [0.10, 0.20, 0.30, 0.40], 'user_avatar_bak_labels_1', '2025-04-01 09:01:00'),
  (10002, 'User 2', 'user_avatar_bak_avatar_style_2', 'English mock description for user_avatar_bak row 2', [0.20, 0.30, 0.40, 0.50], 'user_avatar_bak_labels_2', '2025-04-02 09:02:00'),
  (10003, 'User 3', 'user_avatar_bak_avatar_style_3', 'English mock description for user_avatar_bak row 3', [0.30, 0.40, 0.50, 0.60], 'user_avatar_bak_labels_3', '2025-04-03 09:03:00'),
  (10004, 'User 4', 'user_avatar_bak_avatar_style_4', 'English mock description for user_avatar_bak row 4', [0.40, 0.50, 0.60, 0.70], 'user_avatar_bak_labels_4', '2025-04-04 09:04:00'),
  (10005, 'User 5', 'user_avatar_bak_avatar_style_5', 'English mock description for user_avatar_bak row 5', [0.50, 0.60, 0.70, 0.80], 'user_avatar_bak_labels_5', '2025-04-05 09:05:00');

-- Table: user_avatar_photo
TRUNCATE TABLE `user_avatar_photo`;
INSERT INTO `user_avatar_photo` (`user_id`, `photo_url`, `create_time`) VALUES
  (10001, 'http://example.com/user_avatar_photo/1', '2025-04-01 09:01:00'),
  (10002, 'http://example.com/user_avatar_photo/2', '2025-04-02 09:02:00'),
  (10003, 'http://example.com/user_avatar_photo/3', '2025-04-03 09:03:00'),
  (10004, 'http://example.com/user_avatar_photo/4', '2025-04-04 09:04:00'),
  (10005, 'http://example.com/user_avatar_photo/5', '2025-04-05 09:05:00');

-- Table: user_base
TRUNCATE TABLE `user_base`;
INSERT INTO `user_base` (`user_id`, `user_name`, `id_card_mask`, `auth_status`, `avatar_url`, `create_time`) VALUES
  ('user_bas_001', 'User 1', 'user_base_id_card_mask_1', 1, 'http://example.com/user_base/1', '2025-04-01 09:01:00'),
  ('user_bas_002', 'User 2', 'user_base_id_card_mask_2', 2, 'http://example.com/user_base/2', '2025-04-02 09:02:00'),
  ('user_bas_003', 'User 3', 'user_base_id_card_mask_3', 3, 'http://example.com/user_base/3', '2025-04-03 09:03:00'),
  ('user_bas_004', 'User 4', 'user_base_id_card_mask_4', 4, 'http://example.com/user_base/4', '2025-04-04 09:04:00'),
  ('user_bas_005', 'User 5', 'user_base_id_card_mask_5', 5, 'http://example.com/user_base/5', '2025-04-05 09:05:00');

-- Table: user_behavior
TRUNCATE TABLE `user_behavior`;
INSERT INTO `user_behavior` (`event_id`, `user_id`, `event_date`, `event_time`, `event_type`, `event_category`, `channel`, `product_code`, `amount`, `result_code`, `session_id`, `device_type`, `ip_address`, `extra_props`) VALUES
  (10001, 10001, '2025-04-01', '2025-04-01 09:01:00', 'Retail', 'Retail', 'Mobile App', 'C0001', 10.2500, 'C0001', 'user_beh_001', 'Retail', 'user_behavior_ip_address_1', 'user_behavior_extra_props_1'),
  (10002, 10002, '2025-04-02', '2025-04-02 09:02:00', 'Wealth', 'Wealth', 'Branch', 'C0002', 20.5000, 'C0002', 'user_beh_002', 'Wealth', 'user_behavior_ip_address_2', 'user_behavior_extra_props_2'),
  (10003, 10003, '2025-04-03', '2025-04-03 09:03:00', 'Credit', 'Credit', 'Web', 'C0003', 30.7500, 'C0003', 'user_beh_003', 'Credit', 'user_behavior_ip_address_3', 'user_behavior_extra_props_3'),
  (10004, 10004, '2025-04-04', '2025-04-04 09:04:00', 'Risk', 'Risk', 'Mini Program', 'C0004', 41.0000, 'C0004', 'user_beh_004', 'Risk', 'user_behavior_ip_address_4', 'user_behavior_extra_props_4'),
  (10005, 10005, '2025-04-05', '2025-04-05 09:05:00', 'Operation', 'Operation', 'API', 'C0005', 51.2500, 'C0005', 'user_beh_005', 'Operation', 'user_behavior_ip_address_5', 'user_behavior_extra_props_5');

-- Table: user_log_raw
TRUNCATE TABLE `user_log_raw`;
INSERT INTO `user_log_raw` (`log_id`, `log_date`, `log_time`, `user_id`, `session_id`, `log_level`, `log_source`, `log_content`, `operation_type`, `ip_address`, `user_region`, `device_info`, `response_code`, `response_time`, `filebeat_host`, `raw_json`, `created_at`) VALUES
  (10001, '2025-04-01', '2025-04-01 09:01:00', 10001, 'user_log_001', 'L1', 'user_log_raw_log_source_1', 'English mock description for user_log_raw row 1', 'Retail', 'user_log_raw_ip_address_1', 'user_log_raw_user_region_1', 'user_log_raw_device_info_1', 'C0001', 1, 'user_log_raw_filebeat_host_1', '["demo","english","mock"]', '2025-04-01 09:01:00'),
  (10002, '2025-04-02', '2025-04-02 09:02:00', 10002, 'user_log_002', 'L2', 'user_log_raw_log_source_2', 'English mock description for user_log_raw row 2', 'Wealth', 'user_log_raw_ip_address_2', 'user_log_raw_user_region_2', 'user_log_raw_device_info_2', 'C0002', 2, 'user_log_raw_filebeat_host_2', '["demo","english","mock"]', '2025-04-02 09:02:00'),
  (10003, '2025-04-03', '2025-04-03 09:03:00', 10003, 'user_log_003', 'L3', 'user_log_raw_log_source_3', 'English mock description for user_log_raw row 3', 'Credit', 'user_log_raw_ip_address_3', 'user_log_raw_user_region_3', 'user_log_raw_device_info_3', 'C0003', 3, 'user_log_raw_filebeat_host_3', '["demo","english","mock"]', '2025-04-03 09:03:00'),
  (10004, '2025-04-04', '2025-04-04 09:04:00', 10004, 'user_log_004', 'L4', 'user_log_raw_log_source_4', 'English mock description for user_log_raw row 4', 'Risk', 'user_log_raw_ip_address_4', 'user_log_raw_user_region_4', 'user_log_raw_device_info_4', 'C0004', 4, 'user_log_raw_filebeat_host_4', '["demo","english","mock"]', '2025-04-04 09:04:00'),
  (10005, '2025-04-05', '2025-04-05 09:05:00', 10005, 'user_log_005', 'L5', 'user_log_raw_log_source_5', 'English mock description for user_log_raw row 5', 'Operation', 'user_log_raw_ip_address_5', 'user_log_raw_user_region_5', 'user_log_raw_device_info_5', 'C0005', 5, 'user_log_raw_filebeat_host_5', '["demo","english","mock"]', '2025-04-05 09:05:00');

-- Table: user_log_tag
TRUNCATE TABLE `user_log_tag`;
INSERT INTO `user_log_tag` (`log_id`, `log_date`, `user_id`, `log_time`, `log_type`, `intent_tag`, `anomaly_tag`, `risk_level`, `ai_raw_result`, `tag_source`, `manual_label`, `created_at`) VALUES
  (10001, '2025-04-01', 10001, '2025-04-01 09:01:00', 'Retail', 'user_log_tag_intent_tag_1', 'user_log_tag_anomaly_tag_1', 'Low', 'user_log_tag_ai_raw_result_1', 'user_log_tag_tag', 'user_log_tag_manual_label_1', '2025-04-01 09:01:00'),
  (10002, '2025-04-02', 10002, '2025-04-02 09:02:00', 'Wealth', 'user_log_tag_intent_tag_2', 'user_log_tag_anomaly_tag_2', 'Medium', 'user_log_tag_ai_raw_result_2', 'user_log_tag_tag', 'user_log_tag_manual_label_2', '2025-04-02 09:02:00'),
  (10003, '2025-04-03', 10003, '2025-04-03 09:03:00', 'Credit', 'user_log_tag_intent_tag_3', 'user_log_tag_anomaly_tag_3', 'High', 'user_log_tag_ai_raw_result_3', 'user_log_tag_tag', 'user_log_tag_manual_label_3', '2025-04-03 09:03:00'),
  (10004, '2025-04-04', 10004, '2025-04-04 09:04:00', 'Risk', 'user_log_tag_intent_tag_4', 'user_log_tag_anomaly_tag_4', 'Critical', 'user_log_tag_ai_raw_result_4', 'user_log_tag_tag', 'user_log_tag_manual_label_4', '2025-04-04 09:04:00'),
  (10005, '2025-04-05', 10005, '2025-04-05 09:05:00', 'Operation', 'user_log_tag_intent_tag_5', 'user_log_tag_anomaly_tag_5', 'Low', 'user_log_tag_ai_raw_result_5', 'user_log_tag_tag', 'user_log_tag_manual_label_5', '2025-04-05 09:05:00');

-- Table: user_segment
TRUNCATE TABLE `user_segment`;
INSERT INTO `user_segment` (`segment_id`, `segment_name`, `segment_desc`, `rule_config`, `segment_type`, `snap_date`, `status`, `created_by`, `created_at`, `updated_at`, `segment_bitmap`, `user_count`) VALUES
  (10001, 'Segment 1', 'English mock description for user_segment row 1', 'user_segment_rule_config_1', 'Retail', '2025-04-01', 1, 'user_segment_created_by_1', '2025-04-01 09:01:00', '2025-04-01 09:01:00', bitmap_from_string('10001,10011'), 10),
  (10002, 'Segment 2', 'English mock description for user_segment row 2', 'user_segment_rule_config_2', 'Wealth', '2025-04-02', 2, 'user_segment_created_by_2', '2025-04-02 09:02:00', '2025-04-02 09:02:00', bitmap_from_string('10002,10012'), 20),
  (10003, 'Segment 3', 'English mock description for user_segment row 3', 'user_segment_rule_config_3', 'Credit', '2025-04-03', 3, 'user_segment_created_by_3', '2025-04-03 09:03:00', '2025-04-03 09:03:00', bitmap_from_string('10003,10013'), 30),
  (10004, 'Segment 4', 'English mock description for user_segment row 4', 'user_segment_rule_config_4', 'Risk', '2025-04-04', 4, 'user_segment_created_by_4', '2025-04-04 09:04:00', '2025-04-04 09:04:00', bitmap_from_string('10004,10014'), 40),
  (10005, 'Segment 5', 'English mock description for user_segment row 5', 'user_segment_rule_config_5', 'Operation', '2025-04-05', 5, 'user_segment_created_by_5', '2025-04-05 09:05:00', '2025-04-05 09:05:00', bitmap_from_string('10005,10015'), 50);

-- Table: user_tag
TRUNCATE TABLE `user_tag`;
INSERT INTO `user_tag` (`tag_date`, `tag_category`, `tag_name`, `tag_value`, `user_bitmap`, `user_count`, `updated_at`) VALUES
  ('2025-04-01', 'Retail', 'Tag 1', 'user_tag_tag_value_1', bitmap_from_string('10001,10011'), 10, '2025-04-01 09:01:00'),
  ('2025-04-02', 'Wealth', 'Tag 2', 'user_tag_tag_value_2', bitmap_from_string('10002,10012'), 20, '2025-04-02 09:02:00'),
  ('2025-04-03', 'Credit', 'Tag 3', 'user_tag_tag_value_3', bitmap_from_string('10003,10013'), 30, '2025-04-03 09:03:00'),
  ('2025-04-04', 'Risk', 'Tag 4', 'user_tag_tag_value_4', bitmap_from_string('10004,10014'), 40, '2025-04-04 09:04:00'),
  ('2025-04-05', 'Operation', 'Tag 5', 'user_tag_tag_value_5', bitmap_from_string('10005,10015'), 50, '2025-04-05 09:05:00');

-- Table: user_wide
TRUNCATE TABLE `user_wide`;
INSERT INTO `user_wide` (`user_id`, `update_date`, `user_name`, `id_card`, `phone`, `gender`, `age`, `age_group`, `city`, `province`, `education`, `occupation`, `register_date`, `asset_level`, `aum_total`, `deposit_amount`, `fund_amount`, `loan_amount`, `wm_amount`, `insurance_amount`, `has_credit_card`, `has_debit_card`, `has_mortgage`, `product_count`, `credit_score`, `credit_grade`, `risk_level`, `preferred_channel`, `app_login_30d`, `app_last_login`, `active_level`, `lifecycle_stage`, `churn_prob`, `clv_score`, `log_tags`, `anomaly_flag`, `created_at`, `updated_at`) VALUES
  (10001, '2025-04-01', 'User 1', 'user_wide_id_card_1', '13800000001', 1, 26, 'user_wide_age_gr', 'Beijing', 'Beijing', 1, 'user_wide_occupation_1', '2025-04-01', 'Private Banking', 10.2500, 10.2500, 10.2500, 10.2500, 10.2500, 10.2500, 1, 1, 1, 10, 1, 'user_wid', 1, 'Mobile App', 1, '2025-04-01', 'High Active', 'user_wide_lifecycle_stage_1', 0.0500, 0.0500, '["demo","english","mock"]', 1, '2025-04-01 09:01:00', '2025-04-01 09:01:00'),
  (10002, '2025-04-02', 'User 2', 'user_wide_id_card_2', '13800000002', 2, 27, 'user_wide_age_gr', 'Shanghai', 'Shanghai', 2, 'user_wide_occupation_2', '2025-04-02', 'Diamond', 20.5000, 20.5000, 20.5000, 20.5000, 20.5000, 20.5000, 0, 0, 0, 20, 2, 'user_wid', 2, 'Branch', 2, '2025-04-02', 'Medium Active', 'user_wide_lifecycle_stage_2', 0.1000, 0.1000, '["demo","english","mock"]', 0, '2025-04-02 09:02:00', '2025-04-02 09:02:00'),
  (10003, '2025-04-03', 'User 3', 'user_wide_id_card_3', '13800000003', 1, 28, 'user_wide_age_gr', 'Shenzhen', 'Guangdong', 3, 'user_wide_occupation_3', '2025-04-03', 'Platinum', 30.7500, 30.7500, 30.7500, 30.7500, 30.7500, 30.7500, 1, 1, 1, 30, 3, 'user_wid', 3, 'Web', 3, '2025-04-03', 'Low Active', 'user_wide_lifecycle_stage_3', 0.1500, 0.1500, '["demo","english","mock"]', 1, '2025-04-03 09:03:00', '2025-04-03 09:03:00'),
  (10004, '2025-04-04', 'User 4', 'user_wide_id_card_4', '13800000004', 2, 29, 'user_wide_age_gr', 'Hangzhou', 'Zhejiang', 4, 'user_wide_occupation_4', '2025-04-04', 'Gold', 41.0000, 41.0000, 41.0000, 41.0000, 41.0000, 41.0000, 0, 0, 0, 40, 4, 'user_wid', 4, 'Mini Program', 4, '2025-04-04', 'Dormant', 'user_wide_lifecycle_stage_4', 0.2000, 0.2000, '["demo","english","mock"]', 0, '2025-04-04 09:04:00', '2025-04-04 09:04:00'),
  (10005, '2025-04-05', 'User 5', 'user_wide_id_card_5', '13800000005', 1, 30, 'user_wide_age_gr', 'Chengdu', 'Sichuan', 5, 'user_wide_occupation_5', '2025-04-05', 'Standard', 51.2500, 51.2500, 51.2500, 51.2500, 51.2500, 51.2500, 1, 1, 1, 50, 5, 'user_wid', 5, 'API', 5, '2025-04-05', 'High Active', 'user_wide_lifecycle_stage_5', 0.2500, 0.2500, '["demo","english","mock"]', 1, '2025-04-05 09:05:00', '2025-04-05 09:05:00');

-- Table: user_wide_point_query
TRUNCATE TABLE `user_wide_point_query`;
INSERT INTO `user_wide_point_query` (`user_id`, `update_date`, `user_name`, `id_card`, `phone`, `gender`, `age`, `age_group`, `city`, `province`, `education`, `occupation`, `register_date`, `asset_level`, `aum_total`, `deposit_amount`, `fund_amount`, `loan_amount`, `wm_amount`, `insurance_amount`, `has_credit_card`, `has_debit_card`, `has_mortgage`, `product_count`, `credit_score`, `credit_grade`, `risk_level`, `preferred_channel`, `app_login_30d`, `app_last_login`, `active_level`, `lifecycle_stage`, `churn_prob`, `clv_score`, `log_tags`, `anomaly_flag`, `created_at`, `updated_at`) VALUES
  (10001, '2025-04-01', 'User 1', 'user_wide_point_query_id_card_1', '13800000001', 1, 26, 'user_wide_point_', 'Beijing', 'Beijing', 1, 'user_wide_point_query_occupation', '2025-04-01', 'Private Banking', 10.2500, 10.2500, 10.2500, 10.2500, 10.2500, 10.2500, 1, 1, 1, 10, 1, 'user_wid', 1, 'Mobile App', 1, '2025-04-01', 'High Active', 'user_wide_point_query_lifecycle_', 0.0500, 0.0500, '["demo","english","mock"]', 1, '2025-04-01 09:01:00', '2025-04-01 09:01:00'),
  (10002, '2025-04-02', 'User 2', 'user_wide_point_query_id_card_2', '13800000002', 2, 27, 'user_wide_point_', 'Shanghai', 'Shanghai', 2, 'user_wide_point_query_occupation', '2025-04-02', 'Diamond', 20.5000, 20.5000, 20.5000, 20.5000, 20.5000, 20.5000, 0, 0, 0, 20, 2, 'user_wid', 2, 'Branch', 2, '2025-04-02', 'Medium Active', 'user_wide_point_query_lifecycle_', 0.1000, 0.1000, '["demo","english","mock"]', 0, '2025-04-02 09:02:00', '2025-04-02 09:02:00'),
  (10003, '2025-04-03', 'User 3', 'user_wide_point_query_id_card_3', '13800000003', 1, 28, 'user_wide_point_', 'Shenzhen', 'Guangdong', 3, 'user_wide_point_query_occupation', '2025-04-03', 'Platinum', 30.7500, 30.7500, 30.7500, 30.7500, 30.7500, 30.7500, 1, 1, 1, 30, 3, 'user_wid', 3, 'Web', 3, '2025-04-03', 'Low Active', 'user_wide_point_query_lifecycle_', 0.1500, 0.1500, '["demo","english","mock"]', 1, '2025-04-03 09:03:00', '2025-04-03 09:03:00'),
  (10004, '2025-04-04', 'User 4', 'user_wide_point_query_id_card_4', '13800000004', 2, 29, 'user_wide_point_', 'Hangzhou', 'Zhejiang', 4, 'user_wide_point_query_occupation', '2025-04-04', 'Gold', 41.0000, 41.0000, 41.0000, 41.0000, 41.0000, 41.0000, 0, 0, 0, 40, 4, 'user_wid', 4, 'Mini Program', 4, '2025-04-04', 'Dormant', 'user_wide_point_query_lifecycle_', 0.2000, 0.2000, '["demo","english","mock"]', 0, '2025-04-04 09:04:00', '2025-04-04 09:04:00'),
  (10005, '2025-04-05', 'User 5', 'user_wide_point_query_id_card_5', '13800000005', 1, 30, 'user_wide_point_', 'Chengdu', 'Sichuan', 5, 'user_wide_point_query_occupation', '2025-04-05', 'Standard', 51.2500, 51.2500, 51.2500, 51.2500, 51.2500, 51.2500, 1, 1, 1, 50, 5, 'user_wid', 5, 'API', 5, '2025-04-05', 'High Active', 'user_wide_point_query_lifecycle_', 0.2500, 0.2500, '["demo","english","mock"]', 1, '2025-04-05 09:05:00', '2025-04-05 09:05:00');
