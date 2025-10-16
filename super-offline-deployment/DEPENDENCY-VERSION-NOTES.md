# FaceImgMat 依赖版本说明

## 关键依赖版本要求

### NumPy 版本兼容性问题

**问题描述：**
- `opencv-python 4.8.1.78` 是使用 **NumPy 1.x** 编译的
- 如果环境中安装了 **NumPy 2.x**（如 2.2.6），会导致以下错误：
  ```
  AttributeError: _ARRAY_API not found
  ImportError: numpy.core.multiarray failed to import
  ```

**根本原因：**
- NumPy 2.0 引入了重大的 API 变更（Breaking Changes）
- 用 NumPy 1.x 编译的二进制模块无法在 NumPy 2.x 环境中运行
- OpenCV 4.8.1.78 尚未支持 NumPy 2.x

**解决方案：**
1. **必须使用 NumPy 1.26.4**（在 `requirements.txt` 中已指定）
2. **不要升级到 NumPy 2.x**

### OpenCV 版本说明

**不要同时安装多个 OpenCV 包：**
- ✅ **使用**: `opencv-python==4.8.1.78`（带 GUI 支持）
- ❌ **不要安装**: `opencv-python-headless`（会冲突）

**原因：**
- `opencv-python` 和 `opencv-python-headless` 会相互冲突
- `opencv-python-headless 4.12.0.88` 要求 NumPy >= 2.0，与我们的要求冲突

## 依赖版本锁定

### requirements.txt（必须严格遵守）
```
flask==3.0.0
flask-login==0.6.3
flask-sqlalchemy==3.1.1
faiss-cpu==1.11.0
opencv-python==4.8.1.78
pillow==10.4.0
numpy==1.26.4              # ← 关键：必须 1.x
scikit-learn==1.7.2
werkzeug==3.0.1
python-multipart==0.0.6
sqlalchemy==2.0.23
onnxruntime==1.23.1
insightface==0.7.3
```

### requirements.lock（自动生成）
- 由 `pip freeze` 生成
- 必须确保 `numpy==1.26.4`
- 必须确保不包含 `opencv-python-headless`

## 自动化修复机制

### 准备离线包时（prepare-super-package.ps1）
脚本会自动：
1. ✅ 检查当前虚拟环境的 NumPy 版本
2. ✅ 检测是否存在 `opencv-python-headless`
3. ✅ 如果发现问题，自动修复：
   - 卸载 `opencv-python-headless`
   - 降级 NumPy 到 1.26.4
4. ✅ 导出修复后的依赖到 `requirements.lock`

### 部署时（一键完整部署.bat）
脚本会自动：
1. ✅ 安装依赖后验证 NumPy 版本
2. ✅ 检测并卸载 `opencv-python-headless`
3. ✅ 如果 NumPy 是 2.x，自动降级到 1.26.4
4. ✅ 确保环境兼容性

## 常见问题

### Q1: 为什么不能使用 NumPy 2.x？
**A:** OpenCV 4.8.1.78 是用 NumPy 1.x 编译的，二进制不兼容。要使用 NumPy 2.x，需要等 OpenCV 发布用 NumPy 2.x 编译的新版本。

### Q2: 如何手动修复已有环境？
**A:** 如果已经安装了错误版本，执行：
```powershell
# 卸载冲突的包
python -m pip uninstall -y opencv-python-headless

# 降级 NumPy
python -m pip install numpy==1.26.4
```

### Q3: 为什么会自动安装 opencv-python-headless？
**A:** 某些依赖包（如 `albumentations`、`insightface`）可能会引入 `opencv-python-headless` 作为传递依赖。我们的自动化脚本会检测并移除它。

### Q4: 未来如何升级到 NumPy 2.x？
**A:** 需要同时升级 OpenCV：
1. 等待 OpenCV 发布用 NumPy 2.x 编译的版本（如 opencv-python >= 4.10.0）
2. 同时更新 `requirements.txt`：
   ```
   opencv-python>=4.10.0  # 假设支持 NumPy 2.x
   numpy>=2.0.0
   ```
3. 重新测试所有功能

## 技术细节

### NumPy 2.0 的主要变更
- 移除了 `numpy.core.multiarray` 模块
- 引入了新的 `_ARRAY_API`
- C API 发生重大变化
- 需要重新编译所有 C/C++ 扩展模块

### 兼容性建议
对于生产环境：
- ✅ 使用严格版本锁定（`package==version`）
- ✅ 定期验证依赖兼容性
- ✅ 在 CI/CD 中测试完整的依赖安装
- ❌ 避免使用版本范围（`package>=version`）

## 更新记录

- **2025-10-16**: 识别并修复 NumPy 2.x 兼容性问题
  - 添加自动版本检测和修复
  - 更新所有部署脚本
  - 锁定 numpy==1.26.4
