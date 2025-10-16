# 🚀 FaceImgMat 超级离线部署包

## 📦 适用场景

本部署包适用于**完全没有任何依赖环境**的全新机器：
- ❌ 没有安装 Python
- ❌ 没有安装 Git
- ❌ 没有网络连接
- ✅ 只需要 Windows 10/11 或 Windows Server 操作系统

> ⚠️ **重要提示**: 请先阅读 [依赖版本说明](DEPENDENCY-VERSION-NOTES.md)，了解 NumPy 版本兼容性问题及自动修复机制。

---

## 🎯 两步快速部署

### 步骤1️⃣：制作离线超级包（维护机器，需已联网完成环境配置）

前置条件：
- 已在项目根目录创建并验证 `.venv` 虚拟环境（包含全部依赖）。
- 已成功运行过应用，`%USERPROFILE%\.insightface\models` 中存在 `buffalo_l` 模型。
- `01-Python安装包` 下已存在或可下载 `python-3.12.7-amd64.exe` 安装器。
- **确保 NumPy 版本为 1.26.4**（脚本会自动检测并修复）

```bat
双击运行：准备超级离线包.bat
```

> 进阶：如需跳过压缩或手动控制压缩级别，可在 PowerShell 中执行：
> ```powershell
> # 跳过压缩，待会使用 7-Zip/资源管理器手动打包
> powershell -ExecutionPolicy Bypass -File .\prepare-super-package.ps1 -Silent -SkipZip
>
> # 强制使用快速压缩（默认自动检测 7-Zip -> tar -> Compress-Archive）
> powershell -ExecutionPolicy Bypass -File .\prepare-super-package.ps1 -Silent -CompressionLevel Fastest
>
> # 指定压缩工具：SevenZip / Tar / CompressArchive
> powershell -ExecutionPolicy Bypass -File .\prepare-super-package.ps1 -Silent -ZipTool SevenZip
> ```
> 说明：无论直接运行 BAT 还是手动执行 PowerShell，脚本都会优先寻找 7-Zip（可见实时进度），其次是 Windows 自带的 `tar.exe`，最后才回退到 `Compress-Archive`。

脚本会自动：
- ✅ 校验 `.venv` 状态并导出 `requirements.lock`
- ✅ **自动检测并修复依赖版本**（NumPy 降级、移除 opencv-python-headless）
- ✅ 复制 `.venv\Lib\site-packages`（含 insightface、faiss 等依赖）
- ✅ 复制 `%USERPROFILE%\.insightface\models` 中的模型文件
- ✅ 复制 `FaceImgMat` 项目源码
- ✅ 将以上内容组装为 `offline_bundle` 目录并打包为 `offline_bundle.zip`

**预计时间：** 3-8 分钟（本地复制为主，无大流量下载）

### 步骤2️⃣：一键部署（目标机器，可离线）

确保当前目录存在 `offline_bundle.zip`。如目标机器可访问 GitHub，脚本会自动尝试从最新 Release 下载；离线场景可提前将 zip 拷贝到同级目录。

```bat
双击运行：一键完整部署.bat
```

**自动完成：**
1. ✅ 获取 / 解压离线包
2. ✅ 检查并安装 Python 3.12
3. ✅ 创建全新虚拟环境
4. ✅ 直接同步 site-packages（无需联网安装）
5. ✅ 配置 InsightFace 模型
6. ✅ 初始化数据库与目录
7. ✅ 启动人脸识别服务并打开浏览器

**预计时间：** 10-15 分钟（解压 + 复制为主）

---

## 📂 目录结构

```
super-offline-deployment/
│
├── offline_bundle.zip              ← 分发给用户的最终离线包
├── offline_bundle/                 ← 打包脚本生成的内容（可重新生成）
│   ├── FaceImgMat/                 ← 项目源码快照
│   ├── site-packages/              ← 直接复制的依赖
│   ├── models/insightface_models/  ← InsightFace 模型
│   ├── python/python-3.12.7-*.exe  ← Python 安装程序
│   └── requirements.lock           ← 依赖快照
│
├── 00-使用说明/                    ← 快速上手文档
├── 01-Python安装包/                ← 存放 Python 安装器（供打包脚本复制）
├── 02-项目源码/                    ← 脚本生成的源码缓存
├── 03-Python依赖包/                ← 导出的 site-packages 备份
├── 04-AI模型文件/                  ← 模型缓存（可手动放置）
├── prepare-super-package.ps1       ← 打包脚本（PowerShell）
├── prepare-super-offline.bat       ← 打包启动器（Windows）
├── 准备超级离线包.bat               ← 同上（中文）
├── 一键完整部署.bat                 ← 目标机部署脚本
├── 卸载清理.bat                     ← 清理脚本
└── README.md                       ← 本文档
```


---

## ⏱️ 时间和空间估算

### 制作离线包（步骤1）
| 项目 | 大小/时间 |
|------|----------|
| offline_bundle.zip | ~1.2GB（视模型/依赖而定） |
| 复制 site-packages | 约 3-5 分钟 |
| 复制模型与源码 | 约 1-2 分钟 |
| 压缩打包 | 约 1-3 分钟 |
| **总耗时** | **3-8 分钟** |

### 部署到目标机器（步骤2）
| 项目 | 时间 |
|------|------|
| 解压离线包 | 3-5 分钟 |
| 安装 / 检测 Python | 2-5 分钟 |
| 创建虚拟环境 + 同步依赖 | 3-5 分钟 |
| 配置模型 / 初始化数据库 | 2-3 分钟 |
| **总耗时** | **10-15 分钟** |

---


## 📋 系统要求

### 必需条件
- ✅ Windows 10 (1909+) / Windows 11 / Windows Server 2016+
- ✅ 64位操作系统
- ✅ 5GB+ 可用磁盘空间
- ✅ 2GB+ 可用内存

### 不需要的
- ❌ 不需要网络连接（部署时）
- ❌ 不需要预装 Python
- ❌ 不需要预装 Git
- ❌ 不需要管理员权限（推荐有，但不强制）

---

## 🔐 默认登录信息

部署完成后访问：`http://127.0.0.1:5000`

```
账号: admin
密码: Admin@FaceMatch2025!
```

⚠️ **重要：首次登录后立即修改密码！**

---


## ❓ 常见问题

**Q: 机器完全没装过 Python 可以用吗？**  
A: 可以！这就是本方案的目的，会自动安装 Python。

**Q: 部署时需要网络吗？**  
A: 不需要！所有依赖都在离线包中。准备离线包时需要网络。

**Q: 需要管理员权限吗？**  
A: 推荐有管理员权限，但如果没有，脚本会尝试当前用户安装。

**Q: 可以安装在 D 盘或其他盘吗？**  
A: 可以！将整个文件夹复制到任意位置运行即可。

**Q: 如何卸载？**  
A: 运行 `卸载清理.bat` 会清理所有安装的内容。

**Q: 部署失败了怎么办？**  
A: 运行 `卸载清理.bat` 清理环境，然后重新运行 `一键完整部署.bat`。

**Q: 可以在多台机器上使用吗？**  
A: 可以！复制整个文件夹到多台机器，分别运行即可。

---

## 📦 开发者：如何制作此离线包

在有网络的开发机器上执行：

```powershell
# 1. 克隆项目并在根目录创建虚拟环境（需联网）
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
python -m venv .venv
.venv\Scripts\pip install -r requirements.txt

# 2. 运行测试，确保依赖和模型均可用
.venv\Scripts\python run.py  # 验证应用可启动

# 3. 切回 super-offline-deployment 目录生成离线包
cd super-offline-deployment
.\prepare-super-offline.bat
# 或使用中文脚本
.\准备超级离线包.bat

# 4. 等待脚本完成，得到 offline_bundle.zip
# 将该 ZIP 上传到 GitHub Release 或通过其他途径发给用户
```

---

## 🆘 获取帮助

- 📖 详细文档: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
- 🐛 问题反馈: [GitHub Issues](https://github.com/hxhophxh/FaceImgMat/issues)

---

## 📝 版本信息

- **版本**: v3.0 - 离线超级包复制版
- **更新日期**: 2025-02-22
- **Python版本**: 3.12.7
- **支持系统**: Windows 10/11, Windows Server 2016+

---

**祝您部署顺利！** 🎉

