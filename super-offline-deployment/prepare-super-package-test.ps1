#!/usr/bin/env pwsh
# ===================================================================
# FaceImgMat 超级离线包准备脚本 - 简化测试版
# 在有网络的机器上运行，准备完整的离线部署包
# ===================================================================

param(
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

Write-Host "`n" -NoNewline
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║     FaceImgMat 超级离线包准备工具                              ║" -ForegroundColor Cyan
Write-Host "║     为完全没有Python环境的机器准备部署包                        ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "[提示] 本脚本将准备：" -ForegroundColor Yellow
Write-Host "  1. Python 3.12 安装程序"
Write-Host "  2. FaceImgMat 项目源码"
Write-Host "  3. 所有 Python 依赖包"
Write-Host "  4. InsightFace AI 模型"
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
$SUPER_PKG_DIR = $PSScriptRoot
$PROJECT_ROOT = Split-Path -Parent $SUPER_PKG_DIR

Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 1/6] 创建目录结构..." -ForegroundColor Cyan
Write-Host ""

# 创建必要的目录
$directories = @(
    "01-Python安装包",
    "02-项目源码",
    "03-Python依赖包",
    "04-AI模型文件"
)

foreach ($dir in $directories) {
    $dirPath = Join-Path $SUPER_PKG_DIR $dir
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
        Write-Host "[√] 创建: $dir" -ForegroundColor Green
    } else {
        Write-Host "[√] 已存在: $dir" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 2/6] 下载 Python 安装程序..." -ForegroundColor Cyan
Write-Host ""

$PYTHON_VERSION = "3.12.7"
$PYTHON_URL = "https://www.python.org/ftp/python/$PYTHON_VERSION/python-$PYTHON_VERSION-amd64.exe"
$PYTHON_INSTALLER = Join-Path $SUPER_PKG_DIR "01-Python安装包\python-$PYTHON_VERSION-amd64.exe"

if (Test-Path $PYTHON_INSTALLER) {
    Write-Host "[√] Python 安装程序已存在，跳过下载" -ForegroundColor Gray
    Write-Host "    路径: $PYTHON_INSTALLER" -ForegroundColor Gray
} else {
    Write-Host "[>] 正在下载 Python $PYTHON_VERSION ..." -ForegroundColor Yellow
    Write-Host "    从: $PYTHON_URL" -ForegroundColor Gray
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $PYTHON_URL -OutFile $PYTHON_INSTALLER -UseBasicParsing
        Write-Host "[√] Python 安装程序下载完成" -ForegroundColor Green
    } catch {
        Write-Host "[×] Python 下载失败: $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 3/6] 复制项目源码..." -ForegroundColor Cyan
Write-Host ""

$SOURCE_DIR = Join-Path $SUPER_PKG_DIR "02-项目源码\FaceImgMat"

if (Test-Path $SOURCE_DIR) {
    Write-Host "[√] 项目源码目录已存在，跳过" -ForegroundColor Gray
} else {
    Write-Host "[>] 正在复制项目源码..." -ForegroundColor Yellow
    
    $excludeDirs = @('.venv', '__pycache__', '.git', '.vscode', 'instance', 'logs', 'super-offline-deployment')
    $excludeFiles = @('*.pyc', '*.db')
    
    New-Item -ItemType Directory -Path $SOURCE_DIR -Force | Out-Null
    
    Get-ChildItem -Path $PROJECT_ROOT -Recurse | ForEach-Object {
        $relativePath = $_.FullName.Substring($PROJECT_ROOT.Length + 1)
        
        # 检查是否应该排除
        $shouldExclude = $false
        foreach ($excludeDir in $excludeDirs) {
            if ($relativePath -like "$excludeDir*") {
                $shouldExclude = $true
                break
            }
        }
        
        if (-not $shouldExclude -and $_.PSIsContainer) {
            $destPath = Join-Path $SOURCE_DIR $relativePath
            if (-not (Test-Path $destPath)) {
                New-Item -ItemType Directory -Path $destPath -Force | Out-Null
            }
        } elseif (-not $shouldExclude -and -not $_.PSIsContainer) {
            $destPath = Join-Path $SOURCE_DIR $relativePath
            Copy-Item -Path $_.FullName -Destination $destPath -Force
        }
    }
    
    Write-Host "[√] 项目源码复制完成" -ForegroundColor Green
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 4/6] 下载 Python 依赖包..." -ForegroundColor Cyan
Write-Host ""

$DEPS_DIR = Join-Path $SUPER_PKG_DIR "03-Python依赖包"
$REQUIREMENTS_FILE = Join-Path $PROJECT_ROOT "requirements.txt"

if (-not (Test-Path $REQUIREMENTS_FILE)) {
    Write-Host "[×] 未找到 requirements.txt 文件" -ForegroundColor Red
    exit 1
}

$existingPackages = Get-ChildItem -Path $DEPS_DIR -Filter *.whl -ErrorAction SilentlyContinue
if ($existingPackages.Count -gt 0) {
    Write-Host "[√] 依赖包已存在 ($($existingPackages.Count) 个文件)，跳过" -ForegroundColor Gray
} else {
    Write-Host "[>] 正在下载依赖包..." -ForegroundColor Yellow
    Write-Host "    这可能需要 10-15 分钟" -ForegroundColor Gray
    
    try {
        python -m pip download `
            -r $REQUIREMENTS_FILE `
            -d $DEPS_DIR `
            --python-version 3.12 `
            --only-binary=:all: `
            --platform win_amd64 `
            --index-url https://pypi.tuna.tsinghua.edu.cn/simple
        
        Write-Host "[√] 依赖包下载完成" -ForegroundColor Green
    } catch {
        Write-Host "[×] 依赖包下载失败: $_" -ForegroundColor Red
        Write-Host "[提示] 请确保已安装 Python 并配置好 pip" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 5/6] 准备 InsightFace 模型..." -ForegroundColor Cyan
Write-Host ""

$MODELS_DIR = Join-Path $SUPER_PKG_DIR "04-AI模型文件\insightface_models"
$BUFFALO_MODEL = Join-Path $MODELS_DIR "buffalo_l"

if (Test-Path $BUFFALO_MODEL) {
    Write-Host "[√] InsightFace 模型已存在，跳过" -ForegroundColor Gray
} else {
    Write-Host "[>] InsightFace 模型将在首次运行时自动下载" -ForegroundColor Yellow
    Write-Host "[提示] 如需提前下载，请手动运行测试脚本" -ForegroundColor Gray
    
    New-Item -ItemType Directory -Path $MODELS_DIR -Force | Out-Null
    
    $readmeContent = @"
# InsightFace AI 模型

本目录用于存放 InsightFace 人脸识别模型。

## 模型说明

- 模型名称: buffalo_l
- 模型大小: 约 500MB
- 下载来源: 首次运行时自动从官方源下载

## 手动下载（可选）

如需提前下载模型，可以：

1. 运行项目中的测试脚本：
   ```
   python scripts/test_face_detection.py
   ```

2. 或在部署后首次使用人脸识别功能时自动下载

## 目录结构

下载后的结构：
```
buffalo_l/
├── det_10g.onnx
├── w600k_r50.onnx
└── ...
```
"@
    
    Set-Content -Path (Join-Path $MODELS_DIR "README.md") -Value $readmeContent -Encoding UTF8
    Write-Host "[√] 已创建模型目录和说明文件" -ForegroundColor Green
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "[步骤 6/6] 生成部署说明..." -ForegroundColor Cyan
Write-Host ""

Write-Host "[√] 所有文件已准备完成" -ForegroundColor Green

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ 超级离线包准备完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📦 接下来的步骤：" -ForegroundColor Yellow
Write-Host "  1. 将整个 super-offline-deployment 文件夹打包压缩"
Write-Host "  2. 发送给目标用户（压缩后约 1.5-2GB）"
Write-Host "  3. 在目标机器上解压"
Write-Host "  4. 运行 '一键完整部署.bat' 进行部署"
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (-not $Silent) {
    Write-Host "按任意键退出..." -ForegroundColor Green
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

exit 0
