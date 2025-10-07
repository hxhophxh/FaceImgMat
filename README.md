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

### 方式一：在线部署（推荐）

```bash
# 克隆仓库
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 按照下面的步骤继续...
```

### 方式二：离线部署（无网络环境）

适用于无法访问互联网的环境，详见 [离线部署指南](docs/OFFLINE-DEPLOYMENT.md)

```bash
# 1. 在有网络的机器上运行准备脚本
./prepare_offline_package.sh    # Linux/macOS
# 或
.\prepare_offline_package.ps1   # Windows

# 2. 将生成的离线包传输到目标环境
# 3. 解压并运行部署脚本
./deploy_linux.sh               # Linux/macOS
# 或
.\deploy_windows.ps1            # Windows
```

### 方式二：下载ZIP

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

### 部署相关
- 🚀 [**从GitHub部署到Linux服务器**](docs/GITHUB-TO-LINUX-DEPLOYMENT.md) - 完整的克隆和部署流程
- 🐧 [Linux服务器部署](docs/LINUX-DEPLOYMENT.md) - Linux详细配置
- ✅ [部署检查清单](docs/DEPLOYMENT-CHECKLIST.md) - 部署前后检查项
- 📋 [部署文档](docs/DEPLOYMENT.md) - 通用部署说明

### 使用指南
- 📚 [快速开始指南](docs/quick-start-guide.md) - 5分钟上手
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

## 🔐 安全提醒

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