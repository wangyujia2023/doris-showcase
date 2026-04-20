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
