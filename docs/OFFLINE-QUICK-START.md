# 🚀 离线部署快速参考

本文档提供离线环境部署的快速命令和核心步骤。

**完整指南**: 请参考 [OFFLINE-DEPLOYMENT.md](OFFLINE-DEPLOYMENT.md)

---

## 📦 步骤1：在线环境准备

### 1.1 克隆项目
```bash
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
```

### 1.2 下载Python依赖包
```bash
mkdir ../offline_packages
pip download -r requirements.txt -d ../offline_packages
```

### 1.3 下载InsightFace模型
```bash
# 运行后会自动下载到 ~/.insightface/models/
python -c "import insightface; insightface.app.FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])"

# 复制模型文件
mkdir -p ../insightface_models
cp -r ~/.insightface/models/* ../insightface_models/

# Windows PowerShell
mkdir ..\insightface_models -Force
Copy-Item -Path $env:USERPROFILE\.insightface\models\* -Destination ..\insightface_models\ -Recurse
```

### 1.4 打包所有文件
```bash
cd ..

# Linux/Mac
tar -czf FaceImgMat-offline.tar.gz \
    --exclude='.venv' \
    --exclude='.git' \
    --exclude='__pycache__' \
    FaceImgMat/ offline_packages/ insightface_models/

# Windows PowerShell
Compress-Archive -Path FaceImgMat,offline_packages,insightface_models -DestinationPath FaceImgMat-offline.zip
```

**文件清单**：
- ✅ FaceImgMat-offline.tar.gz (或.zip) - 约 700MB-1GB
- ✅ 包含：项目代码、依赖包、AI模型

---

## 💻 步骤2：离线环境部署

### 2.1 解压文件
```bash
# Linux/Mac
tar -xzf FaceImgMat-offline.tar.gz
cd FaceImgMat

# Windows PowerShell
Expand-Archive -Path FaceImgMat-offline.zip -DestinationPath .
cd FaceImgMat
```

### 2.2 安装Python（如果需要）
确保系统有 Python 3.11 或 3.12

```bash
python --version
# 应显示: Python 3.11.x 或 3.12.x
```

### 2.3 创建虚拟环境
```bash
# Linux/Mac
python3.11 -m venv .venv
source .venv/bin/activate

# Windows PowerShell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

### 2.4 离线安装依赖
```bash
pip install -r requirements.txt --no-index --find-links=../offline_packages
```

### 2.5 配置InsightFace模型
```bash
# Linux/Mac
mkdir -p ~/.insightface/models
cp -r ../insightface_models/* ~/.insightface/models/

# Windows PowerShell
mkdir $env:USERPROFILE\.insightface\models -Force
Copy-Item -Path ..\insightface_models\* -Destination $env:USERPROFILE\.insightface\models\ -Recurse
```

### 2.6 验证数据库
```bash
# 检查数据库文件是否存在
ls -l instance/face_matching.db

# 如果不存在，初始化
python scripts/init_demo_data.py
```

### 2.7 启动服务
```bash
# 直接启动
python run.py

# 或使用启动脚本
# Windows
.\start.ps1

# Linux/Mac
./start.sh
```

---

## ✅ 验证部署

### 访问Web界面
- 地址: http://127.0.0.1:5000
- 用户名: `admin`
- 密码: `Admin@FaceMatch2025!`

### 快速测试
1. 登录系统
2. 上传测试图片: `static/faces/person1.jpg`
3. 查看匹配结果

---

## 🔧 常见问题

### ❌ 依赖安装失败
```bash
# 检查offline_packages目录
ls ../offline_packages | wc -l
# 应该有100+个包

# 手动安装核心包
cd ../offline_packages
pip install Flask-*.whl insightface-*.whl faiss_cpu-*.whl --no-deps
```

### ❌ 模型加载失败
```bash
# 检查模型文件
ls ~/.insightface/models/buffalo_l/
# 应该包含: det_10g.onnx, w600k_r50.onnx, glintr100.onnx

# 重新复制
cp -r ../insightface_models/* ~/.insightface/models/
```

### ❌ 端口被占用
```bash
# 修改 run.py 中的端口
# app.run(host='0.0.0.0', port=8080)  # 改为8080或其他端口
```

---

## 📊 文件大小参考

| 文件/目录 | 大小 |
|----------|------|
| 项目代码 | ~10MB |
| Python依赖包 | 500-800MB |
| InsightFace模型 | ~180MB |
| **总计** | **~700MB-1GB** |

---

## 🔐 安全提醒

⚠️ **部署后立即执行**：
```bash
# 修改默认密码
python scripts/change_admin_password.py
```

---

## 📚 相关文档

- 📖 [完整离线部署指南](OFFLINE-DEPLOYMENT.md)
- 🚀 [在线部署指南](GITHUB-TO-LINUX-DEPLOYMENT.md)
- 📋 [项目README](../README.md)

---

## 🆘 获取帮助

如有问题，请查看：
- [完整部署文档](OFFLINE-DEPLOYMENT.md)
- [GitHub Issues](https://github.com/hxhophxh/FaceImgMat/issues)

---

**最后更新**: 2025-10-08
