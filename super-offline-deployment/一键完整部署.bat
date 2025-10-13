@echo off
REM ====================================================================
REM FaceImgMat 超级离线一键完整部署脚本
REM 适用于完全没有Python环境的全新机器
REM ====================================================================
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║     FaceImgMat 人脸识别系统 - 超级离线一键部署                 ║
echo ║                                                                ║
echo ║     适用于完全没有Python环境的全新机器                          ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [提示] 本脚本将自动完成以下操作：
echo.
echo   [1/7] 检测并安装 Python 3.11
echo   [2/7] 创建 Python 虚拟环境
echo   [3/7] 安装所有 Python 依赖包
echo   [4/7] 配置 InsightFace AI 模型
echo   [5/7] 初始化数据库
echo   [6/7] 启动人脸识别服务
echo   [7/7] 自动打开浏览器
echo.
echo [预计时间] 15-25 分钟（取决于机器性能）
echo.
echo ════════════════════════════════════════════════════════════════
echo.

REM 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM 检查目录结构
echo [√] 检查部署包完整性...
if not exist "%SCRIPT_DIR%\01-Python安装包" (
    echo [错误] 未找到 01-Python安装包 目录！
    echo.
    pause
    exit /b 1
)
if not exist "%SCRIPT_DIR%\02-项目源码\FaceImgMat" (
    echo [错误] 未找到 02-项目源码\FaceImgMat 目录！
    echo.
    pause
    exit /b 1
)
if not exist "%SCRIPT_DIR%\03-Python依赖包" (
    echo [错误] 未找到 03-Python依赖包 目录！
    echo.
    pause
    exit /b 1
)
echo [√] 部署包完整性检查通过
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 1/7] 检测 Python 环境...
echo.

REM 检测Python是否已安装
python --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [√] 检测到已安装的 Python
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo [√] Python 版本: !PYTHON_VERSION!
    echo.
    
    REM 检查版本是否为3.11或3.12
    echo !PYTHON_VERSION! | findstr /R "3\.11\. 3\.12\." >nul
    if !errorlevel! equ 0 (
        echo [√] Python 版本符合要求（3.11 或 3.12）
        echo [提示] 跳过 Python 安装步骤
        set PYTHON_CMD=python
        goto :SKIP_PYTHON_INSTALL
    ) else (
        echo [警告] Python 版本不符合要求，需要安装 Python 3.11
        echo [提示] 将安装到独立目录，不影响现有Python
        echo.
    )
)

echo [提示] 未检测到 Python 或版本不符合要求
echo [提示] 准备安装 Python 3.11.9...
echo.

REM 查找Python安装包
set "PYTHON_INSTALLER="
for %%F in ("%SCRIPT_DIR%\01-Python安装包\python-*.exe") do (
    set "PYTHON_INSTALLER=%%F"
    goto :FOUND_INSTALLER
)

:FOUND_INSTALLER
if not defined PYTHON_INSTALLER (
    echo [错误] 未找到 Python 安装包！
    echo [提示] 请确保 01-Python安装包 目录中有 python-*.exe 文件
    echo.
    pause
    exit /b 1
)

echo [√] 找到 Python 安装包: !PYTHON_INSTALLER!
echo.
echo [提示] 正在安装 Python 3.12.7...
echo [提示] 这可能需要 2-5 分钟，请耐心等待...
echo [提示] 安装位置: D:\Python312
echo [提示] 自动添加到系统环境变量
echo.

REM 静默安装Python到 D 盘，并添加到环境变量
"%PYTHON_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 TargetDir=D:\Python312

REM 等待安装完成
timeout /t 5 /nobreak >nul

REM 刷新环境变量
call refreshenv >nul 2>&1

REM 再次检测Python
timeout /t 2 /nobreak >nul
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] Python 命令不可用，尝试使用完整路径...
    if exist "D:\Python312\python.exe" (
        set "PYTHON_CMD=D:\Python312\python.exe"
        echo [√] 找到 Python: !PYTHON_CMD!
    ) else if exist "C:\Program Files\Python312\python.exe" (
        set "PYTHON_CMD=C:\Program Files\Python312\python.exe"
        echo [√] 找到 Python: !PYTHON_CMD!
    ) else if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" (
        set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
        echo [√] 找到 Python: !PYTHON_CMD!
    ) else (
        echo [错误] Python 安装失败！
        echo [建议] 请手动安装 Python 3.12，然后重新运行此脚本
        echo.
        pause
        exit /b 1
    )
) else (
    set "PYTHON_CMD=python"
    echo [√] Python 安装成功！
)

echo.
"%PYTHON_CMD%" --version
echo.

:SKIP_PYTHON_INSTALL

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 2/7] 创建 Python 虚拟环境...
echo.

REM 进入项目目录
cd /d "%SCRIPT_DIR%\02-项目源码\FaceImgMat"
if %errorlevel% neq 0 (
    echo [错误] 无法进入项目目录！
    pause
    exit /b 1
)

echo [√] 当前目录: %CD%
echo.

REM 删除旧的虚拟环境（如果存在）
if exist ".venv" (
    echo [提示] 删除旧的虚拟环境...
    rmdir /s /q .venv
)

echo [提示] 创建新的虚拟环境...
"%PYTHON_CMD%" -m venv .venv
if %errorlevel% neq 0 (
    echo [错误] 虚拟环境创建失败！
    pause
    exit /b 1
)

echo [√] 虚拟环境创建成功
echo.

REM 激活虚拟环境
call .venv\Scripts\activate.bat
if %errorlevel% neq 0 (
    echo [错误] 虚拟环境激活失败！
    pause
    exit /b 1
)

echo [√] 虚拟环境已激活
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 3/7] 安装 Python 依赖包（这是最耗时的步骤）...
echo.

set "PACKAGES_DIR=%SCRIPT_DIR%\03-Python依赖包"
echo [提示] 依赖包位置: !PACKAGES_DIR!
echo [提示] 正在统计包数量...

REM 统计包数量
set PKG_COUNT=0
for %%F in ("!PACKAGES_DIR!\*.whl") do set /a PKG_COUNT+=1
echo [√] 找到 !PKG_COUNT! 个依赖包
echo.

echo [提示] 升级 pip...
python -m pip install --upgrade pip --no-index --find-links="!PACKAGES_DIR!" --quiet
if %errorlevel% equ 0 (
    echo [√] pip 升级成功
) else (
    echo [警告] pip 升级失败，继续使用当前版本
)
echo.

echo [提示] 安装依赖包（约 5-10 分钟）...
echo [提示] 进度显示：
echo.

python -m pip install -r requirements.txt --no-index --find-links="!PACKAGES_DIR!"

if %errorlevel% neq 0 (
    echo.
    echo [错误] 依赖包安装失败！
    echo [建议] 检查 03-Python依赖包 目录是否包含所有必需的包
    pause
    exit /b 1
)

echo.
echo [√] 所有依赖包安装完成！
echo.

REM 验证关键包
echo [提示] 验证关键依赖...
python -c "import flask; import insightface; import cv2; import faiss" >nul 2>&1
if %errorlevel% equ 0 (
    echo [√] 关键依赖验证通过
) else (
    echo [警告] 部分依赖可能未正确安装，但继续尝试部署
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 4/7] 配置 InsightFace AI 模型...
echo.

set "MODELS_SRC=%SCRIPT_DIR%\04-AI模型文件\insightface_models"
set "MODELS_DST=%USERPROFILE%\.insightface\models"

if exist "!MODELS_SRC!" (
    echo [提示] 模型源目录: !MODELS_SRC!
    echo [提示] 模型目标目录: !MODELS_DST!
    echo.
    
    echo [提示] 创建目标目录...
    if not exist "!MODELS_DST!" (
        mkdir "!MODELS_DST!" 2>nul
    )
    
    echo [提示] 复制模型文件（约 2-3 分钟）...
    xcopy "!MODELS_SRC!" "!MODELS_DST!" /E /I /Y /Q
    
    if %errorlevel% equ 0 (
        echo [√] 模型文件配置成功
        echo.
        echo [提示] 已安装的模型：
        dir "!MODELS_DST!" /B /AD
        echo.
    ) else (
        echo [警告] 模型文件复制失败，首次运行时会自动下载（需要网络）
        echo.
    )
) else (
    echo [警告] 未找到离线模型文件
    echo [提示] 首次运行时会自动下载（需要网络）
    echo.
)

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 5/7] 初始化数据库...
echo.

REM 创建必要目录
echo [提示] 创建必要目录...
if not exist "instance" mkdir instance
if not exist "static\faces" mkdir static\faces
if not exist "static\uploads" mkdir static\uploads
if not exist "logs" mkdir logs
if not exist "models" mkdir models
echo [√] 目录结构创建完成
echo.

REM 检查数据库
if exist "instance\face_matching.db" (
    echo [√] 检测到已有数据库
    echo [提示] 跳过数据库初始化
) else (
    echo [提示] 初始化数据库...
    if exist "scripts\init_demo_data.py" (
        python scripts\init_demo_data.py
        if %errorlevel% equ 0 (
            echo [√] 数据库初始化成功
        ) else (
            echo [警告] 数据库初始化失败，但不影响系统运行
        )
    ) else (
        echo [警告] 未找到初始化脚本
    )
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 6/7] 启动人脸识别服务...
echo.

echo [√] 所有准备工作已完成！
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║                  🎉 部署成功！                                 ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [系统信息]
echo   项目路径: %CD%
echo   访问地址: http://127.0.0.1:5000
echo   默认账号: admin
echo   默认密码: Admin@FaceMatch2025!
echo.
echo [安全提醒]
echo   ⚠️  首次登录后请立即修改管理员密码！
echo   修改方法: python scripts\change_admin_password.py
echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 7/7] 启动服务并打开浏览器...
echo.
echo [提示] 正在启动 Flask 服务...
echo [提示] 服务启动后会自动打开浏览器
echo [提示] 按 Ctrl+C 可停止服务
echo.

REM 后台启动浏览器
start /B cmd /c "timeout /t 5 /nobreak >nul && start http://127.0.0.1:5000"

REM 启动Flask服务（前台运行）
python run.py

REM 如果服务意外退出
echo.
echo [提示] 服务已停止
echo.
pause
