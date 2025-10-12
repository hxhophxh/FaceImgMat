# 📦 FaceImgMat v1.0 - 发布包说明

## 🎯 发布内容

### 轻量级部署包（推荐）

**文件名：** `FaceImgMat-轻量级部署包-v1.0.zip`  
**大小：** ~70KB（压缩后）  
**适用：** 有网络连接的环境  

**使用方法：**
1. 解压到任意目录
2. 进入 `super-offline-deployment` 目录
3. 双击运行 `准备超级离线包.bat`（下载依赖，15-25分钟）
4. 双击运行 `一键完整部署.bat`（部署系统，15-20分钟）

---

## 📥 下载方式

### 方式1：从 GitHub Releases 下载

访问：https://github.com/hxhophxh/FaceImgMat/releases/tag/v1.0

下载：`FaceImgMat-轻量级部署包-v1.0.zip`

### 方式2：从 GitHub 克隆仓库

```bash
# 克隆完整仓库
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat/super-offline-deployment

# 运行准备脚本
.\准备超级离线包.bat

# 运行部署脚本
.\一键完整部署.bat
```

---

## 📦 完整离线包（需自行准备）

如果您的目标环境**完全无法联网**，需要在有网络的机器上准备完整离线包：

### 准备步骤：

```powershell
# 1. 下载或克隆本仓库
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat/super-offline-deployment

# 2. 运行准备脚本（需要网络）
.\准备超级离线包.bat
# 等待 15-25 分钟，下载约 2GB 文件

# 3. 压缩整个目录
cd ..
Compress-Archive -Path "super-offline-deployment" `
                 -DestinationPath "FaceImgMat-完整离线包.zip"

# 4. 传输到目标机器
# 通过 U盘、内网共享等方式
```

### 使用完整离线包：

```powershell
# 1. 在目标机器解压
Expand-Archive -Path "FaceImgMat-完整离线包.zip" -DestinationPath "D:\FaceImgMat"

# 2. 进入目录
cd D:\FaceImgMat\super-offline-deployment

# 3. 直接运行部署脚本
.\一键完整部署.bat
# 等待 15-20 分钟，全程离线
```

---

## 🚀 快速开始

### 第1步：下载部署包

- 有网环境：下载 `FaceImgMat-轻量级部署包-v1.0.zip` (~70KB)
- 离线环境：自行准备完整离线包 (~2GB)

### 第2步：解压

```powershell
# 解压到任意目录，例如
Expand-Archive -Path "FaceImgMat-轻量级部署包-v1.0.zip" `
               -DestinationPath "D:\FaceImgMat"
```

### 第3步：部署

```powershell
# 进入目录
cd D:\FaceImgMat\super-offline-deployment

# 有网环境：先准备后部署
.\准备超级离线包.bat    # 第1步
.\一键完整部署.bat       # 第2步

# 离线环境（已有完整包）：直接部署
.\一键完整部署.bat       # 一步到位
```

### 第4步：访问系统

部署完成后浏览器会自动打开：

```
🔗 地址：http://127.0.0.1:5000
👤 账号：admin
🔑 密码：Admin@FaceMatch2025!
```

⚠️ **首次登录后请立即修改密码！**

---

## 📖 详细文档

解压后在 `super-offline-deployment` 目录中查看：

- **【开始阅读】.txt** - 快速入门（必读！）
- **README-USER.md** - 用户使用指南
- **用户使用说明.txt** - 详细操作手册
- **00-使用说明/** - 帮助文档目录
  - 如何获取依赖文件.md
  - 完整使用流程.md
  - 快速开始.txt

---

## 💻 系统要求

### 最低配置
- **操作系统**：Windows 10/11（64位）
- **内存**：2GB
- **磁盘空间**：5GB
- **网络**：准备阶段需要（部署阶段可离线）

### 推荐配置
- **操作系统**：Windows 11
- **内存**：4GB+
- **磁盘空间**：10GB+
- **处理器**：四核或更好

---

## ⏱️ 时间说明

| 步骤 | 时间 | 网络要求 |
|------|------|----------|
| 准备离线包 | 15-25分钟 | ✅ 需要 |
| 部署系统 | 15-20分钟 | ❌ 不需要 |
| **总计** | **30-45分钟** | 准备时需要 |

---

## 📊 文件大小

| 类型 | 大小 | 说明 |
|------|------|------|
| 轻量级包 | ~70KB | 只含脚本和文档 |
| 完整离线包 | ~2GB | 含所有依赖和模型 |
| 压缩后 | ~500MB | 完整包压缩 |

---

## ❓ 常见问题

### Q1: 轻量级包和完整离线包的区别？

**A:** 
- **轻量级包**：只包含脚本和文档，需要网络下载依赖（约2GB）
- **完整离线包**：包含所有文件，可完全离线部署

### Q2: 我应该选哪个？

**A:**
- 目标机器**有网络** → 选轻量级包（下载快）
- 目标机器**无网络** → 需准备完整离线包

### Q3: 可以在多台机器使用吗？

**A:** 可以！准备一次完整离线包后，可以传输到多台机器使用。

### Q4: 部署失败了怎么办？

**A:** 
1. 查看 `super-offline-deployment/README-USER.md`
2. 查看 `00-使用说明/` 目录中的帮助文档
3. 检查系统要求和磁盘空间
4. 可以重复运行脚本

### Q5: 如何卸载？

**A:** 运行 `super-offline-deployment/卸载清理.bat`

---

## 🔧 技术支持

- **文档**：查看 super-offline-deployment 目录中的文档
- **问题反馈**：https://github.com/hxhophxh/FaceImgMat/issues
- **源码**：https://github.com/hxhophxh/FaceImgMat

---

## 📝 版本信息

- **版本**：v1.0
- **发布日期**：2025-10-12
- **Python 版本**：3.12.7
- **主要功能**：
  - ✅ 人脸识别和比对
  - ✅ 人脸库管理
  - ✅ 批量导入导出
  - ✅ Web 界面操作
  - ✅ 完全离线部署支持

---

## 🎉 开始使用

1. 📥 下载 `FaceImgMat-轻量级部署包-v1.0.zip`
2. 📂 解压到任意目录
3. 📖 打开 `super-offline-deployment/【开始阅读】.txt`
4. 🚀 按步骤操作
5. ✅ 完成！

**祝您使用愉快！** 🎊
