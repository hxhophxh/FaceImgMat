# 📦 FaceImgMat 一键离线部署指南

## 🎯 快速概览

这是最简单的部署方式！只需双击两个文件：
1. **有网络的机器**：双击 `准备离线包.bat` → 生成离线包
2. **无网络的机器**：双击 `一键部署并启动.bat` → 自动部署并打开浏览器

## 📋 部署流程

### 阶段一：准备离线包（需要网络）

#### 1️⃣ 准备环境
```powershell
# 环境要求
- Windows 10/11 或 Windows Server
- Python 3.11 或 3.12（已安装）
- 网络连接（下载依赖包）
- 磁盘空间约 2GB（用于离线包）
```

#### 2️⃣ 生成离线包
```batch
# 操作步骤：
1. 在项目根目录找到 "准备离线包.bat"
2. 双击运行
3. 等待自动完成（约5-15分钟）
```

**自动执行的步骤：**
```
[1/7] 检查Python环境 ✓
[2/7] 下载Python依赖包（~500-800MB）✓
[3/7] 复制InsightFace模型（~325MB）✓
[4/7] 创建自动部署脚本 ✓
[5/7] 生成说明文档 ✓
[6/7] 复制项目文件 ✓
[7/7] 打包压缩（可选）✓
```

#### 3️⃣ 获取离线包
完成后会在当前目录生成：
```
offline_deployment_package/          # 文件夹（~1-1.5GB）
offline_deployment_package.zip       # 压缩包（可选）
```

### 阶段二：离线部署（无需网络）

#### 1️⃣ 传输离线包
将 `offline_deployment_package` 文件夹复制到目标机器任意位置

#### 2️⃣ 一键部署并启动
```batch
# 操作步骤：
1. 进入 offline_deployment_package 文件夹
2. 双击运行 "一键部署并启动.bat"
3. 等待自动完成（约3-8分钟）
4. 浏览器会自动打开 http://127.0.0.1:5000
```

**自动执行的步骤：**
```
部署阶段：
[1/7] 检查部署环境 ✓
[2/7] 验证Python环境 ✓
[3/7] 创建虚拟环境 ✓
[4/7] 安装依赖包 ✓
[5/7] 配置模型文件 ✓
[6/7] 初始化数据库 ✓
[7/7] 完成部署 ✓

启动阶段：
→ 启动Flask服务
→ 等待5秒
→ 自动打开浏览器
→ 显示访问信息
```

#### 3️⃣ 登录系统
浏览器自动打开后，使用以下信息登录：
```
地址：http://127.0.0.1:5000
账号：admin
密码：Admin@FaceMatch2025!
```

## 🎨 命令窗口展示

### 准备阶段（有网络机器）
```
════════════════════════════════════════════
   FaceImgMat 离线包准备工具 v1.0
════════════════════════════════════════════

[1/7] 检查Python环境...
✓ Python版本: 3.12.0
✓ Python路径: C:\Users\xxx\AppData\Local\Programs\Python\Python312\python.exe

[2/7] 下载Python依赖包...
✓ 正在下载 flask...
✓ 正在下载 insightface...
...
✓ 所有依赖包下载完成！

[3/7] 复制InsightFace模型...
✓ 找到模型: buffalo_l
✓ 模型文件复制完成！

[4/7] 创建自动部署脚本...
✓ 已创建: 一键部署并启动.bat

[5/7] 创建说明文档...
✓ 已创建: 离线包使用说明.txt

[6/7] 复制项目文件...
✓ 项目文件复制完成

[7/7] 打包完成！
════════════════════════════════════════════
   离线包准备完成！
════════════════════════════════════════════

📦 离线包位置：
   D:\test\FaceImgMat\offline_deployment_package

📋 下一步操作：
   1. 将 offline_deployment_package 文件夹复制到目标机器
   2. 双击运行"一键部署并启动.bat"
```

### 部署阶段（无网络机器）
```
════════════════════════════════════════════
   FaceImgMat 离线一键部署启动器
════════════════════════════════════════════

[提示] 正在启动部署程序...

╔════════════════════════════════════════════╗
║        FaceImgMat 离线部署安装程序         ║
╚════════════════════════════════════════════╝

[步骤 1/7] 检查部署环境
✓ 离线包路径: D:\offline_deployment_package
✓ 检测到离线依赖包
✓ 检测到模型文件
✓ 环境检查完成

[步骤 2/7] 验证Python环境
✓ Python 3.12.0 已安装

[步骤 3/7] 创建Python虚拟环境
✓ 虚拟环境创建成功

[步骤 4/7] 安装Python依赖包
✓ 正在从离线包安装 flask...
✓ 正在从离线包安装 insightface...
...
✓ 所有依赖包安装完成

[步骤 5/7] 配置InsightFace模型
✓ 模型配置完成

[步骤 6/7] 初始化数据库
✓ 数据库初始化完成

[步骤 7/7] 部署完成
╔════════════════════════════════════════════╗
║              🎉 离线部署完成！              ║
╚════════════════════════════════════════════╝

系统信息：
  项目路径: D:\offline_deployment_package\FaceImgMat
  访问地址: http://127.0.0.1:5000
  默认账号: admin
  默认密码: Admin@FaceMatch2025!

════════════════════════════════════════════
   正在启动服务...
════════════════════════════════════════════

[提示] 正在启动人脸识别系统...
[提示] 服务启动后会自动打开浏览器

[√] 服务已启动！
[√] 正在打开浏览器...

════════════════════════════════════════════
   访问信息
════════════════════════════════════════════

  地址: http://127.0.0.1:5000
  账号: admin
  密码: Admin@FaceMatch2025!

[提示] 按 Ctrl+C 停止服务
════════════════════════════════════════════

 * Serving Flask app 'app'
 * Running on http://127.0.0.1:5000
```

## 🔧 高级用法

### 手动部署（不使用批处理）

如果您需要更多控制，可以手动运行PowerShell脚本：

#### 交互模式（带启动选项）
```powershell
# 进入离线包目录
cd offline_deployment_package

# 运行部署脚本
powershell -ExecutionPolicy Bypass -File deploy_offline.ps1

# 部署完成后会提示选择：
# [1] 立即启动服务并打开浏览器（推荐）
# [2] 仅启动服务（不打开浏览器）
# [3] 稍后手动启动
```

#### 静默模式（自动完成）
```powershell
# 静默部署（不询问，自动退出）
powershell -ExecutionPolicy Bypass -File deploy_offline.ps1 -Silent

# 然后手动启动服务
cd FaceImgMat
.\.venv\Scripts\Activate.ps1
python run.py
```

### 手动启动服务

如果关闭了命令窗口，需要重新启动服务：

```powershell
# 方法1：使用批处理（如果还在）
cd offline_deployment_package
# 再次运行会快速检测并启动

# 方法2：手动启动
cd offline_deployment_package\FaceImgMat
.\.venv\Scripts\Activate.ps1
python run.py

# 方法3：后台启动（Windows）
cd offline_deployment_package\FaceImgMat
start /B .\.venv\Scripts\python.exe run.py
# 访问 http://127.0.0.1:5000
```

## ❓ 常见问题

### Q1: 准备离线包时下载很慢怎么办？
**A:** 可以配置pip镜像加速：
```powershell
# 临时使用清华镜像
$env:PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
.\准备离线包.bat

# 或永久配置
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

### Q2: 运行批处理时报"禁止运行脚本"错误
**A:** 脚本已内置自动处理，如仍失败，手动执行：
```powershell
# 方法1：临时允许（推荐）
powershell -ExecutionPolicy Bypass -File deploy_offline.ps1 -Silent

# 方法2：永久允许（需管理员）
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q3: 离线包太大，如何优化？
**A:** 离线包大小约1-1.5GB，主要包含：
- Python依赖包：~500-800MB
- InsightFace模型：~325MB
- 项目文件：~50MB

优化建议：
```powershell
# 1. 仅下载需要的依赖（修改requirements.txt）
# 2. 使用压缩包传输（可减小30-40%）
# 3. 使用网络共享而不是拷贝
```

### Q4: 如何在多台机器上部署？
**A:** 准备一次离线包，可部署到多台机器：
```
1. 在一台有网的机器上运行"准备离线包.bat"（只需一次）
2. 将offline_deployment_package复制到U盘或共享目录
3. 在每台目标机器上：
   - 复制离线包
   - 运行"一键部署并启动.bat"
```

### Q5: 服务启动后浏览器没有自动打开
**A:** 手动打开浏览器访问：
```
地址：http://127.0.0.1:5000
或：http://localhost:5000
```

### Q6: 如何更改服务端口？
**A:** 修改 `FaceImgMat/run.py`：
```python
# 将 port=5000 改为其他端口
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)  # 改为8080
```

### Q7: 如何停止服务？
**A:** 三种方法：
```
1. 在命令窗口按 Ctrl+C
2. 直接关闭命令窗口
3. 任务管理器结束 python.exe 进程
```

### Q8: 部署失败，如何重新部署？
**A:** 删除旧文件，重新运行：
```powershell
# 删除已部署的项目（保留离线包）
cd offline_deployment_package
Remove-Item -Recurse -Force FaceImgMat, models_cache

# 重新运行部署
.\一键部署并启动.bat
```

### Q9: 如何验证部署是否成功？
**A:** 检查以下几点：
```powershell
# 1. 检查虚拟环境
Test-Path FaceImgMat\.venv\Scripts\python.exe  # 应返回True

# 2. 检查依赖包
cd FaceImgMat
.\.venv\Scripts\python.exe -m pip list | findstr "flask insightface"

# 3. 检查数据库
Test-Path instance\face_matching.db  # 应返回True

# 4. 测试启动
python run.py  # 应该能看到 "Running on http://127.0.0.1:5000"
```

### Q10: 离线包可以跨Windows版本使用吗？
**A:** 可以，但需注意：
```
✓ 支持：Windows 10 → Windows 11
✓ 支持：Windows Server 2016/2019/2022
✓ 支持：相同Python版本（3.11或3.12）
✗ 不支持：Windows → Linux（需要重新准备Linux版本）
✗ 不支持：Python 3.11 → Python 3.12（依赖包不兼容）
```

## 📚 相关文档

- [完整部署指南](./OFFLINE-DEPLOYMENT.md) - 详细的离线部署文档
- [GitHub部署指南](./GITHUB-TO-LINUX-DEPLOYMENT.md) - 从GitHub部署到Linux
- [Git使用指南](./GIT-QUICK-GUIDE.md) - Git操作完整教程
- [快速参考卡](../QUICK-REFERENCE.md) - 常用命令速查

## 🆘 获取帮助

遇到问题？尝试以下方法：

1. **查看日志**
   ```powershell
   # 部署日志在控制台输出
   # 运行日志在 logs/ 目录
   ```

2. **检查环境**
   ```powershell
   # 检查Python
   python --version
   
   # 检查依赖
   cd FaceImgMat
   .\.venv\Scripts\pip list
   ```

3. **重新部署**
   ```powershell
   # 删除旧部署
   Remove-Item -Recurse -Force FaceImgMat
   
   # 重新运行
   .\一键部署并启动.bat
   ```

## 🎉 成功部署后

### 首次使用
1. **登录系统**：http://127.0.0.1:5000
2. **修改密码**：
   ```powershell
   cd FaceImgMat
   python scripts\change_admin_password.py
   ```
3. **导入人脸数据**：登录后使用"数据导入"功能

### 生产环境部署
如需在生产环境使用，请参考：
- [生产环境部署清单](./DEPLOYMENT-CHECKLIST.md)
- [安全配置指南](./SECURITY.md)
- [Linux部署指南](./LINUX-DEPLOYMENT.md)

---

**祝您部署顺利！** 🚀
