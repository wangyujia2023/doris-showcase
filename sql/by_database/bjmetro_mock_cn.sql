-- ================================================================
-- Database: bjmetro
-- Type: Chinese mock data
-- Source: generated from current Doris table metadata.
-- Execute after schema SQL.
-- ================================================================

CREATE DATABASE IF NOT EXISTS bjmetro;
USE bjmetro;

-- Table: bj_metro_daily_flow
TRUNCATE TABLE `bj_metro_daily_flow`;
INSERT INTO `bj_metro_daily_flow`(`flow_date`, `station_id`, `line_id`, `inbound_count`, `outbound_count`, `peak_inbound`) VALUES
  ('2025-04-01', 'ST001', 'L01', 10, 10, 1),
  ('2025-04-02', 'ST002', 'L02', 20, 20, 2),
  ('2025-04-03', 'ST003', 'L03', 30, 30, 3),
  ('2025-04-04', 'ST004', 'L04', 40, 40, 4),
  ('2025-04-05', 'ST005', 'L05', 50, 50, 5);

-- Table: bj_metro_fault_log
TRUNCATE TABLE `bj_metro_fault_log`;
INSERT INTO `bj_metro_fault_log`(`fault_id`, `fault_time`, `line_id`, `station_id`, `device_type`, `fault_type`, `severity`, `description`, `resolve_time`, `resolve_min`, `status`, `handler`) VALUES
  ('bj_metro_001', '2025-04-01 09:01:00', 'L01', 'ST001', '闸机', '闸机', '低', '国贸站设备巡检发现闸机卡票，已安排处理', '2025-04-01 09:01:00', 1, '正常', '张审核'),
  ('bj_metro_002', '2025-04-02 09:02:00', 'L02', 'ST002', '扶梯', '扶梯', '中', '西直门站设备巡检发现扶梯停梯，已安排处理', '2025-04-02 09:02:00', 2, '运行中', '李复核'),
  ('bj_metro_003', '2025-04-03 09:03:00', 'L03', 'ST003', '信号', '信号', '高', '望京站设备巡检发现信号延迟，已安排处理', '2025-04-03 09:03:00', 3, '已成功', '王运营'),
  ('bj_metro_004', '2025-04-04 09:04:00', 'L04', 'ST004', '供电', '供电', '严重', '宋家庄站设备巡检发现供电波动，已安排处理', '2025-04-04 09:04:00', 4, '已生效', '陈风控'),
  ('bj_metro_005', '2025-04-05 09:05:00', 'L05', 'ST005', '屏蔽门', '屏蔽门', '提示', '北京南站设备巡检发现屏蔽门告警，已安排处理', '2025-04-05 09:05:00', 5, '已完成', '赵经理');

-- Table: bj_metro_hourly_flow
TRUNCATE TABLE `bj_metro_hourly_flow`;
INSERT INTO `bj_metro_hourly_flow`(`flow_date`, `flow_hour`, `line_id`, `total_passengers`, `overcapacity_cnt`) VALUES
  ('2025-04-01', 1, 'L01', 1, 10),
  ('2025-04-02', 2, 'L02', 2, 20),
  ('2025-04-03', 3, 'L03', 3, 30),
  ('2025-04-04', 4, 'L04', 4, 40),
  ('2025-04-05', 5, 'L05', 5, 50);

-- Table: bj_metro_lines
TRUNCATE TABLE `bj_metro_lines`;
INSERT INTO `bj_metro_lines`(`line_id`, `line_name`, `line_color`, `total_stations`, `total_length_km`, `open_year`, `daily_capacity_w`, `peak_interval_s`, `offpeak_interval_s`, `status`) VALUES
  ('L01', '1号线', 'bj_metro_l', 1, 10.25, 1, 1, 1, 1, '正常'),
  ('L02', '2号线', 'bj_metro_l', 2, 20.50, 2, 2, 2, 2, '运行中'),
  ('L03', '10号线', 'bj_metro_l', 3, 30.75, 3, 3, 3, 3, '已成功'),
  ('L04', '13号线', 'bj_metro_l', 4, 41.00, 4, 4, 4, 4, '已生效'),
  ('L05', '亦庄线', 'bj_metro_l', 5, 51.25, 5, 5, 5, 5, '已完成');

-- Table: bj_metro_od_flow
TRUNCATE TABLE `bj_metro_od_flow`;
INSERT INTO `bj_metro_od_flow`(`flow_date`, `origin_id`, `dest_id`, `peak_type`, `flow_count`) VALUES
  ('2025-04-01', 'ST001', 'ST001', '早高峰', 10),
  ('2025-04-02', 'ST002', 'ST002', '平峰', 20),
  ('2025-04-03', 'ST003', 'ST003', '晚高峰', 30),
  ('2025-04-04', 'ST004', 'ST004', '夜间', 40),
  ('2025-04-05', 'ST005', 'ST005', '周末', 50);

-- Table: bj_metro_revenue
TRUNCATE TABLE `bj_metro_revenue`;
INSERT INTO `bj_metro_revenue`(`revenue_date`, `line_id`, `ticket_revenue`, `subsidy_amount`, `ticket_count`, `ad_revenue`, `commercial_revenue`) VALUES
  ('2025-04-01', 'L01', 1000.25, 1000.25, 10, 1000.25, 1000.25),
  ('2025-04-02', 'L02', 2000.50, 2000.50, 20, 2000.50, 2000.50),
  ('2025-04-03', 'L03', 3000.75, 3000.75, 30, 3000.75, 3000.75),
  ('2025-04-04', 'L04', 4001.00, 4001.00, 40, 4001.00, 4001.00),
  ('2025-04-05', 'L05', 5001.25, 5001.25, 50, 5001.25, 5001.25);

-- Table: bj_metro_stations
TRUNCATE TABLE `bj_metro_stations`;
INSERT INTO `bj_metro_stations`(`station_id`, `station_name`, `line_id`, `sequence_no`, `district`, `daily_capacity`, `is_interchange`, `interchange_lines`, `is_terminal`) VALUES
  ('ST001', '国贸站', 'L01', 1, '朝阳区', 1, 1, 'bj_metro_stations_interchange_lines_1', 1),
  ('ST002', '西直门站', 'L02', 2, '西城区', 2, 0, 'bj_metro_stations_interchange_lines_2', 0),
  ('ST003', '望京站', 'L03', 3, '海淀区', 3, 1, 'bj_metro_stations_interchange_lines_3', 1),
  ('ST004', '宋家庄站', 'L04', 4, '丰台区', 4, 0, 'bj_metro_stations_interchange_lines_4', 0),
  ('ST005', '北京南站', 'L05', 5, '大兴区', 5, 1, 'bj_metro_stations_interchange_lines_5', 1);

-- Table: bj_metro_train_ops
TRUNCATE TABLE `bj_metro_train_ops`;
INSERT INTO `bj_metro_train_ops`(`ops_date`, `line_id`, `planned_trains`, `actual_trains`, `punctuality_rate`, `delay_count`, `max_delay_sec`, `total_mileage_km`, `fault_count`) VALUES
  ('2025-04-01', 'L01', 1, 1, 0.0500, 10, 1, 26, 10),
  ('2025-04-02', 'L02', 2, 2, 0.1000, 20, 2, 27, 20),
  ('2025-04-03', 'L03', 3, 3, 0.1500, 30, 3, 28, 30),
  ('2025-04-04', 'L04', 4, 4, 0.2000, 40, 4, 29, 40),
  ('2025-04-05', 'L05', 5, 5, 0.2500, 50, 5, 30, 50);
