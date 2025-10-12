# AI模型文件目录

本目录用于存放 InsightFace 人脸识别模型。

## 🤖 模型说明

InsightFace 使用预训练的深度学习模型进行人脸检测和识别：

### buffalo_l 模型
- **用途**: 高精度人脸检测和特征提取
- **大小**: 约 325 MB
- **精度**: 在LFW数据集上达到99.8%+

### 模型文件
```
insightface_models/
└── buffalo_l/
    ├── det_10g.onnx          # 人脸检测模型 (16MB)
    ├── w600k_r50.onnx        # 特征提取模型 (166MB)
    ├── 1k3d68.onnx           # 3D关键点检测 (137MB)
    ├── 2d106det.onnx         # 2D关键点检测 (5MB)
    └── genderage.onnx        # 性别年龄检测 (1.3MB)
```

## 🔄 自动复制

运行准备脚本时，会：
1. 从用户目录 `~/.insightface/models/` 复制模型
2. 如果本地没有模型，首次运行时会自动下载（需要网络）

## 📥 手动下载

如果准备脚本无法自动获取模型，可以手动下载：

1. 在有网络的机器上运行：
   ```python
   import insightface
   model = insightface.app.FaceAnalysis(name='buffalo_l')
   model.prepare(ctx_id=-1, det_size=(640, 640))
   ```

2. 模型会下载到：`C:\Users\<用户名>\.insightface\models\buffalo_l\`

3. 复制整个 `buffalo_l` 目录到本目录的 `insightface_models/` 下

## 🚀 部署时的作用

部署时，脚本会：
1. 将本目录的模型复制到用户的 `~/.insightface/models/`
2. 应用启动时直接使用本地模型
3. 无需联网下载

## ⚠️ 注意事项

- 模型文件较大（325MB），传输可能需要时间
- 模型为 ONNX 格式，跨平台通用
- 如果没有模型，首次运行需要网络下载
- 建议在准备离线包时包含模型

---

**模型**: InsightFace buffalo_l  
**格式**: ONNX  
**大小**: 约 325 MB  
**来源**: InsightFace官方模型库  
**用途**: 人脸检测和识别
