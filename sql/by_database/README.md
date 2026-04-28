# SQL Delivery Layout

This directory groups SQL files by database for handover deployment.

| Database | Schema SQL | Mock Data SQL |
| --- | --- | --- |
| `bank_cdp` | `bank_cdp_schema.sql` | `bank_cdp_mock.sql` |
| `retail_lineage` | `retail_lineage_schema.sql` | `retail_lineage_mock.sql` |
| `regdb` | `regdb_schema.sql` | `regdb_mock.sql` |
| `bjmetro` | `bjmetro_schema.sql` | `bjmetro_mock.sql` |

Recommended execution order:

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bank_cdp_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bank_cdp_mock.sql

mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/retail_lineage_mock.sql

mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/regdb_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/regdb_mock.sql

mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bjmetro_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bjmetro_mock.sql
```

The original SQL files remain in `sql/` and `backend/sql/` for development traceability.
