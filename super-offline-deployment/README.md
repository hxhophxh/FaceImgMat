# 🚀 FaceImgMat 超级离线部署包

## 📦 适用场景

本部署包适用于**完全没有任何依赖环境**的全新机器：
- ❌ 没有安装 Python
- ❌ 没有安装 Git
- ❌ 没有网络连接
- ✅ 只需要 Windows 10/11 或 Windows Server 操作系统

## 📂 目录结构

```
super-offline-deployment/
│
├── 00-使用说明/
│   ├── 快速开始.txt                 ← 先看这个！
│   ├── 详细部署指南.md
│   └── 常见问题.md
│
├── 01-Python安装包/
│   ├── python-3.11.9-amd64.exe      ← Python安装程序（约25MB）
│   ├── 安装Python说明.txt
│   └── 验证安装.bat
│
├── 02-项目源码/
│   └── FaceImgMat/                  ← 完整项目代码
│       ├── run.py
│       ├── requirements.txt
│       ├── app/
│       ├── scripts/
│       ├── templates/
│       ├── static/
│       └── instance/
│
├── 03-Python依赖包/
│   ├── Flask-3.0.0-py3-none-any.whl
│   ├── insightface-0.7.3-py3-none-any.whl
│   └── ... (所有Python依赖包，约500-800MB)
│
├── 04-AI模型文件/
│   └── insightface_models/
│       └── buffalo_l/               ← InsightFace模型（约325MB）
│           ├── det_10g.onnx
│           ├── w600k_r50.onnx
│           └── ...
│
├── 一键完整部署.bat                  ← 双击这个！全自动安装
├── 手动分步部署.bat                  ← 需要手动控制时使用
├── 仅部署项目.bat                    ← Python已安装时使用
├── 卸载清理.bat                      ← 卸载脚本
│
└── scripts/                         ← 内部脚本（不需要手动运行）
    ├── install_python.ps1
    ├── deploy_project.ps1
    ├── verify_installation.ps1
    └── cleanup.ps1
```

## 🎯 使用方法

### 方法一：完全自动（推荐）

```
双击运行：一键完整部署.bat
```

**自动完成：**
1. ✅ 检测并安装 Python 3.11
2. ✅ 创建虚拟环境
3. ✅ 安装所有依赖包
4. ✅ 配置 InsightFace 模型
5. ✅ 初始化数据库
6. ✅ 启动服务
7. ✅ 打开浏览器

**预计时间：** 15-25 分钟（取决于机器性能）

### 方法二：分步手动

如果需要更多控制，使用：
```
双击运行：手动分步部署.bat
```

会提示每一步操作，您可以选择是否继续。

### 方法三：Python已安装

如果机器已经安装了 Python 3.11/3.12：
```
双击运行：仅部署项目.bat
```

跳过 Python 安装，直接部署项目。

## ⏱️ 部署时间估算

| 步骤 | 时间 | 说明 |
|------|------|------|
| 1. 安装Python | 2-5分钟 | 自动安装，无需干预 |
| 2. 创建虚拟环境 | 1分钟 | 自动创建 |
| 3. 安装依赖包 | 5-10分钟 | 从本地安装，无需下载 |
| 4. 配置模型 | 2-3分钟 | 复制模型文件 |
| 5. 初始化数据库 | 1分钟 | 创建数据库 |
| 6. 启动服务 | 10秒 | Flask启动 |
| **总计** | **15-25分钟** | 全自动无需干预 |

## 📋 系统要求

### 必需条件
- ✅ Windows 10 (1909+) / Windows 11 / Windows Server 2016+
- ✅ 64位操作系统
- ✅ 5GB+ 可用磁盘空间
- ✅ 2GB+ 可用内存

### 不需要的
- ❌ 不需要网络连接
- ❌ 不需要预装 Python
- ❌ 不需要预装 Git
- ❌ 不需要管理员权限（推荐有，但不强制）

## 🔐 默认登录信息

部署完成后访问：
```
地址: http://127.0.0.1:5000
账号: admin
密码: Admin@FaceMatch2025!
```

⚠️ **重要：首次登录后立即修改密码！**

## ❓ 常见问题

### Q: 机器完全没装过 Python 可以用吗？
**A:** 可以！这就是本方案的目的，自动安装 Python。

### Q: 需要网络吗？
**A:** 完全不需要！所有内容都在离线包中。

### Q: 需要管理员权限吗？
**A:** 推荐有管理员权限，但如果没有，脚本会尝试当前用户安装。

### Q: 可以安装在 D 盘或其他盘吗？
**A:** 可以！将整个文件夹复制到任意位置运行即可。

### Q: Python 会安装到哪里？
**A:** 默认安装到 `C:\Program Files\Python311\` 或当前用户目录。

### Q: 如何卸载？
**A:** 运行 `卸载清理.bat` 会清理所有安装的内容。

### Q: 部署失败了怎么办？
**A:** 
1. 查看错误信息
2. 运行 `卸载清理.bat` 清理环境
3. 重新运行 `一键完整部署.bat`

### Q: 可以在多台机器上使用吗？
**A:** 可以！复制整个 `super-offline-deployment` 文件夹到多台机器，分别运行即可。

## 📦 如何准备此离线包

### 在有网络的机器上执行：

```powershell
# 1. 克隆项目
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 2. 运行超级离线包准备脚本
.\super-offline-deployment\prepare-super-package.ps1

# 3. 打包整个 super-offline-deployment 文件夹
# 压缩后约 1.5-2GB
```

## 🆘 获取帮助

- 📖 查看 `00-使用说明/详细部署指南.md`
- 📞 查看 `00-使用说明/常见问题.md`
- 🐛 GitHub Issues: https://github.com/hxhophxh/FaceImgMat/issues

## 📝 版本信息

- **版本**: v2.0 - 超级离线部署版
- **更新日期**: 2025-10-12
- **Python版本**: 3.11.9
- **支持系统**: Windows 10/11, Windows Server 2016+

---

**祝您部署顺利！** 🎉
