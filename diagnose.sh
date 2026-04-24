#!/bin/bash

# 诊断脚本 - 检查环境和依赖

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "==============================================="
echo "Bank-CDP 环境诊断工具"
echo "==============================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass() {
  echo -e "${GREEN}✓${NC} $1"
}

fail() {
  echo -e "${RED}✗${NC} $1"
}

warn() {
  echo -e "${YELLOW}⚠${NC} $1"
}

info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

# 系统信息
echo "【系统信息】"
uname -a
echo ""

# Python 检查
echo "【Python 检查】"
if command -v python3 &> /dev/null; then
  PYTHON_PATH=$(which python3)
  PYTHON_VERSION=$(python3 --version 2>&1)
  pass "Python3 已安装: $PYTHON_PATH"
  info "$PYTHON_VERSION"
else
  fail "Python3 未安装"
fi
echo ""

# 虚拟环境检查
echo "【虚拟环境检查】"
if [ -d ".venv" ]; then
  pass "虚拟环境目录存在"

  if [ -f ".venv/bin/python" ]; then
    pass ".venv/bin/python 存在"
    VENV_PYTHON_VERSION=$(.venv/bin/python --version 2>&1)
    info "$VENV_PYTHON_VERSION"
  else
    fail ".venv/bin/python 不存在"
  fi

  if [ -f ".venv/bin/pip" ]; then
    pass ".venv/bin/pip 存在"
  else
    fail ".venv/bin/pip 不存在"
  fi

  if [ -f ".venv/bin/uvicorn" ]; then
    pass ".venv/bin/uvicorn 存在"
  else
    fail ".venv/bin/uvicorn 不存在"
  fi
else
  fail "虚拟环境不存在"
  info "运行: ./init.sh"
fi
echo ""

# 后端依赖检查
echo "【后端依赖检查】"
if [ -f "requirements.txt" ]; then
  pass "requirements.txt 存在"

  if [ -d ".venv" ]; then
    source .venv/bin/activate 2>/dev/null

    # 检查关键包
    PACKAGES=("fastapi" "uvicorn" "pydantic" "pymysql")
    for pkg in "${PACKAGES[@]}"; do
      if python3 -c "import ${pkg//-/_}" 2>/dev/null; then
        pass "$pkg 已安装"
      else
        fail "$pkg 未安装"
      fi
    done
  fi
else
  fail "requirements.txt 不存在"
fi
echo ""

# Node.js 检查
echo "【Node.js 检查】"
if command -v node &> /dev/null; then
  NODE_PATH=$(which node)
  NODE_VERSION=$(node --version)
  pass "Node.js 已安装: $NODE_PATH"
  info "版本: $NODE_VERSION"
else
  fail "Node.js 未安装"
fi

if command -v npm &> /dev/null; then
  NPM_VERSION=$(npm --version)
  pass "npm 已安装"
  info "版本: $NPM_VERSION"
else
  fail "npm 未安装"
fi
echo ""

# 前端依赖检查
echo "【前端依赖检查】"
if [ -d "frontend" ]; then
  pass "frontend 目录存在"

  if [ -f "frontend/package.json" ]; then
    pass "package.json 存在"
  else
    fail "package.json 不存在"
  fi

  if [ -d "frontend/node_modules" ]; then
    pass "node_modules 已安装"

    if [ -d "frontend/node_modules/vite" ]; then
      pass "vite 已安装"
    else
      warn "vite 未安装"
    fi
  else
    warn "node_modules 未安装，运行: npm install (在 frontend 目录)"
  fi
else
  fail "frontend 目录不存在"
fi
echo ""

# 配置文件检查
echo "【配置文件检查】"
if [ -f ".env" ]; then
  pass ".env 存在"

  # 检查关键配置
  if grep -q "DORIS_HOST" .env; then
    pass "DORIS_HOST 已配置"
  else
    warn "DORIS_HOST 未配置"
  fi

  if grep -q "BACKEND_PORT" .env; then
    BACKEND_PORT=$(grep "BACKEND_PORT" .env | cut -d'=' -f2)
    info "BACKEND_PORT = $BACKEND_PORT"
  fi
else
  warn ".env 不存在"
  if [ -f ".env.example" ]; then
    info "可从 .env.example 创建: cp .env.example .env"
  fi
fi
echo ""

# 端口检查
echo "【端口检查】"
BACKEND_PORT=${BACKEND_PORT:-27713}
FRONTEND_PORT=${FRONTEND_PORT:-5173}

if lsof -Pi :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
  warn "端口 $BACKEND_PORT 已被占用"
  lsof -i :$BACKEND_PORT | tail -1
else
  pass "端口 $BACKEND_PORT 可用"
fi

if lsof -Pi :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
  warn "端口 $FRONTEND_PORT 已被占用"
  lsof -i :$FRONTEND_PORT | tail -1
else
  pass "端口 $FRONTEND_PORT 可用"
fi
echo ""

# 总结
echo "==============================================="
echo "诊断完成"
echo "==============================================="
echo ""
echo "【建议】"
echo "1. 如果虚拟环境不存在，运行: ./init.sh"
echo "2. 如果依赖未安装，运行: ./init.sh"
echo "3. 如果端口被占用，运行: kill -9 <PID>"
echo "4. 更多信息查看: QUICKSTART.md"
echo ""
