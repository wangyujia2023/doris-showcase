-- ================================================================
-- 服饰零售 - 商品域真实风格血缘示例
-- 场景：
--   PIM/ERP -> ETL任务 -> Doris DWD/DWS/ADS
-- 目的：
--   让 OpenMetadata 能解析出真实的表级血缘与 Pipeline 血缘
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

-- ------------------------
-- 1. 源表：商品主数据
-- ------------------------
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

-- ------------------------
-- 2. ETL 任务节点（OpenMetadata Pipeline）
-- ------------------------
CREATE TABLE IF NOT EXISTS om_pipeline_asset (
  pipeline_id VARCHAR(64) NOT NULL,
  pipeline_name VARCHAR(128) NOT NULL,
  domain_id VARCHAR(64) NOT NULL,
  owner VARCHAR(128) DEFAULT '',
  description VARCHAR(512) DEFAULT '',
  openmetadata_url VARCHAR(512) DEFAULT '',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(pipeline_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

-- 商品标准化任务
INSERT INTO om_pipeline_asset
(pipeline_id, pipeline_name, domain_id, owner, description, openmetadata_url, updated_at)
VALUES
('pl_product_standardize', '商品标准化任务', 'product', '商品数据组', '将 PIM 商品主数据与 ERP 价格快照加工为商品维表', 'http://10.26.20.3:8585/pipeline/pl_product_standardize', NOW()),
('pl_product_sales', '商品销售汇总任务', 'product', '商品数据组', '按 SKU 聚合销售表现并生成销售汇总', 'http://10.26.20.3:8585/pipeline/pl_product_sales', NOW()),
('pl_product_rank', '热销商品看板任务', 'product', '商品数据组', '生成热销商品排行与趋势看板', 'http://10.26.20.3:8585/pipeline/pl_product_rank', NOW());

-- ------------------------
-- 3. DWD / DWS / ADS 目标表
-- ------------------------
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

-- ------------------------
-- 4. 模拟源数据
-- ------------------------
INSERT INTO pim_item_master
(sku_id, spu_id, sku_name, brand_name, category_lv1, category_lv2, season, gender, color, size_code, launch_date, status, updated_at)
VALUES
(10001, 20001, '秋冬羊毛大衣-米白-S', 'AURA', '外套', '大衣', '2025AW', '女', '米白', 'S', '2025-09-10', 'ACTIVE', NOW()),
(10002, 20001, '秋冬羊毛大衣-米白-M', 'AURA', '外套', '大衣', '2025AW', '女', '米白', 'M', '2025-09-10', 'ACTIVE', NOW()),
(10003, 20002, '轻羽绒短款-黑色-L', 'URBAN', '外套', '羽绒服', '2025AW', '女', '黑色', 'L', '2025-10-01', 'ACTIVE', NOW()),
(10004, 20003, '休闲针织衫-灰色-M', 'BASIC', '上衣', '针织衫', '2025AW', '男', '灰色', 'M', '2025-08-18', 'ACTIVE', NOW());

INSERT INTO erp_sku_price_snapshot
(sku_id, price_date, list_price, sale_price, cost_price, promo_flag, updated_at)
VALUES
(10001, '2025-10-01', 1299.00, 999.00, 520.00, 1, NOW()),
(10002, '2025-10-01', 1299.00, 999.00, 520.00, 1, NOW()),
(10003, '2025-10-01', 1699.00, 1399.00, 710.00, 0, NOW()),
(10004, '2025-10-01', 699.00, 499.00, 210.00, 1, NOW());

INSERT INTO pos_sku_sales_detail
(sale_id, sale_date, store_id, sku_id, qty, gross_amount, discount_amount, net_amount, channel, updated_at)
VALUES
(50001, '2025-10-01', 101, 10001, 12, 15588.00, 3600.00, 11988.00, 'POS', NOW()),
(50002, '2025-10-01', 101, 10002, 8, 10392.00, 2400.00, 7992.00, 'POS', NOW()),
(50003, '2025-10-01', 102, 10003, 6, 10194.00, 1800.00, 8394.00, 'POS', NOW()),
(50004, '2025-10-01', 103, 10004, 20, 13980.00, 3980.00, 10000.00, 'POS', NOW());

INSERT INTO mkt_product_tag_rule
(rule_id, sku_id, tag_name, tag_value, updated_at)
VALUES
(90001, 10001, '风格', '通勤', NOW()),
(90002, 10002, '风格', '通勤', NOW()),
(90003, 10003, '风格', '机能', NOW()),
(90004, 10004, '风格', '基础', NOW());

-- ------------------------
-- 5. ETL 一：商品标准化
-- ------------------------
INSERT INTO dwd_sku_dim
(
  sku_id, spu_id, sku_name, brand_name, category_lv1, category_lv2, season, gender, color, size_code,
  launch_date, status, list_price, sale_price, cost_price, promo_flag, price_date, updated_at
)
SELECT
  p.sku_id,
  p.spu_id,
  p.sku_name,
  p.brand_name,
  p.category_lv1,
  p.category_lv2,
  p.season,
  p.gender,
  p.color,
  p.size_code,
  p.launch_date,
  p.status,
  COALESCE(e.list_price, 0) AS list_price,
  COALESCE(e.sale_price, 0) AS sale_price,
  COALESCE(e.cost_price, 0) AS cost_price,
  COALESCE(e.promo_flag, 0) AS promo_flag,
  e.price_date,
  NOW()
FROM pim_item_master p
LEFT JOIN erp_sku_price_snapshot e
  ON p.sku_id = e.sku_id
 AND e.price_date = '2025-10-01';

-- ------------------------
-- 6. ETL 二：商品销售汇总
-- ------------------------
INSERT INTO dws_product_sales
(
  sale_date, sku_id, sku_name, brand_name, category_lv1,
  qty_total, gross_amount_total, discount_amount_total, net_amount_total, avg_price, updated_at
)
SELECT
  s.sale_date,
  d.sku_id,
  d.sku_name,
  d.brand_name,
  d.category_lv1,
  SUM(s.qty) AS qty_total,
  SUM(s.gross_amount) AS gross_amount_total,
  SUM(s.discount_amount) AS discount_amount_total,
  SUM(s.net_amount) AS net_amount_total,
  ROUND(SUM(s.net_amount) / NULLIF(SUM(s.qty), 0), 2) AS avg_price,
  NOW()
FROM pos_sku_sales_detail s
JOIN dwd_sku_dim d
  ON s.sku_id = d.sku_id
WHERE s.sale_date = '2025-10-01'
GROUP BY s.sale_date, d.sku_id, d.sku_name, d.brand_name, d.category_lv1;

-- ------------------------
-- 7. ETL 三：热销商品看板
-- ------------------------
INSERT INTO ads_product_rank
(
  stat_date, sku_id, sku_name, brand_name, net_amount_total, qty_total, rank_no, updated_at
)
SELECT
  sale_date AS stat_date,
  sku_id,
  sku_name,
  brand_name,
  net_amount_total,
  qty_total,
  ROW_NUMBER() OVER (PARTITION BY sale_date ORDER BY net_amount_total DESC, qty_total DESC, sku_id ASC) AS rank_no,
  NOW()
FROM dws_product_sales
WHERE sale_date = '2025-10-01';

-- ------------------------
-- 8. OpenMetadata 可见的血缘补边
-- ------------------------
INSERT INTO lineage_asset
(asset_id, asset_name, asset_type, domain_id, layer_name, source_system, owner, openmetadata_url, description, refreshed_at)
VALUES
('pim_item_master', 'PIM 商品主数据', 'table', 'product', 'ODS', 'PIM', '商品数据组', 'http://10.26.20.3:8585/table/pim_item_master', '服饰商品主数据源表', NOW()),
('erp_sku_price_snapshot', 'ERP 商品价格快照', 'table', 'product', 'ODS', 'ERP', '商品数据组', 'http://10.26.20.3:8585/table/erp_sku_price_snapshot', 'SKU 价格源表', NOW()),
('pos_sku_sales_detail', 'POS 商品销售明细', 'table', 'product', 'ODS', 'POS', '交易数据组', 'http://10.26.20.3:8585/table/pos_sku_sales_detail', 'POS 销售源表', NOW()),
('mkt_product_tag_rule', '商品标签规则', 'table', 'product', 'ODS', 'MKT', '营销数据组', 'http://10.26.20.3:8585/table/mkt_product_tag_rule', '营销标签规则源表', NOW()),
('dwd_sku_dim', '商品维表', 'table', 'product', 'DWD', 'Doris', '商品数据组', 'http://10.26.20.3:8585/table/dwd_sku_dim', '商品标准化结果表', NOW()),
('dws_product_sales', '商品销售汇总', 'table', 'product', 'DWS', 'Doris', '商品数据组', 'http://10.26.20.3:8585/table/dws_product_sales', '商品销售聚合结果表', NOW()),
('ads_product_rank', '热销商品看板', 'report', 'product', 'ADS', 'BI', '商品数据组', 'http://10.26.20.3:8585/dashboard/ads_product_rank', '商品热销排行看板', NOW());

INSERT INTO lineage_edge
(edge_id, from_asset_id, to_asset_id, relation_type, weight, source_system, updated_at)
VALUES
('rl_001', 'pim_item_master', 'dwd_sku_dim', 'read', 5, 'OpenMetadata', NOW()),
('rl_002', 'erp_sku_price_snapshot', 'dwd_sku_dim', 'read', 5, 'OpenMetadata', NOW()),
('rl_003', 'dwd_sku_dim', 'dws_product_sales', 'transform', 8, 'OpenMetadata', NOW()),
('rl_004', 'pos_sku_sales_detail', 'dws_product_sales', 'read', 5, 'OpenMetadata', NOW()),
('rl_005', 'dws_product_sales', 'ads_product_rank', 'publish', 9, 'OpenMetadata', NOW()),
('rl_006', 'mkt_product_tag_rule', 'dwd_sku_dim', 'read', 3, 'OpenMetadata', NOW());

INSERT INTO lineage_snapshot
(snapshot_id, domain_id, snapshot_name, snapshot_time, asset_count, edge_count, source)
VALUES
('snap_product_real_001', 'product', '商品域真实 ETL 血缘快照', NOW(), 7, 6, 'mock-real-etl');

