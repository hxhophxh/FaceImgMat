# 📦 创建 GitHub Release 操作指南

## 🎯 目标
将超级离线部署包（782 MB）上传到 GitHub Release，供用户下载。

---

## 📋 准备工作

### ✅ 已完成
- [x] 压缩包已创建: `FaceImgMat-超级离线部署包-v1.0.zip` (782 MB)
- [x] Release 文档已提交到仓库
- [x] 代码已推送到 GitHub

### 📍 文件位置
```
D:\test\FaceImgMat\FaceImgMat-超级离线部署包-v1.0.zip (782 MB)
```

---

## 🚀 创建 Release 步骤

### 方法 1: 通过 GitHub 网页界面（推荐）

#### 步骤 1: 进入 Releases 页面
1. 打开浏览器，访问: https://github.com/hxhophxh/FaceImgMat
2. 点击右侧的 **"Releases"** 链接
   - 或直接访问: https://github.com/hxhophxh/FaceImgMat/releases

#### 步骤 2: 创建新 Release
1. 点击 **"Create a new release"** 或 **"Draft a new release"** 按钮

#### 步骤 3: 填写 Release 信息

**Tag version (标签版本):**
```
v1.0.0
```
- 点击 "Choose a tag" 下拉框
- 输入 `v1.0.0`
- 点击 "Create new tag: v1.0.0 on publish"

**Release title (发布标题):**
```
FaceImgMat v1.0.0 - 首次发布 🎉
```

**Description (描述):**
复制粘贴以下内容（或从 `GITHUB-RELEASE-DESCRIPTION.md` 复制）:

```markdown
# 🎉 FaceImgMat v1.0 - 首次发布

基于 InsightFace + FAISS 的高性能人脸识别系统

## 📥 下载指南

### 🎯 方案选择

| 方案 | 文件 | 大小 | 适用场景 |
|------|------|------|----------|
| **用户包（推荐）** | FaceImgMat-用户包-最终版.zip | 33 KB | 在线环境，可访问互联网 |
| **超级离线包** | FaceImgMat-超级离线部署包-v1.0.zip | 782 MB | 完全隔离内网，无任何依赖 |

### ⚡ 快速开始

**在线环境用户：**
1. 下载 `FaceImgMat-用户包-最终版.zip` (33 KB)
2. 解压后运行 `一键完整部署.bat`
3. 访问 http://localhost:5000

**离线环境用户：**
1. 下载下方附件 `FaceImgMat-超级离线部署包-v1.0.zip` (782 MB)
2. 通过U盘传输到目标机器
3. 解压后运行 `一键完整部署.bat`
4. 访问 http://localhost:5000

**默认账号:** admin / admin123 ⚠️ *首次登录后请修改密码*

## ✨ 主要特性

- ✅ 高精度人脸识别（InsightFace buffalo_l）
- ✅ 快速搜索（FAISS 向量索引）
- ✅ 完整的 CRUD 操作
- ✅ Web 界面管理
- ✅ 开箱即用

## 📦 超级离线包包含

- Python 3.12.7 安装包 (50 MB)
- 54 个 Python 依赖包 (176 MB)
- AI 模型文件 (601 MB)
- 完整项目源码 (11 MB)
- 详细使用说明

## 🔧 系统要求

- Windows 10/11 (64位)
- 4GB+ RAM (推荐 8GB)
- 2GB 可用磁盘空间

## 📚 完整文档

查看仓库中的 [RELEASE-NOTES-v1.0.md](https://github.com/hxhophxh/FaceImgMat/blob/main/RELEASE-NOTES-v1.0.md)

## 🐛 问题反馈

https://github.com/hxhophxh/FaceImgMat/issues

---

**感谢使用！如有帮助请给个 ⭐ Star！**
```

#### 步骤 4: 上传附件文件

1. 找到页面下方的 **"Attach binaries"** 区域
2. 点击或拖拽以下文件到该区域：
   ```
   D:\test\FaceImgMat\FaceImgMat-超级离线部署包-v1.0.zip (782 MB)
   ```
3. 等待文件上传完成（大约需要 5-15 分钟，取决于网速）

#### 步骤 5: 发布 Release

1. 确认所有信息无误
2. 选择选项：
   - ✅ **"Set as the latest release"** (设为最新版本)
   - ⬜ "Set as a pre-release" (不勾选)
3. 点击 **"Publish release"** 绿色按钮

---

### 方法 2: 使用 GitHub CLI（高级用户）

如果您安装了 GitHub CLI (gh)，可以使用命令行：

```powershell
# 进入项目目录
cd D:\test\FaceImgMat

# 创建 Release 并上传文件
gh release create v1.0.0 `
  --title "FaceImgMat v1.0.0 - 首次发布 🎉" `
  --notes-file GITHUB-RELEASE-DESCRIPTION.md `
  "FaceImgMat-超级离线部署包-v1.0.zip#超级离线部署包 (782 MB)"
```

**注意**: 需要先安装 GitHub CLI: https://cli.github.com/

---

## ✅ 完成后验证

### 1. 检查 Release 页面
访问: https://github.com/hxhophxh/FaceImgMat/releases/tag/v1.0.0

### 2. 确认内容
- ✅ 版本号: v1.0.0
- ✅ 标题: FaceImgMat v1.0.0 - 首次发布 🎉
- ✅ 描述: 完整的使用说明
- ✅ 附件: FaceImgMat-超级离线部署包-v1.0.zip (782 MB)

### 3. 测试下载
- 点击附件链接，确认可以下载
- 下载速度应该比 Git LFS 快

---

## 📝 下载链接

Release 创建成功后，用户可以通过以下方式下载：

### 直接下载链接（Release 创建后获取）
```
https://github.com/hxhophxh/FaceImgMat/releases/download/v1.0.0/FaceImgMat-超级离线部署包-v1.0.zip
```

### 在 README 中添加下载按钮
```markdown
[![下载超级离线包](https://img.shields.io/badge/下载-超级离线包%20(782MB)-blue?style=for-the-badge)](https://github.com/hxhophxh/FaceImgMat/releases/download/v1.0.0/FaceImgMat-超级离线部署包-v1.0.zip)
```

---

## 🎯 用户使用流程

### 场景 1: 在线环境用户
1. 访问 GitHub 仓库首页
2. 下载 `FaceImgMat-用户包-最终版.zip` (33 KB)
3. 直接使用

### 场景 2: 离线环境用户
1. 访问 Releases 页面
2. 下载 `FaceImgMat-超级离线部署包-v1.0.zip` (782 MB)
3. 通过 U盘 传输到目标机器
4. 解压使用

---

## 🔄 未来更新

### 创建新版本 Release (v1.1, v1.2 等)

1. 修改代码并提交
2. 创建新的 Tag (如 v1.1.0)
3. 准备新的离线部署包
4. 重复上述 Release 创建步骤
5. 更新 Release Notes

---

## ⚠️ 注意事项

1. **文件大小限制**: GitHub Release 单个文件最大 2GB（当前 782 MB 符合要求）
2. **上传时间**: 大文件上传需要时间，请耐心等待
3. **网络稳定**: 确保网络连接稳定，避免上传中断
4. **文件命名**: 使用清晰的文件名，包含版本号
5. **描述清晰**: 在 Release 描述中明确说明各个文件的用途

---

## 🆘 常见问题

### Q: 上传太慢怎么办？
A: 可以考虑：
- 使用更快的网络连接
- 分多个较小的文件上传
- 使用国内的镜像服务（如 Gitee）

### Q: 可以上传多个文件吗？
A: 可以！在 "Attach binaries" 区域可以上传多个文件。

### Q: 如何修改已发布的 Release？
A: 进入 Release 页面，点击 "Edit release" 按钮即可编辑。

### Q: 如何删除 Release？
A: 进入 Release 页面，点击 "Delete" 按钮（需要管理员权限）。

---

## 📞 需要帮助？

如果在创建 Release 过程中遇到问题，可以：
1. 查看 GitHub 官方文档: https://docs.github.com/en/repositories/releasing-projects-on-github
2. 提交 Issue 寻求帮助
3. 联系项目维护者

---

**祝发布顺利！** 🎊
