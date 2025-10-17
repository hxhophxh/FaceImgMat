@echo off
:: 强制使用 UTF-8 代码页，解决中文乱码
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title FaceImgMat 离线一键部署+自动启动（UTF-8 原生中文版）

echo.
echo ================================================================
echo   FaceImgMat - 离线一键部署并自动启动服务（UTF-8 原生中文版）
echo ================================================================
echo.

:: === 任务选择 ===
echo 【请选择开始步骤】：
echo   0 - 准备离线包（含下载）
echo   1 - 检查/安装 Python
echo   2 - 准备项目目录
echo   3 - 创建虚拟环境
echo   4 - 安装依赖
echo   5 - 拷贝模型文件
echo   6 - 部署完成
echo   7 - 启动服务并打开浏览器
echo.

:choose_start
set "START_STEP="
if "%~1"=="" (
    set /p "START_STEP=请选择开始步骤（按回车从第 0 步开始）: "
    if "!START_STEP!"=="" set "START_STEP=0"
) else (
    set "START_STEP=%~1"
)
set /a START_STEP=START_STEP 2>nul
if !START_STEP! lss 0 set "START_STEP=0"
if !START_STEP! gtr 7 set "START_STEP=7"
set /a CURRENT_STEP=0
echo 【信息】将从第 !START_STEP! 步开始执行
echo.

:: === 基础路径 ===
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "BUNDLE_NAME=offline_bundle"
set "BUNDLE_ARCHIVE=%BUNDLE_NAME%.zip"
set "BUNDLE_PATH=%SCRIPT_DIR%\%BUNDLE_ARCHIVE%"
set "BUNDLE_DIR=%SCRIPT_DIR%\%BUNDLE_NAME%"
set "BUNDLE_URL=https://github.com/hxhophxh/FaceImgMat/releases/latest/download/offline_bundle.zip"

set "PYTHON_VERSION_TARGET=3.12"
set "PYTHON_INSTALLER_NAME=python-3.12.7-amd64.exe"
set "SERVICE_PORT=5000"
set "SERVICE_URL=http://127.0.0.1:%SERVICE_PORT%"

:: ##############################################################################
:: 步骤 0  准备离线包（含下载）
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step0_done
echo 【步骤 0】准备离线包...
if exist "%BUNDLE_DIR%" call :clean_with_spinner "%BUNDLE_DIR%"
if not exist "%BUNDLE_PATH%" (
    echo 【信息】本地未发现 %BUNDLE_ARCHIVE% ，准备下载...
    call :download_with_spinner "%BUNDLE_URL%" "%BUNDLE_PATH%"
)
call :unzip_with_retry "%BUNDLE_PATH%" "%SCRIPT_DIR%"
if exist "%SCRIPT_DIR%\%BUNDLE_NAME%\%BUNDLE_NAME%" (
    robocopy "%SCRIPT_DIR%\%BUNDLE_NAME%\%BUNDLE_NAME%" "%SCRIPT_DIR%\%BUNDLE_NAME%" /E /MOVE /NP /NFL /NDL /NJH /NJS >nul
    rmdir "%SCRIPT_DIR%\%BUNDLE_NAME%\%BUNDLE_NAME%" 2>nul
)
echo 【成功】离线包已准备: %BUNDLE_DIR%
echo.
:step0_done
set /a CURRENT_STEP+=1

:: === 预定义路径 ===
set "PROJECT_DIR=%BUNDLE_DIR%\FaceImgMat"
set "SITE_PACKAGES_SRC=%BUNDLE_DIR%\site-packages"
set "MODELS_SRC=%BUNDLE_DIR%\models\insightface_models"
set "PY_INSTALLER=%BUNDLE_DIR%\python\%PYTHON_INSTALLER_NAME%"
set "LOCK_FILE=%BUNDLE_DIR%\requirements.lock"
if not exist "%PROJECT_DIR%" (
    echo 【错误】离线包缺少 FaceImgMat 项目源码
    pause & exit /b 1
)

:: ##############################################################################
:: 步骤 1  检查 / 安装 Python
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step1_done
echo 【步骤 1】检查/安装 Python %PYTHON_VERSION_TARGET%...
set "PYTHON_CMD="
for %%p in (
    "D:\Python312\python.exe"
    "C:\Program Files\Python312\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
) do if exist "%%~p" set "PYTHON_CMD=%%~p"
if not defined PYTHON_CMD (
    python --version >nul 2>&1 && (
        for /f "tokens=2" %%v in ('python --version') do (
            echo %%v | findstr /R "^3\.12\." >nul && set "PYTHON_CMD=python"
        )
    )
)
if defined PYTHON_CMD (
    echo 【成功】检测到 Python: !PYTHON_CMD!
) else (
    echo 【信息】未找到 Python 3.12，准备使用离线包中的安装程序...
    if not exist "%PY_INSTALLER%" (
        echo 【错误】离线包缺少 %PYTHON_INSTALLER_NAME% ，无法自动安装 Python
        pause & exit /b 1
    )
    if exist "D:\" (set "TARGET_PY_DIR=D:\Python312") else set "TARGET_PY_DIR=%SystemDrive%\Python312"
    call :install_python_with_spinner "%PY_INSTALLER%" "%TARGET_PY_DIR%"
    set "PYTHON_CMD=%TARGET_PY_DIR%\python.exe"
    echo 【成功】Python 安装完成: !PYTHON_CMD!
)
:step1_done
set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 2  准备项目目录
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step2_done
echo 【步骤 2】准备项目目录...
cd /d "%PROJECT_DIR%" || (
    echo 【错误】无法进入项目目录: %PROJECT_DIR%
    pause & exit /b 1
)
echo 【成功】当前目录: !CD!
if exist ".venv" call :clean_with_spinner ".venv"
if exist "%LOCK_FILE%" copy "%LOCK_FILE%" "%PROJECT_DIR%\requirements.lock" >nul
:step2_done
set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 3  创建虚拟环境
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step3_done
echo 【步骤 3】创建虚拟环境...
if not exist "%PYTHON_CMD%" (
    echo 【错误】Python 命令未找到: %PYTHON_CMD%
    pause & exit /b 1
)
call :create_venv_with_spinner "%PYTHON_CMD%" "%PROJECT_DIR%"
set "VENV_PY=%PROJECT_DIR%\.venv\Scripts\python.exe"
set "VENV_SITE=%PROJECT_DIR%\.venv\Lib\site-packages"
echo 【成功】虚拟环境已创建
:step3_done
set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 4  安装依赖
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step4_done
echo 【步骤 4】安装依赖...
set "INSTALL_STATUS=0"
set "WHEELS_DIR=%BUNDLE_DIR%\wheels"

if exist "%WHEELS_DIR%" (
    echo 【信息】检测到 wheels 目录，优先离线安装...
    "%VENV_PY%" -m pip install --no-index --find-links "%WHEELS_DIR%" -r requirements.lock
    if !errorlevel! equ 0 (
        set "INSTALL_STATUS=1"
        echo 【成功】pip 离线安装完成
    ) else (
        echo 【警告】pip 安装失败，将 fallback 到 site-packages 同步
    )
)

if "!INSTALL_STATUS!"=="0" (
    echo 【信息】使用 site-packages 同步方式...
    call :sync_site_packages "%SITE_PACKAGES_SRC%" "%VENV_SITE%"
    if errorlevel 1 (
        pause & exit /b 1
    )
)

if not exist "%VENV_SITE%\flask" (
    echo 【错误】Flask 依赖未正确安装，请检查离线包是否完整
    pause & exit /b 1
)
echo 【成功】依赖安装完成
:step4_done
set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 5  拷贝模型文件
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step5_done
echo 【步骤 5】拷贝模型文件...
if exist "%MODELS_SRC%" (
    xcopy /E /I /Q /Y "%MODELS_SRC%" "models\insightface_models" >nul
    if errorlevel 1 (
        echo 【错误】模型文件拷贝失败
        pause & exit /b 1
    )
)
:step5_done
set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 6  部署完成
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step6_done
echo 【步骤 6】部署完成！

:: === 创建桌面快捷方式（目标：offline_bundle\FaceImgMat\start.bat） ===
echo 【信息】正在创建桌面快捷方式...
set "DESKTOP=%USERPROFILE%\Desktop"
set "START_BAT=%BUNDLE_DIR%\FaceImgMat\start.bat"
set "SHORTCUT=%DESKTOP%\FaceImgMat.lnk"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT%'); $Shortcut.TargetPath = '%START_BAT%'; $Shortcut.WorkingDirectory = '%BUNDLE_DIR%\FaceImgMat'; $Shortcut.Save()"
echo 【提示】启动快捷方式已创建到桌面：%SHORTCUT%
:step6_done
set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 7  启动服务并打开浏览器
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step7_done
echo 【步骤 7】正在启动 FaceImgMat 服务并打开浏览器...
if not exist "%START_BAT%" (
    echo 【错误】未找到 %START_BAT%，无法启动服务！
    pause & exit /b 1
)
start "" "%START_BAT%"
timeout /t 6 /nobreak >nul
start "" "%SERVICE_URL%"
echo 【成功】服务已启动并打开浏览器！
:step7_done

echo.
echo 尽情享受 FaceImgMat 吧！
pause
exit /b

:: ========================================================================
:: 通用子程序（echo done 已英文，避免 UTF-8 管道乱码）
:: ========================================================================
:clean_with_spinner
set "TARGET=%~1"
if not exist "%TARGET%" exit /b
echo | set /p="【清理】 %TARGET% ..."
rmdir /s /q "%TARGET%"
echo done
exit /b

:unzip_with_retry
set "ARCHIVE=%~1"
set "DEST=%~2"
:retry_unzip
echo | set /p="【解压】 %ARCHIVE% ..."
powershell -Command "try { Expand-Archive -Path '%ARCHIVE%' -DestinationPath '%DEST%' -Force -ErrorAction Stop } catch { exit 1 }"
if errorlevel 1 (
    echo 失败，ZIP 可能损坏，正在重新下载...
    del /f "%ARCHIVE%" 2>nul
    call :download_with_spinner "%BUNDLE_URL%" "%ARCHIVE%"
    goto retry_unzip
)
echo done
exit /b

:create_venv_with_spinner
set "PY=%~1"
set "DIR=%~2"
if not exist "%PY%" (
    echo 【错误】Python 解释器未找到: %PY%
    exit /b 1
)
echo | set /p="【venv】 创建虚拟环境 ..."
cd /d "%DIR%"
"%PY%" -m venv .venv
echo done
exit /b

:install_python_with_spinner
set "INSTALLER=%~1"
set "TARGET_DIR=%~2"
echo | set /p="【Python】 安装中 ..."
"%INSTALLER%" /quiet InstallAllUsers=0 TargetDir="%TARGET_DIR%" AssociateFiles=0 PrependPath=1
echo done
exit /b

:download_with_spinner
set "URL=%~1"
set "OUTPUT=%~2"
echo | set /p="【下载】 %URL% ..."
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%URL%' -OutFile '%OUTPUT%'"
echo done
exit /b

:sync_site_packages
set "SRC=%~1"
set "DST=%~2"
if not exist "%SRC%" (
    echo 【错误】离线包缺少 site-packages 目录: "%SRC%"
    exit /b 1
)
if not exist "%DST%" (
    mkdir "%DST%" 2>nul
)
echo 【信息】 正在同步 site-packages 到虚拟环境...
robocopy "%SRC%" "%DST%" /MIR /XD __pycache__ /XF *.pyc /NP /NFL /NDL /NJH /NJS /R:3 /W:2 >nul
if %errorlevel% GEQ 8 (
    echo 【错误】 robocopy 同步失败，退出码: %errorlevel%
    exit /b 1
)
echo done
exit /b 0