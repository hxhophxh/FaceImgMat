# ✅ 离线部署完整配置总结

## 📋 当前Git配置状态

### ✅ 已正确排除（不会上传到GitHub）
- ✅ `.venv/` - 虚拟环境（约500MB+）
- ✅ `__pycache__/` - Python字节码缓存
- ✅ `.vscode/` - IDE配置
- ✅ `.idea/` - IDE配置
- ✅ `.DS_Store`, `Thumbs.db` - 系统文件

### ✅ 已包含在仓库中（用于离线部署）
- ✅ `instance/face_matching.db` (49KB) - 初始化数据库
- ✅ `static/faces/*.jpg` (3个测试图片)
- ✅ `static/uploads/.gitkeep` - 保持目录结构
- ✅ `logs/.gitkeep` - 保持目录结构
- ✅ 所有源代码、文档、脚本

---

## 🎯 离线部署完整方案

### 方案1：使用准备脚本（推荐）

#### 在有网络的机器上：

```powershell
# Windows PowerShell
.\prepare_offline_package.ps1
```

这个脚本会自动：
1. 下载所有Python依赖包（约500-800MB）
2. 复制InsightFace模型文件（约325MB）
3. 复制项目源代码
4. 创建部署脚本
5. 生成说明文件

完成后运行：
```powershell
.\create_offline_package.ps1
```
会生成一个完整的ZIP包（约1-1.5GB）

#### 在离线机器上：

```powershell
# 解压ZIP包
Expand-Archive FaceImgMat-offline-*.zip

# 运行部署脚本
cd offline_deployment_package
.\deploy_windows.ps1

# 启动服务
cd FaceImgMat
python run.py
```

---

### 方案2：手动准备（适合特殊情况）

#### 步骤1：克隆项目
```bash
git clone https://github.com/hxhophxh/FaceImgMat.git
```

#### 步骤2：下载Python依赖
```bash
cd FaceImgMat
mkdir offline_packages
pip download -r requirements.txt -d offline_packages
```

#### 步骤3：获取InsightFace模型
```bash
# 运行一次让模型自动下载
python -c "import insightface; insightface.app.FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])"

# 模型位置：
# Windows: C:\Users\<用户名>\.insightface\models\
# Linux: ~/.insightface/models/

# 复制到项目
mkdir insightface_models
# Windows
xcopy /E /I %USERPROFILE%\.insightface\models insightface_models
# Linux
cp -r ~/.insightface/models/* insightface_models/
```

#### 步骤4：打包传输
```bash
# 打包所有文件
tar -czf FaceImgMat-complete.tar.gz \
    FaceImgMat/ \
    offline_packages/ \
    insightface_models/
```

#### 步骤5：离线环境部署
```bash
# 解压
tar -xzf FaceImgMat-complete.tar.gz
cd FaceImgMat

# 创建虚拟环境
python3.11 -m venv .venv
source .venv/bin/activate  # Linux
.\.venv\Scripts\Activate.ps1  # Windows

# 离线安装依赖
pip install -r requirements.txt --no-index --find-links=../offline_packages

# 配置模型
mkdir -p ~/.insightface/models  # Linux
cp -r ../insightface_models/* ~/.insightface/models/

# 启动
python run.py
```

---

## 📊 文件大小统计

| 组件 | 大小 | 说明 |
|------|------|------|
| 项目代码 | ~10MB | 包含数据库和示例图片 |
| Python依赖包 | 500-800MB | requirements.txt所有包 |
| InsightFace模型 | ~325MB | buffalo_l模型 |
| **总计** | **~850MB-1.2GB** | 完整离线包 |

### 模型文件详情
```
insightface_models/buffalo_l/
├── buffalo_l.zip (275MB) - 压缩包
├── 1k3d68.onnx (137MB) - 3D人脸模型
├── 2d106det.onnx (4.8MB) - 关键点检测
├── det_10g.onnx (16MB) - 人脸检测
├── genderage.onnx (1.3MB) - 性别年龄识别
└── w600k_r50.onnx (166MB) - 人脸识别主模型
```

---

## ✅ 验证清单

### 在线环境准备阶段
- [ ] 项目已克隆
- [ ] Python依赖已下载到`offline_packages/`
- [ ] InsightFace模型已复制到`insightface_models/`
- [ ] 所有文件已打包成ZIP/TAR
- [ ] 包大小约1-1.5GB

### 离线环境部署阶段
- [ ] Python 3.11/3.12已安装
- [ ] 离线包已解压
- [ ] 虚拟环境已创建
- [ ] 依赖包已离线安装（检查`pip list`）
- [ ] InsightFace模型已配置到`~/.insightface/models/`
- [ ] 数据库文件存在`instance/face_matching.db`
- [ ] 服务可以启动
- [ ] Web界面可以访问 http://127.0.0.1:5000
- [ ] 登录功能正常（admin / Admin@FaceMatch2025!）
- [ ] 人脸匹配功能正常

---

## 🔧 常见问题

### Q1: 为什么.venv不上传到Git？
**A**: 虚拟环境包含所有依赖包（500MB+），体积太大且与操作系统相关。应该在每个环境独立创建。

### Q2: 数据库文件会上传吗？
**A**: 是的！为了离线部署方便，我们将初始化的数据库文件包含在仓库中，但不包含敏感的生产数据。

### Q3: 如何更新模型文件？
**A**: 模型文件在`~/.insightface/models/`，如需更新：
```bash
# 删除旧模型
rm -rf ~/.insightface/models/*
# 重新下载
python -c "import insightface; insightface.app.FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])"
```

### Q4: 离线环境没有Python怎么办？
**A**: 需要额外准备Python安装包：
- Windows: 从 https://www.python.org/downloads/ 下载安装程序
- Linux: 下载系统包或源码包一起传输

### Q5: 如何验证模型文件完整？
**A**: 运行测试脚本：
```bash
python scripts/test_face_detection.py
```
应该能成功检测人脸并显示结果。

---

## 📁 完整的离线包结构

```
FaceImgMat-offline-20251008.zip (约1-1.5GB)
│
├── offline_deployment_package/
│   ├── FaceImgMat/                    # 项目源代码
│   │   ├── app/                       # 应用代码
│   │   ├── docs/                      # 文档
│   │   ├── instance/                  
│   │   │   └── face_matching.db       # ✅ 初始数据库
│   │   ├── scripts/                   # 辅助脚本
│   │   ├── static/
│   │   │   ├── faces/                 # ✅ 测试图片
│   │   │   └── uploads/               # 上传目录
│   │   ├── templates/                 # HTML模板
│   │   ├── requirements.txt           # 依赖清单
│   │   └── run.py                     # 启动文件
│   │
│   ├── python_packages/               # Python依赖包 (500-800MB)
│   │   ├── Flask-3.0.0-*.whl
│   │   ├── insightface-0.7.3-*.whl
│   │   ├── faiss_cpu-1.11.0-*.whl
│   │   └── ... (100+个包)
│   │
│   ├── insightface_models/            # AI模型 (325MB)
│   │   └── buffalo_l/
│   │       ├── 1k3d68.onnx
│   │       ├── 2d106det.onnx
│   │       ├── det_10g.onnx
│   │       ├── genderage.onnx
│   │       └── w600k_r50.onnx
│   │
│   ├── deploy_windows.ps1             # Windows部署脚本
│   ├── deploy_linux.sh                # Linux部署脚本
│   └── README.txt                     # 说明文件
```

---

## 🚀 快速参考命令

### 准备离线包（在线环境）
```powershell
# 克隆项目
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 运行准备脚本
.\prepare_offline_package.ps1

# 打包
.\create_offline_package.ps1
```

### 部署到离线环境
```powershell
# Windows
Expand-Archive FaceImgMat-offline-*.zip
cd offline_deployment_package
.\deploy_windows.ps1
cd FaceImgMat
python run.py
```

```bash
# Linux
tar -xzf FaceImgMat-offline-*.tar.gz
cd offline_deployment_package
chmod +x deploy_linux.sh
./deploy_linux.sh
cd FaceImgMat
python run.py
```

---

## 📞 相关文档

- [离线部署详细指南](OFFLINE-DEPLOYMENT.md)
- [GitHub到Linux部署](GITHUB-TO-LINUX-DEPLOYMENT.md)
- [完整文档索引](INDEX.md)

---

**最后更新**: 2025-10-08  
**Git配置**: ✅ .venv和__pycache__已正确排除  
**数据库**: ✅ 已包含在仓库中  
**模型文件**: ⚠️ 需单独准备（使用脚本自动化）
