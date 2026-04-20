-- 服饰零售复杂 ETL 示例
-- 特点:
-- 1. 4 表关联
-- 2. 窗口函数
-- 3. 条件过滤
-- 4. 先明细后汇总的多层加工链路

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

DROP TABLE IF EXISTS stg_member_profile;
DROP TABLE IF EXISTS stg_stock_snapshot;
DROP TABLE IF EXISTS stg_promo_rule;
DROP TABLE IF EXISTS stg_order_fact;
DROP TABLE IF EXISTS dwd_retail_order_enriched;
DROP TABLE IF EXISTS dws_retail_member_sales;
DROP TABLE IF EXISTS ads_retail_top_sku;

CREATE TABLE IF NOT EXISTS stg_member_profile (
    member_id       VARCHAR(32) NOT NULL,
    member_name     VARCHAR(50),
    gender          VARCHAR(10),
    level_name      VARCHAR(20),
    city            VARCHAR(20),
    register_date   DATE,
    last_active_dt  DATE,
    is_active       TINYINT,
    updated_at      DATETIME
) DUPLICATE KEY(member_id)
DISTRIBUTED BY HASH(member_id) BUCKETS 2
PROPERTIES("replication_num"="1");

CREATE TABLE IF NOT EXISTS stg_stock_snapshot (
    sku_id          VARCHAR(32) NOT NULL,
    shop_id         VARCHAR(32) NOT NULL,
    stock_qty       INT,
    safety_stock    INT,
    stock_status    VARCHAR(20),
    snapshot_date   DATE,
    updated_at      DATETIME
) DUPLICATE KEY(sku_id, shop_id, snapshot_date)
DISTRIBUTED BY HASH(sku_id) BUCKETS 2
PROPERTIES("replication_num"="1");

CREATE TABLE IF NOT EXISTS stg_promo_rule (
    promo_id        VARCHAR(32) NOT NULL,
    sku_id          VARCHAR(32) NOT NULL,
    promo_type      VARCHAR(20),
    discount_rate   DECIMAL(10,4),
    start_date      DATE,
    end_date        DATE,
    is_enabled      TINYINT,
    updated_at      DATETIME
) DUPLICATE KEY(promo_id, sku_id)
DISTRIBUTED BY HASH(promo_id) BUCKETS 2
PROPERTIES("replication_num"="1");

CREATE TABLE IF NOT EXISTS stg_order_fact (
    order_id        VARCHAR(32) NOT NULL,
    order_dt        DATE,
    member_id       VARCHAR(32),
    sku_id          VARCHAR(32),
    shop_id         VARCHAR(32),
    qty             INT,
    sales_amt       DECIMAL(18,2),
    pay_amt         DECIMAL(18,2),
    order_status    VARCHAR(20),
    channel         VARCHAR(20),
    updated_at      DATETIME
) DUPLICATE KEY(order_id)
DISTRIBUTED BY HASH(order_id) BUCKETS 4
PROPERTIES("replication_num"="1");

CREATE TABLE IF NOT EXISTS dwd_retail_order_enriched (
    order_dt            DATE,
    order_id            VARCHAR(32),
    member_id           VARCHAR(32),
    member_level        VARCHAR(20),
    city                VARCHAR(20),
    sku_id              VARCHAR(32),
    shop_id             VARCHAR(32),
    qty                 INT,
    sales_amt           DECIMAL(18,2),
    pay_amt             DECIMAL(18,2),
    stock_qty           INT,
    stock_status        VARCHAR(20),
    promo_id            VARCHAR(32),
    promo_type          VARCHAR(20),
    discount_rate       DECIMAL(10,4),
    member_day_rank     INT,
    member_month_rank   INT,
    is_big_order        TINYINT,
    updated_at          DATETIME
) DUPLICATE KEY(order_dt, order_id)
DISTRIBUTED BY HASH(order_id) BUCKETS 4
PROPERTIES("replication_num"="1");

CREATE TABLE IF NOT EXISTS dws_retail_member_sales (
    stat_dt             DATE,
    member_id           VARCHAR(32),
    member_level        VARCHAR(20),
    city                VARCHAR(20),
    order_cnt           INT,
    sku_cnt             INT,
    qty_total           BIGINT,
    sales_total         DECIMAL(18,2),
    pay_total           DECIMAL(18,2),
    avg_order_amt       DECIMAL(18,2),
    member_sales_rank   INT,
    last_order_dt       DATE,
    updated_at          DATETIME
) DUPLICATE KEY(stat_dt, member_id)
DISTRIBUTED BY HASH(member_id) BUCKETS 4
PROPERTIES("replication_num"="1");

CREATE TABLE IF NOT EXISTS ads_retail_top_sku (
    stat_dt             DATE,
    sku_id              VARCHAR(32),
    shop_id             VARCHAR(32),
    order_cnt           INT,
    qty_total           BIGINT,
    sales_total         DECIMAL(18,2),
    pay_total           DECIMAL(18,2),
    stock_qty_avg       DOUBLE,
    stock_risk_flag     TINYINT,
    sku_rank            INT,
    updated_at          DATETIME
) DUPLICATE KEY(stat_dt, sku_id, shop_id)
DISTRIBUTED BY HASH(sku_id) BUCKETS 4
PROPERTIES("replication_num"="1");

INSERT INTO stg_member_profile VALUES
('M0001','林雨','F','VIP','上海','2023-01-02','2024-04-18',1,NOW()),
('M0002','周涛','M','GOLD','杭州','2022-11-15','2024-04-20',1,NOW()),
('M0003','陈晨','F','SILVER','北京','2024-02-12','2024-04-19',1,NOW()),
('M0004','赵敏','F','VIP','广州','2021-08-08','2024-04-17',1,NOW());

INSERT INTO stg_stock_snapshot VALUES
('SKU1001','SHOP01',120,80,'NORMAL','2024-04-20',NOW()),
('SKU1002','SHOP01',18,60,'LOW','2024-04-20',NOW()),
('SKU1003','SHOP02',0,50,'OUT','2024-04-20',NOW()),
('SKU1004','SHOP02',95,70,'NORMAL','2024-04-20',NOW());

INSERT INTO stg_promo_rule VALUES
('P0001','SKU1001','满减',0.8800,'2024-04-01','2024-04-30',1,NOW()),
('P0002','SKU1002','折扣',0.7500,'2024-04-10','2024-04-25',1,NOW()),
('P0003','SKU1003','秒杀',0.6200,'2024-04-18','2024-04-21',1,NOW()),
('P0004','SKU1004','无',1.0000,'2024-01-01','2024-12-31',1,NOW());

INSERT INTO stg_order_fact VALUES
('O0001','2024-04-20','M0001','SKU1001','SHOP01',2,398.00,350.24,'PAID','APP',NOW()),
('O0002','2024-04-20','M0001','SKU1002','SHOP01',1,199.00,149.25,'PAID','APP',NOW()),
('O0003','2024-04-20','M0002','SKU1001','SHOP01',1,199.00,175.12,'PAID','MINIAPP',NOW()),
('O0004','2024-04-20','M0003','SKU1003','SHOP02',3,597.00,369.54,'PAID','APP',NOW()),
('O0005','2024-04-20','M0004','SKU1004','SHOP02',1,299.00,299.00,'PAID','STORE',NOW());

INSERT INTO dwd_retail_order_enriched
SELECT
    o.order_dt,
    o.order_id,
    o.member_id,
    m.level_name AS member_level,
    m.city,
    o.sku_id,
    o.shop_id,
    o.qty,
    o.sales_amt,
    o.pay_amt,
    s.stock_qty,
    s.stock_status,
    p.promo_id,
    p.promo_type,
    p.discount_rate,
    ROW_NUMBER() OVER (PARTITION BY o.member_id ORDER BY o.order_dt DESC, o.order_id DESC) AS member_day_rank,
    ROW_NUMBER() OVER (PARTITION BY o.member_id, DATE_FORMAT(o.order_dt, '%Y-%m') ORDER BY o.pay_amt DESC, o.order_id DESC) AS member_month_rank,
    CASE WHEN o.pay_amt >= 300 THEN 1 ELSE 0 END AS is_big_order,
    NOW() AS updated_at
FROM stg_order_fact o
LEFT JOIN stg_member_profile m
    ON o.member_id = m.member_id
LEFT JOIN stg_stock_snapshot s
    ON o.sku_id = s.sku_id
   AND o.shop_id = s.shop_id
   AND o.order_dt = s.snapshot_date
LEFT JOIN stg_promo_rule p
    ON o.sku_id = p.sku_id
   AND o.order_dt BETWEEN p.start_date AND p.end_date
   AND p.is_enabled = 1
WHERE o.order_status = 'PAID'
  AND o.order_dt >= '2024-04-20'
  AND o.channel IN ('APP', 'MINIAPP', 'STORE');

INSERT INTO dws_retail_member_sales
SELECT
    order_dt AS stat_dt,
    member_id,
    member_level,
    city,
    COUNT(DISTINCT order_id) AS order_cnt,
    COUNT(DISTINCT sku_id) AS sku_cnt,
    SUM(qty) AS qty_total,
    SUM(sales_amt) AS sales_total,
    SUM(pay_amt) AS pay_total,
    ROUND(SUM(pay_amt) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS avg_order_amt,
    RANK() OVER (ORDER BY SUM(pay_amt) DESC) AS member_sales_rank,
    MAX(order_dt) AS last_order_dt,
    NOW() AS updated_at
FROM dwd_retail_order_enriched
WHERE is_big_order = 0
  AND member_level IN ('VIP', 'GOLD', 'SILVER')
GROUP BY order_dt, member_id, member_level, city;

INSERT INTO ads_retail_top_sku
SELECT
    d.order_dt AS stat_dt,
    d.sku_id,
    d.shop_id,
    COUNT(DISTINCT d.order_id) AS order_cnt,
    SUM(d.qty) AS qty_total,
    SUM(d.sales_amt) AS sales_total,
    SUM(d.pay_amt) AS pay_total,
    AVG(s.stock_qty) AS stock_qty_avg,
    CASE
        WHEN AVG(s.stock_qty) < 20 OR SUM(d.qty) >= 5 THEN 1
        ELSE 0
    END AS stock_risk_flag,
    ROW_NUMBER() OVER (
        PARTITION BY d.order_dt, d.shop_id
        ORDER BY SUM(d.pay_amt) DESC, SUM(d.qty) DESC, d.sku_id ASC
    ) AS sku_rank,
    NOW() AS updated_at
FROM dwd_retail_order_enriched d
LEFT JOIN stg_stock_snapshot s
    ON d.sku_id = s.sku_id
   AND d.shop_id = s.shop_id
   AND d.order_dt = s.snapshot_date
WHERE d.order_dt = '2024-04-20'
  AND d.pay_amt >= 100
  AND d.stock_status IN ('NORMAL', 'LOW', 'OUT')
GROUP BY d.order_dt, d.sku_id, d.shop_id;

