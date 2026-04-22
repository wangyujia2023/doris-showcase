-- 北京地铁运营分析平台 · 建表DDL（纯DDL，数据库切换由服务层控制）
use  bjmetro;
-- 1. 线路基础信息
DROP TABLE IF EXISTS bj_metro_lines;
CREATE TABLE bj_metro_lines (
    line_id             VARCHAR(10)     NOT NULL,
    line_name           VARCHAR(50)     NOT NULL,
    line_color          VARCHAR(10),
    total_stations      INT,
    total_length_km     DECIMAL(8,2),
    open_year           INT,
    daily_capacity_w    INT             COMMENT '日运能（万人次）',
    peak_interval_s     INT             COMMENT '高峰行车间隔（秒）',
    offpeak_interval_s  INT             COMMENT '平峰行车间隔（秒）',
    status              VARCHAR(20)
) ENGINE=OLAP
UNIQUE KEY(line_id)
DISTRIBUTED BY HASH(line_id) BUCKETS 3
PROPERTIES ("replication_num"="1");

-- 2. 站点信息
DROP TABLE IF EXISTS bj_metro_stations;
CREATE TABLE bj_metro_stations (
    station_id          VARCHAR(20)     NOT NULL,
    station_name        VARCHAR(50)     NOT NULL,
    line_id             VARCHAR(10)     NOT NULL,
    sequence_no         INT,
    district            VARCHAR(20),
    daily_capacity      INT,
    is_interchange      TINYINT         DEFAULT 0,
    interchange_lines   VARCHAR(100),
    is_terminal         TINYINT         DEFAULT 0
) ENGINE=OLAP
UNIQUE KEY(station_id, station_name)
DISTRIBUTED BY HASH(station_id) BUCKETS 5
PROPERTIES ("replication_num"="1");

-- 3. 逐日客流（按站点+日期唯一）
DROP TABLE IF EXISTS bj_metro_daily_flow;
CREATE TABLE bj_metro_daily_flow (
    flow_date           DATE            NOT NULL,
    station_id          VARCHAR(20)     NOT NULL,
    line_id             VARCHAR(10)     NOT NULL,
    inbound_count       BIGINT,
    outbound_count      BIGINT,
    peak_inbound        BIGINT
) ENGINE=OLAP
UNIQUE KEY(flow_date, station_id, line_id)
DISTRIBUTED BY HASH(station_id) BUCKETS 5
PROPERTIES ("replication_num"="1");

-- 4. 逐时客流（按线路+小时+日期唯一）
DROP TABLE IF EXISTS bj_metro_hourly_flow;
CREATE TABLE bj_metro_hourly_flow (
    flow_date           DATE            NOT NULL,
    flow_hour           TINYINT         NOT NULL,
    line_id             VARCHAR(10)     NOT NULL,
    total_passengers    BIGINT,
    overcapacity_cnt    INT
) ENGINE=OLAP
UNIQUE KEY(flow_date, flow_hour, line_id)
DISTRIBUTED BY HASH(line_id) BUCKETS 5
PROPERTIES ("replication_num"="1");

-- 5. 列车运营日报
DROP TABLE IF EXISTS bj_metro_train_ops;
CREATE TABLE bj_metro_train_ops (
    ops_date            DATE            NOT NULL,
    line_id             VARCHAR(10)     NOT NULL,
    planned_trains      INT,
    actual_trains       INT,
    punctuality_rate    DECIMAL(6,4),
    delay_count         INT,
    max_delay_sec       INT,
    total_mileage_km    DECIMAL(10,2),
    fault_count         INT
) ENGINE=OLAP
UNIQUE KEY(ops_date, line_id)
DISTRIBUTED BY HASH(line_id) BUCKETS 3
PROPERTIES ("replication_num"="1");

-- 6. 故障日志（DUPLICATE KEY + 倒排索引）
DROP TABLE IF EXISTS bj_metro_fault_log;
CREATE TABLE bj_metro_fault_log (
    fault_id            VARCHAR(30)     NOT NULL,
    fault_time          DATETIME        NOT NULL,
    line_id             VARCHAR(10),
    station_id          VARCHAR(20),
    device_type         VARCHAR(30),
    fault_type          VARCHAR(50),
    severity            VARCHAR(20),
    description         VARCHAR(200),
    resolve_time        DATETIME,
    resolve_min         INT,
    status              VARCHAR(20),
    handler             VARCHAR(30),
    INDEX idx_fault_type  (fault_type)  USING INVERTED,
    INDEX idx_severity    (severity)    USING INVERTED,
    INDEX idx_device_type (device_type) USING INVERTED
) ENGINE=OLAP
DUPLICATE KEY(fault_id, fault_time)
DISTRIBUTED BY HASH(fault_id) BUCKETS 5
PROPERTIES ("replication_num"="1");

-- 7. 收入日报（金额单位：分）
DROP TABLE IF EXISTS bj_metro_revenue;
CREATE TABLE bj_metro_revenue (
    revenue_date        DATE            NOT NULL,
    line_id             VARCHAR(10)     NOT NULL,
    ticket_revenue      BIGINT,
    subsidy_amount      BIGINT,
    ticket_count        BIGINT,
    ad_revenue          BIGINT,
    commercial_revenue  BIGINT
) ENGINE=OLAP
UNIQUE KEY(revenue_date, line_id)
DISTRIBUTED BY HASH(line_id) BUCKETS 3
PROPERTIES ("replication_num"="1");

-- 8. OD 客流
DROP TABLE IF EXISTS bj_metro_od_flow;
CREATE TABLE bj_metro_od_flow (
    flow_date           DATE            NOT NULL,
    origin_id           VARCHAR(20)     NOT NULL,
    dest_id             VARCHAR(20)     NOT NULL,
    peak_type           VARCHAR(10)     NOT NULL  COMMENT 'morning/evening/off',
    flow_count          BIGINT
) ENGINE=OLAP
UNIQUE KEY(flow_date, origin_id, dest_id, peak_type)
DISTRIBUTED BY HASH(origin_id) BUCKETS 5
PROPERTIES ("replication_num"="1");
