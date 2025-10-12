#!/usr/bin/env pwsh
# ===================================================================
# FaceImgMat 离线部署安装脚本 (Windows PowerShell)
# ===================================================================
# 使用说明：
#   1. 将离线部署包解压到任意目录
#   2. 在包含此脚本的目录运行: .\deploy_offline.ps1
#   3. 等待自动部署完成
# ===================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# ===================================================================
# 检查并设置PowerShell执行策略
# ===================================================================
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -eq "Restricted" -or $currentPolicy -eq "Undefined") {
    Write-Host "检测到PowerShell执行策略限制，正在调整..." -ForegroundColor Yellow
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "✓ 执行策略已设置为 RemoteSigned" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  无法自动设置执行策略，请手动运行：" -ForegroundColor Yellow
        Write-Host "   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Cyan
        Write-Host ""
        Read-Host "按回车键继续（或Ctrl+C退出）"
    }
}

# 颜色输出函数
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    $colors = @{
        "Green" = "Green"; "Red" = "Red"; "Yellow" = "Yellow"; 
        "Cyan" = "Cyan"; "White" = "White"; "Magenta" = "Magenta"
    }
    Write-Host $Message -ForegroundColor $colors[$Color]
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput "`n[$(Get-Date -Format 'HH:mm:ss')] ===== $Message =====" "Cyan"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "  [✓] $Message" "Green"
}

function Write-Error-Custom {
    param([string]$Message)
    Write-ColorOutput "  [✗] $Message" "Red"
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-ColorOutput "  [!] $Message" "Yellow"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "  [i] $Message" "White"
}

# 显示欢迎信息
Clear-Host
Write-ColorOutput @"
╔════════════════════════════════════════════════════════════╗
║      🎭 FaceImgMat 人脸识别系统 - 离线一键部署            ║
║                   版本: 1.0.0 (Offline)                    ║
╚════════════════════════════════════════════════════════════╝
"@ "Magenta"

Write-Info "部署时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Info "工作目录: $PWD"
Write-ColorOutput ""

# ===================================================================
# 第1步：检查离线包结构
# ===================================================================
Write-Step "步骤 1/7: 检查离线部署包"

Write-Info "验证离线包完整性..."

# 检查必要的目录和文件
$requiredItems = @(
    @{Path = "FaceImgMat"; Type = "Directory"; Name = "项目源代码"},
    @{Path = "python_packages"; Type = "Directory"; Name = "Python依赖包"},
    @{Path = "FaceImgMat/requirements.txt"; Type = "File"; Name = "依赖列表文件"}
)

$allItemsPresent = $true
foreach ($item in $requiredItems) {
    if (Test-Path $item.Path) {
        Write-Success "$($item.Name): $($item.Path)"
    } else {
        Write-Error-Custom "缺失 $($item.Name): $($item.Path)"
        $allItemsPresent = $false
    }
}

if (-not $allItemsPresent) {
    Write-Error-Custom "离线包不完整！请确保解压完整的离线部署包。"
    exit 1
}

# 检查Python包数量
$packageCount = (Get-ChildItem "python_packages" -File).Count
$packageSize = [math]::Round((Get-ChildItem "python_packages" | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
Write-Info "Python依赖包: $packageCount 个文件, ${packageSize}MB"

# 检查模型文件
if (Test-Path "insightface_models") {
    $modelSize = [math]::Round((Get-ChildItem "insightface_models" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    Write-Success "InsightFace模型: ${modelSize}MB"
    $hasModels = $true
} else {
    Write-Warning-Custom "未找到InsightFace模型，首次运行时将自动下载（需要网络）"
    $hasModels = $false
}

# ===================================================================
# 第2步：环境检查
# ===================================================================
Write-Step "步骤 2/7: 环境检查"

# 检查Python
Write-Info "检查 Python 安装..."
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Python not found"
    }
    Write-Success "发现 Python: $pythonVersion"
} catch {
    Write-Error-Custom "未找到 Python！"
    Write-Warning-Custom "请先安装 Python 3.11 或 3.12"
    Write-Warning-Custom "下载地址: https://www.python.org/downloads/"
    exit 1
}

# 检查Python版本
$versionMatch = $pythonVersion -match "Python (\d+)\.(\d+)"
if ($versionMatch) {
    $majorVersion = [int]$matches[1]
    $minorVersion = [int]$matches[2]
    
    if ($majorVersion -ne 3 -or $minorVersion -lt 11) {
        Write-Error-Custom "需要 Python 3.11 或更高版本，当前版本: $pythonVersion"
        Write-Warning-Custom "建议安装 Python 3.11 或 3.12"
        exit 1
    }
    Write-Success "Python 版本检查通过"
}

# 检查磁盘空间
Write-Info "检查磁盘空间..."
$drive = (Get-Location).Drive.Name + ":"
$disk = Get-PSDrive -Name $drive[0]
$freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
if ($freeSpaceGB -lt 3) {
    Write-Error-Custom "磁盘空间不足！剩余: ${freeSpaceGB}GB，建议至少 3GB"
    exit 1
}
Write-Success "磁盘空间充足: ${freeSpaceGB}GB 可用"

# ===================================================================
# 第3步：进入项目目录
# ===================================================================
Write-Step "步骤 3/7: 准备项目目录"

$projectPath = Join-Path $PWD "FaceImgMat"
Write-Info "项目路径: $projectPath"

Set-Location $projectPath
Write-Success "已进入项目目录"

# ===================================================================
# 第4步：创建虚拟环境
# ===================================================================
Write-Step "步骤 4/7: 创建 Python 虚拟环境"

$venvPath = ".venv"
if (Test-Path $venvPath) {
    Write-Warning-Custom "虚拟环境已存在，将重新创建..."
    Remove-Item -Recurse -Force $venvPath
}

Write-Info "创建虚拟环境..."
python -m venv $venvPath
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "创建虚拟环境失败！"
    exit 1
}
Write-Success "虚拟环境创建成功"

# 激活虚拟环境
Write-Info "激活虚拟环境..."
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"

try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
} catch {
    Write-Warning-Custom "无法设置执行策略，可能需要管理员权限"
}

& $activateScript
Write-Success "虚拟环境激活成功"

# 升级 pip（离线模式）
Write-Info "升级 pip..."
$packagesPath = Join-Path (Split-Path $projectPath) "python_packages"
python -m pip install --upgrade pip --no-index --find-links="$packagesPath" --quiet
Write-Success "pip 升级完成"

# ===================================================================
# 第5步：安装依赖包（离线）
# ===================================================================
Write-Step "步骤 5/7: 安装 Python 依赖包（离线模式）"

Write-Info "从本地包安装依赖..."
Write-Info "包目录: $packagesPath"

pip install -r requirements.txt --no-index --find-links="$packagesPath"

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "依赖包安装失败！"
    Write-Warning-Custom "请检查 python_packages 目录是否包含所有必要的包"
    exit 1
}

Write-Success "所有依赖包安装完成！"

# 验证关键包
Write-Info "验证关键依赖..."
$keyPackages = @("flask", "insightface", "faiss-cpu", "opencv-python")
foreach ($pkg in $keyPackages) {
    pip show $pkg 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "  ✓ $pkg"
    } else {
        Write-Error-Custom "  ✗ $pkg 未正确安装"
        exit 1
    }
}

# ===================================================================
# 第6步：配置InsightFace模型
# ===================================================================
Write-Step "步骤 6/7: 配置 InsightFace 模型"

if ($hasModels) {
    Write-Info "复制 InsightFace 模型到用户目录..."
    
    $modelSrc = Join-Path (Split-Path $projectPath) "insightface_models"
    $modelDst = Join-Path $env:USERPROFILE ".insightface\models"
    
    if (-not (Test-Path (Split-Path $modelDst))) {
        New-Item -ItemType Directory -Path (Split-Path $modelDst) -Force | Out-Null
    }
    
    if (Test-Path $modelDst) {
        Write-Info "目标目录已存在，将覆盖..."
        Remove-Item -Recurse -Force $modelDst
    }
    
    Copy-Item -Path $modelSrc -Destination $modelDst -Recurse -Force
    Write-Success "模型文件已配置到: $modelDst"
    
    # 列出模型文件
    Write-Info "已安装的模型："
    Get-ChildItem $modelDst -Recurse -File | ForEach-Object {
        $sizeMB = [math]::Round($_.Length / 1MB, 2)
        Write-Info "  - $($_.Name) (${sizeMB}MB)"
    }
} else {
    Write-Warning-Custom "未提供离线模型，首次运行时需要网络连接下载模型"
}

# ===================================================================
# 第7步：初始化数据库
# ===================================================================
Write-Step "步骤 7/7: 初始化数据库"

# 创建必要的目录
$directories = @("static/faces", "static/uploads", "instance", "logs", "models")
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Success "创建目录: $dir"
    }
}

# 检查数据库是否已存在
$dbPath = "instance\face_matching.db"
if (-not (Test-Path $dbPath)) {
    Write-Info "数据库不存在，正在初始化..."
    
    if (Test-Path "scripts\init_demo_data.py") {
        python scripts\init_demo_data.py
        if ($LASTEXITCODE -eq 0) {
            Write-Success "数据库初始化成功，已创建演示数据"
        } else {
            Write-Warning-Custom "数据库初始化失败，但不影响系统运行"
        }
    } else {
        Write-Warning-Custom "未找到初始化脚本"
    }
} else {
    Write-Info "数据库已存在: $dbPath"
    $dbSize = [math]::Round((Get-Item $dbPath).Length / 1KB, 2)
    Write-Info "数据库大小: ${dbSize}KB"
}

# ===================================================================
# 部署完成
# ===================================================================
Write-ColorOutput @"

╔════════════════════════════════════════════════════════════╗
║              🎉 离线部署完成！                             ║
╚════════════════════════════════════════════════════════════╝
"@ "Green"

Write-ColorOutput ""
Write-Info "系统信息："
Write-Success "  项目路径: $projectPath"
Write-Success "  访问地址: http://127.0.0.1:5000"
Write-Success "  默认账号: admin"
Write-Success "  默认密码: Admin@FaceMatch2025!"

Write-ColorOutput ""
Write-Warning-Custom "安全提醒："
Write-Info "  1. 首次登录后请立即修改管理员密码"
Write-Info "  2. 运行命令: python scripts\change_admin_password.py"
Write-Info "  3. 生产环境请配置 HTTPS 和防火墙"

Write-ColorOutput ""
Write-Info "启动服务："
Write-ColorOutput "  cd FaceImgMat" "Cyan"
Write-ColorOutput "  .\.venv\Scripts\Activate.ps1" "Cyan"
Write-ColorOutput "  python run.py" "Cyan"

Write-ColorOutput ""
Write-Warning-Custom "是否立即启动服务？(Y/N)"
$response = Read-Host
if ($response -eq "Y" -or $response -eq "y") {
    Write-Info "正在启动服务..."
    Write-Warning-Custom "按 Ctrl+C 可停止服务"
    Write-ColorOutput ""
    python run.py
}
