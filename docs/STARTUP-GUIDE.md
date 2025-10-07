# 🚀 快速启动指南

## PowerShell vs CMD vs Bash

### ❓ 为什么 `start` 命令不工作？

在 **PowerShell** 中：
- `start` 是 `Start-Process` 的别名，需要参数
- 直接输入 `start` 会提示输入 `FilePath`

在 **CMD** 中：
- `start` 可以直接运行批处理文件
- `start.bat` 或 `start start.bat` 都可以

---

## ✅ 正确的启动方式

### Windows PowerShell（推荐）

```powershell
# 方式 1：使用 PowerShell 脚本（推荐）
.\start.ps1

# 方式 2：使用批处理文件
.\start.bat

# 方式 3：直接运行 Python
python run.py
```

### Windows 命令提示符 (CMD)

```cmd
REM 方式 1
start.bat

REM 方式 2
.\start.bat

REM 方式 3
python run.py
```

### Linux / macOS

```bash
# 首次需要添加执行权限
chmod +x start.sh

# 启动
./start.sh

# 或直接运行
python run.py
```

---

## 📁 启动脚本对比

| 脚本 | 适用系统 | 说明 |
|------|---------|------|
| `start.ps1` | Windows PowerShell | ✅ 推荐，彩色输出，功能完整 |
| `start.bat` | Windows CMD | ✅ 兼容性好，适用所有 Windows |
| `start.sh` | Linux/macOS | ✅ Unix 系统标准 |
| `run.py` | 所有系统 | ✅ 通用，但需要手动激活虚拟环境 |

---

## 🔧 启动脚本功能

所有启动脚本都会自动：

1. ✅ **检查虚拟环境**
   - 如果不存在，提示创建

2. ✅ **激活虚拟环境**
   - Windows: `.venv\Scripts\activate`
   - Linux/Mac: `.venv/bin/activate`

3. ✅ **初始化数据库**（首次运行）
   - 检测 `instance/face_matching.db` 是否存在
   - 如果不存在，自动运行 `scripts/init_demo_data.py`

4. ✅ **启动 Flask 应用**
   - 运行 `python run.py`
   - 显示访问地址和默认账号

5. ✅ **显示信息**
   - 系统地址：http://127.0.0.1:5000
   - 默认账号：admin
   - 默认密码：Admin@FaceMatch2025!

---

## 🐛 常见问题

### 问题 1：PowerShell 提示"无法加载文件"

**错误信息**：
```
.\start.ps1 : 无法加载文件 D:\test\FaceImgMat\start.ps1，因为在此系统上禁止运行脚本。
```

**解决方法**：
```powershell
# 临时允许（当前会话）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 或者使用批处理文件
.\start.bat
```

---

### 问题 2：找不到 Python 命令

**错误信息**：
```
'python' 不是内部或外部命令
```

**解决方法**：
```powershell
# 检查 Python 是否安装
python --version

# 如果未安装，从官网下载
# https://www.python.org/downloads/

# 或使用 py 启动器
py -3.12 run.py
```

---

### 问题 3：虚拟环境不存在

**错误信息**：
```
❌ 虚拟环境不存在！
```

**解决方法**：
```powershell
# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
.\.venv\Scripts\Activate.ps1  # PowerShell
# 或
.venv\Scripts\activate.bat     # CMD

# 安装依赖
pip install -r requirements.txt

# 再次启动
.\start.ps1
```

---

### 问题 4：端口 5000 已被占用

**错误信息**：
```
OSError: [Errno 48] Address already in use
```

**解决方法**：

**方式 1：停止占用端口的程序**
```powershell
# 查找占用 5000 端口的进程
netstat -ano | findstr :5000

# 停止该进程（替换 PID）
taskkill /F /PID <进程ID>
```

**方式 2：修改端口**
编辑 `run.py`：
```python
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)  # 改为 5001
```

---

## 🎯 推荐启动流程

### 首次安装

```powershell
# 1. 创建虚拟环境
python -m venv .venv

# 2. 激活虚拟环境
.\.venv\Scripts\Activate.ps1

# 3. 安装依赖
pip install -r requirements.txt

# 4. 启动系统（自动初始化数据）
.\start.ps1
```

### 日常使用

```powershell
# PowerShell 用户
.\start.ps1

# CMD 用户
start.bat

# Linux/macOS 用户
./start.sh
```

### 生产部署

参考 [部署文档](DEPLOYMENT.md)

---

## 📝 脚本源码位置

- `start.ps1` - PowerShell 启动脚本（彩色输出）
- `start.bat` - Windows 批处理脚本
- `start.sh` - Linux/macOS Shell 脚本
- `run.py` - Python 启动入口

---

## 🔗 相关文档

- [项目 README](../README.md)
- [部署指南](DEPLOYMENT.md)
- [安全文档](SECURITY.md)
- [脚本说明](../scripts/README.md)

---

最后更新: 2025-10-07
