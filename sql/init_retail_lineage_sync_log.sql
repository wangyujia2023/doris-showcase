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
