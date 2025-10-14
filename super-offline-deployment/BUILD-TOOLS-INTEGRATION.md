# Build Tools 自动安装集成说明

## 更新内容

已将 **Visual Studio Build Tools 2022** 的下载和安装整合到超级离线包准备流程中。

## 新增功能

### 1. 自动下载 Build Tools 安装程序

运行 `准备超级离线包.bat` 时：
- 脚本会自动检测当前机器是否安装了 Visual Studio Build Tools 2022
- 如果未安装，会提示是否下载 Build Tools 安装程序到离线包中
- 下载的文件约 3-4 MB（仅安装程序，不包含组件）

### 2. 新增目录结构

```
super-offline-deployment/
├── 00-编译工具/              ← 新增目录
│   ├── vs_BuildTools.exe     ← Build Tools 安装程序
│   ├── .vsconfig            ← 自动配置文件
│   ├── 自动安装BuildTools.bat ← 一键安装脚本
│   └── 安装说明.txt          ← 详细说明文档
├── 01-Python安装包/
├── 02-项目源码/
├── 03-Python依赖包/
└── 04-AI模型文件/
```

### 3. 自动配置文件 (.vsconfig)

包含必需组件的配置：
- Microsoft.VisualStudio.Workload.VCTools（C++ 工作负载）
- Microsoft.VisualStudio.Component.VC.Tools.x86.x64（C++ 编译器）
- Microsoft.VisualStudio.Component.Windows11SDK.22000（Windows SDK）
- Microsoft.VisualStudio.Component.VC.CMake.Project（CMake 工具）

### 4. 一键安装脚本

提供 `自动安装BuildTools.bat`，可以：
- 自动检测管理员权限
- 使用 .vsconfig 配置文件静默安装
- 仅安装必需的组件（约 6-8 GB）
- 避免安装完整的 Visual Studio

## 使用流程

### 在有网络的机器上准备离线包

1. 运行 `准备超级离线包.bat`
2. 当提示检测到未安装 Build Tools 时，选择 `Y` 下载
3. 脚本会自动：
   - 下载 vs_BuildTools.exe
   - 创建 .vsconfig 配置文件
   - 生成自动安装脚本
   - 生成详细的安装说明

### 在离线机器上部署

**方案一：自动安装（推荐）**
```batch
# 1. 首先安装 Build Tools（需要网络）
cd 00-编译工具
以管理员身份运行 "自动安装BuildTools.bat"
等待安装完成（15-30 分钟）

# 2. 然后安装 Python 和部署项目
cd ..
运行 "一键完整部署.bat"
```

**方案二：手动安装**
```batch
# 1. 手动安装 Build Tools
cd 00-编译工具
双击 vs_BuildTools.exe
按照界面提示选择：
  - 使用 C++ 的桌面开发
  - Windows 11 SDK

# 2. 部署项目
cd ..
运行 "一键完整部署.bat"
```

## 重要说明

### Build Tools 安装特点

1. **需要网络连接**
   - 安装程序（vs_BuildTools.exe）只有 3-4 MB
   - 实际组件需要从微软服务器下载（6-8 GB）
   - 即使在"离线"环境，安装 Build Tools 时仍需联网

2. **为什么不能真正离线？**
   - Build Tools 的安装包非常大（约 6-8 GB）
   - 微软不提供完整的离线安装包下载
   - 即使下载了完整包，也需要定期更新

3. **替代方案**
   - 如果目标机器完全离线，建议：
     - 在能联网的机器上安装 Build Tools
     - 然后下载 Python 依赖包（已编译的 wheel 包）
     - 将依赖包复制到离线机器

### 安装 Build Tools 的时机

**推荐时机：在准备离线包时**
- 准备离线包的机器通常有网络
- 可以正确下载所有需要编译的依赖包
- 生成的 wheel 包可以在任何 Windows 机器上使用

**不推荐：在部署时才安装**
- 如果目标机器离线，无法下载 Build Tools 组件
- 会导致部署失败

## 技术细节

### .vsconfig 文件格式

```json
{
  "version": "1.0",
  "components": [
    "Microsoft.VisualStudio.Workload.VCTools",
    "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "Microsoft.VisualStudio.Component.Windows11SDK.22000",
    "Microsoft.VisualStudio.Component.VC.CMake.Project"
  ]
}
```

### 自动安装命令

```batch
vs_BuildTools.exe --quiet --wait --norestart --nocache --config .vsconfig
```

参数说明：
- `--quiet`: 静默安装（无界面）
- `--wait`: 等待安装完成
- `--norestart`: 完成后不自动重启
- `--nocache`: 不缓存安装文件
- `--config .vsconfig`: 使用配置文件

### 检测安装是否成功

检查以下路径是否存在：
```
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC
C:\Program Files (x86)\Windows Kits\10
```

或运行命令：
```cmd
where cl
```

如果返回 cl.exe 的路径，说明安装成功。

## 常见问题

### Q: 为什么 Build Tools 不能完全离线？

A: 微软的设计决定。Build Tools 采用组件化安装，需要从服务器下载具体组件。虽然可以创建"本地布局"（local layout），但：
- 需要 30+ GB 空间
- 需要特殊命令创建
- 维护复杂
- 对于本项目来说过于臃肿

### Q: 如果目标机器真的完全离线怎么办？

A: 两种方案：

**方案1：使用预编译包**
- 在联网机器上运行 `准备超级离线包.bat`
- 确保该机器已安装 Build Tools
- 脚本会下载所有预编译的 wheel 包
- 这些 wheel 包可以在没有 Build Tools 的机器上安装

**方案2：提前安装 Build Tools**
- 在目标机器联网时先安装 Build Tools
- 安装完成后可以断网
- 然后部署 FaceImgMat 项目

### Q: 能否跳过 Build Tools？

A: 可以尝试，但可能遇到问题：
- 大部分依赖包都提供了 wheel 格式（预编译）
- 但某些包可能只有源码格式（需要编译）
- 如果所有包都有 wheel，可以跳过 Build Tools
- 脚本已优化为优先下载 wheel 包

### Q: Build Tools 占用多少空间？

A: 
- 安装程序：3-4 MB
- 最小安装（仅 C++ tools + SDK）：6-8 GB
- 完整安装（所有组件）：30+ GB
- 本脚本只安装必需组件（6-8 GB）

## 更新日志

- **2025-10-14**: 
  - 集成 Build Tools 下载到准备流程
  - 添加自动安装脚本和配置文件
  - 创建详细的安装说明文档
  - 更新步骤从 8 步增加到 9 步
