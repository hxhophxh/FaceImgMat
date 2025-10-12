#!/usr/bin/env pwsh
# ===================================================================
# FaceImgMat 在线一键部署脚本 (Windows PowerShell)
# ===================================================================
# 适用场景：全新Windows机器，有网络连接
# 功能：自动检查环境、创建虚拟环境、安装依赖、初始化数据、启动服务
# ===================================================================

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

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

# 检查命令是否存在
function Test-CommandExists {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# 显示欢迎信息
Clear-Host
Write-ColorOutput @"
╔════════════════════════════════════════════════════════════╗
║        🎭 FaceImgMat 人脸识别系统 - 在线一键部署          ║
║                     版本: 1.0.0                            ║
╚════════════════════════════════════════════════════════════╝
"@ "Magenta"

Write-Info "部署时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Info "工作目录: $PWD"
Write-ColorOutput ""

# ===================================================================
# 第1步：环境检查
# ===================================================================
Write-Step "步骤 1/6: 环境检查"

# 检查Python
Write-Info "检查 Python 安装..."
if (-not (Test-CommandExists "python")) {
    Write-Error-Custom "未找到 Python！"
    Write-Warning-Custom "请先安装 Python 3.11 或 3.12"
    Write-Warning-Custom "下载地址: https://www.python.org/downloads/"
    exit 1
}

$pythonVersion = python --version 2>&1
Write-Success "发现 Python: $pythonVersion"

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
} else {
    Write-Warning-Custom "无法解析 Python 版本，继续执行..."
}

# 检查pip
Write-Info "检查 pip 安装..."
if (-not (Test-CommandExists "pip")) {
    Write-Error-Custom "未找到 pip！"
    Write-Warning-Custom "请重新安装 Python 并确保勾选 'pip' 组件"
    exit 1
}
Write-Success "发现 pip: $(pip --version)"

# 检查网络连接
Write-Info "检查网络连接..."
try {
    $response = Test-Connection -ComputerName pypi.org -Count 1 -Quiet -ErrorAction SilentlyContinue
    if ($response) {
        Write-Success "网络连接正常"
    } else {
        Write-Warning-Custom "无法连接到 pypi.org，可能会影响包下载"
        Write-Warning-Custom "如果部署失败，请检查网络或使用离线部署方式"
    }
} catch {
    Write-Warning-Custom "网络检查失败，继续执行..."
}

# 检查磁盘空间
Write-Info "检查磁盘空间..."
$drive = (Get-Location).Drive.Name + ":"
$disk = Get-PSDrive -Name $drive[0]
$freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
if ($freeSpaceGB -lt 5) {
    Write-Error-Custom "磁盘空间不足！剩余: ${freeSpaceGB}GB，建议至少 5GB"
    exit 1
}
Write-Success "磁盘空间充足: ${freeSpaceGB}GB 可用"

# ===================================================================
# 第2步：创建虚拟环境
# ===================================================================
Write-Step "步骤 2/6: 创建 Python 虚拟环境"

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
if (-not (Test-Path $activateScript)) {
    Write-Error-Custom "找不到激活脚本: $activateScript"
    exit 1
}

# 设置执行策略（如果需要）
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
} catch {
    Write-Warning-Custom "无法设置执行策略，可能需要管理员权限"
}

& $activateScript
Write-Success "虚拟环境激活成功"

# 升级 pip
Write-Info "升级 pip 到最新版本..."
python -m pip install --upgrade pip --quiet
Write-Success "pip 升级完成"

# ===================================================================
# 第3步：安装依赖包
# ===================================================================
Write-Step "步骤 3/6: 安装 Python 依赖包"

if (-not (Test-Path "requirements.txt")) {
    Write-Error-Custom "未找到 requirements.txt 文件！"
    exit 1
}

Write-Info "开始安装依赖包（这可能需要 5-15 分钟，请耐心等待）..."
Write-Warning-Custom "正在下载和安装: Flask, InsightFace, FAISS, OpenCV 等..."

# 使用超时和重试机制
$maxRetries = 3
$retryCount = 0
$installSuccess = $false

while ($retryCount -lt $maxRetries -and -not $installSuccess) {
    if ($retryCount -gt 0) {
        Write-Warning-Custom "第 $($retryCount + 1) 次尝试安装..."
    }
    
    try {
        pip install -r requirements.txt --timeout 300
        if ($LASTEXITCODE -eq 0) {
            $installSuccess = $true
        } else {
            $retryCount++
        }
    } catch {
        $retryCount++
    }
}

if (-not $installSuccess) {
    Write-Error-Custom "依赖包安装失败！"
    Write-Warning-Custom "可能的原因："
    Write-Warning-Custom "  1. 网络连接不稳定"
    Write-Warning-Custom "  2. PyPI 服务器响应慢"
    Write-Warning-Custom "建议："
    Write-Warning-Custom "  1. 检查网络连接"
    Write-Warning-Custom "  2. 使用国内镜像: pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple"
    Write-Warning-Custom "  3. 使用离线部署方式"
    exit 1
}

Write-Success "所有依赖包安装完成！"

# 验证关键包
Write-Info "验证关键依赖..."
$keyPackages = @("flask", "insightface", "faiss-cpu", "opencv-python")
foreach ($pkg in $keyPackages) {
    $installed = pip show $pkg 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "  ✓ $pkg"
    } else {
        Write-Error-Custom "  ✗ $pkg 未正确安装"
        exit 1
    }
}

# ===================================================================
# 第4步：创建必要的目录
# ===================================================================
Write-Step "步骤 4/6: 创建项目目录结构"

$directories = @(
    "static/faces",
    "static/uploads",
    "instance",
    "logs",
    "models"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Success "创建目录: $dir"
    } else {
        Write-Info "目录已存在: $dir"
    }
}

# ===================================================================
# 第5步：初始化数据库和演示数据
# ===================================================================
Write-Step "步骤 5/6: 初始化数据库和演示数据"

if (Test-Path "scripts/init_demo_data.py") {
    Write-Info "运行数据初始化脚本..."
    python scripts/init_demo_data.py
    if ($LASTEXITCODE -eq 0) {
        Write-Success "数据库和演示数据初始化成功"
        Write-Info "已创建 3 个测试人员（张三、李四、王五）"
    } else {
        Write-Warning-Custom "数据初始化失败，但不影响系统启动"
    }
} else {
    Write-Warning-Custom "未找到初始化脚本，跳过数据初始化"
}

# ===================================================================
# 第6步：启动服务
# ===================================================================
Write-Step "步骤 6/6: 启动 FaceImgMat 服务"

Write-ColorOutput @"

╔════════════════════════════════════════════════════════════╗
║                    🎉 部署完成！                           ║
╚════════════════════════════════════════════════════════════╝
"@ "Green"

Write-Info "系统信息："
Write-Success "  访问地址: http://127.0.0.1:5000"
Write-Success "  默认账号: admin"
Write-Success "  默认密码: Admin@FaceMatch2025!"

Write-ColorOutput ""
Write-Warning-Custom "安全提醒："
Write-Info "  1. 首次登录后请立即修改管理员密码"
Write-Info "  2. 运行命令: python scripts/change_admin_password.py"
Write-Info "  3. 生产环境请配置 HTTPS 和防火墙"

Write-ColorOutput ""
Write-Info "正在启动服务..."
Write-Warning-Custom "按 Ctrl+C 可停止服务"
Write-ColorOutput ""

# 启动服务
python run.py
