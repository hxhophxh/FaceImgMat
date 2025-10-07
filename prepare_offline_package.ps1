# 离线部署准备脚本 (Windows PowerShell)
# 此脚本帮助您准备完整的离线部署包

Write-Host "🚀 开始准备离线部署包..." -ForegroundColor Green
Write-Host ""

# 1. 检查当前目录
if (-not (Test-Path "requirements.txt")) {
    Write-Host "❌ 错误：请在项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

$projectRoot = Get-Location
Write-Host "📁 项目目录: $projectRoot" -ForegroundColor Cyan

# 2. 创建离线包目录
$offlineDir = Join-Path $projectRoot.Path "offline_deployment_package"
if (Test-Path $offlineDir) {
    Write-Host "⚠️  离线包目录已存在，将被覆盖" -ForegroundColor Yellow
    Remove-Item $offlineDir -Recurse -Force
}
New-Item -ItemType Directory -Path $offlineDir -Force | Out-Null
Write-Host "✅ 创建离线包目录: $offlineDir" -ForegroundColor Green

# 3. 下载Python依赖包
Write-Host ""
Write-Host "📦 下载Python依赖包..." -ForegroundColor Cyan
$packagesDir = Join-Path $offlineDir "python_packages"
New-Item -ItemType Directory -Path $packagesDir -Force | Out-Null

Write-Host "   正在下载依赖包（这可能需要5-10分钟）..." -ForegroundColor Yellow
pip download -r requirements.txt -d $packagesDir --no-cache-dir

if ($LASTEXITCODE -eq 0) {
    $packageCount = (Get-ChildItem $packagesDir).Count
    $packageSize = [math]::Round((Get-ChildItem $packagesDir | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    Write-Host "✅ 已下载 $packageCount 个依赖包，总大小: ${packageSize}MB" -ForegroundColor Green
} else {
    Write-Host "❌ 依赖包下载失败" -ForegroundColor Red
    exit 1
}

# 4. 复制InsightFace模型
Write-Host ""
Write-Host "🤖 复制InsightFace模型文件..." -ForegroundColor Cyan
$insightfaceSrc = Join-Path $env:USERPROFILE ".insightface\models"
$insightfaceDst = Join-Path $offlineDir "insightface_models"

if (Test-Path $insightfaceSrc) {
    Copy-Item -Path $insightfaceSrc -Destination $insightfaceDst -Recurse -Force
    $modelSize = [math]::Round((Get-ChildItem $insightfaceDst -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    Write-Host "✅ 模型文件已复制，大小: ${modelSize}MB" -ForegroundColor Green
    
    # 列出模型文件
    Write-Host "   模型文件列表:" -ForegroundColor Gray
    Get-ChildItem $insightfaceDst -Recurse -File | ForEach-Object {
        $sizeMB = [math]::Round($_.Length / 1MB, 2)
        Write-Host "   - $($_.Name) (${sizeMB}MB)" -ForegroundColor Gray
    }
} else {
    Write-Host "⚠️  未找到InsightFace模型，将在首次运行时自动下载" -ForegroundColor Yellow
    Write-Host "   建议先运行一次应用以下载模型：" -ForegroundColor Yellow
    Write-Host "   python -c `"import insightface; insightface.app.FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])`"" -ForegroundColor Gray
}

# 5. 复制项目文件
Write-Host ""
Write-Host "📄 复制项目文件..." -ForegroundColor Cyan
$projectDst = Join-Path $offlineDir "FaceImgMat"

# 排除的目录
$excludeDirs = @('.venv', '.git', '__pycache__', 'offline_deployment_package')

# 使用robocopy复制（Windows推荐）
$excludeArgs = $excludeDirs | ForEach-Object { "/XD", $_ }
robocopy $projectRoot $projectDst /E /XD $excludeDirs /XF *.pyc /NFL /NDL /NJH /NJS | Out-Null

if ($LASTEXITCODE -lt 8) {
    $projectSize = [math]::Round((Get-ChildItem $projectDst -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    Write-Host "✅ 项目文件已复制，大小: ${projectSize}MB" -ForegroundColor Green
} else {
    Write-Host "❌ 项目文件复制失败" -ForegroundColor Red
    exit 1
}

# 6. 创建部署脚本
Write-Host ""
Write-Host "📝 创建部署脚本..." -ForegroundColor Cyan

# Windows部署脚本
$deployScriptWin = @'
# 离线部署脚本 (Windows)
Write-Host "🚀 开始离线部署..." -ForegroundColor Green

# 检查Python
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 未找到Python，请先安装Python 3.11或3.12" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Python版本: $pythonVersion" -ForegroundColor Green

# 进入项目目录
Set-Location FaceImgMat

# 创建虚拟环境
Write-Host "📦 创建虚拟环境..." -ForegroundColor Cyan
python -m venv .venv
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 虚拟环境创建失败" -ForegroundColor Red
    exit 1
}

# 激活虚拟环境
& .\.venv\Scripts\Activate.ps1

# 升级pip
Write-Host "⬆️  升级pip..." -ForegroundColor Cyan
python -m pip install --upgrade pip --no-index --find-links=..\python_packages

# 安装依赖
Write-Host "📦 安装依赖包..." -ForegroundColor Cyan
pip install -r requirements.txt --no-index --find-links=..\python_packages

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 依赖安装失败" -ForegroundColor Red
    exit 1
}

# 配置InsightFace模型
Write-Host "🤖 配置InsightFace模型..." -ForegroundColor Cyan
$modelDst = Join-Path $env:USERPROFILE ".insightface\models"
New-Item -ItemType Directory -Path $modelDst -Force | Out-Null
Copy-Item -Path ..\insightface_models\* -Destination $modelDst -Recurse -Force

# 检查数据库
if (-not (Test-Path "instance\face_matching.db")) {
    Write-Host "⚠️  数据库不存在，正在初始化..." -ForegroundColor Yellow
    python scripts\init_demo_data.py
}

Write-Host ""
Write-Host "✅ 部署完成！" -ForegroundColor Green
Write-Host ""
Write-Host "启动服务：python run.py" -ForegroundColor Cyan
Write-Host "访问地址：http://127.0.0.1:5000" -ForegroundColor Cyan
Write-Host "默认账户：admin / Admin@FaceMatch2025!" -ForegroundColor Cyan
'@

$deployScriptWin | Out-File -FilePath (Join-Path $offlineDir "deploy_windows.ps1") -Encoding UTF8

# Linux部署脚本
$deployScriptLinux = @'
#!/bin/bash
# 离线部署脚本 (Linux)
set -e

echo "🚀 开始离线部署..."

# 检查Python
if ! command -v python3.11 &> /dev/null; then
    echo "❌ 未找到Python 3.11，请先安装"
    exit 1
fi

echo "✅ Python版本: $(python3.11 --version)"

# 进入项目目录
cd FaceImgMat

# 创建虚拟环境
echo "📦 创建虚拟环境..."
python3.11 -m venv .venv

# 激活虚拟环境
source .venv/bin/activate

# 升级pip
echo "⬆️  升级pip..."
python -m pip install --upgrade pip --no-index --find-links=../python_packages

# 安装依赖
echo "📦 安装依赖包..."
pip install -r requirements.txt --no-index --find-links=../python_packages

# 配置InsightFace模型
echo "🤖 配置InsightFace模型..."
mkdir -p ~/.insightface/models
cp -r ../insightface_models/* ~/.insightface/models/

# 检查数据库
if [ ! -f "instance/face_matching.db" ]; then
    echo "⚠️  数据库不存在，正在初始化..."
    python scripts/init_demo_data.py
fi

echo ""
echo "✅ 部署完成！"
echo ""
echo "启动服务：python run.py"
echo "访问地址：http://127.0.0.1:5000"
echo "默认账户：admin / Admin@FaceMatch2025!"
'@

$deployScriptLinux | Out-File -FilePath (Join-Path $offlineDir "deploy_linux.sh") -Encoding UTF8

Write-Host "✅ 部署脚本已创建" -ForegroundColor Green

# 7. 创建说明文件
$readmeContent = @"
# 离线部署包说明

## 📦 包含内容

1. **FaceImgMat/** - 项目源代码
   - 包含数据库文件（已初始化）
   - 包含测试图片
   
2. **python_packages/** - Python依赖包（约500-800MB）
   - 所有requirements.txt中的包
   - 可离线安装

3. **insightface_models/** - AI模型文件（约300MB）
   - buffalo_l模型
   - 人脸检测和识别模型

4. **deploy_windows.ps1** - Windows自动部署脚本
5. **deploy_linux.sh** - Linux自动部署脚本
6. **README.txt** - 本说明文件

## 🚀 快速部署

### Windows环境

1. 确保已安装Python 3.11或3.12
2. 右键点击 deploy_windows.ps1，选择"使用PowerShell运行"
3. 等待部署完成
4. 运行: python run.py

### Linux环境

1. 确保已安装Python 3.11或3.12
2. 运行: chmod +x deploy_linux.sh && ./deploy_linux.sh
3. 运行: python run.py

## 📊 系统要求

- Python 3.11 或 3.12
- 至少 2GB RAM
- 至少 5GB 磁盘空间

## 🔐 默认账户

- 用户名: admin
- 密码: Admin@FaceMatch2025!

⚠️ 首次登录后请立即修改密码！

## 📚 详细文档

查看 FaceImgMat/docs/OFFLINE-DEPLOYMENT.md

## 🆘 问题排查

如果遇到问题，请查看：
- FaceImgMat/docs/OFFLINE-DEPLOYMENT.md
- FaceImgMat/README.md
"@

$readmeContent | Out-File -FilePath (Join-Path $offlineDir "README.txt") -Encoding UTF8

Write-Host "✅ 说明文件已创建" -ForegroundColor Green

# 8. 生成打包脚本
Write-Host ""
Write-Host "📦 生成打包脚本..." -ForegroundColor Cyan

$zipScript = @"
# 打包离线部署包
`$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
`$zipFile = "FaceImgMat-offline-`$timestamp.zip"

Write-Host "正在打包到: `$zipFile"
Compress-Archive -Path offline_deployment_package\* -DestinationPath `$zipFile -Force

`$zipSize = [math]::Round((Get-Item `$zipFile).Length / 1MB, 2)
Write-Host "✅ 打包完成！文件大小: `${zipSize}MB"
Write-Host "文件位置: `$((Get-Item `$zipFile).FullName)"
"@

$zipScript | Out-File -FilePath (Join-Path $projectRoot "create_offline_package.ps1") -Encoding UTF8

Write-Host "✅ 打包脚本已创建: create_offline_package.ps1" -ForegroundColor Green

# 9. 统计信息
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 离线部署包统计" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

$totalSize = [math]::Round((Get-ChildItem $offlineDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)

Write-Host "📁 目录: $offlineDir" -ForegroundColor White
Write-Host "💾 总大小: ${totalSize}MB" -ForegroundColor White
Write-Host ""

Get-ChildItem $offlineDir -Directory | ForEach-Object {
    $dirSize = [math]::Round((Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    Write-Host "  📂 $($_.Name): ${dirSize}MB" -ForegroundColor Gray
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✅ 离线部署包准备完成！" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 下一步操作：" -ForegroundColor Yellow
Write-Host "   1. 运行 .\create_offline_package.ps1 打包成ZIP文件" -ForegroundColor White
Write-Host "   2. 将ZIP文件传输到离线环境" -ForegroundColor White
Write-Host "   3. 在离线环境解压并运行部署脚本" -ForegroundColor White
Write-Host ""
Write-Host "📚 详细说明请查看: offline_deployment_package\README.txt" -ForegroundColor Cyan
