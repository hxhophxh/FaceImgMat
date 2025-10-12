# FaceImgMat v1.0 - 首次发布

## 📦 发布内容

### 🎯 项目简介
FaceImgMat 是一个基于 InsightFace + FAISS 的高性能人脸识别系统，支持人脸录入、搜索和管理。

### ✨ 主要特性
- ✅ 高精度人脸识别（基于 InsightFace buffalo_l 模型）
- ✅ 快速人脸搜索（FAISS 向量索引）
- ✅ 完整的人脸数据管理（增删改查）
- ✅ Web 界面操作（Flask + Bootstrap）
- ✅ 多种部署方式（在线/离线/超级离线）

---

## 📥 下载说明

### 方案 1️⃣: 用户包（推荐 - 轻量级）
**适合**: 已安装 Python 的用户，或能访问互联网的环境

**下载文件**:
- `FaceImgMat-用户包-最终版.zip` (33 KB)
- `FaceImgMat-用户包-精简版.zip` (33 KB)

**使用方法**:
1. 下载并解压 ZIP 文件
2. 阅读 `开始阅读.txt` 
3. 运行 `一键完整部署.bat`（会自动安装 Python 和依赖）
4. 访问 http://localhost:5000

**优点**: 
- 文件小，下载快速
- 自动安装最新版 Python 和依赖
- 适合在线环境

---

### 方案 2️⃣: 超级离线部署包（完整包）
**适合**: 完全隔离的内网环境，目标机器**没有安装任何东西**

**下载文件**:
- `FaceImgMat-超级离线部署包-v1.0.zip` (782 MB) ⬅️ **本 Release 附件**

**包含内容**:
- ✅ Python 3.12.7 安装包 (50 MB)
- ✅ 所有 Python 依赖包 (176 MB) - 54 个 .whl 文件
- ✅ AI 模型文件 (601 MB) - InsightFace buffalo_l 模型
- ✅ 完整项目源码 (11 MB)
- ✅ 详细使用说明

**使用方法**:
1. 下载 `FaceImgMat-超级离线部署包-v1.0.zip` (782 MB)
2. 通过 U盘/内网 传输到目标机器
3. 解压后运行 `一键完整部署.bat`
4. 访问 http://localhost:5000

**优点**:
- 零网络依赖，完全离线
- 包含所有必需文件
- 适合内网/隔离环境

---

### 方案 3️⃣: 源码克隆（开发者）
**适合**: 开发者或需要自定义的用户

```bash
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
pip install -r requirements.txt
python run.py
```

---

## 🔧 技术栈

- **后端**: Flask 3.0.3
- **AI 框架**: InsightFace (buffalo_l 模型)
- **向量搜索**: FAISS 1.9.0
- **数据库**: SQLite
- **前端**: Bootstrap 5.3

---

## 📋 系统要求

### 最低配置
- **操作系统**: Windows 10/11 (64位)
- **内存**: 4GB RAM
- **磁盘空间**: 2GB 可用空间
- **Python**: 3.10 - 3.12 (超级离线包会自动安装)

### 推荐配置
- **内存**: 8GB+ RAM
- **处理器**: 4核+ CPU
- **GPU**: 可选（InsightFace 支持 GPU 加速）

---

## 📖 快速开始

### 5 分钟上手指南

1. **下载选择**
   - 在线环境: 下载 `FaceImgMat-用户包-最终版.zip` (33 KB)
   - 离线环境: 下载 `FaceImgMat-超级离线部署包-v1.0.zip` (782 MB)

2. **解压并运行**
   ```cmd
   解压 ZIP 文件
   双击运行: 一键完整部署.bat
   等待安装完成（3-10分钟）
   ```

3. **访问系统**
   ```
   浏览器打开: http://localhost:5000
   默认账号: admin
   默认密码: admin123
   ```

4. **开始使用**
   - 导入人脸图片
   - 上传照片进行搜索
   - 管理人脸数据

---

## 🔒 安全建议

⚠️ **首次登录后请立即修改管理员密码！**

修改密码方法：
```cmd
cd FaceImgMat
python scripts\change_admin_password.py
```

---

## 📚 文档导航

- **快速开始**: 查看 `user-package/开始阅读.txt`
- **详细手册**: 查看 `user-package/详细使用手册.txt`
- **部署指南**: 查看 `DEPLOYMENT-QUICK-REFERENCE.md`
- **项目结构**: 查看 `docs/PROJECT-STRUCTURE.md`
- **安全指南**: 查看 `docs/SECURITY.md`

---

## 🐛 问题反馈

如遇到问题，请提供以下信息：
- 操作系统版本
- Python 版本（如已安装）
- 错误截图或日志文件 (`logs/app.log`)
- 详细的操作步骤

提交 Issue: https://github.com/hxhophxh/FaceImgMat/issues

---

## 📝 更新日志

### v1.0 (2025-10-12)
- 🎉 首次发布
- ✅ 完整的人脸识别功能
- ✅ Web 界面管理
- ✅ 三种部署方案（在线/离线/超级离线）
- ✅ 完善的文档和脚本
- ✅ 开箱即用的用户包

---

## 👥 贡献者

感谢所有为本项目做出贡献的开发者！

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 🌟 支持项目

如果这个项目对您有帮助，请给我们一个 ⭐ Star！

---

**祝您使用愉快！** 🎊
