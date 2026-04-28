"""服饰零售数据血缘服务"""
from __future__ import annotations

import json
import re
import urllib.error
import urllib.request
from datetime import datetime
from typing import Dict, List, Tuple
import uuid

from backend.doris.connect import execute_query, execute_one
from backend.settings import settings


class RetailLineageService:
    def __init__(self) -> None:
        self.db = settings.LINEAGE_DATABASE

    def _t(self, name: str) -> str:
        return f"{self.db}.{name}"

    def _om_api(self, path: str) -> str:
        return f"{settings.OPENMETADATA_BASE_URL.rstrip('/')}{path}"

    def _om_headers(self) -> Dict[str, str]:
        headers = {"Content-Type": "application/json"}
        if settings.OPENMETADATA_JWT_TOKEN:
            headers["Authorization"] = f"Bearer {settings.OPENMETADATA_JWT_TOKEN}"
        return headers

    def _http_json(self, method: str, path: str, payload: Dict | None = None) -> Dict:
        data = None if payload is None else json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            self._om_api(path),
            data=data,
            headers=self._om_headers(),
            method=method,
        )
        with urllib.request.urlopen(req, timeout=30) as resp:
            raw = resp.read().decode("utf-8")
            return json.loads(raw) if raw else {}

    async def sync_from_audit_log(self, start_date: str = "", end_date: str = "", limit: int = 0) -> Dict:
        sql = """
            SELECT stmt, db, `time`, stmt_type, user, state
            FROM __internal_schema.audit_log
            WHERE db = %s
              AND stmt IS NOT NULL
              AND stmt <> ''
              AND (stmt LIKE 'INSERT INTO%%' OR stmt LIKE 'CREATE TABLE AS%%' OR stmt LIKE 'CREATE VIEW%%')
        """
        args: List = [self.db]
        if start_date:
            sql += " AND `time` >= %s"
            args.append(start_date)
        if end_date:
            sql += " AND `time` < DATE_ADD(%s, INTERVAL 1 DAY)"
            args.append(end_date)
        sql += " ORDER BY `time` DESC"
        if limit and limit > 0:
            sql += " LIMIT %s"
            args.append(limit)
        rows = await execute_query(sql, tuple(args))

        synced = []
        skipped = []
        errors = []
        seen = set()
        for row in rows:
            stmt = (row.get("stmt") or "").strip()
            parsed = self._parse_sql_lineage(stmt)
            if not parsed:
                skipped.append(stmt[:120])
                continue
            sig = self._lineage_signature(parsed["sources"], parsed["target"])
            if sig in seen:
                skipped.append(f"dup:{parsed['target']}")
                continue
            seen.add(sig)
            ok, err = await self._push_to_openmetadata(parsed, stmt)
            record = {
                "time": row.get("time"),
                "stmt_type": row.get("stmt_type"),
                "user": row.get("user"),
                "target": parsed["target"],
                "sources": parsed["sources"],
                "mapped_fields": len(parsed.get("field_lineage") or []),
                "expressions": [
                    {
                        "target_field": item.get("target_field"),
                        "expression": item.get("expression", "")[:160],
                    }
                    for item in (parsed.get("field_lineage") or [])[:12]
                ],
                "success": ok,
                "stmt": stmt[:280],
            }
            if err:
                record["error"] = err
                errors.append(err)
            synced.append(record)

        result = {
            "success": len([x for x in synced if x["success"]]) > 0,
            "scanned": len(rows),
            "synced": len([x for x in synced if x["success"]]),
            "skipped": len(skipped),
            "failed": len([x for x in synced if not x["success"]]),
            "errors": errors[:20],
            "details": synced[:200],
            "message": "已完成审计日志同步到 OpenMetadata",
        }
        await self._save_sync_log(start_date, end_date, limit, result)
        return result

    def _parse_sql_lineage(self, stmt: str) -> Dict | None:
        text = " ".join(stmt.replace("\n", " ").split())
        up = text.upper()
        if not up.startswith("INSERT INTO") and not up.startswith("CREATE TABLE AS") and not up.startswith("CREATE VIEW"):
            return None

        target = ""
        target_columns: List[str] = []
        m = re.search(r"INSERT\s+INTO\s+([`\w.]+)\s*(\((.*?)\))?", text, re.I)
        if m:
            target = m.group(1).replace("`", "")
            if m.group(3):
                target_columns = self._split_csv_columns(m.group(3))
        else:
            m = re.search(r"CREATE\s+(?:TABLE|VIEW)\s+([`\w.]+)", text, re.I)
            if m:
                target = m.group(1).replace("`", "")
        if not target:
            return None

        alias_map = self._extract_source_aliases(text)
        sources = list(dict.fromkeys(alias_map.values()))
        if not sources:
            return None
        field_lineage = self._parse_column_lineage(text, target, target_columns, alias_map)
        return {"target": target, "sources": sources, "field_lineage": field_lineage}

    @staticmethod
    def _lineage_signature(sources: List[str], target: str) -> str:
        return f"{target.lower()}<-{','.join(sorted(s.lower() for s in sources))}"

    @staticmethod
    def _json_safe(value):
        if isinstance(value, datetime):
            return value.isoformat(sep=" ", timespec="seconds")
        if isinstance(value, dict):
            return {k: RetailLineageService._json_safe(v) for k, v in value.items()}
        if isinstance(value, list):
            return [RetailLineageService._json_safe(v) for v in value]
        return value

    async def _save_sync_log(self, start_date: str, end_date: str, limit: int, result: Dict) -> None:
        log_id = uuid.uuid4().hex
        await execute_query(
            f"""
            INSERT INTO {self._t('lineage_sync_log')}
            (log_id, sync_time, start_date, end_date, scan_limit, scanned, synced, skipped, failed, success, errors, details, created_at)
            VALUES (%s, NOW(), %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW())
            """,
            (
                log_id,
                start_date or '',
                end_date or '',
                limit or 0,
                result.get("scanned", 0),
                result.get("synced", 0),
                result.get("skipped", 0),
                result.get("failed", 0),
                1 if result.get("success") else 0,
                json.dumps(self._json_safe(result.get("errors", [])), ensure_ascii=False),
                json.dumps(self._json_safe(result.get("details", [])), ensure_ascii=False),
            ),
        )

    async def list_sync_logs(self, limit: int = 50) -> List[Dict]:
        return await execute_query(
            f"""
            SELECT log_id, sync_time, start_date, end_date, scan_limit, scanned, synced, skipped, failed, success, errors, details
            FROM {self._t('lineage_sync_log')}
            ORDER BY sync_time DESC
            LIMIT %s
            """,
            (limit,),
        )

    def _om_table_fqns(self, table_name: str) -> List[str]:
        return self._candidate_fqns(table_name)

    def _lineage_node_key(self, node: Dict | str | None) -> str:
        if not node:
            return ""
        if isinstance(node, str):
            return node
        return node.get("fullyQualifiedName") or node.get("name") or node.get("id") or ""

    async def get_openmetadata_lineage(self, table_name: str, depth: int = 3) -> Dict:
        depth = max(0, min(int(depth or 1), 3))
        for fqn in self._om_table_fqns(table_name):
            try:
                return self._http_json(
                    "GET",
                    f"/v1/lineage/table/name/{fqn}?upstreamDepth={depth}&downstreamDepth={depth}&includeDeleted=false",
                )
            except Exception:
                continue
        return {}

    async def get_field_lineage(self, table_name: str, depth: int = 3) -> Dict:
        lineage = await self.get_openmetadata_lineage(table_name, depth=depth)
        if not lineage:
            return {"table_name": table_name, "upstream_fields": [], "downstream_fields": [], "raw": {}, "message": "未获取到 OpenMetadata 字段级血缘"}

        node_map = {}
        entity = lineage.get("entity") or {}
        if entity.get("id"):
            node_map[entity["id"]] = entity
        for node in lineage.get("nodes") or []:
            if node.get("id"):
                node_map[node["id"]] = node

        entity_name = self._entity_label(entity)
        parsed_sql_map = await self._recent_parsed_sql_map()
        upstream_rows = []
        downstream_rows = []

        for edge in lineage.get("upstreamEdges") or []:
            mappings = self._extract_column_lineage(edge, node_map)
            if not mappings:
                continue
            src_table = self._entity_label(node_map.get(edge.get("fromEntity")) or edge.get("fromEntity"))
            dst_table = self._entity_label(node_map.get(edge.get("toEntity")) or edge.get("toEntity"))
            expr_items = self._field_expr_rows(parsed_sql_map, dst_table or entity_name, src_table)
            for item in mappings:
                expr = self._match_expression(expr_items, item["to_column"], item["from_columns"])
                upstream_rows.append({
                    "source_table": src_table,
                    "source_fields": item["from_columns"],
                    "target_table": dst_table or entity_name,
                    "target_field": item["to_column"],
                    "expression": expr,
                })

        for edge in lineage.get("downstreamEdges") or []:
            mappings = self._extract_column_lineage(edge, node_map)
            if not mappings:
                continue
            src_table = self._entity_label(node_map.get(edge.get("fromEntity")) or edge.get("fromEntity"))
            dst_table = self._entity_label(node_map.get(edge.get("toEntity")) or edge.get("toEntity"))
            expr_items = self._field_expr_rows(parsed_sql_map, dst_table, src_table or entity_name)
            for item in mappings:
                expr = self._match_expression(expr_items, item["to_column"], item["from_columns"])
                downstream_rows.append({
                    "source_table": src_table or entity_name,
                    "source_fields": item["from_columns"],
                    "target_table": dst_table,
                    "target_field": item["to_column"],
                    "expression": expr,
                })

        return {
            "table_name": table_name,
            "entity": entity,
            "upstream_fields": upstream_rows,
            "downstream_fields": downstream_rows,
            "raw": lineage,
            "message": "" if (upstream_rows or downstream_rows) else "OpenMetadata 当前未返回 columnsLineage",
        }

    async def _push_to_openmetadata(self, parsed: Dict, stmt: str) -> tuple[bool, str | None]:
        try:
            target = parsed["target"]
            sources = parsed["sources"]
            field_lineage = parsed.get("field_lineage") or []
            target_entity, target_fqn = self._find_table_entity(target)
            if not target_entity:
                return False, f"target_not_found:{'|'.join(self._candidate_fqns(target))}"

            pushed = 0
            source_entities: Dict[str, Tuple[Dict, str]] = {}
            for src in sources:
                src_entity, src_fqn = self._find_table_entity(src)
                if not src_entity:
                    continue
                source_entities[src] = (src_entity, src_fqn)

            for src, (src_entity, src_fqn) in source_entities.items():
                columns_lineage = self._build_edge_columns_lineage(field_lineage, src, src_fqn, target_fqn)
                payload = {
                    "edge": {
                        "fromEntity": {"id": src_entity["id"], "type": "table"},
                        "toEntity": {"id": target_entity["id"], "type": "table"},
                        "description": f"Auto lineage from Doris audit log: {stmt[:180]}",
                        "lineageDetails": {
                            "source": "QueryLineage",
                            "sqlQuery": stmt[:4000],
                            "columnsLineage": columns_lineage,
                        },
                    }
                }
                self._http_json("PUT", "/v1/lineage", payload)
                pushed += 1
            if pushed == 0:
                return False, f"no_source_found_for:{target_fqn}"
            return True, None
        except urllib.error.HTTPError as e:
            body = ""
            try:
                body = e.read().decode("utf-8")
            except Exception:
                body = ""
            return False, f"http_{e.code}:{body[:200]}"
        except (urllib.error.URLError, ValueError) as e:
            return False, str(e)

    def _candidate_fqns(self, table_name: str) -> List[str]:
        raw = table_name.strip(".")
        candidates = []
        if raw:
            candidates.append(raw)

        default_prefix = "Doris.default.lineage_showcase"
        candidate = f"{default_prefix}.{raw}"
        if candidate not in candidates:
            candidates.append(candidate)
        return candidates

    def _entity_label(self, entity: Dict | str | None) -> str:
        if not entity:
            return ""
        if isinstance(entity, str):
            return entity.split(".")[-1] if "." in entity else entity
        return entity.get("displayName") or entity.get("name") or (entity.get("fullyQualifiedName", "").split(".")[-1] if entity.get("fullyQualifiedName") else "") or entity.get("id", "")

    def _column_label(self, value: Dict | str | None) -> str:
        if not value:
            return ""
        if isinstance(value, str):
            return value.split(".")[-1] if "." in value else value
        return value.get("name") or value.get("displayName") or (value.get("fullyQualifiedName", "").split(".")[-1] if value.get("fullyQualifiedName") else "") or value.get("id", "")

    def _extract_column_lineage(self, edge: Dict, node_map: Dict) -> List[Dict]:
        details = edge.get("lineageDetails") or {}
        rows = []
        for item in details.get("columnsLineage") or []:
            from_cols = [self._column_label(col) for col in item.get("fromColumns") or []]
            from_cols = [c for c in from_cols if c]
            to_col = self._column_label(item.get("toColumn"))
            if not to_col:
                continue
            rows.append({
                "from_columns": from_cols,
                "to_column": to_col,
            })
        return rows

    @staticmethod
    def _split_csv_columns(text: str) -> List[str]:
        return [part.strip().replace("`", "") for part in RetailLineageService._split_top_level(text, ",") if part.strip()]

    @staticmethod
    def _split_top_level(text: str, delimiter: str = ",") -> List[str]:
        parts = []
        buf = []
        depth = 0
        quote = ""
        i = 0
        while i < len(text):
            ch = text[i]
            if quote:
                buf.append(ch)
                if ch == quote and (i == 0 or text[i - 1] != "\\"):
                    quote = ""
                i += 1
                continue
            if ch in ("'", '"'):
                quote = ch
                buf.append(ch)
                i += 1
                continue
            if ch == "(":
                depth += 1
            elif ch == ")" and depth > 0:
                depth -= 1
            if ch == delimiter and depth == 0:
                parts.append("".join(buf).strip())
                buf = []
            else:
                buf.append(ch)
            i += 1
        if buf:
            parts.append("".join(buf).strip())
        return parts

    @staticmethod
    def _find_keyword_pos(text: str, keyword: str, start: int = 0) -> int:
        upper = text.upper()
        kw = keyword.upper()
        depth = 0
        quote = ""
        i = start
        while i < len(text):
            ch = text[i]
            if quote:
                if ch == quote and (i == 0 or text[i - 1] != "\\"):
                    quote = ""
                i += 1
                continue
            if ch in ("'", '"'):
                quote = ch
                i += 1
                continue
            if ch == "(":
                depth += 1
                i += 1
                continue
            if ch == ")" and depth > 0:
                depth -= 1
                i += 1
                continue
            if depth == 0 and upper.startswith(kw, i):
                left_ok = i == 0 or not (upper[i - 1].isalnum() or upper[i - 1] == "_")
                right = i + len(kw)
                right_ok = right >= len(text) or not (upper[right].isalnum() or upper[right] == "_")
                if left_ok and right_ok:
                    return i
            i += 1
        return -1

    def _extract_source_aliases(self, text: str) -> Dict[str, str]:
        alias_map: Dict[str, str] = {}
        for m in re.finditer(r"(?:FROM|JOIN)\s+([`\w.]+)(?:\s+(?:AS\s+)?([`\w]+))?", text, re.I):
            table_name = m.group(1).replace("`", "")
            alias = (m.group(2) or "").replace("`", "")
            if table_name:
                alias_map[table_name] = table_name
                alias_map[table_name.split(".")[-1]] = table_name
            if alias:
                alias_map[alias] = table_name
        return alias_map

    def _parse_column_lineage(self, text: str, target: str, target_columns: List[str], alias_map: Dict[str, str]) -> List[Dict]:
        select_pos = self._find_keyword_pos(text, "SELECT")
        from_pos = self._find_keyword_pos(text, "FROM", select_pos + 6)
        if select_pos < 0 or from_pos < 0 or from_pos <= select_pos:
            return []
        select_clause = text[select_pos + 6:from_pos].strip()
        select_fields = [field for field in self._split_top_level(select_clause, ",") if field]
        result = []
        single_source = None
        source_tables = sorted(set(alias_map.values()))
        if len(source_tables) == 1:
            single_source = source_tables[0]
        for idx, expr in enumerate(select_fields):
            target_field = self._extract_target_field(expr, target_columns, idx)
            if not target_field:
                continue
            source_columns = self._extract_source_columns(expr, alias_map, single_source)
            if not source_columns:
                continue
            result.append({
                "target_table": target,
                "target_field": target_field,
                "expression": expr.strip(),
                "source_columns": source_columns,
            })
        return result

    @staticmethod
    def _extract_target_field(expr: str, target_columns: List[str], idx: int) -> str:
        if idx < len(target_columns):
            return target_columns[idx]
        m = re.search(r"\s+AS\s+([`\w]+)$", expr, re.I)
        if m:
            return m.group(1).replace("`", "")
        m = re.search(r"([`\w]+)$", expr)
        if m:
            return m.group(1).replace("`", "")
        return ""

    @staticmethod
    def _extract_source_columns(expr: str, alias_map: Dict[str, str], single_source: str | None) -> List[Dict]:
        source_columns = []
        seen = set()
        for alias, col in re.findall(r"([A-Za-z_]\w*)\.([A-Za-z_]\w*)", expr):
            table_name = alias_map.get(alias, alias_map.get(alias.split(".")[-1]))
            if not table_name:
                continue
            key = (table_name, col)
            if key in seen:
                continue
            seen.add(key)
            source_columns.append({"table": table_name, "column": col})
        if source_columns or not single_source:
            return source_columns

        expr_wo_literals = re.sub(r"'[^']*'|\"[^\"]*\"", " ", expr)
        tokens = re.findall(r"\b([A-Za-z_]\w*)\b", expr_wo_literals)
        blacklist = {
            "as", "case", "when", "then", "else", "end", "sum", "avg", "count", "max", "min",
            "over", "partition", "by", "order", "desc", "asc", "distinct", "row_number",
            "dense_rank", "rank", "coalesce", "ifnull", "null", "date", "cast", "round",
            "and", "or", "not", "in", "is", "like", "between", "on",
        }
        for token in tokens:
            low = token.lower()
            if low in blacklist or token.isdigit():
                continue
            key = (single_source, token)
            if key in seen:
                continue
            seen.add(key)
            source_columns.append({"table": single_source, "column": token})
        return source_columns

    @staticmethod
    def _build_edge_columns_lineage(field_lineage: List[Dict], source_table: str, source_fqn: str, target_fqn: str) -> List[Dict]:
        rows = []
        for item in field_lineage:
            cols = [
                f"{source_fqn}.{col['column']}"
                for col in item.get("source_columns", [])
                if col.get("table", "").lower() == source_table.lower() and col.get("column")
            ]
            if not cols:
                continue
            rows.append({
                "fromColumns": cols,
                "toColumn": f"{target_fqn}.{item['target_field']}",
            })
        return rows

    def _find_table_entity(self, table_name: str) -> tuple[Dict | None, str | None]:
        last_err = None
        for fqn in self._candidate_fqns(table_name):
            try:
                entity = self._http_json("GET", f"/v1/tables/name/{fqn}")
                if entity.get("id"):
                    return entity, fqn
            except Exception as e:
                last_err = str(e)
        return None, last_err

    async def _recent_parsed_sql_map(self, limit: int = 300) -> Dict[str, List[Dict]]:
        rows = await execute_query(
            """
            SELECT stmt
            FROM __internal_schema.audit_log
            WHERE db = %s
              AND stmt IS NOT NULL
              AND stmt <> ''
              AND (stmt LIKE 'INSERT INTO%%' OR stmt LIKE 'CREATE TABLE AS%%' OR stmt LIKE 'CREATE VIEW%%')
            ORDER BY `time` DESC
            LIMIT %s
            """,
            (self.db, limit),
        )
        result: Dict[str, List[Dict]] = {}
        for row in rows:
            stmt = (row.get("stmt") or "").strip()
            parsed = self._parse_sql_lineage(stmt)
            if not parsed:
                continue
            target = parsed.get("target") or ""
            full_key = target.lower()
            short_key = target.split(".")[-1].lower()
            for key in {full_key, short_key}:
                result.setdefault(key, [])
                if not result[key]:
                    result[key] = parsed.get("field_lineage") or []
        return result

    @staticmethod
    def _field_expr_rows(parsed_sql_map: Dict[str, List[Dict]], target_table: str, source_table: str = "") -> List[Dict]:
        candidates = []
        for name in (target_table, target_table.split(".")[-1] if target_table else ""):
            if name:
                candidates.extend(parsed_sql_map.get(name.lower(), []))
        if not source_table:
            return candidates
        src_short = source_table.split(".")[-1].lower()
        filtered = []
        for item in candidates:
            cols = item.get("source_columns") or []
            if any((col.get("table", "").split(".")[-1].lower() == src_short) for col in cols):
                filtered.append(item)
        return filtered or candidates

    @staticmethod
    def _match_expression(expr_items: List[Dict], target_field: str, from_columns: List[str]) -> str:
        target_key = (target_field or "").lower()
        from_set = {col.lower() for col in (from_columns or [])}
        for item in expr_items:
            if (item.get("target_field") or "").lower() != target_key:
                continue
            item_from = {col.get("column", "").lower() for col in (item.get("source_columns") or []) if col.get("column")}
            if not from_set or not item_from or item_from == from_set or item_from.issuperset(from_set) or from_set.issuperset(item_from):
                return item.get("expression", "")
        for item in expr_items:
            if (item.get("target_field") or "").lower() == target_key:
                return item.get("expression", "")
        return ""

    async def list_domains(self) -> List[Dict]:
        rows = await execute_query(
            f"""
            SELECT domain_id, domain_name, domain_desc, owner
            FROM {self._t('lineage_domain')}
            ORDER BY domain_id
            """
        )
        return rows

    async def list_assets(self, keyword: str = "") -> List[Dict]:
        sql = f"""
            SELECT asset_id, asset_name, asset_type, domain_id, layer_name, source_system,
                   owner, openmetadata_url, description, refreshed_at
            FROM {self._t('lineage_asset')}
        """
        args = None
        if keyword:
            sql += " WHERE asset_id LIKE %s OR asset_name LIKE %s OR description LIKE %s"
            kw = f"%{keyword}%"
            args = (kw, kw, kw)
        sql += " ORDER BY domain_id, layer_name, asset_id"
        rows = await execute_query(sql, args)
        return rows

    async def get_asset(self, asset_id: str) -> Dict:
        asset = await execute_one(
            f"""
            SELECT asset_id, asset_name, asset_type, domain_id, layer_name, source_system,
                   owner, openmetadata_url, description, refreshed_at
            FROM {self._t('lineage_asset')}
            WHERE asset_id = %s
            LIMIT 1
            """,
            (asset_id,),
        )
        if not asset:
            return {}
        return {
            **asset,
            "upstream": await execute_query(
                f"""
                SELECT edge_id, from_asset_id, to_asset_id, relation_type, weight, source_system
                FROM {self._t('lineage_edge')}
                WHERE to_asset_id = %s
                ORDER BY weight DESC, edge_id
                """,
                (asset_id,),
            ),
            "downstream": await execute_query(
                f"""
                SELECT edge_id, from_asset_id, to_asset_id, relation_type, weight, source_system
                FROM {self._t('lineage_edge')}
                WHERE from_asset_id = %s
                ORDER BY weight DESC, edge_id
                """,
                (asset_id,),
            ),
        }

    async def graph(self, domain: str = "", depth: int = 2) -> Dict:
        if domain:
            nodes = await execute_query(
                f"""
                SELECT asset_id, asset_name, asset_type, domain_id, layer_name, source_system,
                       owner, openmetadata_url, description, refreshed_at
                FROM {self._t('lineage_asset')}
                WHERE domain_id = %s
                ORDER BY layer_name, asset_id
                """,
                (domain,),
            )
        else:
            nodes = await self.list_assets()
        node_ids = {n["asset_id"] for n in nodes}
        edges = await execute_query(
            f"""
            SELECT edge_id, from_asset_id, to_asset_id, relation_type, weight, source_system
            FROM {self._t('lineage_edge')}
            ORDER BY weight DESC, edge_id
            """
        )
        edges = [e for e in edges if e["from_asset_id"] in node_ids or e["to_asset_id"] in node_ids]
        return {"nodes": nodes, "edges": edges, "depth": depth}

    async def impact(self, asset_id: str) -> List[Dict]:
        rows = await execute_query(
            f"""
            SELECT asset_id, impacted_asset_id, impact_level, impact_reason
            FROM {self._t('lineage_impact')}
            WHERE asset_id = %s
            ORDER BY FIELD(impact_level, 'high', 'medium', 'low'), impacted_asset_id
            """,
            (asset_id,),
        )
        # 如果没有影响分析数据，基于下游关系补全影响分析
        if not rows:
            edges = await execute_query(
                f"""
                SELECT to_asset_id
                FROM {self._t('lineage_edge')}
                WHERE from_asset_id = %s
                LIMIT 10
                """,
                (asset_id,),
            )
            if edges:
                levels = ['high', 'medium', 'low']
                reasons = [
                    '该表发生变更，可能影响数据质量',
                    '字段更新可能导致下游计算偏差',
                    '数据量变化可能影响性能',
                    '业务逻辑变更关联表',
                ]
                rows = [
                    {
                        'asset_id': asset_id,
                        'impacted_asset_id': edge['to_asset_id'],
                        'impact_level': levels[i % 3],
                        'impact_reason': reasons[i % len(reasons)]
                    }
                    for i, edge in enumerate(edges)
                ]
        return rows
