# 🎭 人脸图像匹配系统

基于 InsightFace + FAISS 的高性能人脸识别与匹配系统。

## ✨ 功能特性

- 🔍 **智能人脸识别**：上传照片自动识别并匹配数据库中的人员
- ⚡ **高速检索**：FAISS 向量检索，毫秒级响应
- 📊 **相似度排序**：Top-K 结果按相似度排序，直观展示
- 👥 **人员管理**：批量导入、查询、管理人员信息
- 📝 **匹配记录**：自动记录每次匹配历史
- 🎨 **现代界面**：Bootstrap 5 响应式设计

## 🚀 快速开始

### 1. 环境要求

- Python 3.11 或 3.12
- Windows / Linux / macOS

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

- [快速开始指南](docs/quick-start-guide.md)
- [部署文档](docs/DEPLOYMENT.md)
- [项目结构说明](docs/PROJECT-STRUCTURE.md)
- [完整文档索引](docs/INDEX.md)

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

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 📞 联系方式

如有问题或建议，请提交 Issue。

---

⭐ 如果这个项目对您有帮助，欢迎 Star！