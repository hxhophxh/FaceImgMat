# 人脸图像匹配系统 - 快速实施方案

## 1. 项目概述

### 1.1 核心需求
根据 ReadMe.MD 的要求，系统需要实现：
1. **管理员登录** - 身份认证与授权
2. **图片上传** - 管理员上传单张人脸图片
3. **人脸匹配** - 与库中图片（URL地址）进行匹配
4. **结果展示** - 输出最相似的3张图片及对应人物名字

### 1.2 技术策略
- **快速启动**: 使用轻量级技术栈，最快2-3周上线MVP
- **易于扩展**: 模块化设计，支持后续升级到重量级框架
- **成本优化**: 优先开源方案，降低初期投入

## 2. 推荐技术栈（MVP版本）

### 2.1 最小可行方案（2-3周实现）

```yaml
前端 (轻量级):
  框架: React 18 + Vite
  UI库: Ant Design 5.x
  状态管理: React Query + useState
  HTTP: Axios
  
后端 (快速开发):
  框架: FastAPI (Python 3.10+)
  认证: JWT (python-jose)
  ORM: SQLAlchemy 2.0 (异步)
  验证: Pydantic V2
  
AI/ML (核心功能):
  人脸识别: InsightFace (ArcFace模型)
  向量检索: FAISS (IndexFlatL2)
  图像处理: OpenCV + Pillow
  
数据存储 (简化版):
  数据库: PostgreSQL 15
  向量索引: FAISS (内存 + 文件)
  图片存储: 本地文件系统
  
部署 (单机版):
  容器: Docker + Docker Compose
  反向代理: Nginx
  进程管理: Uvicorn
```

### 2.2 扩展路径

**MVP → 优化版 → 生产版**

- MVP: FAISS IndexFlatL2 + 本地存储 + 单机
- 优化: FAISS IVF+PQ + MinIO + Redis缓存
- 生产: Qdrant/Milvus + Kubernetes + 微服务

## 3. 系统架构设计

### 3.1 MVP架构图

```
┌─────────────────────────────────────────────────────────┐
│                    Client Browser                        │
│              React + Ant Design + Axios                  │
└─────────────────────────────────────────────────────────┘
                         │ HTTPS (REST API)
                         ▼
┌─────────────────────────────────────────────────────────┐
│                    Nginx (Port 80/443)                   │
│              SSL Termination + Static Files              │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              FastAPI Backend (Port 8000)                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │   Auth   │  │  Upload  │  │  Match   │              │
│  │  Module  │  │  Module  │  │  Module  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────┘
         │              │              │
         ▼              ▼              ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ PostgreSQL   │ │ File System  │ │ FAISS Index  │
│   (Port      │ │  /storage/   │ │  (Memory)    │
│    5432)     │ │              │ │              │
└──────────────┘ └──────────────┘ └──────────────┘
```

### 3.2 目录结构

```
FaceImgMat/
├── backend/                    # 后端代码
│   ├── app/
│   │   ├── main.py            # FastAPI应用入口
│   │   ├── config.py          # 配置管理
│   │   ├── database.py        # 数据库连接
│   │   ├── models/            # SQLAlchemy模型
│   │   ├── schemas/           # Pydantic模式
│   │   ├── api/               # API路由
│   │   ├── services/          # 业务逻辑
│   │   └── utils/             # 工具函数
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
│
├── frontend/                   # 前端代码
│   ├── src/
│   │   ├── pages/             # 页面组件
│   │   ├── components/        # 通用组件
│   │   ├── services/          # API服务
│   │   └── types/             # TypeScript类型
│   ├── package.json
│   ├── vite.config.ts
│   └── Dockerfile
│
├── nginx/                      # Nginx配置
├── storage/                    # 文件存储
├── docs/                       # 文档
├── docker-compose.yml
└── README.md
```

## 4. 详细实施计划

### Phase 1: 项目初始化（1-2天）

#### 1.1 创建项目结构
```bash
mkdir -p backend/app/{models,schemas,api,services,utils}
mkdir -p frontend/src/{pages,components,services,types}
mkdir -p nginx storage/{faces,uploads,faiss} docs
```

#### 1.2 后端依赖安装
```bash
# requirements.txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
asyncpg==0.29.0
psycopg2-binary==2.9.9
pydantic==2.5.0
pydantic-settings==2.1.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
aiofiles==23.2.1
insightface==0.7.3
onnxruntime==1.16.3
faiss-cpu==1.7.4
opencv-python==4.8.1.78
Pillow==10.1.0
numpy==1.24.3
```

#### 1.3 前端依赖安装
```bash
# package.json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "antd": "^5.11.5",
    "@tanstack/react-query": "^5.8.4",
    "axios": "^1.6.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@vitejs/plugin-react": "^4.2.0",
    "typescript": "^5.2.2",
    "vite": "^5.0.0"
  }
}
```

### Phase 2: 后端核心开发（5-7天）

#### 2.1 数据库模型（1天）
基于 [`database-schema.md`](../ImgMat.bak/docs/database-schema.md) 实现：
- [`models/admin.py`] - 管理员模型
- [`models/person.py`] - 人物信息模型
- [`models/face_image.py`] - 人脸图片模型
- [`models/match_record.py`] - 匹配记录模型

#### 2.2 认证系统（1-2天）
- JWT Token生成与验证
- 密码bcrypt加密
- 登录失败锁定机制
- 中间件权限验证

#### 2.3 API端点（2-3天）
```python
# 认证相关
POST   /api/v1/auth/login          # 管理员登录
POST   /api/v1/auth/logout         # 登出
GET    /api/v1/auth/me             # 获取当前用户

# 匹配相关
POST   /api/v1/match/upload        # 上传并匹配
GET    /api/v1/match/history       # 匹配历史
GET    /api/v1/match/{id}          # 匹配详情

# 人物库相关
GET    /api/v1/persons             # 人物列表
GET    /api/v1/persons/{id}        # 人物详情
POST   /api/v1/persons             # 添加人物
PUT    /api/v1/persons/{id}        # 更新人物
DELETE /api/v1/persons/{id}        # 删除人物
```

#### 2.4 数据库初始化（1天）
- 创建数据库表
- 初始化管理员账户
- 系统配置数据

### Phase 3: AI/ML集成（4-5天）

#### 3.1 InsightFace集成（2天）
```python
# services/face_service.py
import insightface
from insightface.app import FaceAnalysis

class FaceRecognitionService:
    def __init__(self):
        self.app = FaceAnalysis(
            providers=['CPUExecutionProvider']
        )
        self.app.prepare(ctx_id=0, det_size=(640, 640))
    
    def detect_face(self, image_path: str):
        """检测人脸并提取特征"""
        img = cv2.imread(image_path)
        faces = self.app.get(img)
        
        if len(faces) == 0:
            return None, "No face detected"
        
        # 返回第一个人脸的512维特征向量
        embedding = faces[0].embedding
        embedding = embedding / np.linalg.norm(embedding)
        
        return embedding, None
```

#### 3.2 FAISS向量检索（2天）
```python
# services/match_service.py
import faiss
import numpy as np

class VectorSearchService:
    def __init__(self):
        self.dimension = 512
        self.index = faiss.IndexFlatL2(self.dimension)
        self.id_mapping = {}  # FAISS索引ID -> 数据库ID
        
    def add_vector(self, face_id: int, embedding: np.ndarray):
        """添加向量到索引"""
        self.index.add(embedding.reshape(1, -1))
        idx = self.index.ntotal - 1
        self.id_mapping[idx] = face_id
        
    def search(self, query_embedding: np.ndarray, k: int = 3):
        """搜索最相似的k个向量"""
        distances, indices = self.index.search(
            query_embedding.reshape(1, -1), k
        )
        
        results = []
        for dist, idx in zip(distances[0], indices[0]):
            if idx in self.id_mapping:
                results.append({
                    'face_id': self.id_mapping[idx],
                    'distance': float(dist),
                    'similarity': 1 / (1 + float(dist))
                })
        
        return results
    
    def save_index(self, path: str):
        """保存索引到文件"""
        faiss.write_index(self.index, path)
        
    def load_index(self, path: str):
        """从文件加载索引"""
        self.index = faiss.read_index(path)
```

#### 3.3 匹配流程实现（1天）
```python
# api/match.py
@router.post("/upload", response_model=MatchResponse)
async def upload_and_match(
    image: UploadFile,
    threshold: float = 0.7,
    top_k: int = 3,
    current_user: Admin = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    # 1. 保存上传的图片
    file_path = await save_upload_file(image)
    
    # 2. 检测人脸并提取特征
    embedding, error = face_service.detect_face(file_path)
    if error:
        raise HTTPException(status_code=400, detail=error)
    
    # 3. 向量检索
    results = vector_service.search(embedding, k=top_k)
    
    # 4. 过滤低于阈值的结果
    filtered_results = [
        r for r in results 
        if r['similarity'] >= threshold
    ]
    
    # 5. 查询人物信息
    face_ids = [r['face_id'] for r in filtered_results]
    persons = await get_persons_by_face_ids(db, face_ids)
    
    # 6. 记录匹配历史
    match_record = await create_match_record(
        db, current_user.id, file_path, filtered_results
    )
    
    return MatchResponse(
        match_id=match_record.id,
        results=persons,
        processing_time_ms=processing_time
    )
```

### Phase 4: 前端开发（5-6天）

#### 4.1 基础框架搭建（1天）
- React Router配置
- Ant Design主题配置
- Axios拦截器（Token、错误处理）
- React Query配置

#### 4.2 登录页面（1天）
```tsx
// pages