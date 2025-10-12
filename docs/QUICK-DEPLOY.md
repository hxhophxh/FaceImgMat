# 🚀 快速开始 - 2分钟部署指南

这是最简单、最快速的部署方式。

## 选择你的部署方式

### 🌐 有网络？→ 在线一键部署

```bash
# Windows PowerShell
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
.\deploy_online.ps1

# Linux/macOS
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
chmod +x deploy_online.sh && ./deploy_online.sh
```

**完成！** 等待5-10分钟自动安装。

### 📦 无网络？→ 离线一键部署

**步骤1** - 在有网络的机器上：
```bash
# 下载项目
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# Windows
.\prepare_offline_package.ps1
.\create_offline_package.ps1

# Linux/macOS
./prepare_offline_package.sh
zip -r FaceImgMat-offline.zip offline_deployment_package/
```

**步骤2** - 传输 ZIP 到目标机器（U盘/内网共享）

**步骤3** - 在目标机器上：
```bash
# 解压
unzip FaceImgMat-offline-*.zip    # Linux/macOS
# 或
Expand-Archive FaceImgMat-offline-*.zip  # Windows

cd offline_deployment_package

# 部署
.\deploy_offline.ps1    # Windows
# 或
./deploy_offline.sh     # Linux/macOS
```

**完成！** 2-3分钟完成部署。

## 访问系统

```
🌐 地址: http://127.0.0.1:5000
👤 账号: admin
🔑 密码: Admin@FaceMatch2025!
```

## 下一步

1. **修改密码**（重要！）
   ```bash
   python scripts/change_admin_password.py
   ```

2. **导入人员数据**
   - 在Web界面点击"批量导入"
   - 或将照片放入 `static/faces/` 目录

3. **开始使用**
   - 上传照片进行人脸匹配
   - 查看匹配结果和历史记录

## 需要帮助？

- 📖 [完整部署文档](ONE-CLICK-DEPLOYMENT.md)
- 🐛 [常见问题](ONE-CLICK-DEPLOYMENT.md#常见问题)
- 💬 [提交Issue](https://github.com/hxhophxh/FaceImgMat/issues)

---

**就这么简单！享受人脸识别的乐趣吧！** 🎉
