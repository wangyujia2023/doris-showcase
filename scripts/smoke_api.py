#!/usr/bin/env python3
"""Full API smoke check for Doris Showcase.

The script verifies that important demo endpoints return HTTP 200 and non-empty
payloads. It is intentionally dependency-free so it can run on a fresh server.
"""
import json
import os
import sys
import urllib.request

BASE = os.getenv("SMOKE_BASE_URL") or f"http://127.0.0.1:{os.getenv('BACKEND_PORT', '27713')}/api"
TIMEOUT = int(os.getenv("SMOKE_TIMEOUT", "30"))

TESTS = [
    ("GET", "/system/health", None),
    ("GET", "/dashboard", None),
    ("GET", "/management", None),
    ("GET", "/user/wide?page=1&page_size=20", None),
    ("GET", "/segment/list", None),
    ("POST", "/behavior/funnel", {}),
    ("POST", "/behavior/retention", {}),
    ("GET", "/behavior/transaction", None),
    ("GET", "/behavior/rfm", None),
    ("GET", "/cdp/wide/tag-meta", None),
    ("POST", "/cdp/wide/query", {"tag_ids": [], "page": 1, "page_size": 20}),
    ("GET", "/cdp/wide/distribution", None),
    ("GET", "/cdp/etl/overview", None),
    ("POST", "/cdp/bitmap/compute", {"include_tag_ids": [1], "exclude_tag_ids": [], "return_users": True, "limit": 20}),
    ("POST", "/cdp/behavior/funnel", {}),
    ("POST", "/cdp/behavior/retention", {}),
    ("GET", "/cdp/behavior/path?top_n=10", None),
    ("GET", "/cdp/crowd/list", None),
    ("GET", "/tag-analysis/overview", None),
    ("GET", "/tag-analysis/users", None),
    ("GET", "/tag-analysis/risk", None),
    ("GET", "/tag-analysis/cross", None),
    ("GET", "/tag-analysis/cooccurrence", None),
    ("GET", "/vector/labels", None),
    ("GET", "/vector/dim-labels", None),
    ("GET", "/vector/users", None),
    ("GET", "/satellite/overview", None),
    ("GET", "/satellite/charts", None),
    ("GET", "/regulatory/nav", None),
    ("GET", "/regulatory/master", None),
    ("GET", "/regulatory/overview", None),
    ("GET", "/regulatory/indicators", None),
    ("GET", "/regulatory/history", None),
    ("GET", "/report/overview", None),
    ("GET", "/report/transaction", None),
    ("GET", "/report/risk", None),
    ("GET", "/metrics/definitions", None),
    ("GET", "/metrics/templates", None),
    ("POST", "/metrics/query", {"dimensions": ["asset_level"], "measures": ["user_cnt", "total_aum"], "limit": 20, "page": 1}),
    ("GET", "/observe/logs?limit=20", None),
    ("GET", "/observe/stats", None),
    ("GET", "/trace/list?limit=20", None),
    ("GET", "/benchmark/audit-stats?limit=300", None),
    ("GET", "/mfg/overview", None),
    ("GET", "/mfg/oee-trend", None),
    ("GET", "/mfg/machine-status", None),
    ("GET", "/manufacturing/overview", None),
    ("GET", "/manufacturing/oee-trend", None),
    ("GET", "/sec/overview", None),
    ("GET", "/sec/trend", None),
    ("GET", "/securities/overview", None),
    ("GET", "/securities/trend", None),
    ("GET", "/fund/overview", None),
    ("GET", "/fund/list", None),
    ("GET", "/news/list", None),
    ("GET", "/news/stats", None),
    ("GET", "/news/sentiment-overview", None),
    ("GET", "/news/sector-metrics", None),
    ("GET", "/bjmetro/overview/all", None),
    ("GET", "/bjmetro/flow/hourly", None),
    ("GET", "/bjmetro/flow/hot-stations", None),
    ("GET", "/bjmetro/train/kpi", None),
    ("GET", "/lineage/assets?keyword=", None),
    ("GET", "/lineage/graph?domain=&depth=3", None),
    ("GET", "/lineage/sync-logs?limit=20", None),
]

REQUIRED_NON_EMPTY = {
    "GET /system/health",
    "GET /dashboard",
    "GET /user/wide?page=1&page_size=20",
    "GET /cdp/wide/tag-meta",
    "GET /vector/labels",
    "GET /lineage/assets?keyword=",
}


def print_help():
    print(
        "Usage: python3 scripts/smoke_api.py\n\n"
        "Environment:\n"
        "  BACKEND_PORT     Backend port, default 27713\n"
        "  SMOKE_BASE_URL   Full API base URL, default http://127.0.0.1:${BACKEND_PORT}/api\n"
        "  SMOKE_TIMEOUT    Per-request timeout seconds, default 30\n"
        "  STRICT_EMPTY     true: all endpoints must be non-empty. default false\n"
    )


def request(method, path, payload):
    body = None
    headers = {}
    if payload is not None:
        body = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(BASE + path, data=body, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
        text = resp.read().decode("utf-8")
        try:
            return resp.status, json.loads(text)
        except Exception:
            return resp.status, text


def countish(value):
    if isinstance(value, list):
        return len(value)
    if isinstance(value, dict):
        for key in ("rows", "data", "items", "list", "logs", "assets", "templates", "dimensions", "measures", "periods"):
            if isinstance(value.get(key), list):
                return len(value[key])
        if value.get("latest"):
            return 1
        if "total" in value:
            return value.get("total") or 0
        if "count" in value:
            return value.get("count") or 0
        if "nodes" in value:
            return len(value.get("nodes") or [])
        if "steps" in value:
            return len(value.get("steps") or [])
        return len([v for v in value.values() if v not in (None, {}, [], 0, "")])
    return 1 if value else 0


def main():
    failed = []
    empty = []
    ok = []
    strict_empty = os.getenv("STRICT_EMPTY", "false").lower() == "true"
    print(f"== Doris Showcase API smoke ==\nBase: {BASE}")
    for method, path, payload in TESTS:
        name = f"{method} {path}"
        try:
            status, value = request(method, path, payload)
            count = countish(value)
            if status != 200:
                failed.append(name)
                print(f"FAIL  {name} status={status}")
            elif count == 0 and (strict_empty or name in REQUIRED_NON_EMPTY):
                empty.append(name)
                print(f"EMPTY {name}")
            elif count == 0:
                ok.append(name)
                print(f"PASS  {name} count=0 optional-empty")
            else:
                ok.append(name)
                print(f"PASS  {name} count={count}")
        except Exception as exc:
            failed.append(name)
            print(f"FAIL  {name} error={exc}")
    print(json.dumps({"pass": len(ok), "empty": empty, "fail": failed}, ensure_ascii=False, indent=2))
    return 1 if failed or empty else 0


if __name__ == "__main__":
    if any(arg in ("-h", "--help") for arg in sys.argv[1:]):
        print_help()
        sys.exit(0)
    sys.exit(main())
