-- ================================================================
-- Database: bjmetro
-- Type: English mock data
-- Source: generated from current Doris table metadata.
-- Execute after schema SQL.
-- ================================================================

CREATE DATABASE IF NOT EXISTS bjmetro;
USE bjmetro;

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

-- Table: bj_metro_od_flow
TRUNCATE TABLE `bj_metro_od_flow`;
INSERT INTO `bj_metro_od_flow` (`flow_date`, `origin_id`, `dest_id`, `peak_type`, `flow_count`) VALUES
  ('2025-04-01', 'bj_metro_001', 'bj_metro_001', 'Retail', 10),
  ('2025-04-02', 'bj_metro_002', 'bj_metro_002', 'Wealth', 20),
  ('2025-04-03', 'bj_metro_003', 'bj_metro_003', 'Credit', 30),
  ('2025-04-04', 'bj_metro_004', 'bj_metro_004', 'Risk', 40),
  ('2025-04-05', 'bj_metro_005', 'bj_metro_005', 'Operation', 50);

-- Table: bj_metro_revenue
TRUNCATE TABLE `bj_metro_revenue`;
INSERT INTO `bj_metro_revenue` (`revenue_date`, `line_id`, `ticket_revenue`, `subsidy_amount`, `ticket_count`, `ad_revenue`, `commercial_revenue`) VALUES
  ('2025-04-01', 'bj_metro_0', 1000.25, 1000.25, 10, 1000.25, 1000.25),
  ('2025-04-02', 'bj_metro_0', 2000.50, 2000.50, 20, 2000.50, 2000.50),
  ('2025-04-03', 'bj_metro_0', 3000.75, 3000.75, 30, 3000.75, 3000.75),
  ('2025-04-04', 'bj_metro_0', 4001.00, 4001.00, 40, 4001.00, 4001.00),
  ('2025-04-05', 'bj_metro_0', 5001.25, 5001.25, 50, 5001.25, 5001.25);

-- Table: bj_metro_stations
TRUNCATE TABLE `bj_metro_stations`;
INSERT INTO `bj_metro_stations` (`station_id`, `station_name`, `line_id`, `sequence_no`, `district`, `daily_capacity`, `is_interchange`, `interchange_lines`, `is_terminal`) VALUES
  ('bj_metro_001', 'Station 1', 'bj_metro_0', 1, 'bj_metro_stations_di', 1, 1, 'bj_metro_stations_interchange_lines_1', 1),
  ('bj_metro_002', 'Station 2', 'bj_metro_0', 2, 'bj_metro_stations_di', 2, 0, 'bj_metro_stations_interchange_lines_2', 0),
  ('bj_metro_003', 'Station 3', 'bj_metro_0', 3, 'bj_metro_stations_di', 3, 1, 'bj_metro_stations_interchange_lines_3', 1),
  ('bj_metro_004', 'Station 4', 'bj_metro_0', 4, 'bj_metro_stations_di', 4, 0, 'bj_metro_stations_interchange_lines_4', 0),
  ('bj_metro_005', 'Station 5', 'bj_metro_0', 5, 'bj_metro_stations_di', 5, 1, 'bj_metro_stations_interchange_lines_5', 1);

-- Table: bj_metro_train_ops
TRUNCATE TABLE `bj_metro_train_ops`;
INSERT INTO `bj_metro_train_ops` (`ops_date`, `line_id`, `planned_trains`, `actual_trains`, `punctuality_rate`, `delay_count`, `max_delay_sec`, `total_mileage_km`, `fault_count`) VALUES
  ('2025-04-01', 'bj_metro_0', 1, 1, 0.0500, 10, 1, 26, 10),
  ('2025-04-02', 'bj_metro_0', 2, 2, 0.1000, 20, 2, 27, 20),
  ('2025-04-03', 'bj_metro_0', 3, 3, 0.1500, 30, 3, 28, 30),
  ('2025-04-04', 'bj_metro_0', 4, 4, 0.2000, 40, 4, 29, 40),
  ('2025-04-05', 'bj_metro_0', 5, 5, 0.2500, 50, 5, 30, 50);
