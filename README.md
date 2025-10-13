# 🎭 人脸图像匹配系统

[![GitHub](https://img.shields.io/badge/GitHub-FaceImgMat-blue?logo=github)](https://github.com/hxhophxh/FaceImgMat)
[![Python](https://img.shields.io/badge/Python-3.11%20%7C%203.12-blue?logo=python)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

基于 InsightFace + FAISS 的高性能人脸识别与匹配系统。

## 🔗 快速链接

- 📦 **GitHub仓库**: [https://github.com/hxhophxh/FaceImgMat](https://github.com/hxhophxh/FaceImgMat)
- 🚀 **一键部署到Linux**: 查看 [部署指南](docs/GITHUB-TO-LINUX-DEPLOYMENT.md)
- 📖 **完整文档**: 查看 [文档索引](docs/INDEX.md)

## ✨ 功能特性

- 🔍 **智能人脸识别**：上传照片自动识别并匹配数据库中的人员
- ⚡ **高速检索**：FAISS 向量检索，毫秒级响应
- 📊 **相似度排序**：Top-K 结果按相似度排序，直观展示
- 👥 **人员管理**：批量导入、查询、管理人员信息
- 📝 **匹配记录**：自动记录每次匹配历史
- 🎨 **现代界面**：Bootstrap 5 响应式设计
- 🔌 **离线部署**：支持完全离线环境部署

## 🚀 快速开始

### 🎯 方案选择

我们提供**三种**部署方式，适应不同场景：

| 方案 | 适用场景 | 前置条件 | 传输大小 | 部署时间 |
|------|---------|---------|---------|---------|
| **🌐 在线部署** | 有Python + 有网络 | Python 3.11/3.12 | 几KB | 5-15分钟 |
| **📦 标准离线** | 有Python + 无网络 | Python 3.11/3.12 | ~1.5GB | 2-5分钟 |
| **🎯 超级离线** | 无Python + 可选网络 | 无需任何软件 | 10MB或2GB | 15-40分钟 |

📖 **完整对比**: 查看 [部署方案快速参考](DEPLOYMENT-QUICK-REFERENCE.md)

---

### 🎯 方案一：超级离线部署（零依赖）

> **最适合**：全新机器、没有Python、完全零基础用户  
> **平台**：Windows 10/11  
> **特点**：自动安装Python 3.12.7，用户只需双击

#### 场景A：用户机器可以暂时联网

**您发送：** `super-offline-deployment` 文件夹（~10MB）

**用户操作：**
```batch
# 第1步：下载依赖（需要网络，15-20分钟）
双击运行: prepare-super-offline.bat

# 第2步：安装部署（完全离线，15-20分钟）
双击运行: 一键完整部署.bat

# 完成！浏览器自动打开
```

#### 场景B：用户机器完全离线

**您先准备：**
```batch
cd super-offline-deployment
双击运行: prepare-super-offline.bat
# 等待15-20分钟，生成完整离线包（~2GB）
```

**您发送：** `super-offline-deployment` 文件夹（~2GB，已准备好）

**用户操作：**
```batch
# 一键部署（15-20分钟）
双击运行: 一键完整部署.bat

# 完成！浏览器自动打开
```

📖 **详细指南**: [超级离线部署使用指南](super-offline-deployment/使用指南.md)

---

### 🌐 方案二：在线一键部署

适合有网络连接且已安装Python的环境：

```bash
# Windows PowerShell
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
.\deploy_online.ps1

# Linux/macOS
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
chmod +x deploy_online.sh && ./deploy_online.sh
```

---

### 📦 方案三：标准离线部署

适合已安装Python但无网络的环境：

适合无网络或内网环境，**双击批处理文件即可完成部署**：

**第一步：准备离线包**（在有网络的机器上）
```batch
# Windows：双击运行
准备离线包.bat

# 或手动运行脚本
.\prepare_offline_package.ps1    # Windows
./prepare_offline_package.sh     # Linux/macOS
```

**第二步：离线部署**（在无网络的机器上）
```batch
# 1. 将 offline_deployment_package 文件夹复制到目标机器

# 2. Windows：双击运行
一键部署并启动.bat

# 或手动运行脚本
.\deploy_offline.ps1             # Windows
./deploy_offline.sh              # Linux/macOS

# 3. 浏览器自动打开 http://127.0.0.1:5000
# 4. 使用默认账号登录：admin / Admin@FaceMatch2025!
```

📖 **详细指南**: 
- [一键部署快速指南](一键部署说明.txt) - 快速参考卡
- [完整离线部署教程](docs/ONE-CLICK-OFFLINE-GUIDE.md) - 图文详解
- [离线部署文档](docs/OFFLINE-DEPLOYMENT.md) - 技术细节

---

### 手动部署

如果你更喜欢手动控制每个步骤：

### 方式一：在线部署（推荐）

```bash
# 克隆仓库
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 按照下面的步骤继续...
```

### 方式二：从GitHub部署到Linux

详见 [GitHub到Linux部署指南](docs/GITHUB-TO-LINUX-DEPLOYMENT.md)

```bash
# 在Linux服务器上
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
chmod +x deploy_online.sh
./deploy_online.sh
```

### 方式三：下载ZIP

从 [GitHub Releases](https://github.com/hxhophxh/FaceImgMat/releases) 下载最新版本

---

### 1. 环境要求

- Python 3.11 或 3.12
- Windows / Linux / macOS
- 至少 2GB RAM
- 至少 5GB 磁盘空间

### 2. 安装依赖

```bash
# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
# Windows PowerShell:
.\.venv\Scripts\Activate.ps1
# Linux/macOS:
source .venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

### 3. 初始化数据

```bash
# 初始化演示数据（3个测试人员）
python scripts/init_demo_data.py
```

### 4. 启动服务

```bash
# Windows PowerShell（推荐）
.\start.ps1

# Windows 命令提示符 (CMD)
start.bat

# Linux/macOS
./start.sh

# 或直接运行
python run.py
```

### 5. 访问系统

- 系统地址：http://127.0.0.1:5000
- 默认账号：`admin`
- 默认密码：`Admin@FaceMatch2025!`

## 📖 文档

### 快速入门
- 🚀 [**一键部署完整教程**](docs/ONE-CLICK-DEPLOYMENT.md) - ⭐ 最快部署方式
- 📚 [快速开始指南](docs/quick-start-guide.md) - 5分钟上手

### 部署相关
- 🚀 [**从GitHub部署到Linux服务器**](docs/GITHUB-TO-LINUX-DEPLOYMENT.md) - 完整的克隆和部署流程
- 🐧 [Linux服务器部署](docs/LINUX-DEPLOYMENT.md) - Linux详细配置
- 💾 [离线部署指南](docs/OFFLINE-DEPLOYMENT.md) - 无网络环境部署
- ✅ [部署检查清单](docs/DEPLOYMENT-CHECKLIST.md) - 部署前后检查项
- 📋 [部署文档](docs/DEPLOYMENT.md) - 通用部署说明

### 使用指南
- 🏗️ [项目结构说明](docs/PROJECT-STRUCTURE.md) - 代码组织结构
- 🔒 [安全指南](docs/SECURITY.md) - 安全配置建议

### 完整文档
- 📑 [完整文档索引](docs/INDEX.md) - 所有文档汇总

## 🏗️ 项目结构

```
FaceImgMat/
├── app/                    # 应用核心代码
│   ├── __init__.py        # Flask 应用工厂
│   ├── routes.py          # 路由处理
│   ├── models.py          # 数据模型
│   └── face_matcher.py    # 人脸匹配引擎
├── templates/             # HTML 模板
├── static/               # 静态资源
│   ├── css/             # 样式文件
│   ├── js/              # JavaScript
│   ├── faces/           # 人员照片库
│   └── uploads/         # 上传临时文件
├── scripts/              # 辅助脚本
│   ├── init_demo_data.py      # 初始化演示数据
│   ├── fix_image_paths.py     # 修复图片路径
│   └── test_face_detection.py # 测试人脸检测
├── docs/                 # 项目文档
├── instance/             # 实例数据（数据库）
├── requirements.txt      # 依赖列表
└── run.py               # 启动入口
```

## 🎯 使用场景

- ✅ **企业考勤系统**：员工刷脸打卡
- ✅ **访客管理系统**：访客身份识别
- ✅ **安防监控系统**：实时人脸比对
- ✅ **智能相册管理**：照片自动分类

## 🛠️ 技术栈

- **后端框架**：Flask 3.0
- **人脸识别**：InsightFace 0.7.3
- **向量检索**：FAISS 1.11.0
- **数据库**：SQLite / PostgreSQL
- **前端框架**：Bootstrap 5 + jQuery

## 📊 性能指标

- **检测速度**：< 100ms / 张照片
- **匹配速度**：< 50ms / 万级人员库
- **准确率**：> 99% (相似度阈值 70%)
- **并发支持**：支持多用户同时访问

## 🚢 生产环境部署

### Linux服务器快速部署

```bash
# 1. 克隆项目
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 2. 运行一键部署脚本（详见部署文档）
chmod +x deploy.sh
./deploy.sh
```

详细步骤请参考：[从GitHub部署到Linux服务器完整指南](docs/GITHUB-TO-LINUX-DEPLOYMENT.md)

### 使用Docker部署（即将支持）

```bash
docker pull hxhophxh/faceimgmat:latest
docker-compose up -d
```

## �️ 防病毒软件误报说明

⚠️ **重要提示**：从 GitHub 下载 ZIP 包时，Windows Defender 或其他防病毒软件可能会误报病毒警告。

**这是误报！** 本项目完全安全、开源、透明。

### 为什么会误报？

防病毒软件将包含以下特征的脚本标记为可疑：
- 批处理文件静默安装 Python（`/quiet` 参数）
- PowerShell 脚本下载文件（`Start-BitsTransfer`）
- 自动化部署流程

### 如何处理？

**推荐方案**：
1. 使用 `git clone` 而不是下载 ZIP（通常不会误报）
2. 将项目文件夹添加到防病毒软件白名单
3. 手动检查脚本内容（所有代码公开透明）

**详细说明**：查看 [安全声明文档](SECURITY-NOTICE.md)

所有下载源都是官方可信任的：
- Python 官方：python.org
- 华为云镜像：repo.huaweicloud.com
- 清华大学镜像：mirrors.tuna.tsinghua.edu.cn
- 淘宝镜像：registry.npmmirror.com

## �🔐 安全提醒

⚠️ **首次部署后必须执行以下操作：**

1. **立即修改管理员密码**
   ```bash
   python scripts/change_admin_password.py
   ```

2. **配置HTTPS**（生产环境必须）
   - 参考文档：[安全指南](docs/SECURITY.md)

3. **限制访问IP**（可选但推荐）
   - 在Nginx配置中添加IP白名单

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 支持与反馈

- 💬 **提问题**: [GitHub Issues](https://github.com/hxhophxh/FaceImgMat/issues)
- 📧 **联系作者**: 通过 GitHub Issues 联系
- 📖 **查看文档**: [完整文档索引](docs/INDEX.md)

---

⭐ 如果这个项目对您有帮助，欢迎 Star！