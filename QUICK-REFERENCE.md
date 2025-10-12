# 🚀 FaceImgMat 一键部署 - 快速参考卡

## ⚡ 快速命令

### Windows PowerShell

```powershell
# 在线部署（有网络）- 一条命令搞定
.\deploy_online.ps1

# 离线部署（无网络）
# 步骤1: 准备离线包（在有网络的机器上）
.\prepare_offline_package.ps1

# 步骤2: 传输到目标机器后执行
.\deploy_offline.ps1
```

### Linux/macOS

```bash
# 在线部署（有网络）- 一条命令搞定
chmod +x deploy_online.sh && ./deploy_online.sh

# 离线部署（无网络）
# 步骤1: 准备离线包（在有网络的机器上）
chmod +x prepare_offline_package.sh && ./prepare_offline_package.sh

# 步骤2: 传输到目标机器后执行
chmod +x deploy_offline.sh && ./deploy_offline.sh
```

## 📦 文件说明

| 文件 | 用途 | 何时使用 |
|------|------|----------|
| `deploy_online.ps1` | Windows在线部署 | 有网络的Windows环境 |
| `deploy_online.sh` | Linux/macOS在线部署 | 有网络的Linux/Mac环境 |
| `prepare_offline_package.ps1` | 准备离线包(Win) | 为离线环境准备部署包 |
| `prepare_offline_package.sh` | 准备离线包(Linux) | 为离线环境准备部署包 |
| `deploy_offline.ps1` | Windows离线部署 | 无网络的Windows环境 |
| `deploy_offline.sh` | Linux/macOS离线部署 | 无网络的Linux/Mac环境 |

## 🎯 部署流程图

### 在线部署
```
开始 → 运行脚本 → 自动检查环境 → 安装依赖 → 初始化数据 → 启动服务 → 完成
        (1条命令)    (5-15分钟)
```

### 离线部署
```
有网络机器                     无网络机器
    ↓                             ↓
准备离线包 → 打包 → [传输] → 解压 → 运行脚本 → 完成
(10-20分钟)  (可选)   (U盘等)          (2-5分钟)
```

## ✅ 前置条件

- Python 3.11 或 3.12
- pip 工具
- 5GB+ 磁盘空间
- 2GB+ 内存
- 在线部署需要网络

## 🌐 访问系统

部署成功后访问：

```
地址: http://127.0.0.1:5000
账号: admin
密码: Admin@FaceMatch2025!
```

⚠️ **首次登录后立即修改密码：**
```bash
python scripts/change_admin_password.py
```

## 📚 详细文档

- [完整部署教程](docs/ONE-CLICK-DEPLOYMENT.md)
- [快速开始](docs/QUICK-DEPLOY.md)
- [脚本说明](DEPLOYMENT-SCRIPTS-README.md)

## ❓ 常见问题

**Q: Windows提示"禁止运行脚本"？**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Q: Linux提示"权限被拒绝"？**
```bash
chmod +x deploy_online.sh
```

**Q: 网络很慢怎么办？**
使用离线部署方式！

**Q: 端口5000被占用？**
修改 `run.py` 中的端口号。

## 🆘 获取帮助

- 📖 [完整文档](docs/ONE-CLICK-DEPLOYMENT.md)
- 🐛 [GitHub Issues](https://github.com/hxhophxh/FaceImgMat/issues)

---

**打印此页作为快速参考！** 📄
