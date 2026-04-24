#!/bin/bash

# 测试后端 API

BACKEND_URL="http://localhost:27713"

echo "==============================================="
echo "测试后端 API"
echo "==============================================="
echo ""

# 1. 测试健康检查
echo "【测试 1: 健康检查】"
echo "GET $BACKEND_URL/"
curl -s -m 5 "$BACKEND_URL/" | head -50
echo ""
echo ""

# 2. 测试 API 文档
echo "【测试 2: API 文档】"
echo "GET $BACKEND_URL/docs"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$BACKEND_URL/docs")
echo "HTTP 状态码: $HTTP_CODE"
echo ""

# 3. 查看最新日志
echo "【后端日志（最后 30 行）】"
if [ -f "backend.log" ]; then
  tail -30 backend.log
else
  echo "未找到 backend.log"
fi
