-- ================================================================
-- 服饰零售数据血缘 ETL 导出包
-- 内容：
-- 1. 商品域真实风格 ETL
-- 2. 服饰零售血缘 mock 节点与 ETL 任务
-- 3. 可直接给 Airflow / OpenMetadata 使用
-- ================================================================

-- 说明：
-- 如需完整运行，请先按顺序导入：
--   1) sql/init_retail_lineage.sql
--   2) sql/init_retail_lineage_mock.sql
--   3) sql/init_retail_lineage_etl_mock.sql
--   4) sql/init_retail_lineage_product_real_etl.sql
--
-- 本文件用于导出归档，便于后续搬运到别的环境。

-- ================================================================
-- 商品域真实风格 ETL
-- 来源：sql/init_retail_lineage_product_real_etl.sql
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

CREATE TABLE IF NOT EXISTS pim_item_master (
  sku_id BIGINT NOT NULL,
  spu_id BIGINT NOT NULL,
  sku_name VARCHAR(128) NOT NULL,
  brand_name VARCHAR(64) DEFAULT '',
  category_lv1 VARCHAR(64) DEFAULT '',
  category_lv2 VARCHAR(64) DEFAULT '',
  season VARCHAR(32) DEFAULT '',
  gender VARCHAR(16) DEFAULT '',
  color VARCHAR(32) DEFAULT '',
  size_code VARCHAR(32) DEFAULT '',
  launch_date DATE,
  status VARCHAR(16) DEFAULT 'ACTIVE',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(sku_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS erp_sku_price_snapshot (
  sku_id BIGINT NOT NULL,
  price_date DATE NOT NULL,
  list_price DECIMAL(10,2) DEFAULT 0,
  sale_price DECIMAL(10,2) DEFAULT 0,
  cost_price DECIMAL(10,2) DEFAULT 0,
  promo_flag TINYINT DEFAULT 0,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(sku_id, price_date)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS pos_sku_sales_detail (
  sale_id BIGINT NOT NULL,
  sale_date DATE NOT NULL,
  store_id BIGINT NOT NULL,
  sku_id BIGINT NOT NULL,
  qty INT DEFAULT 0,
  gross_amount DECIMAL(12,2) DEFAULT 0,
  discount_amount DECIMAL(12,2) DEFAULT 0,
  net_amount DECIMAL(12,2) DEFAULT 0,
  channel VARCHAR(32) DEFAULT 'POS',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(sale_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS mkt_product_tag_rule (
  rule_id BIGINT NOT NULL,
  sku_id BIGINT NOT NULL,
  tag_name VARCHAR(64) NOT NULL,
  tag_value VARCHAR(64) NOT NULL,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(rule_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS dwd_sku_dim (
  sku_id BIGINT NOT NULL,
  spu_id BIGINT NOT NULL,
  sku_name VARCHAR(128) NOT NULL,
  brand_name VARCHAR(64) DEFAULT '',
  category_lv1 VARCHAR(64) DEFAULT '',
  category_lv2 VARCHAR(64) DEFAULT '',
  season VARCHAR(32) DEFAULT '',
  gender VARCHAR(16) DEFAULT '',
  color VARCHAR(32) DEFAULT '',
  size_code VARCHAR(32) DEFAULT '',
  launch_date DATE,
  status VARCHAR(16) DEFAULT 'ACTIVE',
  list_price DECIMAL(10,2) DEFAULT 0,
  sale_price DECIMAL(10,2) DEFAULT 0,
  cost_price DECIMAL(10,2) DEFAULT 0,
  promo_flag TINYINT DEFAULT 0,
  price_date DATE,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(sku_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS dws_product_sales (
  sale_date DATE NOT NULL,
  sku_id BIGINT NOT NULL,
  sku_name VARCHAR(128) NOT NULL,
  brand_name VARCHAR(64) DEFAULT '',
  category_lv1 VARCHAR(64) DEFAULT '',
  qty_total INT DEFAULT 0,
  gross_amount_total DECIMAL(12,2) DEFAULT 0,
  discount_amount_total DECIMAL(12,2) DEFAULT 0,
  net_amount_total DECIMAL(12,2) DEFAULT 0,
  avg_price DECIMAL(12,2) DEFAULT 0,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(sale_date, sku_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS ads_product_rank (
  stat_date DATE NOT NULL,
  sku_id BIGINT NOT NULL,
  sku_name VARCHAR(128) NOT NULL,
  brand_name VARCHAR(64) DEFAULT '',
  net_amount_total DECIMAL(12,2) DEFAULT 0,
  qty_total INT DEFAULT 0,
  rank_no INT DEFAULT 0,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(stat_date, sku_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

INSERT INTO pim_item_master VALUES
(10001, 20001, '秋冬羊毛大衣-米白-S', 'AURA', '外套', '大衣', '2025AW', '女', '米白', 'S', '2025-09-10', 'ACTIVE', NOW()),
(10002, 20001, '秋冬羊毛大衣-米白-M', 'AURA', '外套', '大衣', '2025AW', '女', '米白', 'M', '2025-09-10', 'ACTIVE', NOW()),
(10003, 20002, '轻羽绒短款-黑色-L', 'URBAN', '外套', '羽绒服', '2025AW', '女', '黑色', 'L', '2025-10-01', 'ACTIVE', NOW()),
(10004, 20003, '休闲针织衫-灰色-M', 'BASIC', '上衣', '针织衫', '2025AW', '男', '灰色', 'M', '2025-08-18', 'ACTIVE', NOW());

INSERT INTO erp_sku_price_snapshot VALUES
(10001, '2025-10-01', 1299.00, 999.00, 520.00, 1, NOW()),
(10002, '2025-10-01', 1299.00, 999.00, 520.00, 1, NOW()),
(10003, '2025-10-01', 1699.00, 1399.00, 710.00, 0, NOW()),
(10004, '2025-10-01', 699.00, 499.00, 210.00, 1, NOW());

INSERT INTO pos_sku_sales_detail VALUES
(50001, '2025-10-01', 101, 10001, 12, 15588.00, 3600.00, 11988.00, 'POS', NOW()),
(50002, '2025-10-01', 101, 10002, 8, 10392.00, 2400.00, 7992.00, 'POS', NOW()),
(50003, '2025-10-01', 102, 10003, 6, 10194.00, 1800.00, 8394.00, 'POS', NOW()),
(50004, '2025-10-01', 103, 10004, 20, 13980.00, 3980.00, 10000.00, 'POS', NOW());

INSERT INTO mkt_product_tag_rule VALUES
(90001, 10001, '风格', '通勤', NOW()),
(90002, 10002, '风格', '通勤', NOW()),
(90003, 10003, '风格', '机能', NOW()),
(90004, 10004, '风格', '基础', NOW());

INSERT INTO dwd_sku_dim
SELECT
  p.sku_id, p.spu_id, p.sku_name, p.brand_name, p.category_lv1, p.category_lv2,
  p.season, p.gender, p.color, p.size_code, p.launch_date, p.status,
  COALESCE(e.list_price, 0), COALESCE(e.sale_price, 0), COALESCE(e.cost_price, 0),
  COALESCE(e.promo_flag, 0), e.price_date, NOW()
FROM pim_item_master p
LEFT JOIN erp_sku_price_snapshot e
  ON p.sku_id = e.sku_id AND e.price_date = '2025-10-01';

INSERT INTO dws_product_sales
SELECT
  s.sale_date,
  d.sku_id,
  d.sku_name,
  d.brand_name,
  d.category_lv1,
  SUM(s.qty),
  SUM(s.gross_amount),
  SUM(s.discount_amount),
  SUM(s.net_amount),
  ROUND(SUM(s.net_amount) / NULLIF(SUM(s.qty), 0), 2),
  NOW()
FROM pos_sku_sales_detail s
JOIN dwd_sku_dim d ON s.sku_id = d.sku_id
WHERE s.sale_date = '2025-10-01'
GROUP BY s.sale_date, d.sku_id, d.sku_name, d.brand_name, d.category_lv1;

INSERT INTO ads_product_rank
SELECT
  sale_date,
  sku_id,
  sku_name,
  brand_name,
  net_amount_total,
  qty_total,
  ROW_NUMBER() OVER (PARTITION BY sale_date ORDER BY net_amount_total DESC, qty_total DESC, sku_id ASC),
  NOW()
FROM dws_product_sales
WHERE sale_date = '2025-10-01';

-- ================================================================
-- 模拟 ETL / Pipeline / lineage 的导出说明
-- ================================================================
-- 其余模拟 ETL 请直接导出以下文件：
--   sql/init_retail_lineage.sql
--   sql/init_retail_lineage_mock.sql
--   sql/init_retail_lineage_etl_mock.sql
--
-- 它们分别包含：
--   1. 血缘基础表
--   2. 业务域、资产、边、影响分析
--   3. ETL 任务、任务输入输出、Pipeline 血缘
