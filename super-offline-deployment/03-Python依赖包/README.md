# Python依赖包目录

本目录用于存放 FaceImgMat 项目所需的所有 Python 依赖包（.whl文件）。

## 📦 包含内容

运行 `准备超级离线包.bat` 后，会自动下载约 **80+个** Python包：

### 核心依赖
- Flask 3.0.0 (Web框架)
- insightface 0.7.3 (人脸识别)
- opencv-python (图像处理)
- numpy (数值计算)
- faiss-cpu (向量检索)
- SQLAlchemy (数据库ORM)

### 其他依赖
- werkzeug, jinja2, click... (Flask生态)
- onnxruntime (AI模型运行时)
- scikit-learn, scipy (机器学习)
- pillow (图像处理)
- 等约70+个依赖包

## 📊 统计信息

- **包数量**: 约 80-100 个 .whl 文件
- **总大小**: 约 500-800 MB
- **格式**: 全部为 .whl (wheel) 格式
- **平台**: 适用于 Windows 64位 + Python 3.11/3.12

## 🔄 自动下载

运行准备脚本时，会：
1. 读取 `requirements.txt`
2. 使用 `pip download` 下载所有依赖
3. 保存为 .whl 文件到本目录
4. 无需手动下载

## 📋 离线安装

部署时，会使用以下命令从本目录安装：
```bash
pip install -r requirements.txt --no-index --find-links="此目录"
```

这样就不需要网络连接了！

## ⚠️ 注意事项

- 所有包均为预编译的 wheel 文件
- 适用于 Windows 64位系统
- Python版本: 3.11 或 3.12
- 跨平台需要重新下载对应平台的包

---

**来源**: PyPI (Python Package Index)  
**格式**: .whl (Python Wheel)  
**用途**: 离线安装Python依赖
