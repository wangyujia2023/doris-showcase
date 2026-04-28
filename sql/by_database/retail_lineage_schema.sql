-- ================================================================
-- Database: retail_lineage
-- Type: schema
-- Description: Retail lineage metadata tables, sync log, ETL task tables and retail ETL physical tables.
-- Execute: mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_schema.sql
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

CREATE TABLE IF NOT EXISTS lineage_domain (
  domain_id VARCHAR(64) NOT NULL,
  domain_name VARCHAR(128) NOT NULL,
  domain_desc VARCHAR(512) DEFAULT '',
  owner VARCHAR(128) DEFAULT '',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(domain_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS lineage_asset (
  asset_id VARCHAR(64) NOT NULL,
  asset_name VARCHAR(256) NOT NULL,
  asset_type VARCHAR(32) NOT NULL,
  domain_id VARCHAR(64) NOT NULL,
  layer_name VARCHAR(32) DEFAULT '',
  source_system VARCHAR(128) DEFAULT '',
  owner VARCHAR(128) DEFAULT '',
  openmetadata_url VARCHAR(512) DEFAULT '',
  description VARCHAR(1024) DEFAULT '',
  refreshed_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(asset_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS lineage_edge (
  edge_id VARCHAR(64) NOT NULL,
  from_asset_id VARCHAR(64) NOT NULL,
  to_asset_id VARCHAR(64) NOT NULL,
  relation_type VARCHAR(32) NOT NULL,
  weight INT DEFAULT 1,
  source_system VARCHAR(128) DEFAULT '',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(edge_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS lineage_snapshot (
  snapshot_id VARCHAR(64) NOT NULL,
  domain_id VARCHAR(64) NOT NULL,
  snapshot_name VARCHAR(128) NOT NULL,
  snapshot_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  asset_count INT DEFAULT 0,
  edge_count INT DEFAULT 0,
  source VARCHAR(64) DEFAULT 'openmetadata'
)
DUPLICATE KEY(snapshot_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS lineage_impact (
  impact_id VARCHAR(64) NOT NULL,
  asset_id VARCHAR(64) NOT NULL,
  impacted_asset_id VARCHAR(64) NOT NULL,
  impact_level VARCHAR(32) NOT NULL,
  impact_reason VARCHAR(512) DEFAULT '',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(impact_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");


-- ================================================================
-- Sync log table
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

CREATE TABLE IF NOT EXISTS lineage_sync_log (
  log_id VARCHAR(64) NOT NULL,
  sync_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  start_date VARCHAR(32) DEFAULT '',
  end_date VARCHAR(32) DEFAULT '',
  scan_limit INT DEFAULT 0,
  scanned INT DEFAULT 0,
  synced INT DEFAULT 0,
  skipped INT DEFAULT 0,
  failed INT DEFAULT 0,
  success TINYINT DEFAULT 0,
  errors TEXT,
  details TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(log_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");


-- ================================================================
-- ETL task metadata tables
-- ================================================================

-- ================================================================
-- 服饰零售数据血缘 - ETL 模拟数据
-- 说明：
-- 1. 依赖 retail_lineage 库与 init_retail_lineage.sql
-- 2. 模拟 ETL 任务、任务输入输出、任务与表的血缘关系
-- 3. 让 OpenMetadata 可呈现 Pipeline / Table / Dashboard 关系
-- ================================================================

CREATE DATABASE IF NOT EXISTS retail_lineage;
USE retail_lineage;

CREATE TABLE IF NOT EXISTS etl_task (
  task_id VARCHAR(64) NOT NULL,
  task_name VARCHAR(256) NOT NULL,
  domain_id VARCHAR(64) NOT NULL,
  task_type VARCHAR(32) NOT NULL,
  schedule_cron VARCHAR(64) DEFAULT '',
  source_system VARCHAR(128) DEFAULT '',
  owner VARCHAR(128) DEFAULT '',
  openmetadata_url VARCHAR(512) DEFAULT '',
  description VARCHAR(1024) DEFAULT '',
  last_run_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(task_id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS etl_task_input (
  id VARCHAR(64) NOT NULL,
  task_id VARCHAR(64) NOT NULL,
  input_asset_id VARCHAR(64) NOT NULL,
  input_role VARCHAR(32) DEFAULT 'source',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");

CREATE TABLE IF NOT EXISTS etl_task_output (
  id VARCHAR(64) NOT NULL,
  task_id VARCHAR(64) NOT NULL,
  output_asset_id VARCHAR(64) NOT NULL,
  output_role VARCHAR(32) DEFAULT 'target',
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
DUPLICATE KEY(id)
PROPERTIES ("replication_num" = "1", "light_schema_change" = "true");



-- ================================================================
-- Product real ETL physical tables
-- ================================================================

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


-- ================================================================
-- Complex ETL physical tables
-- ================================================================

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

