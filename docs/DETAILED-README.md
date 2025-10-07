# 🎭 人脸图像匹配系统 (Face Image Matching System)

一个基于深度学习的人脸识别与匹配系统，支持管理员上传人脸图片并快速检索出最相似的 Top-3 匹配结果。

## ✨ 核心功能

- 🔐 **管理员登录** - 安全的身份认证系统
- 📤 **图片上传** - 支持拖拽上传人脸图片
- 🤖 **智能匹配** - 基于 InsightFace 的高精度人脸识别
- 🏆 **Top-3 结果** - 展示最相似的 3 张人脸及相似度评分
- ⚡ **毫秒级响应** - FAISS 向量检索，快速返回结果

## 🛠️ 技术栈

| 技术类别 | 技术选型 | 说明 |
|---------|---------|------|
| **后端框架** | Flask 3.0 | 轻量级 Web 框架 |
| **数据库** | SQLite + SQLAlchemy | 开发环境快速部署 |
| **身份认证** | Flask-Login | 会话管理 |
| **人脸识别** | InsightFace (buffalo_l) | 512 维特征提取 |
| **向量检索** | FAISS | 高性能相似度搜索 |
| **前端** | Bootstrap 5 + jQuery | 响应式界面 |
| **图像处理** | OpenCV + Pillow | 图片预处理 |

## 📁 项目结构

```
FaceImgMat/
├── app/                          # 应用核心代码
│   ├── __init__.py              # Flask 应用工厂
│   ├── models.py                # 数据库模型 (Admin, Person)
│   ├── face_matcher.py          # 人脸匹配核心逻辑
│   └── routes.py                # 路由处理 (登录/匹配)
├── templates/                    # HTML 模板
│   ├── login.html               # 登录页面
│   └── match.html               # 匹配页面
├── static/                       # 静态资源
│   ├── css/                     # 样式文件
│   ├── js/                      # JavaScript 文件
│   ├── faces/                   # 人脸库图片 (需手动添加)
│   └── uploads/                 # 临时上传目录
├── models/                       # InsightFace 模型文件 (自动下载)
├── docs/                         # 项目文档
│   ├── implementation-plan.md   # 实施计划
│   ├── quick-start-guide.md     # 快速开始指南
│   └── technology-decisions.md  # 技术决策文档
├── init_demo_data.py            # 演示数据初始化脚本
├── run.py                       # 应用启动入口
├── requirements.txt             # Python 依赖
├── start.bat                    # Windows 启动脚本
├── start.sh                     # Linux/Mac 启动脚本
└── README.md                    # 项目说明文档
```

## 📋 前置要求

- ✅ **Python 3.8+** (推荐 3.9 或 3.10)
- ✅ **pip** 包管理器
- ✅ **虚拟环境** (推荐使用 venv 或 conda)
- ✅ **至少 2GB 可用内存** (用于加载 InsightFace 模型)

## 🚀 安装步骤

### 1️⃣ 克隆或下载项目

```bash
# 如果使用 Git
git clone <repository-url>
cd FaceImgMat

# 或直接下载 ZIP 并解压
```

### 2️⃣ 创建虚拟环境

**Windows:**
```cmd
python -m venv venv
venv\Scripts\activate
```

**Linux/Mac:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3️⃣ 安装依赖

```bash
pip install -r requirements.txt
```

> ⚠️ **注意**: 首次运行时，InsightFace 会自动下载 `buffalo_l` 模型文件（约 200MB），请确保网络连接正常。模型将保存在 `~/.insightface/models/` 目录。

### 4️⃣ 准备演示数据

#### 添加人脸图片

在 `static/faces/` 目录下放置 3-5 张人脸图片：

```bash
static/faces/
├── person1.jpg    # 张三的照片
├── person2.jpg    # 李四的照片
└── person3.jpg    # 王五的照片
```

**图片要求:**
- ✅ 清晰的正面人脸照片
- ✅ 光线充足，无遮挡
- ✅ 格式: JPG/PNG
- ✅ 建议尺寸: 至少 200x200 像素

#### 初始化数据库

```bash
python init_demo_data.py
```

成功后会看到类似输出：
```
✅ 添加: 张三
✅ 添加: 李四
✅ 添加: 王五

✨ 演示数据初始化完成！共 3 个人物
```

## 🎯 运行应用

### 方式一：使用启动脚本（推荐）

**Windows:**
```cmd
start.bat
```

**Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

### 方式二：直接运行 Python

```bash
python run.py
```

### 访问应用

打开浏览器访问: **http://localhost:5000**

**默认管理员账号:**
- 用户名: `admin`
- 密码: `Admin@FaceMatch2025!`

## 📖 使用指南

### 1. 登录系统

![Login Page](docs/screenshots/login.png)

使用默认账号 `admin` / `Admin@FaceMatch2025!` 登录系统。

### 2. 上传人脸图片

![Match Page](docs/screenshots/match.png)

- 点击 "选择图片" 或拖拽图片到上传区域
- 支持 JPG/PNG 格式
- 系统会自动检测人脸并提取特征

### 3. 查看匹配结果

![Results](docs/screenshots/results.png)

系统会展示 Top-3 最相似的人脸：
- 显示匹配人物的姓名
- 显示相似度评分（0-1 之间，越接近 1 越相似）
- 显示原始人脸图片

## 🔌 API 接口参考

### POST `/login`
管理员登录

**请求体:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**响应:**
```json
{
  "success": true,
  "message": "登录成功"
}
```

### GET `/logout`
退出登录

**响应:**
```json
{
  "success": true,
  "message": "已退出登录"
}
```

### POST `/match`
上传图片进行人脸匹配

**请求:** `multipart/form-data`
- `file`: 图片文件

**响应:**
```json
{
  "success": true,
  "matches": [
    {
      "name": "张三",
      "similarity": 0.95,
      "image_url": "/static/faces/person1.jpg"
    },
    {
      "name": "李四",
      "similarity": 0.87,
      "image_url": "/static/faces/person2.jpg"
    },
    {
      "name": "王五",
      "similarity": 0.82,
      "image_url": "/static/faces/person3.jpg"
    }
  ]
}
```

## 🐛 常见问题排查

### 问题 1: InsightFace 安装失败

**症状:** `pip install insightface` 报错

**解决方案:**
```bash
# 方案 1: 升级 pip
pip install --upgrade pip setuptools wheel

# 方案 2: 使用国内镜像
pip install insightface -i https://pypi.tuna.tsinghua.edu.cn/simple

# 方案 3: 安装预编译版本
pip install insightface==0.7.3
```

### 问题 2: 模型下载失败

**症状:** 运行时提示 "Failed to download model"

**解决方案:**
1. 检查网络连接
2. 手动下载模型文件:
   - 访问 [InsightFace Model Zoo](https://github.com/deepinsight/insightface/tree/master/model_zoo)
   - 下载 `buffalo_l` 模型
   - 解压到 `~/.insightface/models/buffalo_l/`

### 问题 3: 人脸检测失败

**症状:** 上传图片后提示 "未检测到人脸"

**可能原因:**
- ❌ 图片中没有清晰的正面人脸
- ❌ 人脸被遮挡或角度过大
- ❌ 图片分辨率过低
- ❌ 光线条件不佳

**解决方案:**
- ✅ 使用清晰的正面人脸照片
- ✅ 确保人脸占据图片的主要部分
- ✅ 使用至少 200x200 像素的图片
- ✅ 确保光线充足

### 问题 4: 端口被占用

**症状:** `Address already in use: 5000`

**解决方案:**
```bash
# Windows: 查找并结束占用进程
netstat -ano | findstr :5000
taskkill /PID <进程ID> /F

# Linux/Mac: 查找并结束占用进程
lsof -i :5000
kill -9 <进程ID>

# 或修改 run.py 中的端口号
app.run(debug=True, host='0.0.0.0', port=5001)
```

### 问题 5: FAISS 索引构建失败

**症状:** 启动时报 FAISS 相关错误

**解决方案:**
```bash
# 重新安装 FAISS
pip uninstall faiss-cpu
pip install faiss-cpu==1.7.4

# 如果有 GPU，可以安装 GPU 版本
pip install faiss-gpu
```

## 🔮 未来增强计划

### 短期目标 (1-3 个月)

- [ ] 🚀 **迁移到 FastAPI** - 提升性能和异步支持
- [ ] 🗄️ **PostgreSQL 支持** - 生产环境数据库
- [ ] 👥 **人员管理界面** - Web 端添加/删除人员
- [ ] 📊 **匹配历史记录** - 查看历史匹配结果
- [ ] 🔍 **高级搜索** - 按相似度阈值过滤

### 中期目标 (3-6 个月)

- [ ] 🐳 **Docker 部署** - 容器化部署方案
- [ ] 📈 **性能监控** - 添加 Prometheus + Grafana
- [ ] 🔐 **RBAC 权限** - 多角色权限管理
- [ ] 📱 **移动端适配** - 响应式设计优化
- [ ] 🌐 **多语言支持** - 国际化 (i18n)

### 长期目标 (6-12 个月)

- [ ] ☁️ **云原生架构** - Kubernetes 部署
- [ ] 🚄 **Milvus 集成** - 支持千万级人脸库
- [ ] 🤖 **模型升级** - 支持更先进的人脸识别模型
- [ ] 🔄 **实时视频流** - 支持摄像头实时匹配
- [ ] 📊 **数据分析** - 匹配统计和可视化

## 🔧 开发指南

### 添加新的人脸数据

```python
from app import create_app
from app.models import db, Person
from app.face_matcher import face_matcher

app = create_app()
with app.app_context():
    # 提取特征
    embedding, error = face_matcher.extract_features('path/to/image.jpg')
    
    if embedding is not None:
        person = Person(
            name='新人物',
            image_url='path/to/image.jpg',
            feature_vector=embedding.tolist()
        )
        db.session.add(person)
        db.session.commit()
        
        # 重建索引
        face_matcher.build_index()
```

### 修改相似度阈值

编辑 [`app/face_matcher.py`](app/face_matcher.py:45)：

```python
def find_matches(self, query_embedding, top_k=3, threshold=0.6):
    # 调整 threshold 参数 (0.0-1.0)
    # 值越大，匹配越严格
```

### 更换人脸识别模型

编辑 [`app/face_matcher.py`](app/face_matcher.py:15)：

```python
# 可选模型: buffalo_l, buffalo_m, buffalo_s
self.app = FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])
```

## 📄 许可证

本项目采用 MIT 许可证开源。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

本项目使用了以下优秀的开源项目：

- [InsightFace](https://github.com/deepinsight/insightface) - 高性能人脸识别库
- [FAISS](https://github.com/facebookresearch/faiss) - Facebook AI 相似度搜索库
- [Flask](https://flask.palletsprojects.com/) - Python Web 框架
- [Bootstrap](https://getbootstrap.com/) - 前端 UI 框架

## 📞 联系方式

如有问题或建议，欢迎通过以下方式联系：

- 📧 Email: your-email@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/yourname/FaceImgMat/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/yourname/FaceImgMat/discussions)

---

<div align="center">

**⭐ 如果这个项目对你有帮助，请给个 Star！⭐**

Made with ❤️ by [Your Name]

</div>