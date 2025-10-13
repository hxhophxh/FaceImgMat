# 🛡️ 安全声明 / Security Notice

## 关于防病毒软件误报

### ⚠️ 常见误报情况

如果您从 GitHub 下载本项目的 ZIP 包时，Windows Defender 或其他防病毒软件可能会报警，提示检测到 `Trojan:Script/Wacatac.B!ml` 或类似威胁。

**这是误报！** ❌

### 📋 误报原因分析

防病毒软件将本项目标记为可疑的主要原因：

1. **批处理脚本自动安装软件**
   - `一键完整部署.bat` 包含静默安装 Python 的命令
   - 使用 `/quiet` 参数进行无人值守安装
   - 这是合法的自动化部署方式

2. **PowerShell 脚本下载文件**
   - `prepare-super-package.ps1` 使用 `Start-BitsTransfer` 下载 Python 安装程序
   - 从官方镜像源下载依赖包
   - 所有下载源都是可信任的（python.org、清华大学镜像、华为云镜像等）

3. **自动化部署特征**
   - 创建虚拟环境
   - 安装依赖包
   - 启动 Web 服务
   - 这些都是标准的 Python 项目部署流程

### ✅ 安全保证

本项目是**完全开源**的，您可以：

1. **检查所有源代码**
   - 所有脚本都可以在 GitHub 上查看
   - 代码透明，没有任何恶意行为

2. **验证下载来源**
   ```powershell
   # prepare-super-package.ps1 中的下载源：
   - 华为云镜像: https://repo.huaweicloud.com/python/
   - 淘宝镜像: https://registry.npmmirror.com/-/binary/python/
   - 清华大学镜像: https://mirrors.tuna.tsinghua.edu.cn/python-releases/
   - Python 官方: https://www.python.org/ftp/python/
   ```

3. **手动执行部署步骤**
   - 如果担心自动脚本，可以按照文档手动部署
   - 参见 `docs/DETAILED-README.md`

### 🔍 如何验证项目安全性

#### 方法 1：检查脚本内容

使用文本编辑器打开以下文件，检查其内容：

- `super-offline-deployment/一键完整部署.bat`
- `super-offline-deployment/prepare-super-package.ps1`
- `super-offline-deployment/准备超级离线包.bat`

您会看到所有操作都是标准的 Python 项目部署流程。

#### 方法 2：使用 VirusTotal 多引擎扫描

访问 [VirusTotal.com](https://www.virustotal.com/) 上传脚本文件进行多引擎扫描，大多数引擎都会显示安全。

#### 方法 3：查看 GitHub 历史记录

所有代码修改都有完整的提交历史，可追溯每一行代码的来源。

### 🚀 如何处理误报

#### 选项 1：添加到白名单（推荐）

**Windows Defender:**
1. 打开 "Windows 安全中心"
2. 进入 "病毒和威胁防护" > "管理设置"
3. 滚动到 "排除项" > "添加或删除排除项"
4. 添加整个项目文件夹

**其他杀毒软件:**
- 根据软件说明添加到信任区或白名单

#### 选项 2：手动部署

如果您不信任自动脚本，可以手动执行以下步骤：

```bash
# 1. 安装 Python 3.12
从 python.org 下载并安装

# 2. 克隆项目
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 3. 创建虚拟环境
python -m venv .venv
.venv\Scripts\activate

# 4. 安装依赖
pip install -r requirements.txt

# 5. 运行项目
python run.py
```

#### 选项 3：从源码构建

```bash
# 克隆仓库而不是下载 ZIP
git clone https://github.com/hxhophxh/FaceImgMat.git
```

Git 克隆的文件通常不会被误报，因为没有经过 ZIP 压缩。

### 📞 联系方式

如果您对项目安全性有任何疑问，欢迎：

- 在 GitHub 上提出 Issue
- 查看完整的源代码审查
- 联系项目维护者

### 🔐 最佳实践

1. **始终从官方 GitHub 仓库下载**
   - 官方地址：https://github.com/hxhophxh/FaceImgMat

2. **验证代码完整性**
   - 使用 `git clone` 而不是下载 ZIP
   - 检查提交签名和历史记录

3. **在虚拟环境中运行**
   - 项目使用 Python 虚拟环境
   - 不会影响系统全局环境

4. **定期更新**
   - 关注项目更新
   - 及时获取安全补丁

---

## 📝 技术说明

### 脚本功能概述

#### `一键完整部署.bat`
- **功能**：自动部署 Python 和项目依赖
- **操作**：
  - 检查 Python 是否已安装
  - 静默安装 Python（如需要）
  - 创建虚拟环境
  - 安装依赖包
  - 启动服务

#### `prepare-super-package.ps1`
- **功能**：准备离线部署包
- **操作**：
  - 下载 Python 安装程序
  - 复制项目源码
  - 下载依赖包
  - 复制 AI 模型

#### `准备超级离线包.bat`
- **功能**：批处理启动器
- **操作**：
  - 调用 PowerShell 脚本
  - 处理编码问题

### 使用的命令说明

```powershell
# 1. Python 静默安装（批处理）
"%PYTHON_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1

# 2. 下载文件（PowerShell）
Start-BitsTransfer -Source $url -Destination $path

# 3. 创建虚拟环境
python -m venv .venv

# 4. 安装依赖
pip install -r requirements.txt
```

所有命令都是标准的、合法的 Python 开发和部署操作。

---

## ✨ 总结

- ✅ 本项目是**完全安全**的开源项目
- ✅ 所有代码都是**公开透明**的
- ✅ 防病毒软件的警告是**误报**
- ✅ 您可以**完全信任**本项目

如果您仍有疑虑，建议采用手动部署方式或在隔离环境中测试。

---

**最后更新**: 2025-10-14  
**项目地址**: https://github.com/hxhophxh/FaceImgMat  
**License**: MIT
