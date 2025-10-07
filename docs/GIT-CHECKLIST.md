# Git 仓库文件清单

## ✅ 已包含在 Git 仓库中的文件

### 核心配置文件
- `.gitignore` - Git 忽略规则
- `README.md` - 项目说明文档
- `requirements.txt` - Python 依赖清单
- `run.py` - 应用启动入口

### 启动脚本
- `start.bat` - Windows 批处理启动脚本
- `start.ps1` - PowerShell 启动脚本
- `start.sh` - Linux/macOS Bash 启动脚本

### 应用代码 (app/)
- `__init__.py` - Flask 应用工厂
- `models.py` - 数据库模型
- `face_matcher.py` - 人脸识别核心逻辑
- `routes.py` - 路由和视图函数

### 模板文件 (templates/)
- `login.html` - 登录页面
- `match.html` - 人脸匹配页面
- `import.html` - 人脸数据导入页面

### 静态文件 (static/)
- `faces/person1.jpg` - 演示人脸图片 1
- `faces/person2.jpg` - 演示人脸图片 2
- `faces/person3.jpg` - 演示人脸图片 3
- `css/` - CSS 样式文件（空目录）
- `js/` - JavaScript 脚本文件（空目录）
- `uploads/.gitkeep` - 上传目录占位文件

### 工具脚本 (scripts/)
- `README.md` - 脚本说明文档
- `init_demo_data.py` - 初始化演示数据
- `change_admin_password.py` - 修改管理员密码
- `update_password_now.py` - 紧急密码更新
- `fix_image_paths.py` - 修复图片路径
- `test_face_detection.py` - 测试人脸检测

### 文档目录 (docs/)
- `INDEX.md` - 文档索引
- `DETAILED-README.md` - 详细说明文档
- `PROJECT-STRUCTURE.md` - 项目结构说明
- `DEPLOYMENT.md` - 部署指南
- `LINUX-DEPLOYMENT.md` - **Linux 生产环境完整部署指南**
- `SECURITY.md` - 安全配置文档
- `STARTUP-GUIDE.md` - 启动指南
- `quick-start-guide.md` - 快速开始
- `complete-fix-summary.md` - 问题修复总结
- 其他技术文档...

### 占位文件
- `logs/.gitkeep` - 日志目录占位
- `models/README.md` - 模型目录说明
- `static/uploads/.gitkeep` - 上传目录占位

---

## ❌ 已排除（不提交到 Git）的文件

### Python 相关
- `.venv/` - **虚拟环境目录（约 500MB）**
- `__pycache__/` - Python 缓存文件
- `*.pyc`, `*.pyo` - 编译后的 Python 文件
- `*.egg-info/` - Python 包信息

### 数据库文件
- `instance/` - **包含 SQLite 数据库和用户数据**
- `instance/face_matching.db` - **数据库文件（包含敏感信息）**

### 用户上传文件
- `static/uploads/*.jpg` - **用户上传的图片（已排除）**
- `static/uploads/*.png`
- `static/uploads/*.jpeg`

### AI 模型文件
- `models/*.onnx` - **InsightFace 模型文件（约 200MB）**
- `models/buffalo_l/` - **模型目录（自动下载）**

### 日志文件
- `logs/*.log` - **应用日志（运行时生成）**
- `logs/access.log`
- `logs/error.log`
- `logs/gunicorn.pid`

### IDE 和系统文件
- `.vscode/` - VS Code 配置
- `.idea/` - PyCharm 配置
- `FaceImgMat.code-workspace` - VS Code 工作区文件
- `.DS_Store` - macOS 系统文件
- `Thumbs.db` - Windows 缩略图缓存

### 临时文件
- `*.tmp` - 临时文件
- `*.bak` - 备份文件
- `*.swp` - Vim 交换文件

---

## 📊 文件大小统计

| 类别 | 是否提交 | 大小估算 | 说明 |
|------|---------|---------|------|
| Python 代码 | ✅ | ~50KB | 核心应用代码 |
| 文档 | ✅ | ~500KB | Markdown 文档 |
| 模板/静态 | ✅ | ~100KB | HTML/CSS/JS |
| 演示图片 | ✅ | ~500KB | 3 张演示人脸图片 |
| **虚拟环境** | ❌ | ~500MB | 会自动重新创建 |
| **AI 模型** | ❌ | ~200MB | 首次运行自动下载 |
| **数据库** | ❌ | ~100KB | 包含敏感数据 |
| **用户上传** | ❌ | 变化 | 用户数据 |

**Git 仓库总大小**: ~1MB（不含虚拟环境和模型）

---

## 🚀 部署到 Linux 服务器步骤

### 1. 克隆项目

```bash
# 在 Linux 服务器上
git clone https://github.com/your-username/FaceImgMat.git
cd FaceImgMat
```

### 2. 创建虚拟环境

```bash
python3 -m venv .venv
source .venv/bin/activate
```

### 3. 安装依赖

```bash
pip install -r requirements.txt
pip install gunicorn gevent
```

### 4. 初始化数据库

```bash
python scripts/init_demo_data.py
```

### 5. 下载 AI 模型

```bash
# 首次运行时自动下载，或手动触发
python -c "from insightface.app import FaceAnalysis; app = FaceAnalysis(name='buffalo_l'); app.prepare(ctx_id=0)"
```

### 6. 配置生产环境

按照 `docs/LINUX-DEPLOYMENT.md` 详细步骤配置：
- Gunicorn + Systemd
- Nginx 反向代理
- SSL 证书
- 防火墙
- 监控日志

---

## 🔐 重要提醒

### 不要提交的敏感文件

1. **数据库文件** (`instance/face_matching.db`)
   - 包含用户密码哈希
   - 包含人脸特征向量数据

2. **用户上传文件** (`static/uploads/`)
   - 可能包含个人隐私图片

3. **环境变量文件** (`.env`)
   - 如果包含密钥、密码等敏感信息

4. **AI 模型文件** (`models/*.onnx`)
   - 文件太大（200MB+）
   - 可通过脚本自动下载

### 服务器首次部署需要手动操作

1. 创建 `instance/` 目录
2. 运行 `scripts/init_demo_data.py` 初始化数据库
3. 修改管理员密码（使用 `scripts/change_admin_password.py`）
4. 配置生产环境参数（数据库连接、密钥等）

---

## 📝 提交命令示例

```bash
# 首次提交
git commit -m "Initial commit: Face matching system v1.0

- Flask 3.0 web application
- InsightFace face recognition
- FAISS vector similarity search
- Complete documentation
- Linux deployment guide"

# 推送到远程仓库
git remote add origin https://github.com/your-username/FaceImgMat.git
git push -u origin master
```

---

## 🔄 后续更新流程

```bash
# 修改代码后
git add app/*.py
git commit -m "Fix: 修复人脸匹配阈值问题"
git push

# 在服务器上更新
cd /home/faceapp/FaceImgMat
git pull
sudo systemctl restart faceimgmat
```

---

**最后更新**: 2025-10-07
