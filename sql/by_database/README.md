# SQL Delivery Layout

This directory is the only SQL delivery entry. Schema files are rebuilt from the current Doris database structure, and mock files contain English demo data that has been validated in temporary Doris databases.

| Database | Tables | Schema SQL | Mock Data SQL |
| --- | ---: | --- | --- |
| `doris_showcase` | 52 | `doris_showcase_schema.sql` | `doris_showcase_mock.sql` |
| `lineage_showcase` | 14 | `lineage_showcase_schema.sql` | `lineage_showcase_mock.sql` |
| `regdb` | 8 | `regdb_schema.sql` | `regdb_mock.sql` |
| `bjmetro` | 8 | `bjmetro_schema.sql` | `bjmetro_mock.sql` |

Recommended one-click execution:

```bash
sh init_database.sh
```

Single database modes:

```bash
sh init_database.sh core
sh init_database.sh lineage
sh init_database.sh regdb
sh init_database.sh bjmetro
```

Manual execution order:

```bash
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/doris_showcase_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/doris_showcase_mock.sql

mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/lineage_showcase_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/lineage_showcase_mock.sql

mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/regdb_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/regdb_mock.sql

mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bjmetro_schema.sql
mysql -h <DORIS_FE_HOST> -P19030 -uroot -p < sql/by_database/bjmetro_mock.sql
```

The old root-level `sql/*.sql` files were removed to avoid duplicate initialization paths. Use only this directory and `init_database.sh`.
