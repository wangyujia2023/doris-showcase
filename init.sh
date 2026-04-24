#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "==============================================="
echo "Bank-CDP 初始化脚本 v2.0"
echo "==============================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

error() {
  echo -e "${RED}❌ 错误: $1${NC}"
  exit 1
}

success() {
  echo -e "${GREEN}✓ $1${NC}"
}

warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. 检查 Python
echo "【步骤1】检查 Python 环境..."
if ! command -v python3 &> /dev/null; then
  error "未找到 python3，请先安装 Python 3.8+"
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "  Python 版本: $PYTHON_VERSION"

# 检查 Python 版本是否 >= 3.8
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 8 ]); then
  error "Python 版本过低，需要 3.8+，当前: $PYTHON_VERSION"
fi
success "Python 版本检查通过"

# 2. 清理旧虚拟环境（可选）
echo ""
echo "【步骤2】管理虚拟环境..."
if [ -d ".venv" ]; then
  echo "  检测到旧虚拟环境"
  read -p "  是否删除并重新创建? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf .venv
    echo "  已删除旧虚拟环境"
  else
    echo "  跳过重建"
  fi
fi

# 创建虚拟环境
if [ ! -d ".venv" ]; then
  echo "  创建虚拟环境..."
  python3 -m venv .venv
  success "虚拟环境创建完成"
else
  echo "  虚拟环境已存在"
fi

# 激活虚拟环境
echo "  激活虚拟环境..."
source .venv/bin/activate
success "虚拟环境已激活"

# 3. 升级 pip
echo ""
echo "【步骤3】升级 pip、setuptools、wheel..."
python3 -m pip install --upgrade pip setuptools wheel -q 2>/dev/null || {
  python3 -m pip install --upgrade pip setuptools wheel
}
success "pip 升级完成"

# 4. 安装后端依赖
echo ""
echo "【步骤4】安装后端依赖..."
if [ ! -f "requirements.txt" ]; then
  error "未找到 requirements.txt"
fi

echo "  安装中... 这可能需要几分钟"
if pip install -r requirements.txt -q 2>/dev/null; then
  success "后端依赖安装完成"
else
  warning "pip 安装失败，尝试重新安装..."
  pip install -r requirements.txt --force-reinstall
fi

# 验证 uvicorn 安装
if ! python3 -c "import uvicorn" 2>/dev/null; then
  error "uvicorn 安装失败，请检查 requirements.txt 或网络连接"
fi
success "uvicorn 已安装"

# 5. 检查 Node.js
echo ""
echo "【步骤5】检查 Node.js 环境..."
if ! command -v node &> /dev/null; then
  error "Node.js 未安装，请先安装: https://nodejs.org/"
fi

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo "  Node.js 版本: $NODE_VERSION"
echo "  npm 版本: $NPM_VERSION"
success "Node.js 环境检查通过"

# 6. 安装前端依赖
echo ""
echo "【步骤6】安装前端依赖..."
if [ ! -d "frontend" ] || [ ! -f "frontend/package.json" ]; then
  error "未找到 frontend/package.json"
fi

cd "$PROJECT_DIR/frontend"
echo "  安装中... 这可能需要几分钟"
npm install
success "前端依赖安装完成"
cd "$PROJECT_DIR"

# 7. 验证安装
echo ""
echo "【步骤7】验证安装..."
source .venv/bin/activate 2>/dev/null || true

# 检查后端工具
if ! command -v uvicorn &> /dev/null; then
  warning "uvicorn 不在 PATH 中，检查虚拟环境..."
  if [ -f ".venv/bin/uvicorn" ]; then
    success "uvicorn 已安装在虚拟环境中"
  else
    error "uvicorn 未正确安装"
  fi
else
  success "uvicorn 已就绪"
fi

# 检查前端工具
if ! command -v vite &> /dev/null && [ ! -d "frontend/node_modules" ]; then
  error "前端依赖安装失败"
fi
success "前端依赖已就绪"

# 8. 检查配置文件
echo ""
echo "【步骤8】检查配置文件..."
if [ ! -f ".env" ]; then
  if [ -f ".env.example" ]; then
    cp .env.example .env
    success ".env 配置已创建"
    warning "请编辑 .env 配置数据库连接信息"
  else
    error "未找到 .env 或 .env.example"
  fi
else
  success ".env 配置文件已存在"
fi

echo ""
echo "==============================================="
echo "✅ 初始化完成！"
echo "==============================================="
echo ""
echo "【后续步骤】"
echo "1. 编辑 .env 配置数据库连接"
echo "   nano .env"
echo ""
echo "2. 启动服务"
echo "   ./start_all.sh"
echo ""
echo "【快速启动】"
echo "  ./start_all.sh"
echo ""
echo "【访问地址】"
echo "  前端: http://localhost:5173"
echo "  后端: http://localhost:27713/docs"
echo ""
