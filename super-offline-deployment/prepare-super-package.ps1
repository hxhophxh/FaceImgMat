#!/usr/bin/env pwsh
# ===================================================================
# FaceImgMat 超级离线包准备脚本
# 在有网络的机器上运行，准备完整的离线部署包（包含Python安装程序）
# ===================================================================

param(
    [switch]$Silent  # 静默模式，跳过确认提示
)

$ErrorActionPreference = "Stop"

Write-Host @"

╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║     FaceImgMat 超级离线包准备工具                              ║
║     为完全没有Python环境的机器准备部署包                        ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "[提示] 本脚本将准备：" -ForegroundColor Yellow
Write-Host "  1. Python 3.11.9 安装程序"
Write-Host "  2. FaceImgMat 项目源码"
Write-Host "  3. 所有 Python 依赖包"
Write-Host "  4. InsightFace AI 模型"
Write-Host "  5. 自动部署脚本"
Write-Host ""
Write-Host "[预计时间] 20-30 分钟（取决于网速）" -ForegroundColor Yellow
Write-Host "[所需磁盘] 约 2-2.5GB" -ForegroundColor Yellow
Write-Host ""

if (-not $Silent) {
    Write-Host "按任意键开始..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
} else {
    Write-Host "[静默模式] 自动开始..." -ForegroundColor Green
    Write-Host ""
}

# 获取当前脚本目录
$SUPER_PKG_DIR = Split-Path -Parent $PSCommandPath
$PROJECT_ROOT = Split-Path -Parent $SUPER_PKG_DIR

Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 1/6] 创建目录结构..." -ForegroundColor Cyan
Write-Host ""

# 创建目录结构
$dirs = @(
    "01-Python安装包",
    "02-项目源码",
    "03-Python依赖包",
    "04-AI模型文件"
)

foreach ($dir in $dirs) {
    $path = Join-Path $SUPER_PKG_DIR $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "[√] 创建: $dir" -ForegroundColor Green
    } else {
        Write-Host "[√] 已存在: $dir" -ForegroundColor Yellow
    }
}
Write-Host ""

Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 2/6] 下载 Python 3.12.7 安装程序..." -ForegroundColor Cyan
Write-Host ""

$pythonInstaller = Join-Path $SUPER_PKG_DIR "01-Python安装包\python-3.12.7-amd64.exe"

if (Test-Path $pythonInstaller) {
    Write-Host "[√] Python 安装程序已存在，跳过下载" -ForegroundColor Yellow
} else {
    Write-Host "[提示] 正在从 python.org 下载 Python 3.12.7..." -ForegroundColor Yellow
    Write-Host "[提示] 文件大小约 26MB，请耐心等待..." -ForegroundColor Yellow
    Write-Host ""
    
    $pythonUrl = "https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe"
    
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller -UseBasicParsing
        Write-Host "[√] Python 安装程序下载完成" -ForegroundColor Green
        
        $size = (Get-Item $pythonInstaller).Length / 1MB
        Write-Host "[√] 文件大小: $([math]::Round($size, 2)) MB" -ForegroundColor Green
    } catch {
        Write-Host "[错误] Python 安装程序下载失败: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "[建议] 请手动下载 Python 3.12.7 安装程序到:" -ForegroundColor Yellow
        Write-Host "  $pythonInstaller" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "下载地址: $pythonUrl" -ForegroundColor Cyan
        exit 1
    }
}
Write-Host ""

# 创建Python安装说明
$pythonReadme = @"
╔════════════════════════════════════════════════════════════════╗
║          Python 3.12.7 安装说明                                ║
╚════════════════════════════════════════════════════════════════╝

📦 本目录包含：
   python-3.11.9-amd64.exe  (约 25MB)

🎯 安装方法：

方法1：自动安装（推荐）
   运行上级目录的「一键完整部署.bat」会自动安装

方法2：手动安装
   1. 双击 python-3.11.9-amd64.exe
   2. 勾选 "Add Python to PATH"
   3. 选择 "Install Now"
   4. 等待安装完成

✅ 验证安装：
   打开命令提示符，输入：python --version
   应该显示：Python 3.11.9

⚠️  注意事项：
   - 安装路径: C:\Program Files\Python311
   - 需要约 150MB 磁盘空间
   - 建议以管理员身份安装

"@

$pythonReadme | Out-File -FilePath (Join-Path $SUPER_PKG_DIR "01-Python安装包\安装Python说明.txt") -Encoding UTF8
Write-Host "[√] 创建 Python 安装说明" -ForegroundColor Green
Write-Host ""

Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 3/6] 复制项目源码..." -ForegroundColor Cyan
Write-Host ""

$projectDst = Join-Path $SUPER_PKG_DIR "02-项目源码\FaceImgMat"

if (Test-Path $projectDst) {
    Write-Host "[提示] 删除旧的项目源码..." -ForegroundColor Yellow
    Remove-Item -Path $projectDst -Recurse -Force
}

Write-Host "[提示] 复制项目文件..." -ForegroundColor Yellow

# 排除不需要的文件和目录
$excludes = @(
    ".git",
    ".venv",
    "__pycache__",
    "*.pyc",
    ".vscode",
    ".idea",
    "node_modules",
    "super-offline-deployment",
    "offline_deployment_package"
)

# 使用robocopy复制文件（更快）
$robocopyArgs = @(
    $PROJECT_ROOT,
    $projectDst,
    "/E",
    "/XD", ".git", ".venv", "__pycache__", ".vscode", ".idea", "node_modules", "super-offline-deployment", "offline_deployment_package",
    "/XF", "*.pyc",
    "/NFL", "/NDL", "/NJH", "/NJS", "/nc", "/ns", "/np"
)

$result = Start-Process -FilePath "robocopy" -ArgumentList $robocopyArgs -Wait -PassThru -NoNewWindow

if ($result.ExitCode -le 8) {
    Write-Host "[√] 项目源码复制完成" -ForegroundColor Green
} else {
    Write-Host "[错误] 项目源码复制失败" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 4/6] 下载 Python 依赖包..." -ForegroundColor Cyan
Write-Host ""

$packagesDir = Join-Path $SUPER_PKG_DIR "03-Python依赖包"
$requirementsFile = Join-Path $projectDst "requirements.txt"

if (!(Test-Path $requirementsFile)) {
    Write-Host "[错误] 未找到 requirements.txt 文件" -ForegroundColor Red
    exit 1
}

Write-Host "[提示] 从 requirements.txt 下载依赖包..." -ForegroundColor Yellow
Write-Host "[提示] 这是最耗时的步骤（约 10-15 分钟）..." -ForegroundColor Yellow
Write-Host "[提示] 使用清华大学镜像源加速下载..." -ForegroundColor Yellow
Write-Host "[提示] 为 Python 3.12 下载预编译包（.whl）..." -ForegroundColor Yellow
Write-Host ""

# 下载依赖包（为Python 3.12下载，优先wheel包，包含所有传递依赖）
# 使用 --python-version 确保下载正确版本的包
python -m pip download -r $requirementsFile -d $packagesDir -i https://pypi.tuna.tsinghua.edu.cn/simple --prefer-binary --python-version 3.12 --only-binary=:all: 2>&1 | ForEach-Object {
    $line = $_.ToString()
    if ($line -match "Collecting|Downloading|Saved|Successfully downloaded") {
        Write-Host $line -ForegroundColor Gray
    } elseif ($line -match "ERROR|error") {
        Write-Host $line -ForegroundColor Red
    }
}

if ($LASTEXITCODE -eq 0) {
    $count = (Get-ChildItem $packagesDir -Filter "*.whl").Count
    $size = (Get-ChildItem $packagesDir | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host ""
    Write-Host "[√] 依赖包下载完成" -ForegroundColor Green
    Write-Host "[√] 包数量: $count 个" -ForegroundColor Green
    Write-Host "[√] 总大小: $([math]::Round($size, 2)) MB" -ForegroundColor Green
} else {
    Write-Host "[错误] 依赖包下载失败" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 5/6] 复制 InsightFace 模型..." -ForegroundColor Cyan
Write-Host ""

$modelsSrc = Join-Path $env:USERPROFILE ".insightface\models"
$modelsDst = Join-Path $SUPER_PKG_DIR "04-AI模型文件\insightface_models"

if (Test-Path $modelsSrc) {
    Write-Host "[提示] 找到本地模型文件" -ForegroundColor Yellow
    Write-Host "[提示] 复制模型文件..." -ForegroundColor Yellow
    
    if (Test-Path $modelsDst) {
        Remove-Item -Path $modelsDst -Recurse -Force
    }
    
    Copy-Item -Path $modelsSrc -Destination $modelsDst -Recurse -Force
    
    $size = (Get-ChildItem $modelsDst -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "[√] 模型文件复制完成" -ForegroundColor Green
    Write-Host "[√] 大小: $([math]::Round($size, 2)) MB" -ForegroundColor Green
} else {
    Write-Host "[警告] 未找到本地模型文件" -ForegroundColor Yellow
    Write-Host "[提示] 离线包将不包含模型，首次使用时需要网络下载" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 6/6] 验证离线包完整性..." -ForegroundColor Cyan
Write-Host ""

$checkItems = @{
    "Python安装程序" = (Test-Path $pythonInstaller)
    "项目源码" = (Test-Path $projectDst)
    "依赖包目录" = (Test-Path $packagesDir)
    "部署脚本" = (Test-Path (Join-Path $SUPER_PKG_DIR "一键完整部署.bat"))
}

$allGood = $true
foreach ($item in $checkItems.GetEnumerator()) {
    if ($item.Value) {
        Write-Host "[√] $($item.Key)" -ForegroundColor Green
    } else {
        Write-Host "[×] $($item.Key)" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host ""

if ($allGood) {
    Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                                ║" -ForegroundColor Green
    Write-Host "║              ✅ 超级离线包准备完成！                            ║" -ForegroundColor Green
    Write-Host "║                                                                ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    
    $totalSize = (Get-ChildItem $SUPER_PKG_DIR -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1GB
    
    Write-Host "[离线包信息]" -ForegroundColor Cyan
    Write-Host "  位置: $SUPER_PKG_DIR" -ForegroundColor White
    Write-Host "  大小: $([math]::Round($totalSize, 2)) GB" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[使用方法]" -ForegroundColor Cyan
    Write-Host "  1. 将整个 super-offline-deployment 文件夹复制到目标机器" -ForegroundColor White
    Write-Host "  2. 双击运行「一键完整部署.bat」" -ForegroundColor White
    Write-Host "  3. 等待自动完成（约 15-25 分钟）" -ForegroundColor White
    Write-Host ""
    
    Write-Host "[建议]" -ForegroundColor Yellow
    Write-Host "  - 可以压缩成 ZIP 文件方便传输（约压缩 30-40%）" -ForegroundColor White
    Write-Host "  - 一份离线包可以在多台机器上使用" -ForegroundColor White
    Write-Host ""
    
    Write-Host "按任意键打开离线包目录..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Start-Process "explorer.exe" -ArgumentList $SUPER_PKG_DIR
    
} else {
    Write-Host "[错误] 离线包准备未完成，请检查上方错误信息" -ForegroundColor Red
    exit 1
}
