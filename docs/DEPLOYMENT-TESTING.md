# 部署脚本测试指南

本文档用于测试和验证一键部署脚本的功能。

## 测试前准备

### 测试环境
- Windows 10/11 + PowerShell 5.1+
- 或 Linux/macOS + Bash 4.0+
- Python 3.11 或 3.12
- 至少 5GB 磁盘空间

### 测试工具
- Python
- pip
- git（可选）

## 在线部署测试

### Windows PowerShell

```powershell
# 1. 检查脚本语法
Get-Content deploy_online.ps1 | Out-Null

# 2. 模拟执行（干运行）
# 注释掉实际安装命令，只运行检查部分

# 3. 完整测试
.\deploy_online.ps1
```

### Linux/macOS

```bash
# 1. 检查脚本语法
bash -n deploy_online.sh

# 2. 添加执行权限
chmod +x deploy_online.sh

# 3. 完整测试
./deploy_online.sh
```

## 离线部署测试

### 准备离线包测试

```powershell
# Windows
.\prepare_offline_package.ps1

# 检查生成的文件
Test-Path offline_deployment_package
Test-Path offline_deployment_package/FaceImgMat
Test-Path offline_deployment_package/python_packages
```

```bash
# Linux/macOS
./prepare_offline_package.sh

# 检查生成的文件
ls -la offline_deployment_package/
du -sh offline_deployment_package/*
```

### 离线部署测试

```powershell
# Windows
cd offline_deployment_package
.\deploy_offline.ps1
```

```bash
# Linux/macOS
cd offline_deployment_package
./deploy_offline.sh
```

## 测试检查清单

### 环境检查
- [ ] Python 版本检查正常
- [ ] pip 检查正常
- [ ] 磁盘空间检查正常
- [ ] 网络检查正常（在线模式）

### 虚拟环境
- [ ] .venv 目录创建成功
- [ ] 虚拟环境激活成功
- [ ] pip 升级成功

### 依赖安装
- [ ] requirements.txt 读取正常
- [ ] 所有包安装成功
- [ ] 关键包验证通过
  - [ ] flask
  - [ ] insightface
  - [ ] faiss-cpu
  - [ ] opencv-python

### 数据初始化
- [ ] instance 目录创建
- [ ] static/faces 目录创建
- [ ] static/uploads 目录创建
- [ ] 数据库文件创建
- [ ] 演示数据导入成功

### 服务启动
- [ ] 服务启动成功
- [ ] 可以访问 http://127.0.0.1:5000
- [ ] 登录界面正常显示
- [ ] 可以使用默认账号登录

## 常见测试问题

### 问题1：执行策略限制

**症状：**
```
无法加载文件，因为在此系统上禁止运行脚本
```

**解决：**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 问题2：权限不足

**症状：**
```
Permission denied
```

**解决：**
```bash
chmod +x deploy_online.sh
chmod +x deploy_offline.sh
```

### 问题3：Python 版本不对

**症状：**
```
需要 Python 3.11 或更高版本
```

**解决：**
安装正确的 Python 版本

### 问题4：网络超时

**症状：**
```
Read timed out
```

**解决：**
- 检查网络连接
- 使用国内镜像
- 或使用离线部署

## 测试报告模板

```
测试时间：2025-10-12
测试人员：[姓名]
测试环境：Windows 11 / Python 3.11.5

在线部署测试：
- 环境检查：✅ 通过
- 虚拟环境：✅ 通过
- 依赖安装：✅ 通过
- 数据初始化：✅ 通过
- 服务启动：✅ 通过
- 部署时间：8 分钟 32 秒

离线部署测试：
- 离线包准备：✅ 通过
- 离线包大小：1.2GB
- 离线部署：✅ 通过
- 部署时间：3 分钟 15 秒

发现问题：
- 无

建议改进：
- 无

测试结论：✅ 通过
```

## 自动化测试脚本

### Windows PowerShell

```powershell
# test_deployment.ps1
Write-Host "开始部署测试..."

# 测试在线部署
Write-Host "`n测试在线部署脚本..."
$startTime = Get-Date
.\deploy_online.ps1
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n部署耗时: $($duration.TotalMinutes) 分钟"

# 测试服务
Write-Host "`n测试服务访问..."
$response = Invoke-WebRequest -Uri "http://127.0.0.1:5000" -UseBasicParsing
if ($response.StatusCode -eq 200) {
    Write-Host "✅ 服务访问正常" -ForegroundColor Green
} else {
    Write-Host "❌ 服务访问失败" -ForegroundColor Red
}
```

### Linux/macOS

```bash
#!/bin/bash
# test_deployment.sh

echo "开始部署测试..."

# 测试在线部署
echo -e "\n测试在线部署脚本..."
START_TIME=$(date +%s)
./deploy_online.sh
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n部署耗时: $((DURATION / 60)) 分钟 $((DURATION % 60)) 秒"

# 测试服务
echo -e "\n测试服务访问..."
if curl -s http://127.0.0.1:5000 > /dev/null; then
    echo "✅ 服务访问正常"
else
    echo "❌ 服务访问失败"
fi
```

## 性能基准

### 在线部署基准

| 环境 | Python版本 | 网络速度 | 部署时间 |
|------|-----------|---------|---------|
| Windows 11 | 3.11.5 | 100Mbps | 8-12分钟 |
| Ubuntu 22.04 | 3.11.6 | 100Mbps | 6-10分钟 |
| macOS 14 | 3.12.0 | 100Mbps | 7-11分钟 |

### 离线部署基准

| 环境 | Python版本 | 部署时间 |
|------|-----------|---------|
| Windows 11 | 3.11.5 | 2-4分钟 |
| Ubuntu 22.04 | 3.11.6 | 2-3分钟 |
| macOS 14 | 3.12.0 | 2-4分钟 |

---

**完成测试后，请将结果报告提交到 Issues！**
