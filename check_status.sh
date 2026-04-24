#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "==============================================="
echo "实时监控 - Bank-CDP 服务状态"
echo "==============================================="
echo ""

# 检查进程
echo "【进程状态】"
BACKEND_PID=$(lsof -t -i:27713 2>/dev/null || echo "")
FRONTEND_PID=$(lsof -t -i:5173 2>/dev/null || echo "")

if [ -n "$BACKEND_PID" ]; then
  echo "✓ 后端进程运行中 (PID: $BACKEND_PID)"
  ps aux | grep $BACKEND_PID | grep -v grep
else
  echo "✗ 后端进程未运行"
fi

if [ -n "$FRONTEND_PID" ]; then
  echo "✓ 前端进程运行中 (PID: $FRONTEND_PID)"
else
  echo "✗ 前端进程未运行"
fi

echo ""
echo "【资源使用情况】"
if [ -n "$BACKEND_PID" ]; then
  echo "后端进程:"
  ps -p $BACKEND_PID -o %cpu,%mem,etime,rss
fi

if [ -n "$FRONTEND_PID" ]; then
  echo "前端进程:"
  ps -p $FRONTEND_PID -o %cpu,%mem,etime,rss
fi

echo ""
echo "【最新日志（后端错误）】"
tail -20 backend.log | grep -i error || echo "  无错误信息"

echo ""
echo "【最新日志（后端最后 5 行）】"
tail -5 backend.log

echo ""
echo "【最新日志（前端错误）】"
tail -20 frontend.log | grep -i error || echo "  无错误信息"

echo ""
echo "==============================================="
