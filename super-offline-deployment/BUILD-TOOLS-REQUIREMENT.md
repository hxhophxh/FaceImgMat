# Visual Studio Build Tools 安装要求

## 概述

在准备 FaceImgMat 超级离线包时，需要安装 **Visual Studio Build Tools 2022**，因为某些 Python 依赖包（特别是包含 C/C++ 扩展的包）在下载时需要编译工具。

## 为什么需要 Build Tools？

许多 Python 包（如 numpy、scipy、opencv 等）包含原生 C/C++ 代码，需要编译才能在 Windows 上运行。虽然 PyPI 提供了预编译的 wheel 包（.whl），但在某些情况下，pip 仍然需要编译环境来处理这些包的依赖。

## 安装步骤

### 1. 下载 Build Tools for Visual Studio 2022

访问官方下载页面：
```
https://visualstudio.microsoft.com/downloads/
```

向下滚动到 **"All Downloads"** 部分，找到 **"Tools for Visual Studio"**，下载：
- **Build Tools for Visual Studio 2022**

### 2. 安装必需组件

运行下载的安装程序后，**必须选择以下工作负载和组件**：

#### 主要工作负载
- ✅ **使用 C++ 的桌面开发** (Desktop development with C++)
  - 也称为 "C++ build tools"

#### 必需的单独组件
在 "单独组件" 选项卡中，确保勾选：
- ✅ **Windows 11 SDK** (或 Windows 10 SDK 的最新版本)
- ✅ **MSVC v143 - VS 2022 C++ x64/x86 生成工具**（通常会自动选中）
- ✅ **C++ CMake tools for Windows**（推荐）

### 3. 完成安装

- 安装大小约 **6-8 GB**
- 安装时间约 **10-20 分钟**（取决于网速和机器性能）

### 4. 验证安装

安装完成后，可以通过以下方式验证：

```powershell
# 检查 Visual Studio 安装路径
dir "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

# 或者
dir "C:\Program Files\Microsoft Visual Studio\2022\BuildTools"

# 检查 Windows SDK
dir "C:\Program Files (x86)\Windows Kits\10"
```

或者直接运行 `准备超级离线包.bat`，脚本会自动检测并提示安装结果。

## 常见问题

### Q1: 我已经安装了 Visual Studio Community/Professional，还需要安装 Build Tools 吗？

**不需要**。如果您已经安装了 Visual Studio 2022 的完整版本（Community、Professional 或 Enterprise），并且包含了 C++ 开发工作负载，那么 Build Tools 已经包含在内了。

### Q2: 可以使用其他版本的 Visual Studio 吗？

建议使用 **Visual Studio 2022**。虽然 VS 2019 也可能工作，但某些新的 Python 包可能需要更新的编译工具。

### Q3: 为什么有些包还是下载失败？

可能的原因：
1. **Build Tools 未正确安装** - 确保勾选了所有必需组件
2. **环境变量未更新** - 重启终端或重新启动电脑
3. **PyPI 镜像源问题** - 脚本会自动尝试多个镜像源

### Q4: 我不想安装这么大的工具，有其他办法吗？

可以尝试：
1. 只下载 wheel 包（.whl）- 脚本已经配置为优先下载预编译包
2. 在已经安装了 Build Tools 的机器上运行准备脚本
3. 使用虚拟机或 Docker 环境

## 技术说明

### 受影响的常见 Python 包

以下包通常需要编译环境：
- `numpy` - 数值计算库
- `scipy` - 科学计算库  
- `opencv-python` - 计算机视觉库
- `Pillow` - 图像处理库
- `onnxruntime` - AI 模型推理引擎
- 其他包含 C/C++ 扩展的包

### pip download 命令说明

脚本使用的下载命令：
```bash
pip download -r requirements.txt \
    --dest 03-Python依赖包 \
    --prefer-binary \
    --python-version 3.12 \
    --only-binary=:all:
```

参数说明：
- `--prefer-binary`: 优先下载预编译的 wheel 包
- `--only-binary=:all:`: 仅下载二进制包，不编译源码
- `--python-version 3.12`: 指定目标 Python 版本

## 相关链接

- [Visual Studio 下载页面](https://visualstudio.microsoft.com/downloads/)
- [Build Tools 文档](https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container)
- [Python Windows 编译指南](https://wiki.python.org/moin/WindowsCompilers)

## 更新日志

- **2025-10-14**: 添加 Visual Studio Build Tools 检测和安装说明
- **2025-10-14**: 修复批处理文件编码问题（改用 ANSI + CRLF）
