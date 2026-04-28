-- ================================================================
-- Doris Showcase lineage ETL examples
-- Purpose: generate real INSERT INTO ... SELECT audit logs for OpenMetadata lineage sync.
-- Execute after lineage_showcase_schema.sql and lineage_showcase_mock.sql.
-- ================================================================

CREATE DATABASE IF NOT EXISTS lineage_showcase;
USE lineage_showcase;

-- ETL 1: Product master + ERP price snapshot -> DWD SKU dimension
-- Expected table lineage:
--   pim_item_master -> dwd_sku_dim
--   erp_sku_price_snapshot -> dwd_sku_dim
-- Expected column lineage examples:
--   pim_item_master.sku_id -> dwd_sku_dim.sku_id
--   pim_item_master.sku_name -> dwd_sku_dim.sku_name
--   erp_sku_price_snapshot.list_price -> dwd_sku_dim.list_price
--   erp_sku_price_snapshot.sale_price -> dwd_sku_dim.sale_price
INSERT INTO dwd_sku_dim (
    sku_id,
    spu_id,
    sku_name,
    brand_name,
    category_lv1,
    category_lv2,
    season,
    gender,
    color,
    size_code,
    launch_date,
    status,
    list_price,
    sale_price,
    cost_price,
    promo_flag,
    price_date,
    updated_at
)
SELECT
    p.sku_id AS sku_id,
    p.spu_id AS spu_id,
    p.sku_name AS sku_name,
    p.brand_name AS brand_name,
    p.category_lv1 AS category_lv1,
    p.category_lv2 AS category_lv2,
    p.season AS season,
    p.gender AS gender,
    p.color AS color,
    p.size_code AS size_code,
    p.launch_date AS launch_date,
    CASE WHEN p.status IN ('Normal', 'Running', 'Active') THEN 'ACTIVE' ELSE 'INACTIVE' END AS status,
    e.list_price AS list_price,
    e.sale_price AS sale_price,
    e.cost_price AS cost_price,
    e.promo_flag AS promo_flag,
    e.price_date AS price_date,
    NOW() AS updated_at
FROM pim_item_master p
JOIN erp_sku_price_snapshot e
  ON p.sku_id = e.sku_id
WHERE p.status IS NOT NULL
  AND e.price_date >= '2025-01-01';

-- ETL 2: DWD SKU dimension + POS sales detail -> DWS product sales aggregate
-- Expected table lineage:
--   dwd_sku_dim -> dws_product_sales
--   pos_sku_sales_detail -> dws_product_sales
-- Expected column lineage examples:
--   pos_sku_sales_detail.sale_date -> dws_product_sales.sale_date
--   dwd_sku_dim.sku_name -> dws_product_sales.sku_name
--   pos_sku_sales_detail.qty -> dws_product_sales.qty_total
--   pos_sku_sales_detail.net_amount -> dws_product_sales.net_amount_total
INSERT INTO dws_product_sales (
    sale_date,
    sku_id,
    sku_name,
    brand_name,
    category_lv1,
    qty_total,
    gross_amount_total,
    discount_amount_total,
    net_amount_total,
    avg_price,
    updated_at
)
SELECT
    s.sale_date AS sale_date,
    d.sku_id AS sku_id,
    d.sku_name AS sku_name,
    d.brand_name AS brand_name,
    d.category_lv1 AS category_lv1,
    SUM(s.qty) AS qty_total,
    SUM(s.gross_amount) AS gross_amount_total,
    SUM(s.discount_amount) AS discount_amount_total,
    SUM(s.net_amount) AS net_amount_total,
    ROUND(SUM(s.net_amount) / NULLIF(SUM(s.qty), 0), 2) AS avg_price,
    NOW() AS updated_at
FROM pos_sku_sales_detail s
JOIN dwd_sku_dim d
  ON s.sku_id = d.sku_id
WHERE s.sale_date >= '2025-01-01'
  AND UPPER(d.status) IN ('ACTIVE', 'NORMAL', 'RUNNING', 'SUCCESS', 'COMPLETED')
GROUP BY
    s.sale_date,
    d.sku_id,
    d.sku_name,
    d.brand_name,
    d.category_lv1;
