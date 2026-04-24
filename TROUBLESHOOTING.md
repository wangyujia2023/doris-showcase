# 故障排查指南

## 快速诊断

首先运行诊断工具：
```bash
./diagnose.sh
```

这会检查：
- Python 环境
- 虚拟环境
- 依赖安装
- Node.js 环境
- 配置文件
- 端口占用

---

## 常见问题

### 1. `uvicorn: command not found` 或 `No such file or directory`

**症状**：
```
nohup: failed to run command '/path/to/.venv/bin/uvicorn': No such file or directory
```

**原因**：虚拟环境不存在或依赖未安装

**解决方案**：
```bash
# 清空旧虚拟环境
rm -rf .venv

# 重新初始化
./init.sh

# 启动
./start_all.sh
```

---

### 2. `vite: command not found`

**症状**：
```
sh: line 1: vite: command not found
```

**原因**：前端依赖未安装

**解决方案**：
```bash
cd frontend
npm install
cd ..
./start_all.sh
```

---

### 3. 端口被占用

**症状**：
```
Address already in use
```

**查找占用的进程**：
```bash
# 后端端口 (27713)
lsof -i :27713

# 前端端口 (5173)
lsof -i :5173
```

**杀掉进程**：
```bash
# 使用 PID 杀掉
kill -9 <PID>

# 或者直接杀掉所有相关进程
pkill -f uvicorn
pkill -f vite
pkill -f "npm run dev"
```

**重新启动**：
```bash
./start_all.sh
```

---

### 4. 数据库连接失败

**症状**：
```
Error: failed to connect to Doris at host:port
```

**检查清单**：
```bash
# 1. 验证 .env 配置
cat .env | grep DORIS

# 2. 测试网络连接
ping <DORIS_HOST>

# 3. 测试端口连接
telnet <DORIS_HOST> <DORIS_PORT>

# 4. 验证凭证
# - DORIS_USER
# - DORIS_PASSWORD
```

**修复步骤**：
```bash
# 1. 编辑 .env
nano .env

# 2. 修改以下内容
DORIS_HOST=your-actual-host
DORIS_PORT=19030
DORIS_USER=root
DORIS_PASSWORD=your-password
DORIS_DATABASE=bank_cdp

# 3. 重启服务
./start_all.sh
```

---

### 5. Python 版本过低

**症状**：
```
Python version too low, need 3.8+
```

**解决方案**：
```bash
# 检查 Python 版本
python3 --version

# 安装 Python 3.8+ (以 Ubuntu 为例)
sudo apt-get install python3.9 python3.9-venv

# 重新初始化（可选指定 Python 版本）
python3.9 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

### 6. npm 安装失败

**症状**：
```
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
```

**解决方案**：
```bash
# 清空 npm 缓存
npm cache clean --force

# 删除 node_modules
cd frontend
rm -rf node_modules package-lock.json

# 重新安装
npm install

cd ..
./start_all.sh
```

---

### 7. 权限错误

**症状**：
```
Permission denied: ./init.sh
```

**解决方案**：
```bash
# 添加执行权限
chmod +x init.sh start_all.sh diagnose.sh

# 重试
./init.sh
```

---

### 8. 内存不足

**症状**：
```
MemoryError
```

**解决方案**：
```bash
# 查看可用内存
free -h

# 清理缓存
sync; echo 3 > /proc/sys/vm/drop_caches  # 需要 root 权限

# 或者增加 swap（Linux）
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

### 9. 网络连接问题

**症状**：
```
Failed to fetch packages
Connection timeout
```

**解决方案**：
```bash
# 1. 检查网络连接
ping 8.8.8.8

# 2. 更换 npm 源
npm config set registry https://registry.npmmirror.com

# 3. 更换 pip 源
pip config set global.index-url https://pypi.tsinghua.edu.cn/simple

# 4. 重新安装
./init.sh
```

---

### 10. 文件权限/所有权问题（Linux/Mac）

**症状**：
```
Permission denied
```

**解决方案**：
```bash
# 查看当前用户
whoami

# 查看目录权限
ls -la

# 修复权限（当前用户）
chmod -R u+rw .venv
chmod -R u+rw frontend/node_modules

# 如果需要 sudo
sudo chown -R $USER:$USER /mnt/disk13/wangyujia/opt/workspace/bank-demo
```

---

## 完整重新安装

如果问题无法解决，尝试完全重新安装：

```bash
# 1. 停止所有进程
pkill -f uvicorn
pkill -f vite

# 2. 清空依赖
rm -rf .venv
cd frontend && rm -rf node_modules && cd ..

# 3. 重新初始化
./init.sh

# 4. 配置 .env
nano .env

# 5. 启动
./start_all.sh

# 6. 查看日志
tail -f backend.log
tail -f frontend.log
```

---

## 日志分析

### 后端日志
```bash
# 实时查看
tail -f backend.log

# 查看最后 100 行
tail -100 backend.log

# 搜索错误
grep ERROR backend.log
grep "Traceback" backend.log
```

### 前端日志
```bash
# 实时查看
tail -f frontend.log

# 查看编译错误
tail -50 frontend.log
```

---

## 调试模式

### 后端调试
```bash
# 激活虚拟环境
source .venv/bin/activate

# 运行后端（交互模式）
uvicorn backend.app:app --reload --port 27713

# 会显示详细的错误信息
```

### 前端调试
```bash
cd frontend

# 运行前端（交互模式）
npm run dev -- --port 5173

# 会显示详细的编译和热更新信息
```

---

## 获取帮助

1. **检查文档**
   - QUICKSTART.md - 快速启动指南
   - README.md - 项目说明

2. **运行诊断**
   - `./diagnose.sh` - 环境诊断

3. **查看日志**
   - backend.log - 后端日志
   - frontend.log - 前端日志

4. **检查配置**
   - `.env` - 环境配置
   - `requirements.txt` - Python 依赖
   - `frontend/package.json` - Node 依赖

---

## 环境变量配置

如果需要自定义配置，编辑 `.env`：

```ini
# 服务端口
BACKEND_HOST=0.0.0.0
BACKEND_PORT=27713
FRONTEND_HOST=0.0.0.0
FRONTEND_PORT=5173

# 日志路径
BACKEND_LOG=/path/to/backend.log
FRONTEND_LOG=/path/to/frontend.log

# Python 和 npm 路径（可选）
PYTHON_BIN=/path/to/python
UVICORN_BIN=/path/to/uvicorn
NPM_BIN=/path/to/npm

# Doris 数据库
DORIS_HOST=your-host
DORIS_PORT=19030
DORIS_USER=root
DORIS_PASSWORD=password
DORIS_DATABASE=bank_cdp
```

---

## 性能优化

### 增加虚拟内存
```bash
# Linux
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 查看资源使用
```bash
# 查看进程占用
ps aux | grep uvicorn
ps aux | grep node

# 查看内存使用
free -h

# 查看磁盘使用
df -h

# 实时监控
top
```

---

## 联系支持

如果问题仍未解决，请收集以下信息：

```bash
# 1. 系统信息
uname -a > system_info.txt

# 2. 诊断结果
./diagnose.sh > diagnose_result.txt

# 3. 最后 100 行日志
tail -100 backend.log > backend_log.txt
tail -100 frontend.log > frontend_log.txt

# 4. 配置信息（隐去敏感信息）
cat .env > env_config.txt
```

然后提供这些文件和具体的错误信息。
