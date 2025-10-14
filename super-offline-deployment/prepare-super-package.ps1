#!/usr/bin/env pwsh
# FaceImgMat: Prepare Super Offline Package (Online machine)
# Encoding: UTF-8 with BOM, CRLF

param(
    [switch]$Silent
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Section([string]$title) {
    Write-Host ""; Write-Host "================================================================" -ForegroundColor Cyan
    if ($title) { Write-Host "[$title]" -ForegroundColor Cyan; Write-Host "" }
}

# Intro (ASCII-only)
Write-Host @"
================================================================
  FaceImgMat Super Offline Package Preparer
  (Run this on an online Windows machine)
================================================================
"@ -ForegroundColor Cyan

if (-not $Silent) {
    Write-Host "Press any key to start..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Paths
$SUPER_PKG_DIR = Split-Path -Parent $PSCommandPath
$PROJECT_ROOT  = Split-Path -Parent $SUPER_PKG_DIR

# --- Utils ---
function Get-PythonInfo {
    $info = [ordered]@{ HasAny=$false; Has312=$false; Cmd=$null; VersionText=$null }
    try {
        $v = & python --version 2>&1
        if ($LASTEXITCODE -eq 0 -and $v) {
            $info.VersionText = $v.Trim()
            if ($v -match 'Python 3\.') { $info.HasAny = $true; $info.Cmd = 'python' }
            if ($v -match 'Python 3\.12\.') { $info.Has312 = $true }
        }
    } catch {}
    return $info
}

function Test-BuildTools {
    $vsRoots = @(
        "C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools",
        "C:\\Program Files\\Microsoft Visual Studio\\2022\\BuildTools",
        "C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\Community",
        "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community"
    )
    foreach ($r in $vsRoots) { if (Test-Path $r) { return $true } }
    return $false
}

function Install-Python312([string]$InstallerPath) {
    Write-Host "[INFO] Installing temp Python 3.12.7..." -ForegroundColor Cyan
    $installPath = 'D:\\Python312-Temp'
    $argsList = @('/quiet','InstallAllUsers=0','PrependPath=1','Include_test=0','Include_doc=0',"TargetDir=$installPath")
    $p = Start-Process -FilePath $InstallerPath -ArgumentList $argsList -Wait -PassThru -NoNewWindow
    if ($p.ExitCode -eq 0) {
        $exe = Join-Path $installPath 'python.exe'
        if (Test-Path $exe) { return $exe } else { return $null }
    }
    if ($p.ExitCode -eq 1638) {
        $pi = Get-PythonInfo
        if ($pi.Has312) { return 'python' }
        $exe = Join-Path $installPath 'python.exe'
        if (Test-Path $exe) { return $exe }
    }
    return $null
}

function Remove-TempPython([bool]$NeedCleanup) {
    if (-not $NeedCleanup) { return }
    $tempPath = 'D:\\Python312-Temp'
    if (Test-Path $tempPath) { Remove-Item -Path $tempPath -Recurse -Force }
}

# Step 1: Check Python
Write-Section 'Step 1/6: Check Python'
$py = Get-PythonInfo
$pythonCommand = $py.Cmd
$needCleanup = $false
if ($py.Has312) {
    Write-Host "[OK] Found $($py.VersionText)" -ForegroundColor Green
} elseif ($py.HasAny) {
    Write-Host "[INFO] Found $($py.VersionText); will still download wheels for 3.12" -ForegroundColor Yellow
} else {
    Write-Host "[INFO] No Python found; will install temp 3.12.7 later" -ForegroundColor Yellow
}

# Step 2: Check Build Tools (optional)
Write-Section 'Step 2/6: Check VS Build Tools (optional)'
$hasBT = Test-BuildTools
if ($hasBT) { Write-Host "[OK] VS Build Tools detected" -ForegroundColor Green } else { Write-Host "[WARN] VS Build Tools not detected" -ForegroundColor Yellow }

# Step 3: Create folders
Write-Section 'Step 3/6: Create folders'
$dirs = @('00-编译工具','01-Python安装包','02-项目源码','03-Python依赖包','04-AI模型文件')
foreach ($d in $dirs) { $p = Join-Path $SUPER_PKG_DIR $d; if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null } }
Write-Host "[OK] Folders ready" -ForegroundColor Green

# Step 4: Download Python installer
Write-Section 'Step 4/6: Download Python 3.12.7 installer'
$pyInstaller = Join-Path $SUPER_PKG_DIR '01-Python安装包\python-3.12.7-amd64.exe'
if (Test-Path $pyInstaller) {
    Write-Host "[SKIP] Python installer exists" -ForegroundColor Yellow
} else {
    $urls = @(
        'https://repo.huaweicloud.com/python/3.12.7/python-3.12.7-amd64.exe',
        'https://registry.npmmirror.com/-/binary/python/3.12.7/python-3.12.7-amd64.exe',
        'https://mirrors.tuna.tsinghua.edu.cn/python-releases/3.12.7/python-3.12.7-amd64.exe',
        'https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe'
    )
    $ok = $false
    foreach ($u in $urls) {
        try { Invoke-WebRequest -Uri $u -OutFile $pyInstaller -UseBasicParsing -ErrorAction Stop; $ok = $true; break } catch { Write-Host "[WARN] $u failed: $($_.Exception.Message)" -ForegroundColor Yellow }
    }
    if (-not $ok) { throw 'Failed to download Python installer' }
}

# Step 5: Copy project source
Write-Section 'Step 5/6: Copy project source'
$dst = Join-Path $SUPER_PKG_DIR '02-项目源码\FaceImgMat'
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
$rc = Start-Process -FilePath 'robocopy' -ArgumentList @($PROJECT_ROOT,$dst,'/E','/XD','.git','.venv','__pycache__','.vscode','.idea','node_modules','super-offline-deployment','offline_deployment_package','/XF','*.pyc','/NFL','/NDL','/NJH','/NJS','/NC','/NS','/NP') -Wait -PassThru -NoNewWindow
if ($rc.ExitCode -gt 8) { throw 'robocopy failed' } else { Write-Host "[OK] Project copied" -ForegroundColor Green }

# Step 6: Download wheels for Python 3.12
Write-Section 'Step 6/6: Download dependency wheels (for 3.12)'
$packagesDir = Join-Path $SUPER_PKG_DIR '03-Python依赖包'
$req = Join-Path $dst 'requirements.txt'
if (-not (Test-Path $req)) { throw 'requirements.txt not found in project' }
if (-not $py.HasAny) {
    $pythonCommand = Install-Python312 -InstallerPath $pyInstaller
    if (-not $pythonCommand) { throw 'Cannot install or find Python 3.12' }
    if ($pythonCommand -ne 'python') { $needCleanup = $true }
}
Write-Host "[INFO] Using: $pythonCommand -m pip download ..." -ForegroundColor Yellow
& $pythonCommand -m pip download -r $req -d $packagesDir -i https://pypi.tuna.tsinghua.edu.cn/simple --prefer-binary --python-version 3.12 --only-binary=:all:
if ($LASTEXITCODE -ne 0) { throw 'pip download failed' }

Remove-TempPython -NeedCleanup:$needCleanup
Write-Host ""; Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "[DONE] Offline package prepared at: $SUPER_PKG_DIR" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
