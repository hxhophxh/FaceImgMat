@echo off
REM ====================================================================
REM FaceImgMat 仅部署项目脚本（Python已安装）
REM 适用于已经安装Python 3.11/3.12的机器
REM ====================================================================
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║     FaceImgMat - 仅部署项目（Python已安装）                    ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [提示] 本脚本适用于已安装 Python 3.11 或 3.12 的机器
echo [提示] 如果Python未安装，请运行「一键完整部署.bat」
echo.

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo [步骤 1/5] 检测 Python 环境...
echo.

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Python！
    echo.
    echo [建议] 请运行「一键完整部署.bat」自动安装Python
    echo.
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [√] Python 版本: %PYTHON_VERSION%

REM 检查版本
echo %PYTHON_VERSION% | findstr /R "3\.11\. 3\.12\." >nul
if %errorlevel% neq 0 (
    echo [警告] Python 版本不符合要求（需要 3.11 或 3.12）
    echo [提示] 当前版本: %PYTHON_VERSION%
    echo [提示] 继续尝试部署，可能会遇到兼容性问题...
    echo.
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 2/5] 创建虚拟环境...
echo.

cd /d "%SCRIPT_DIR%\02-项目源码\FaceImgMat"
if %errorlevel% neq 0 (
    echo [错误] 无法进入项目目录！
    pause
    exit /b 1
)

if exist ".venv" (
    echo [提示] 删除旧的虚拟环境...
    rmdir /s /q .venv
)

python -m venv .venv
if %errorlevel% neq 0 (
    echo [错误] 虚拟环境创建失败！
    pause
    exit /b 1
)
echo [√] 虚拟环境创建成功
echo.

call .venv\Scripts\activate.bat
echo [√] 虚拟环境已激活
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 3/5] 安装依赖包...
echo.

set "PACKAGES_DIR=%SCRIPT_DIR%\03-Python依赖包"
echo [提示] 升级 pip...
python -m pip install --upgrade pip --no-index --find-links="!PACKAGES_DIR!" --quiet
echo.

echo [提示] 安装依赖包...
python -m pip install -r requirements.txt --no-index --find-links="!PACKAGES_DIR!"

if %errorlevel% neq 0 (
    echo [错误] 依赖包安装失败！
    pause
    exit /b 1
)
echo [√] 依赖包安装完成
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 4/5] 配置 AI 模型...
echo.

set "MODELS_SRC=%SCRIPT_DIR%\04-AI模型文件\insightface_models"
set "MODELS_DST=%USERPROFILE%\.insightface\models"

if exist "!MODELS_SRC!" (
    if not exist "!MODELS_DST!" mkdir "!MODELS_DST!" 2>nul
    xcopy "!MODELS_SRC!" "!MODELS_DST!" /E /I /Y /Q
    echo [√] 模型配置完成
) else (
    echo [警告] 未找到离线模型
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 5/5] 初始化数据库...
echo.

if not exist "instance" mkdir instance
if not exist "static\faces" mkdir static\faces
if not exist "static\uploads" mkdir static\uploads
if not exist "logs" mkdir logs
if not exist "models" mkdir models

if not exist "instance\face_matching.db" (
    if exist "scripts\init_demo_data.py" (
        python scripts\init_demo_data.py
        echo [√] 数据库初始化成功
    )
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  🎉 部署成功！                                 ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [访问信息]
echo   地址: http://127.0.0.1:5000
echo   账号: admin
echo   密码: Admin@FaceMatch2025!
echo.
echo [提示] 正在启动服务...
echo.

start /B cmd /c "timeout /t 5 /nobreak >nul && start http://127.0.0.1:5000"
python run.py

pause
