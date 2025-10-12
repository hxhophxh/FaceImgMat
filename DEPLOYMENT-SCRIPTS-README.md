# 🎭 FaceImgMat 一键部署工具说明

本项目提供了完整的一键部署解决方案，支持**在线**和**离线**两种部署模式。

## 📦 部署脚本清单

### 在线部署脚本
- **deploy_online.ps1** - Windows PowerShell 在线部署脚本
- **deploy_online.sh** - Linux/macOS Bash 在线部署脚本

### 离线部署脚本
- **prepare_offline_package.ps1** - Windows 离线包准备脚本
- **prepare_offline_package.sh** - Linux/macOS 离线包准备脚本
- **deploy_offline.ps1** - Windows 离线部署脚本
- **deploy_offline.sh** - Linux/macOS 离线部署脚本

## 🚀 快速使用

### 在线部署（推荐用于开发测试）

**Windows PowerShell:**
```powershell
.\deploy_online.ps1
```

**Linux/macOS:**
```bash
chmod +x deploy_online.sh
./deploy_online.sh
```

**功能特性：**
- ✅ 自动检查 Python 环境和版本
- ✅ 自动检查网络连接和磁盘空间
- ✅ 自动创建和激活虚拟环境
- ✅ 自动安装所有依赖包（从 PyPI）
- ✅ 自动初始化数据库和演示数据
- ✅ 自动启动服务
- ✅ 提供详细的进度和日志输出
- ✅ 完善的错误处理和重试机制

**部署时间：** 约 5-15 分钟（取决于网络速度）

---

### 离线部署（推荐用于生产环境）

#### 第一步：准备离线包（在有网络的机器上）

**Windows PowerShell:**
```powershell
.\prepare_offline_package.ps1
```

**Linux/macOS:**
```bash
chmod +x prepare_offline_package.sh
./prepare_offline_package.sh
```

**脚本功能：**
- 📦 下载所有 Python 依赖包（约 600MB）
- 🤖 复制 InsightFace 模型文件（约 300MB）
- 📄 复制项目源代码
- 📝 生成部署脚本和说明文档
- 🗜️ 提供打包命令（可选）

**离线包结构：**
```
offline_deployment_package/
├── FaceImgMat/              # 项目源代码
├── python_packages/         # Python依赖包 (~600MB)
├── insightface_models/      # AI模型 (~300MB)
├── deploy_offline.ps1       # Windows部署脚本
├── deploy_offline.sh        # Linux部署脚本
└── README.txt              # 说明文档
```

#### 第二步：传输离线包

将 `offline_deployment_package` 目录（或打包后的ZIP）传输到目标机器：
- 💾 U盘/移动硬盘
- 📡 内网文件共享
- 📧 邮件系统
- 💿 光盘刻录

#### 第三步：部署（在目标机器上）

**Windows PowerShell:**
```powershell
cd offline_deployment_package
.\deploy_offline.ps1
```

**Linux/macOS:**
```bash
cd offline_deployment_package
chmod +x deploy_offline.sh
./deploy_offline.sh
```

**脚本功能：**
- ✅ 检查离线包完整性
- ✅ 验证 Python 环境
- ✅ 创建虚拟环境
- ✅ 从本地安装所有依赖（无需网络）
- ✅ 配置 InsightFace 模型
- ✅ 初始化数据库
- ✅ 提供启动命令

**部署时间：** 约 2-5 分钟

---

## 🎯 部署模式对比

| 特性 | 在线部署 | 离线部署 |
|------|---------|---------|
| 网络要求 | ✅ 需要稳定网络 | ❌ 完全离线 |
| 部署时间 | 5-15分钟 | 2-5分钟 |
| 准备工作 | ❌ 无需准备 | ✅ 需要准备离线包 |
| 适用场景 | 开发、测试 | 生产、内网 |
| 可重复部署 | ⚠️ 需要网络 | ✅ 任意次数 |
| 包大小 | N/A | ~1GB |

## 📋 脚本功能详解

### 在线部署脚本功能

**环境检查：**
- Python 版本检查（需要 3.11+）
- pip 可用性检查
- 网络连接测试
- 磁盘空间检查（需要 5GB+）

**自动化安装：**
- 创建 Python 虚拟环境
- 升级 pip 到最新版
- 安装 requirements.txt 中的所有依赖
- 支持自动重试（最多3次）
- 验证关键包安装成功

**数据初始化：**
- 创建必要的目录结构
- 初始化 SQLite 数据库
- 导入演示数据（3个测试人员）

**服务启动：**
- 激活虚拟环境
- 启动 Flask 开发服务器
- 提供访问地址和默认账号

### 离线部署脚本功能

**离线包准备（prepare_offline_package）：**
- 使用 `pip download` 下载所有依赖包
- 复制 InsightFace 模型到离线包
- 复制项目源代码（排除 .venv, .git 等）
- 生成平台特定的部署脚本
- 创建详细的 README 文档
- 提供统计信息（包大小、文件数量）

**离线安装（deploy_offline）：**
- 验证离线包完整性
- 检查 Python 环境
- 从本地 `python_packages/` 安装依赖
- 使用 `--no-index --find-links` 参数
- 复制模型到用户目录 `~/.insightface/models/`
- 初始化数据库

## 🔧 技术细节

### PowerShell 脚本特性
- 使用 `$ErrorActionPreference = "Stop"` 确保错误时停止
- 彩色输出（Green/Red/Yellow/Cyan）
- 详细的进度信息
- 支持 PowerShell 5.1+ 和 PowerShell Core

### Bash 脚本特性
- 使用 `set -e` 确保错误时退出
- ANSI 颜色支持
- 兼容 Linux 和 macOS
- 支持 Bash 4.0+

### 错误处理
- 环境检查失败时给出明确的解决方案
- 网络错误时自动重试
- 依赖安装失败时提供备选方案
- 详细的错误日志输出

## 🛠️ 自定义配置

### 修改 Python 版本要求

编辑脚本，修改版本检查部分：

**PowerShell:**
```powershell
if ($majorVersion -ne 3 -or $minorVersion -lt 10) {
    # 改为支持 Python 3.10+
```

**Bash:**
```bash
if [ "$PYTHON_MAJOR" -ne 3 ] || [ "$PYTHON_MINOR" -lt 10 ]; then
    # 改为支持 Python 3.10+
```

### 修改 pip 镜像源

在安装命令中添加镜像参数：

```bash
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### 修改服务端口

编辑 `run.py`:

```python
app.run(debug=True, host='0.0.0.0', port=5001)  # 改为 5001
```

## 📊 部署统计

### 在线部署
- 下载大小：约 600-800MB
- 安装时间：5-15 分钟
- 需要网络：是
- 磁盘占用：约 2-3GB

### 离线部署
- 离线包大小：约 1GB
- 准备时间：10-20 分钟（一次性）
- 部署时间：2-5 分钟
- 需要网络：否
- 磁盘占用：约 2-3GB

## 🔒 安全建议

1. **修改默认密码**
   ```bash
   python scripts/change_admin_password.py
   ```

2. **限制访问**
   - 配置防火墙规则
   - 使用 Nginx 反向代理
   - 设置 IP 白名单

3. **生产环境配置**
   - 使用 HTTPS
   - 使用 Gunicorn + Nginx
   - 配置日志监控
   - 定期备份数据库

## 📞 获取帮助

- 📖 详细文档：[ONE-CLICK-DEPLOYMENT.md](docs/ONE-CLICK-DEPLOYMENT.md)
- 🐛 问题报告：[GitHub Issues](https://github.com/hxhophxh/FaceImgMat/issues)
- 💬 常见问题：查看文档中的故障排查部分

## 🎉 部署成功后

访问系统：
```
🌐 地址: http://127.0.0.1:5000
👤 账号: admin
🔑 密码: Admin@FaceMatch2025!
```

开始使用：
1. 登录系统
2. 修改密码
3. 导入人员数据
4. 上传照片进行匹配

---

## 📝 更新日志

### v1.0.0 (2025-10-12)
- ✨ 新增在线一键部署脚本
- ✨ 新增离线一键部署脚本
- ✨ 支持 Windows、Linux、macOS 三大平台
- 📖 提供完整的部署文档
- 🐛 完善错误处理和重试机制
- 🎨 优化输出格式和用户体验

---

**享受一键部署的便利！** 🚀

如果这些脚本帮助了你，欢迎给项目加星 ⭐
