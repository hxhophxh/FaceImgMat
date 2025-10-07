# 📂 项目结构说明

完整的项目目录结构和说明。

```
FaceImgMat/
│
├── 📁 app/                         # 应用核心代码
│   ├── __init__.py                 # Flask 应用工厂，初始化配置
│   ├── models.py                   # 数据库模型定义（Admin, Person, MatchRecord）
│   ├── routes.py                   # 路由和视图函数（登录、匹配等）
│   ├── face_matcher.py             # 人脸匹配引擎（InsightFace + FAISS）
│   └── __pycache__/                # Python 缓存文件
│
├── 📁 docs/                        # 项目文档目录
│   ├── INDEX.md                    # 文档索引（本文件）
│   ├── README.md                   # 详细项目说明
│   ├── DEPLOYMENT.md               # 部署指南
│   ├── quick-start-guide.md        # 快速入门
│   ├── implementation-plan.md      # 实现计划
│   ├── face-data-management.md     # 数据管理文档
│   ├── enhanced-results-display.md # 显示增强文档
│   └── ...                         # 其他文档
│
├── 📁 scripts/                     # 辅助脚本目录
│   ├── README.md                   # 脚本使用说明
│   ├── init_demo_data.py           # 初始化演示数据
│   ├── fix_image_paths.py          # 修复图片路径
│   └── test_face_detection.py      # 测试人脸检测
│
├── 📁 static/                      # 静态资源目录
│   ├── css/                        # 样式文件
│   │   └── style.css               # 自定义样式
│   ├── js/                         # JavaScript 文件
│   │   └── app.js                  # 前端交互逻辑
│   ├── faces/                      # 人脸库照片存储
│   │   ├── person1.jpg
│   │   ├── person2.jpg
│   │   └── ...
│   └── uploads/                    # 用户上传的临时照片
│       └── ...
│
├── 📁 templates/                   # HTML 模板目录
│   ├── login.html                  # 登录页面
│   ├── match.html                  # 人脸匹配页面
│   └── import.html                 # 导入管理页面（可选）
│
├── 📁 instance/                    # 实例数据目录（不提交到 Git）
│   └── face_matching.db            # SQLite 数据库文件
│
├── 📁 models/                      # 预训练模型目录
│   └── ...                         # InsightFace 模型文件（自动下载）
│
├── 📁 .venv/                       # Python 虚拟环境（不提交到 Git）
│   └── ...
│
├── 📄 README.md                    # 项目主说明文件
├── 📄 requirements.txt             # Python 依赖清单
├── 📄 run.py                       # 应用启动入口
├── 📄 start.bat                    # Windows 启动脚本
├── 📄 start.sh                     # Linux/Mac 启动脚本
├── 📄 .gitignore                   # Git 忽略文件配置
└── 📄 FaceImgMat.code-workspace    # VS Code 工作区配置
```

---

## 📁 目录详解

### 🔵 核心代码目录

#### `app/` - 应用代码
- **__init__.py**: 
  - 创建 Flask 应用实例
  - 初始化数据库和登录管理
  - 注册蓝图路由
  
- **models.py**:
  - `Admin`: 管理员账户模型
  - `Person`: 人员信息和人脸特征
  - `MatchRecord`: 匹配历史记录

- **routes.py**:
  - `/login`: 登录处理
  - `/match`: 人脸匹配主功能
  - `/logout`: 登出

- **face_matcher.py**:
  - `FaceMatcher`: 人脸匹配引擎类
  - `extract_features()`: 提取人脸特征
  - `build_index()`: 构建 FAISS 索引
  - `search()`: 相似度搜索

---

### 📘 文档目录

#### `docs/` - 项目文档
所有项目相关文档集中存放，便于查阅和维护。

**分类**:
- **入门**: quick-start-guide.md
- **部署**: DEPLOYMENT.md
- **开发**: implementation-plan.md
- **测试**: management-test-guide.md
- **修复**: complete-fix-summary.md

---

### 🔧 脚本目录

#### `scripts/` - 辅助工具
用于初始化、测试、维护的 Python 脚本。

**用途**:
- 数据初始化
- 批量导入
- 路径修复
- 功能测试

详见 [scripts/README.md](../scripts/README.md)

---

### 🎨 静态资源目录

#### `static/` - 前端资源
- **css/**: 样式表
- **js/**: JavaScript 脚本
- **faces/**: 人脸库存储（重要数据）
- **uploads/**: 临时上传文件

**注意**: `faces/` 目录需要定期备份！

---

### 🖼️ 模板目录

#### `templates/` - Jinja2 模板
Flask 渲染的 HTML 模板文件。

**模板列表**:
- `login.html`: 登录界面
- `match.html`: 人脸匹配界面
- 可扩展添加管理界面

---

### 💾 数据目录

#### `instance/` - 实例数据
存放运行时生成的数据，不应提交到版本控制。

**内容**:
- `face_matching.db`: SQLite 数据库
- 生产环境建议使用 PostgreSQL/MySQL

#### `models/` - AI 模型
InsightFace 自动下载的预训练模型文件。

**位置**: 通常在 `~/.insightface/models/`

---

## 🔐 .gitignore 配置

```gitignore
# Python
__pycache__/
*.py[cod]
*.so
.Python
.venv/
venv/
ENV/

# 数据库
instance/
*.db
*.sqlite3

# 上传文件
static/uploads/*
!static/uploads/.gitkeep

# 模型文件
models/
*.onnx
*.pth

# IDE
.vscode/
.idea/
*.code-workspace

# 日志
*.log

# 临时文件
*.tmp
*.bak
.DS_Store
Thumbs.db
```

---

## 📦 依赖文件

### `requirements.txt`
```txt
flask==3.0.0
flask-login==0.6.3
flask-sqlalchemy==3.1.1
insightface
faiss-cpu==1.11.0
opencv-python==4.8.1.78
pillow==10.4.0
numpy>=1.26.0
scikit-learn==1.3.2
werkzeug==3.0.1
python-multipart==0.0.6
sqlalchemy==2.0.23
onnxruntime
```

---

## 🚀 启动文件

### `run.py`
```python
from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

### `start.bat` (Windows)
```batch
@echo off
call .venv\Scripts\activate.bat
python run.py
pause
```

### `start.sh` (Linux/Mac)
```bash
#!/bin/bash
source .venv/bin/activate
python run.py
```

---

## 📊 数据流向

```
用户上传照片 (templates/match.html)
    ↓
路由处理 (app/routes.py)
    ↓
特征提取 (app/face_matcher.py → InsightFace)
    ↓
向量检索 (FAISS Index)
    ↓
数据库查询 (app/models.py → SQLite)
    ↓
返回结果 (JSON → 前端渲染)
```

---

## 🔄 开发流程

1. **编辑代码**: 修改 `app/` 目录下的文件
2. **测试脚本**: 使用 `scripts/` 中的工具测试
3. **更新文档**: 同步更新 `docs/` 中的文档
4. **提交代码**: 遵循 Git 工作流
5. **部署上线**: 参考 `docs/DEPLOYMENT.md`

---

## 📝 命名规范

### 文件命名
- Python: `snake_case.py`
- HTML: `kebab-case.html`
- CSS/JS: `kebab-case.css`
- 文档: `kebab-case.md`

### 代码规范
- 遵循 PEP 8
- 类名: `PascalCase`
- 函数/变量: `snake_case`
- 常量: `UPPER_SNAKE_CASE`

---

## 🔗 相关文档

- [项目 README](../README.md)
- [快速入门](quick-start-guide.md)
- [部署指南](DEPLOYMENT.md)
- [文档索引](INDEX.md)

---

最后更新: 2025-10-07
