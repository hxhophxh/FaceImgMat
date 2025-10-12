# 🚀 FaceImgMat 部署方案 - 完整快速参考

> **三种部署方案**，适应不同场景需求

---

## 📊 部署方案选择指南

| 方案 | 适用场景 | 前置条件 | 传输大小 | 部署时间 |
|------|---------|---------|---------|---------|
| **🌐 在线部署** | 有Python + 有网络 | Python 3.11/3.12 | 几KB | 5-15分钟 |
| **📦 标准离线** | 有Python + 无网络 | Python 3.11/3.12 | ~1.5GB | 2-5分钟 |
| **🎯 超级离线** | 无Python + 可选网络 | 无需任何软件 | 10MB或2GB | 15-40分钟 |

---

## 🎯 方案一：超级离线部署（推荐）

> **适用于**：全新机器、没有Python、完全零依赖  
> **平台**：Windows 10/11  
> **优势**：用户无需任何技术背景，双击即可

### 场景A：用户机器可以暂时联网

**您需要发送：** `super-offline-deployment` 文件夹（~10MB，仅脚本）

**用户操作步骤：**

```batch
# 步骤1: 下载依赖（需要网络，15-20分钟）
双击运行: prepare-super-offline.bat

# 步骤2: 安装部署（离线，15-20分钟）
双击运行: 一键完整部署.bat

# 完成！浏览器自动打开
```

**优势：**
- ✅ 用户自己准备，无需传输大文件
- ✅ 总时间 30-40分钟，但无需您准备
- ✅ 用户可以重复使用（多台机器）

---

### 场景B：用户机器完全离线

**您需要准备：**

```batch
# 在您的有网机器上运行
cd super-offline-deployment
双击: prepare-super-offline.bat

# 等待15-20分钟，生成完整离线包（~2GB）
```

**您需要发送：** `super-offline-deployment` 文件夹（~2GB，已准备好）

**传输方式：**
- 压缩为ZIP：`FaceImgMat-SuperOffline.zip`（~1.5-2GB）
- U盘拷贝
- 网络共享

**用户操作步骤：**

```batch
# 解压（如果是ZIP）
# 进入文件夹

# 一键部署（15-20分钟）
双击运行: 一键完整部署.bat

# 完成！浏览器自动打开
```

**优势：**
- ✅ 用户零操作，一键完成
- ✅ 完全离线可用
- ✅ 自动安装Python 3.12.7

---

### 📁 超级离线部署文件结构

```
super-offline-deployment/
├── 00-使用说明/
│   └── 快速开始.txt              用户指南
├── 01-Python安装包/              [准备后有内容]
│   └── python-3.12.7-amd64.exe   26MB
├── 02-项目源码/                  [准备后有内容]
│   └── FaceImgMat/               完整代码
├── 03-Python依赖包/              [准备后有内容]
│   └── *.whl                     80+个包，500-800MB
├── 04-AI模型文件/                [准备后有内容]
│   └── insightface_models/       325MB
├── prepare-super-offline.bat     ⭐ 准备脚本
├── 一键完整部署.bat               ⭐ 部署脚本
├── 仅部署项目.bat                 （Python已安装时用）
├── 卸载清理.bat                   清理脚本
├── README.md                     详细文档
└── 使用指南.md                    完整说明
```

---

## 🌐 方案二：在线部署

> **适用于**：已安装Python 3.11/3.12，有网络连接  
> **平台**：Windows + Linux/macOS  
> **优势**：最快捷，一条命令搞定

### Windows (PowerShell)

```powershell
# 一条命令完成所有操作
.\deploy_online.ps1

# 预计时间: 5-15分钟（取决于网速）
```

### Linux/macOS (Bash)

```bash
# 一条命令完成所有操作
chmod +x deploy_online.sh && ./deploy_online.sh

# 预计时间: 5-15分钟（取决于网速）
```

### 自动完成的操作

```
✓ 检测Python环境
✓ 创建虚拟环境
✓ 安装所有依赖
✓ 下载AI模型
✓ 初始化数据库
✓ 启动服务
```

---

## 📦 方案三：标准离线部署

> **适用于**：已安装Python 3.11/3.12，但无网络连接  
> **平台**：Windows + Linux/macOS  
> **优势**：快速部署，2-5分钟完成

### Windows 离线部署

**步骤1: 准备离线包（在有网络的机器上）**

```powershell
.\prepare_offline_package.ps1

# 生成: offline-deployment-package/ (~1.5GB)
```

**步骤2: 传输到目标机器后部署**

```powershell
.\deploy_offline.ps1

# 或双击运行: 一键部署并启动.bat
# 预计时间: 2-5分钟
```

### Linux/macOS 离线部署

**步骤1: 准备离线包（在有网络的机器上）**

```bash
chmod +x prepare_offline_package.sh
./prepare_offline_package.sh

# 生成: offline-deployment-package/ (~1.5GB)
```

**步骤2: 传输到目标机器后部署**

```bash
chmod +x deploy_offline.sh
./deploy_offline.sh

# 预计时间: 2-5分钟
```

---

## ✅ 前置条件对比

| 方案 | Python | pip | Git | 网络 | 磁盘空间 |
|------|--------|-----|-----|------|---------|
| 🌐 **在线部署** | ✅ 3.11/3.12 | ✅ | ❌ | ✅ 需要 | 5GB+ |
| 📦 **标准离线** | ✅ 3.11/3.12 | ✅ | ❌ | ❌ 不需要 | 5GB+ |
| 🎯 **超级离线** | ❌ 自动安装 | ❌ 自动安装 | ❌ | ⚠️ 可选 | 5GB+ |

---

## 🌐 访问系统

所有部署方案完成后，访问：

```
地址: http://127.0.0.1:5000
账号: admin
密码: Admin@FaceMatch2025!
```

⚠️ **首次登录后立即修改密码：**

```bash
python scripts/change_admin_password.py
```

---

## 🎯 部署流程图

### 在线部署流程

```
开始 → 运行脚本 → 检查环境 → 下载依赖 → 初始化 → 启动 → 完成
        (1命令)                  (自动)              (5-15分钟)
```

### 标准离线部署流程

```
有网络机器                     无网络机器
    ↓                             ↓
准备离线包 → 压缩 → [传输] → 解压 → 运行脚本 → 完成
(10-20分钟)        (U盘等)          (2-5分钟)
```

### 超级离线部署流程（场景A：用户可联网）

```
用户机器
    ↓
准备依赖 → 一键部署 → 完成
(15-20分钟) (15-20分钟) (30-40分钟总计)
双击脚本1    双击脚本2
```

### 超级离线部署流程（场景B：用户完全离线）

```
您的机器                       用户机器
    ↓                             ↓
准备离线包 → 压缩 → [传输] → 解压 → 一键部署 → 完成
(15-20分钟)        (U盘等)          (15-20分钟)
                                   双击脚本
```

---

## 📋 文件清单

### 根目录脚本（Python已安装场景）

| 文件 | 用途 | 平台 | 需要网络 |
|------|------|------|---------|
| `deploy_online.ps1` | 在线部署 | Windows | ✅ |
| `deploy_online.sh` | 在线部署 | Linux/macOS | ✅ |
| `prepare_offline_package.ps1` | 准备标准离线包 | Windows | ✅ |
| `prepare_offline_package.sh` | 准备标准离线包 | Linux/macOS | ✅ |
| `deploy_offline.ps1` | 标准离线部署 | Windows | ❌ |
| `deploy_offline.sh` | 标准离线部署 | Linux/macOS | ❌ |

### super-offline-deployment/ 目录（零依赖场景）

| 文件 | 用途 | 平台 | 需要网络 |
|------|------|------|---------|
| `prepare-super-offline.bat` | 准备超级离线包 | Windows | ✅ |
| `一键完整部署.bat` | 全自动部署（含Python安装） | Windows | ❌ |
| `仅部署项目.bat` | 快速部署（Python已安装） | Windows | ❌ |
| `卸载清理.bat` | 完整卸载 | Windows | ❌ |

---

## ❓ 常见问题

### Q1: 如何选择部署方案？

**决策树：**

```
用户机器有Python 3.11/3.12吗？
├─ 是 → 有网络吗？
│   ├─ 是 → 🌐 在线部署（最快）
│   └─ 否 → 📦 标准离线部署
│
└─ 否 → 🎯 超级离线部署
    └─ 用户能暂时联网吗？
        ├─ 是 → 发送脚本，用户自己准备（省事）
        └─ 否 → 您准备好再发送（用户一键）
```

### Q2: Windows提示"禁止运行脚本"？

**解决方案：**
- 所有批处理文件（.bat）都会自动处理此问题
- PowerShell脚本（.ps1）已自动设置执行策略
- 如仍有问题，手动运行：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q3: Linux提示"权限被拒绝"？

```bash
chmod +x deploy_online.sh
# 或
chmod +x *.sh
```

### Q4: 网络很慢怎么办？

- 使用**标准离线部署**或**超级离线部署**
- 超级离线支持用户自己准备（如果用户网络好）

### Q5: 端口5000被占用？

修改 `run.py` 中的端口号：

```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)  # 改为其他端口
```

### Q6: 超级离线部署和标准离线有什么区别？

| 对比项 | 标准离线 | 超级离线 |
|--------|---------|---------|
| **需要Python** | ✅ 3.11/3.12 | ❌ 自动安装 |
| **包大小** | ~1.5GB | ~2GB 或 10MB |
| **部署时间** | 2-5分钟 | 15-20分钟 |
| **适用场景** | Python已安装 | 全新机器 |
| **用户技能** | 基础 | 零基础 |

### Q7: 如何验证部署成功？

```bash
# 访问浏览器
http://127.0.0.1:5000

# 能看到登录页面 = 成功
# 使用 admin / Admin@FaceMatch2025! 登录
```

---

## 📚 详细文档

- 📖 [超级离线部署使用指南](super-offline-deployment/使用指南.md)
- 📖 [超级离线部署完整说明](super-offline-deployment/完整说明.md)
- 📖 [在线部署教程](docs/ONE-CLICK-DEPLOYMENT.md)
- 📖 [快速开始指南](docs/QUICK-DEPLOY.md)
- 📖 [标准脚本说明](DEPLOYMENT-SCRIPTS-README.md)

---

## 🆘 获取帮助

- 💬 [GitHub Issues](https://github.com/hxhophxh/FaceImgMat/issues)
- 📧 联系开发者
- 📖 查阅详细文档

---

## 🎯 推荐方案总结

### 给技术人员（有Python环境）

```
✅ 推荐: 🌐 在线部署
   命令: .\deploy_online.ps1 (Windows)
         ./deploy_online.sh (Linux)
   时间: 5-15分钟
```

### 给普通用户（无Python环境）

```
✅ 推荐: 🎯 超级离线部署
   
   如果用户能联网:
   1. 发送: super-offline-deployment 文件夹（10MB）
   2. 用户双击: prepare-super-offline.bat
   3. 用户双击: 一键完整部署.bat
   
   如果用户完全离线:
   1. 您双击: prepare-super-offline.bat
   2. 发送: super-offline-deployment 文件夹（2GB）
   3. 用户双击: 一键完整部署.bat
```

### 给离线环境（有Python但无网络）

```
✅ 推荐: 📦 标准离线部署
   准备: .\prepare_offline_package.ps1
   部署: .\deploy_offline.ps1
   时间: 准备10-20分钟，部署2-5分钟
```

---

**选择最适合您场景的方案，快速部署！** 🚀

---

*最后更新: 2025-10-12*  
*适用版本: FaceImgMat v2.0+*  
*支持平台: Windows 10/11, Linux, macOS*
