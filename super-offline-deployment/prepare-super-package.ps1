#!/usr/bin/env pwsh
# FaceImgMat: 准备超级离线包（维护者专用）
# 仅使用 Windows 11 自带 Compress-Archive，无需 tar/7-Zip
# Encoding: UTF-8 with BOM, CRLF

param(
    [switch]$Silent,
    [string]$BundleName = 'offline_bundle',
    [string]$VenvPath,
    [switch]$SkipZip,
    [switch]$ShowRoboLog,          # 显示 robocopy 详细日志
    [ValidateSet('Optimal','Fastest','NoCompression')]
    [string]$CompressionLevel = 'Fastest',
    [ValidateSet('Auto','SevenZip','Tar','CompressArchive')]
    [string]$ZipTool = 'CompressArchive'   # 默认只用系统自带
)

# 设置 UTF-8 输出编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Section([string]$title) {
    Write-Host ""; Write-Host "================================================================" -ForegroundColor Cyan
    if ($title) { Write-Host "[$title]" -ForegroundColor Cyan; Write-Host "" }
}

function Get-DirectorySize([string]$Path) {
    if (-not (Test-Path $Path)) { return 0 }
    $total = 0L
    Get-ChildItem -LiteralPath $Path -Recurse -File | ForEach-Object { $total += $_.Length }
    return $total
}

function Format-Bytes([long]$bytes) {
    if ($bytes -le 0) { return '0 B' }
    $units = 'B','KB','MB','GB','TB'
    $power = [Math]::Min([Math]::Floor([Math]::Log($bytes,1024)), $units.Length - 1)
    $value = $bytes / [Math]::Pow(1024, $power)
    return "{0:N2} {1}" -f $value, $units[$power]
}

# ---------- 仅保留 Compress-Archive 的路径 ----------
function Resolve-ZipTool {
    param([string]$Preference)
    if ($Preference -in 'SevenZip','Tar') {
        Write-Warning "当前脚本仅支持 Compress-Archive，已强制使用该工具"
    }
    return @{ Name = 'CompressArchive'; Path = $null }
}

# ---------- 仅保留 Compress-Archive 分支 ----------
function Invoke-ZipArchive {
    param(
        [string]$SourceDir,
        [string]$Destination,
        [string]$CompressionLevel
    )
    if (Test-Path -LiteralPath $Destination) { Remove-Item -LiteralPath $Destination -Force }

    $level = switch ($CompressionLevel) {
        'Optimal'       { 'Optimal' }
        'NoCompression' { 'NoCompression' }
        Default         { 'Fastest' }
    }

    Compress-Archive -Path $SourceDir -DestinationPath $Destination -Force -CompressionLevel $level
}

# -------------------- 主流程 --------------------
Write-Host @"
================================================================
  FaceImgMat 超级离线包准备工具  (Windows11 自带压缩版)
================================================================
"@ -ForegroundColor Cyan

if (-not $Silent) {
    Write-Host "按任意键开始..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

$SUPER_PKG_DIR = Split-Path -Parent $PSCommandPath
$PROJECT_ROOT  = Split-Path -Parent $SUPER_PKG_DIR
if (-not $VenvPath) { $VenvPath = Join-Path $PROJECT_ROOT '.venv' }

$pythonInstallerName = 'python-3.12.7-amd64.exe'
$pythonInstallerUrls = @(
    'https://repo.huaweicloud.com/python/3.12.7/python-3.12.7-amd64.exe',
    'https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-amd64.exe',
    'https://mirrors.tuna.tsinghua.edu.cn/python-releases/3.12.7/python-3.12.7-amd64.exe',
    'https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe'
)

Write-Section '步骤 1/6: 检查开发环境'
if (-not (Test-Path $VenvPath)) {
    throw "未找到虚拟环境: $VenvPath。请先在项目根目录创建并安装依赖 (python -m venv .venv && .venv\\Scripts\\pip install -r requirements.txt)"
}
$venvPython = Join-Path $VenvPath 'Scripts\python.exe'
if (-not (Test-Path $venvPython)) { throw "虚拟环境缺少 python.exe: $venvPython" }
$pythonVersion = & $venvPython --version 2>&1
Write-Host "[成功] 虚拟环境 Python 版本: $pythonVersion" -ForegroundColor Green
try {
    $pipVersion = & $venvPython -m pip --version 2>&1
    Write-Host "[成功] pip 信息: $pipVersion" -ForegroundColor Green
} catch {
    throw "虚拟环境缺少 pip，请先运行 $venvPython -m ensurepip"
}

Write-Section '步骤 2/6: 准备输出目录'
@('00-编译工具','01-Python安装包','02-项目源码','03-Python依赖包','04-AI模型文件') | ForEach-Object {
    $path = Join-Path $SUPER_PKG_DIR $_
    if (-not (Test-Path $path)) { $null = New-Item -ItemType Directory -Path $path }
}
Write-Host "[成功] 输出目录已准备" -ForegroundColor Green

Write-Section '步骤 3/6: 准备 Python 安装程序'
$pythonInstallerPath = Join-Path $SUPER_PKG_DIR (Join-Path '01-Python安装包' $pythonInstallerName)
if (Test-Path $pythonInstallerPath) {
    Write-Host "[跳过] 已存在 Python 安装包: $pythonInstallerPath" -ForegroundColor Yellow
} else {
    $downloaded = $false
    foreach ($url in $pythonInstallerUrls) {
        try {
            Write-Host "[下载] $url" -ForegroundColor Cyan
            Invoke-WebRequest -Uri $url -OutFile $pythonInstallerPath -UseBasicParsing -ErrorAction Stop
            $downloaded = $true; break
        } catch {
            Write-Host "  [失败] $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    if ($downloaded) {
        Write-Host "[成功] Python 安装包已下载" -ForegroundColor Green
    } else {
        Write-Host "[警告] 未能下载 Python 安装程序，请手动放入 01-Python安装包" -ForegroundColor Yellow
    }
}

Write-Section '步骤 4/6: 复制项目源码'
$projectDst = Join-Path $SUPER_PKG_DIR '02-项目源码\FaceImgMat'
if (Test-Path $projectDst) { Remove-Item $projectDst -Recurse -Force }
$roboArgs = @(
    $PROJECT_ROOT, $projectDst, '/MIR',
    '/XD','.git','.venv','__pycache__','.vscode','.idea','node_modules','super-offline-deployment','offline_deployment_package','offline_bundle',
    '/XF','*.pyc'
)
if (-not $ShowRoboLog) { $roboArgs += @('/NFL','/NDL','/NJH','/NJS','/NC','/NS','/NP') }
& robocopy @roboArgs
if ($LASTEXITCODE -ge 8) { throw "robocopy 复制项目失败，退出码 $LASTEXITCODE" }
Write-Host "[成功] 项目源码已复制" -ForegroundColor Green

Write-Section '步骤 5/6: 导出虚拟环境依赖'

# ===== 验证 NumPy 版本 =====
Write-Host "[检查] 验证 NumPy 版本..." -ForegroundColor Cyan
$currentPackages = & $venvPython -m pip list --format=freeze 2>&1
$currentNumpy = ($currentPackages | Where-Object { $_ -match '^numpy==(.+)$' }) -replace '^numpy==', ''
Write-Host "[信息] 当前 NumPy 版本: $currentNumpy" -ForegroundColor Cyan

$requirementsPath = Join-Path $PROJECT_ROOT 'requirements.txt'
if (-not $currentNumpy) {
    throw "虚拟环境中未检测到 NumPy，请先安装 requirements.txt 中的依赖"
}
if (Test-Path $requirementsPath) {
    $requirementsContent = Get-Content -LiteralPath $requirementsPath -Raw
    $requiredMatch = [regex]::Match($requirementsContent, "(?im)^\s*numpy==([^\s#]+)")
    if ($requiredMatch.Success) {
        $requiredNumpy = $requiredMatch.Groups[1].Value.Trim()
        Write-Host "[信息] requirements.txt 指定 NumPy 版本: $requiredNumpy" -ForegroundColor Cyan
        if ($requiredNumpy -and $currentNumpy -ne $requiredNumpy) {
            throw "虚拟环境中的 NumPy 版本 $currentNumpy 与 requirements.txt 中的 $requiredNumpy 不一致，请先在虚拟环境中执行 .\.venv\Scripts\python.exe -m pip install --force-reinstall numpy==$requiredNumpy"
        }
    } else {
        Write-Host "[警告] requirements.txt 中未找到 numpy==X.Y.Z 的固定版本" -ForegroundColor Yellow
    }
} else {
    Write-Host "[警告] 未找到 requirements.txt，跳过版本比对" -ForegroundColor Yellow
}

$packagesDir = Join-Path $SUPER_PKG_DIR '03-Python依赖包'
if (Test-Path $packagesDir) { Remove-Item $packagesDir -Recurse -Force }
$null = New-Item -ItemType Directory -Path $packagesDir

# ---- 优先复用项目根目录的 requirements.lock ----
$lockPath = Join-Path $packagesDir 'requirements.lock'
$devLock  = Join-Path $PROJECT_ROOT 'requirements.lock'
if (Test-Path $devLock) {
    Write-Host "[拷贝] 发现项目根目录已有 requirements.lock，直接复用" -ForegroundColor Green
    Copy-Item $devLock $lockPath -Force
} else {
    Write-Host "[生成] 项目根目录无 requirements.lock，现场 pip freeze 生成" -ForegroundColor Yellow
    & $venvPython -m pip freeze | Set-Content -Path $lockPath -Encoding UTF8
}

# ---- 复制 site-packages ----
$sitePackagesSrc = Join-Path $VenvPath 'Lib\site-packages'
$sitePackagesDst = Join-Path $packagesDir 'site-packages'
Write-Host "[信息] 正在复制 site-packages，请稍候..." -ForegroundColor Cyan
$roboArgs = @($sitePackagesSrc, $sitePackagesDst, '/E', '/PURGE', '/XD', '__pycache__', '/XF', '*.pyc')
if (-not $ShowRoboLog) { $roboArgs += @('/NFL','/NDL','/NJH','/NJS','/NC','/NS','/NP') }
& robocopy @roboArgs
if ($LASTEXITCODE -ge 8) { throw "复制 site-packages 失败，退出码 $LASTEXITCODE" }

# ---- wheels 处理 ----
Write-Host "[信息] 准备 wheels 子目录..." -ForegroundColor Cyan
$wheelDir = Join-Path $packagesDir 'wheels'
$devWheelDir = if (Test-Path (Join-Path $PROJECT_ROOT 'wheel')) {
    Join-Path $PROJECT_ROOT 'wheel'
} elseif (Test-Path (Join-Path $PROJECT_ROOT 'wheels')) {
    Join-Path $PROJECT_ROOT 'wheels'
} else { $null }

if ($devWheelDir -and (Get-ChildItem -Path $devWheelDir -Filter '*.whl' -File).Count) {
    Write-Host "[拷贝] 发现开发目录已有 wheels，直接复制: $devWheelDir" -ForegroundColor Green
    if (-not (Test-Path $wheelDir)) { $null = New-Item -ItemType Directory -Path $wheelDir }
    $roboArgs = @($devWheelDir, $wheelDir, '/MIR')
    if (-not $ShowRoboLog) { $roboArgs += @('/NFL','/NDL','/NJH','/NJS','/NC','/NS','/NP') }
    & robocopy @roboArgs
    if ($LASTEXITCODE -ge 8) { throw "复制已有 wheels 失败" }
} else {
    Write-Host "[下载] 未找到可用本地 wheels，正在重新下载..." -ForegroundColor Yellow
    if (-not (Test-Path $wheelDir)) { $null = New-Item -ItemType Directory -Path $wheelDir }
    & $venvPython -m pip download -r $lockPath -d $wheelDir --no-deps
    if ($LASTEXITCODE -ne 0) { Write-Warning "wheel 补全失败，部署端将 fallback 到 site-packages 拷贝" }
}

Write-Host "[成功] 虚拟环境依赖已导出" -ForegroundColor Green

Write-Section '步骤 6/6: 构建离线超级包'
$bundleRoot = Join-Path $SUPER_PKG_DIR $BundleName
if (Test-Path $bundleRoot) { Remove-Item $bundleRoot -Recurse -Force }
$null = New-Item -ItemType Directory -Path $bundleRoot

& robocopy (Join-Path $SUPER_PKG_DIR '02-项目源码\FaceImgMat') (Join-Path $bundleRoot 'FaceImgMat') /MIR /XD __pycache__ /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "复制项目到离线包失败" }

& robocopy $sitePackagesDst (Join-Path $bundleRoot 'site-packages') /MIR /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "复制 site-packages 到离线包失败" }

# Python 安装包
$bundlePythonDir = Join-Path $bundleRoot 'python'
$null = New-Item -ItemType Directory -Path $bundlePythonDir
if (Test-Path $pythonInstallerPath) {
    Copy-Item $pythonInstallerPath (Join-Path $bundlePythonDir $pythonInstallerName) -Force
    Write-Host "[成功] 已包含 Python 安装包" -ForegroundColor Green
} else {
    Write-Host "[警告] 离线包未包含 Python 安装包，请手动补齐" -ForegroundColor Yellow
}

# 模型文件
$bundleModelDir = Join-Path $bundleRoot 'models'
$null = New-Item -ItemType Directory -Path $bundleModelDir
foreach ($modelSrc in @(
        (Join-Path $SUPER_PKG_DIR '04-AI模型文件\insightface_models'),
        (Join-Path $env:USERPROFILE '.insightface\models')
)) {
    if (Test-Path $modelSrc) {
        & robocopy $modelSrc (Join-Path $bundleModelDir 'insightface_models') /MIR /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
        if ($LASTEXITCODE -lt 8) { break }
    }
}

Copy-Item $lockPath (Join-Path $bundleRoot 'requirements.lock') -Force

# 把 wheels 目录也复制进去（如果生成成功）
if (Test-Path $wheelDir) {
    $bundleWheelDir = Join-Path $bundleRoot 'wheels'
    & robocopy $wheelDir $bundleWheelDir /MIR /NFL /NDL /NJH /NJS /NC /NS /NP | Out-Null
}

# 写说明
@"
# FaceImgMat 超级离线包

- 构建时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- 来源虚拟环境: $VenvPath
- 依赖快照: requirements.lock
- NumPy 版本: $currentNumpy

目录结构：
- FaceImgMat/                项目源码
- site-packages/             预构建依赖
- wheels/                    离线 wheel 包（优先使用）
- python/                    Python 安装程序
- models/insightface_models  InsightFace 模型
- requirements.lock          依赖版本记录
"@ | Set-Content (Join-Path $bundleRoot 'README-OFFLINE-BUNDLE.md') -Encoding UTF8

$bundleSize = Get-DirectorySize $bundleRoot
Write-Host "[信息] 离线包目录大小: $(Format-Bytes $bundleSize)" -ForegroundColor Cyan

# -------------------- 压缩 --------------------
$bundleZip = Join-Path $SUPER_PKG_DIR ($BundleName + '.zip')
if (-not $SkipZip) {
    $fileCount = (Get-ChildItem -LiteralPath $bundleRoot -Recurse -File | Measure-Object).Count
    if ($fileCount -eq 0) { throw "离线包源目录为空，请检查前置步骤" }

    $resolvedTool = Resolve-ZipTool -Preference 'CompressArchive'
    Write-Host "[信息] 正在使用 Compress-Archive 压缩 -> $bundleZip (级别：$CompressionLevel)..." -ForegroundColor Cyan
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        Invoke-ZipArchive -SourceDir $bundleRoot -Destination $bundleZip -CompressionLevel $CompressionLevel
    } catch {
        throw "压缩离线包失败: $($_.Exception.Message)"
    } finally {
        $sw.Stop()
    }

    $zipSize = (Get-Item $bundleZip).Length
    Write-Host ("[成功] {0} 已生成，大小 {1}，耗时 {2}" -f $bundleZip, (Format-Bytes $zipSize), $sw.Elapsed.ToString('mm\:ss')) -ForegroundColor Green
} else {
    Write-Host "[提示] 已跳过压缩，可手动打包 $bundleRoot" -ForegroundColor Yellow
    Write-Host "      推荐命令（保持长路径）：" -ForegroundColor DarkYellow
    Write-Host "      robocopy `"$bundleRoot`" <目标目录> /MIR" -ForegroundColor DarkYellow
    $bundleZip = $null
}

# -------------------- 结束 --------------------
Write-Host ""; Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "[完成] 超级离线包已生成" -ForegroundColor Green
if ($bundleZip) {
    Write-Host "[输出] $bundleZip" -ForegroundColor Cyan
    Write-Host "[下一步] 将 ZIP 上传到 GitHub Release 并与部署脚本一起分发" -ForegroundColor Yellow
} else {
    Write-Host "[输出] $bundleRoot" -ForegroundColor Cyan
    Write-Host "[下一步] 手动压缩 offline_bundle 目录或保持文件夹形式传输" -ForegroundColor Yellow
}
Write-Host "================================================================" -ForegroundColor Cyan