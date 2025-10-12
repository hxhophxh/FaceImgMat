# 📦 如何在 GitHub 创建 v1.0 Release

## 🎯 步骤概览

1. 访问 GitHub 仓库
2. 创建新的 Release
3. 上传发布文件
4. 发布

---

## 📝 详细步骤

### 第1步：访问 Releases 页面

1. 打开浏览器，访问：
   ```
   https://github.com/hxhophxh/FaceImgMat/releases
   ```

2. 点击右侧的 **"Draft a new release"** 或 **"Create a new release"** 按钮

---

### 第2步：填写 Release 信息

#### Tag 版本
```
v1.0
```
- 点击 **"Choose a tag"**
- 输入 `v1.0`
- 点击 **"Create new tag: v1.0 on publish"**

#### Release 标题
```
FaceImgMat v1.0 - 人脸识别系统首个正式版
```

#### Release 描述

复制以下内容：

```markdown
# 🎉 FaceImgMat v1.0 - 首个正式版本

## ✨ 主要特性

- ✅ **人脸识别和比对**：基于 InsightFace 的高精度人脸识别
- ✅ **人脸库管理**：添加、删除、搜索人脸数据
- ✅ **批量操作**：支持批量导入和匹配
- ✅ **Web 界面**：友好的 Web 操作界面
- ✅ **离线部署**：支持完全离线环境部署
- ✅ **一键部署**：自动化部署脚本，30分钟完成

## 📦 发布内容

### FaceImgMat-轻量级部署包-v1.0.zip (~70KB)

**适用于：** 有网络连接的环境

**包含内容：**
- 所有部署脚本（.bat, .ps1）
- 完整使用文档
- 配置文件和说明

**使用方法：**
1. 下载并解压
2. 进入 `super-offline-deployment` 目录
3. 运行 `准备超级离线包.bat`（下载依赖，15-25分钟）
4. 运行 `一键完整部署.bat`（部署系统，15-20分钟）
5. 访问 http://127.0.0.1:5000

## 🚀 快速开始

### 方式1：使用轻量级包（推荐）

```powershell
# 1. 下载 FaceImgMat-轻量级部署包-v1.0.zip
# 2. 解压
Expand-Archive -Path "FaceImgMat-轻量级部署包-v1.0.zip" -DestinationPath "D:\FaceImgMat"

# 3. 进入目录
cd D:\FaceImgMat\super-offline-deployment

# 4. 运行准备脚本（需要网络）
.\准备超级离线包.bat

# 5. 运行部署脚本
.\一键完整部署.bat
```

### 方式2：从源码部署

```bash
# 1. 克隆仓库
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat/super-offline-deployment

# 2. 运行准备脚本
.\准备超级离线包.bat

# 3. 运行部署脚本
.\一键完整部署.bat
```

## 💻 系统要求

### 最低配置
- Windows 10/11（64位）
- 2GB 内存
- 5GB 磁盘空间

### 推荐配置
- Windows 11
- 4GB+ 内存
- 10GB+ 磁盘空间

## 📖 文档

- [发布说明](RELEASE-v1.0.md)
- [快速开始](super-offline-deployment/【开始阅读】.txt)
- [用户使用指南](super-offline-deployment/README-USER.md)
- [完整使用流程](super-offline-deployment/00-使用说明/完整使用流程.md)

## 🔐 默认登录信息

```
地址：http://127.0.0.1:5000
账号：admin
密码：Admin@FaceMatch2025!
```

⚠️ **首次登录后请立即修改密码！**

## ⏱️ 部署时间

- 准备阶段：15-25分钟（需要网络）
- 部署阶段：15-20分钟（可以离线）
- 总计：30-45分钟

## 🆘 问题反馈

如遇到问题，请：
1. 查看文档：[RELEASE-v1.0.md](RELEASE-v1.0.md)
2. 提交 Issue：https://github.com/hxhophxh/FaceImgMat/issues

## 📊 技术栈

- **后端**：Flask 3.0.0 + Python 3.12.7
- **人脸识别**：InsightFace + ONNX Runtime
- **向量检索**：Faiss
- **数据库**：SQLite
- **前端**：Bootstrap 5

## 🎊 致谢

感谢所有贡献者和用户的支持！

---

**发布日期**：2025-10-12  
**版本号**：v1.0  
**下载量**：待统计
```

---

### 第3步：上传发布文件

在 **"Attach binaries by dropping them here or selecting them."** 区域：

1. 点击或拖拽上传文件
2. 上传文件：
   - `FaceImgMat-轻量级部署包-v1.0.zip` (位于项目根目录)

---

### 第4步：发布

1. 确认所有信息无误
2. 选择 **"Set as the latest release"** (设为最新版本)
3. 点击 **"Publish release"** 按钮

---

## ✅ 发布后

### 验证发布

访问：https://github.com/hxhophxh/FaceImgMat/releases/tag/v1.0

应该看到：
- ✅ Release 标题和描述
- ✅ 可下载的 `FaceImgMat-轻量级部署包-v1.0.zip`
- ✅ 自动生成的 Source code (zip) 和 (tar.gz)

### 分享链接

发布后，可以分享以下链接：

- **Release 页面**：https://github.com/hxhophxh/FaceImgMat/releases/tag/v1.0
- **下载链接**：https://github.com/hxhophxh/FaceImgMat/releases/download/v1.0/FaceImgMat-轻量级部署包-v1.0.zip
- **仓库主页**：https://github.com/hxhophxh/FaceImgMat

---

## 📝 Release 管理

### 编辑 Release

如需修改：
1. 访问 Release 页面
2. 点击 **"Edit release"**
3. 修改后点击 **"Update release"**

### 删除 Release

如需删除：
1. 访问 Release 页面
2. 点击 **"Edit release"**
3. 滚动到底部
4. 点击 **"Delete this release"**

---

## 🎯 后续版本

创建新版本时：
1. 修改代码并提交
2. 创建新的 tag（如 v1.1, v2.0）
3. 重复上述步骤创建 Release
4. 在描述中说明更新内容

---

## 💡 提示

1. **Tag 命名规范**：使用语义化版本号（v主版本.次版本.修订号）
2. **Release 描述**：详细说明新功能、修复的问题、重大变更
3. **文件命名**：包含版本号，便于用户识别
4. **Changelog**：列出所有重要的更改
5. **下载说明**：清晰说明每个文件的用途

---

**现在就去创建您的第一个 Release 吧！** 🚀
