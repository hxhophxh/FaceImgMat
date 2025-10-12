# 🎭 FaceImgMat 一键部署完整指南

本文档提供 FaceImgMat 人脸识别系统的**在线部署**和**离线部署**两种方式的完整指南。

---

## 📋 目录

- [在线一键部署](#在线一键部署)
  - [Windows 环境](#windows-在线部署)
  - [Linux/macOS 环境](#linuxmacos-在线部署)
- [离线一键部署](#离线一键部署)
  - [准备离线包](#步骤-1-准备离线部署包)
  - [传输和部署](#步骤-2-传输到目标环境)
  - [安装和启动](#步骤-3-执行离线部署)
- [常见问题](#常见问题)
- [故障排查](#故障排查)

---

## 🌐 在线一键部署

适用于有网络连接的全新机器，可以从互联网下载依赖包。

### 前置条件

- ✅ Python 3.11 或 3.12
- ✅ 稳定的网络连接
- ✅ 至少 5GB 磁盘空间
- ✅ 至少 2GB RAM

### Windows 在线部署

#### 方法一：使用 PowerShell 脚本（推荐）

```powershell
# 1. 克隆或下载项目
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 2. 运行一键部署脚本
.\deploy_online.ps1
```

**就这么简单！** 脚本会自动完成：
- ✅ 检查 Python 环境和版本
- ✅ 创建虚拟环境
- ✅ 安装所有依赖包
- ✅ 初始化数据库
- ✅ 启动服务

#### 方法二：手动步骤

如果脚本无法运行，可以手动执行：

```powershell
# 1. 创建虚拟环境
python -m venv .venv

# 2. 激活虚拟环境
.\.venv\Scripts\Activate.ps1

# 3. 升级 pip
python -m pip install --upgrade pip

# 4. 安装依赖
pip install -r requirements.txt

# 5. 初始化数据
python scripts\init_demo_data.py

# 6. 启动服务
python run.py
```

### Linux/macOS 在线部署

#### 方法一：使用 Shell 脚本（推荐）

```bash
# 1. 克隆或下载项目
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 2. 添加执行权限并运行
chmod +x deploy_online.sh
./deploy_online.sh
```

#### 方法二：手动步骤

```bash
# 1. 创建虚拟环境
python3 -m venv .venv

# 2. 激活虚拟环境
source .venv/bin/activate

# 3. 升级 pip
python -m pip install --upgrade pip

# 4. 安装依赖
pip install -r requirements.txt

# 5. 初始化数据
python scripts/init_demo_data.py

# 6. 启动服务
python run.py
```

### 部署完成

✅ 访问地址：http://127.0.0.1:5000  
✅ 默认账号：`admin`  
✅ 默认密码：`Admin@FaceMatch2025!`

⚠️ **首次登录后请立即修改密码！**

---

## 📦 离线一键部署

适用于无网络连接或网络受限的环境（如内网服务器、隔离环境）。

### 离线部署概览

```
有网络的机器            无网络的机器
    │                      │
    ├─ 1. 准备离线包        │
    ├─ 2. 打包成 ZIP        │
    │                      │
    └─────[传输]──────────>├─ 3. 解压离线包
                           ├─ 4. 运行部署脚本
                           └─ 5. 启动服务
```

### 步骤 1: 准备离线部署包

在**有网络连接**的机器上执行：

#### Windows (PowerShell)

```powershell
# 在项目目录下运行
.\prepare_offline_package.ps1

# 脚本会自动：
# - 下载所有 Python 依赖包
# - 复制 InsightFace 模型文件
# - 复制项目源代码
# - 生成部署脚本和文档
```

#### Linux/macOS (Bash)

```bash
# 在项目目录下运行
chmod +x prepare_offline_package.sh
./prepare_offline_package.sh
```

#### 打包成 ZIP

```powershell
# Windows
.\create_offline_package.ps1

# Linux/macOS
zip -r FaceImgMat-offline-$(date +%Y%m%d).zip offline_deployment_package/
```

完成后会生成类似 `FaceImgMat-offline-20251012_143022.zip` 的文件。

### 步骤 2: 传输到目标环境

使用任意方式将 ZIP 文件传输到目标机器：

- 💾 U盘/移动硬盘
- 📡 内网文件共享
- 📧 邮件/内部传输系统
- 💿 光盘刻录

### 步骤 3: 执行离线部署

在**目标机器**上执行：

#### Windows 环境

```powershell
# 1. 解压离线包
Expand-Archive -Path FaceImgMat-offline-*.zip -DestinationPath .

# 2. 进入解压目录
cd offline_deployment_package

# 3. 运行离线部署脚本（一键部署！）
.\deploy_offline.ps1
```

#### Linux/macOS 环境

```bash
# 1. 解压离线包
unzip FaceImgMat-offline-*.zip
cd offline_deployment_package

# 2. 添加执行权限
chmod +x deploy_offline.sh

# 3. 运行离线部署脚本（一键部署！）
./deploy_offline.sh
```

### 离线部署脚本功能

脚本会自动完成以下所有操作：

- ✅ 检查离线包完整性
- ✅ 验证 Python 环境
- ✅ 创建虚拟环境
- ✅ **从本地安装**所有依赖包（无需网络）
- ✅ 配置 InsightFace 模型
- ✅ 初始化数据库
- ✅ 提供启动命令

整个过程**完全离线**，不需要任何网络连接！

### 启动服务

部署完成后：

```bash
cd FaceImgMat

# 激活虚拟环境
# Windows:
.\.venv\Scripts\Activate.ps1
# Linux/macOS:
source .venv/bin/activate

# 启动服务
python run.py
```

---

## 📊 离线包内容说明

离线部署包结构：

```
offline_deployment_package/
├── FaceImgMat/                    # 项目源代码
│   ├── app/                       # 应用代码
│   ├── static/                    # 静态资源
│   ├── templates/                 # HTML模板
│   ├── scripts/                   # 辅助脚本
│   ├── requirements.txt           # 依赖列表
│   └── run.py                     # 启动文件
│
├── python_packages/               # Python依赖包 (~500-800MB)
│   ├── Flask-3.0.0-*.whl
│   ├── insightface-*.whl
│   ├── faiss_cpu-*.whl
│   ├── opencv_python-*.whl
│   └── ... (所有依赖包)
│
├── insightface_models/            # AI模型文件 (~300MB)
│   └── buffalo_l/
│       ├── det_10g.onnx           # 人脸检测模型
│       ├── w600k_r50.onnx         # 人脸识别模型
│       └── ...
│
├── deploy_offline.ps1             # Windows部署脚本
├── deploy_offline.sh              # Linux/macOS部署脚本
└── README.txt                     # 说明文档
```

**总大小**: 约 800MB - 1.2GB

---

## 🚀 部署后操作

### 1. 访问系统

```
地址: http://127.0.0.1:5000
账号: admin
密码: Admin@FaceMatch2025!
```

### 2. 修改管理员密码（重要！）

```bash
python scripts/change_admin_password.py
```

### 3. 导入人员数据

- 方法1：通过Web界面批量导入
- 方法2：将照片放入 `static/faces/` 目录

### 4. 配置生产环境（可选）

如果用于生产环境，建议：

- 🔒 配置 HTTPS（使用 Nginx + Let's Encrypt）
- 🔥 配置防火墙规则
- 🗄️ 使用 PostgreSQL 替代 SQLite
- 📊 配置日志监控
- ⚡ 使用 Gunicorn + Nginx 部署

参考文档：
- [部署文档](DEPLOYMENT.md)
- [Linux部署指南](LINUX-DEPLOYMENT.md)
- [安全指南](SECURITY.md)

---

## ❓ 常见问题

### Q1: 在线部署时网络很慢怎么办？

**A**: 使用国内镜像源加速：

```bash
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### Q2: 离线包太大，能否精简？

**A**: 离线包主要包含：
- Python依赖包 (~600MB) - 必需
- AI模型文件 (~300MB) - 必需
- 项目代码 (~50MB) - 必需

已经是最小化配置，无法进一步精简。

### Q3: 离线部署后首次启动很慢？

**A**: 首次启动时 InsightFace 需要加载模型到内存，大约需要 10-30 秒。后续启动会更快。

### Q4: 可以在 Python 3.10 上运行吗？

**A**: 不推荐。部分依赖包（如 insightface）在 Python 3.10 上可能有兼容性问题。建议使用 Python 3.11 或 3.12。

### Q5: Windows 提示"无法加载文件，因为在此系统上禁止运行脚本"？

**A**: 运行以下命令设置执行策略：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q6: Linux 提示权限被拒绝？

**A**: 添加执行权限：

```bash
chmod +x deploy_online.sh
chmod +x deploy_offline.sh
```

---

## 🔧 故障排查

### 问题：Python 版本不符合要求

**症状**：
```
需要 Python 3.11 或更高版本，当前版本: Python 3.9.x
```

**解决**：
1. 卸载旧版本 Python
2. 下载并安装 Python 3.11 或 3.12
3. 确认版本：`python --version`

### 问题：依赖包安装失败

**症状**：
```
ERROR: Could not find a version that satisfies the requirement...
```

**解决**：
1. 检查网络连接
2. 使用国内镜像：`pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple`
3. 或使用离线部署方式

### 问题：InsightFace 模型下载失败

**症状**：
```
Cannot download model from...
```

**解决**：
1. 使用离线部署（已包含模型）
2. 或手动下载模型后放入 `~/.insightface/models/` 目录

### 问题：端口 5000 已被占用

**症状**：
```
OSError: [Errno 98] Address already in use
```

**解决**：
1. 修改 `run.py` 中的端口号：
   ```python
   app.run(debug=True, host='0.0.0.0', port=5001)  # 改为5001
   ```
2. 或停止占用端口的程序

### 问题：虚拟环境激活失败

**Windows PowerShell**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
.\.venv\Scripts\Activate.ps1
```

**Linux/macOS**:
```bash
source .venv/bin/activate
```

---

## 📞 获取帮助

如遇到其他问题：

1. 📖 查看[完整文档](docs/INDEX.md)
2. 🐛 提交 [GitHub Issues](https://github.com/hxhophxh/FaceImgMat/issues)
3. 💬 在 Issues 中搜索类似问题

---

## 🎯 总结

### 在线部署（推荐用于开发/测试）

```bash
# 一行命令搞定
./deploy_online.sh   # Linux/macOS
# 或
.\deploy_online.ps1  # Windows
```

**优点**：
- ✅ 简单快速
- ✅ 自动下载最新依赖

**缺点**：
- ❌ 需要网络连接
- ❌ 首次部署较慢

### 离线部署（推荐用于生产/内网）

```bash
# 1. 准备（有网络）
./prepare_offline_package.sh && zip -r package.zip offline_deployment_package/

# 2. 传输到目标机器

# 3. 部署（无网络）
unzip package.zip && cd offline_deployment_package && ./deploy_offline.sh
```

**优点**：
- ✅ 完全离线
- ✅ 可重复部署
- ✅ 适合内网环境

**缺点**：
- ❌ 需要提前准备
- ❌ 离线包较大（~1GB）

---

## 📝 更新日志

### v1.0.0 (2025-10-12)
- ✨ 新增在线一键部署脚本
- ✨ 新增离线一键部署脚本
- ✨ 新增离线包准备工具
- 📖 完善部署文档
- 🐛 修复多项部署问题

---

**Happy Deploying! 🎉**

如果本文档对您有帮助，欢迎给项目加星 ⭐
