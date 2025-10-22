@echo off
:: 强制 UTF-8，解决中文乱码
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title FaceImgMat 离线一键部署+自动启动（极简离线版）

:: 全局错误处理：捕获所有错误并显示
if not defined ERROR_HANDLER (
    set "ERROR_HANDLER=1"
    cmd /c "%~f0" %* 2>&1
    set "EXIT_CODE=!ERRORLEVEL!"
    if !EXIT_CODE! neq 0 (
        echo.
        echo ================================================================
        echo   【错误】脚本执行出错，退出码: !EXIT_CODE!
        echo ================================================================
        echo.
    )
    pause
    exit /b !EXIT_CODE!
)

echo.

echo ================================================================
echo   FaceImgMat - 离线一键部署并自动启动服务（极简离线版）
echo ================================================================
echo.

:: === 任务选择（纯英文符号，无中文引号、无全角空格） ===
echo 【请选择开始步骤】（将从选择的步骤执行到步骤8）：
echo   0   准备离线包（含下载）
echo   1   检测并安装 VC++ 2015-2022 x64 运行库(onnxruntime 依赖)
echo   2   检查/安装 Python
echo   3   准备项目目录
echo   4   创建虚拟环境
echo   5   安装依赖
echo   6   预置 InsightFace 缓存模型（断网关键）
echo   7   部署完成
echo   8   启动服务并打开浏览器
echo.

:choose_start
set "START_STEP="
if "%~1"=="" (
    set /p "START_STEP=请选择开始步骤（按回车从第 0 步开始）: "
    if "!START_STEP!"=="" set "START_STEP=0"
) else (
    set "START_STEP=%~1"
)

:: 验证输入是否为数字
set "TEST_NUM=!START_STEP!"
for /f "delims=0123456789" %%i in ("!TEST_NUM!") do (
    echo 【错误】输入无效，请输入 0-8 之间的数字
    goto :choose_start
)

:: 转换为数字并验证范围
set /a START_STEP=!START_STEP! 2>nul
if !START_STEP! lss 0 (
    echo 【错误】步骤不能小于 0
    goto :choose_start
)
if !START_STEP! gtr 8 (
    echo 【错误】步骤不能大于 8
    goto :choose_start
)

set /a CURRENT_STEP=0
echo.
echo 【信息】将从第 !START_STEP! 步开始执行，直到步骤 8
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
:: 步骤 0  准备离线包（优先本地，失败再下载）
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step0_done
echo 【步骤 0】准备离线包...

:: ① 若已存在 zip 先尝试解压，成功则跳过下载
if exist "%BUNDLE_PATH%" (
    echo 【信息】发现本地离线包，正在校验...
    call :unzip_with_retry "%BUNDLE_PATH%" "%SCRIPT_DIR%"
    if not errorlevel 1 (
        echo 【成功】本地离线包解压完成，跳过下载。
        goto :skip_download
    )
    echo 【警告】本地包损坏，将重新下载...
    del /f "%BUNDLE_PATH%" 2>nul
)

:: ② 本地没有或解压失败才下载
echo 【信息】本地未发现可用离线包，准备下载...
call :download_with_spinner "%BUNDLE_URL%" "%BUNDLE_PATH%"
call :unzip_with_retry "%BUNDLE_PATH%" "%SCRIPT_DIR%"
if errorlevel 1 (
    echo 【错误】离线包解压失败
    pause & exit /b 1
)

:skip_download
:: 处理双层嵌套目录
if exist "%SCRIPT_DIR%\%BUNDLE_NAME%\%BUNDLE_NAME%" (
    echo 【信息】检测到嵌套目录，正在展平...
    robocopy "%SCRIPT_DIR%\%BUNDLE_NAME%\%BUNDLE_NAME%" "%SCRIPT_DIR%\%BUNDLE_NAME%" /E /MOVE /NP /NFL /NDL /NJH /NJS >nul
    rmdir "%SCRIPT_DIR%\%BUNDLE_NAME%\%BUNDLE_NAME%" 2>nul
)

:: 等待文件系统同步
timeout /t 2 /nobreak >nul

:: 验证关键文件
echo 【信息】验证离线包完整性...
if not exist "%BUNDLE_DIR%" (
    echo 【错误】离线包目录不存在: %BUNDLE_DIR%
    pause & exit /b 1
)
echo 【成功】离线包已准备: %BUNDLE_DIR%
echo.
:step0_done
if !CURRENT_STEP! equ 0 set /a CURRENT_STEP+=1

:: === 预定义路径（在步骤1之前检查并设置）===
if !START_STEP! geq 1 (
    if not exist "%BUNDLE_DIR%" (
        echo.
        echo 【错误】未找到离线包目录: %BUNDLE_DIR%
        echo 【提示】请先执行步骤0准备离线包，或确保 offline_bundle 文件夹存在
        echo.
        pause
        exit /b 1
    )
    
    :: 设置项目路径变量（当跳过步骤0时必须设置）
    set "PROJECT_DIR=%BUNDLE_DIR%\FaceImgMat"
    set "SITE_PACKAGES_SRC=%BUNDLE_DIR%\site-packages"
    set "MODELS_SRC=%BUNDLE_DIR%\models\insightface_models"
    set "PY_INSTALLER=%BUNDLE_DIR%\python\%PYTHON_INSTALLER_NAME%"
    set "LOCK_FILE=%BUNDLE_DIR%\requirements.lock"
)

:: ##############################################################################
:: 步骤 1  检测并安装 VC++ 2015-2022 x64 运行库（onnxruntime 依赖）
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step1_done
echo 【步骤 1】检测 VC++ 2015-2022 x64 运行库...

:: 注册表判存在
set "VC_REG=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64"
reg query "%VC_REG%" /v "Installed" 2>nul | find "0x1" >nul
if not errorlevel 1 (
    echo 【成功】已检测到 VC++ 2015-2022 x64 运行库，跳过安装。
    goto :step1_done
)

:: 未安装 -> 多路径查找离线包中的vc_redist
set "VC_INSTALLER="
for %%p in (
    "%BUNDLE_DIR%\vc_redist\vc_redist.x64.exe"
    "%BUNDLE_DIR%\vc_redist.x64.exe"
    "%SCRIPT_DIR%\offline_bundle\vc_redist\vc_redist.x64.exe"
) do if exist "%%~p" set "VC_INSTALLER=%%~p"
set "VC_URL=https://aka.ms/vs/17/release/vc_redist.x64.exe"

if defined VC_INSTALLER (
    echo 【信息】找到离线包中的VC++安装程序: !VC_INSTALLER!
) else (
    echo 【信息】离线包未含 vc_redist.x64.exe，准备联网下载...
    set "VC_INSTALLER=%SCRIPT_DIR%\vc_redist.x64.exe"
    call :download_with_spinner "%VC_URL%" "!VC_INSTALLER!"
    if not exist "!VC_INSTALLER!" (
        echo 【警告】下载失败，请手动安装：%VC_URL%
        pause
        goto :step1_done
    )
)

:: 静默安装
echo 【信息】正在静默安装 VC++ 运行库...
"!VC_INSTALLER!" /quiet /norestart
if errorlevel 1 (
    echo 【警告】安装失败，请手动安装：!VC_INSTALLER!
    pause
) else (
    echo 【成功】VC++ 2015-2022 x64 运行库安装完成。
)
echo.
:step1_done
if !CURRENT_STEP! equ 1 set /a CURRENT_STEP+=1

:: === 设置项目路径变量（如果还未设置）===
if not defined PROJECT_DIR (
    set "PROJECT_DIR=%BUNDLE_DIR%\FaceImgMat"
    set "SITE_PACKAGES_SRC=%BUNDLE_DIR%\site-packages"
    set "MODELS_SRC=%BUNDLE_DIR%\models\insightface_models"
    set "PY_INSTALLER=%BUNDLE_DIR%\python\%PYTHON_INSTALLER_NAME%"
    set "LOCK_FILE=%BUNDLE_DIR%\requirements.lock"
)

:: === 检测Python和设置虚拟环境路径（当跳过步骤2-4时）===
if !START_STEP! geq 3 goto :check_python_skip
goto :skip_python_check
:check_python_skip
if defined PYTHON_CMD goto :python_already_set

:: 扫描常见目录
if exist "D:\Python312\python.exe" set "PYTHON_CMD=D:\Python312\python.exe"
if exist "C:\Program Files\Python312\python.exe" set "PYTHON_CMD=C:\Program Files\Python312\python.exe"
if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PYTHON_CMD=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"

:: 检查PATH
if not defined PYTHON_CMD (
    where python >nul 2>&1
    if not errorlevel 1 (
        for /f "delims=" %%i in ('where python 2^>nul') do (
            set "PYTHON_CMD=%%i"
            goto :python_already_set
        )
    )
)

if not defined PYTHON_CMD (
    echo 【错误】未检测到 Python 3.12，请先执行步骤2安装Python
    pause
    exit /b 1
)

:python_already_set
:: 设置虚拟环境路径（当跳过步骤4时）
if !START_STEP! geq 5 (
    if not defined VENV_PY (
        set "VENV_PY=%PROJECT_DIR%\.venv\Scripts\python.exe"
        set "VENV_SITE=%PROJECT_DIR%\.venv\Lib\site-packages"
        
        if not exist "!VENV_PY!" (
            echo 【错误】虚拟环境不存在，请先执行步骤4创建虚拟环境
            echo 虚拟环境路径: !VENV_PY!
            pause
            exit /b 1
        )
        
        :: 检查虚拟环境是否完整（检查pip模块）
        "!VENV_PY!" -m pip --version >nul 2>&1
        if errorlevel 1 (
            echo 【警告】虚拟环境不完整（缺少pip模块），将重新创建
            echo 【信息】正在删除旧的虚拟环境...
            rmdir /s /q "%PROJECT_DIR%\.venv" 2>nul
            echo 【信息】正在重新创建虚拟环境...
            "!PYTHON_CMD!" -m venv "%PROJECT_DIR%\.venv"
            if errorlevel 1 (
                echo 【错误】虚拟环境创建失败
                pause
                exit /b 1
            )
            echo 【成功】虚拟环境已重新创建
        )
    )
)
:skip_python_check

:: ##############################################################################
:: 步骤 2  检查 / 安装 Python
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step2_done
echo.
echo 【步骤 2】检查/安装 Python %PYTHON_VERSION_TARGET%...

:: ① 先扫描几个常见目录
set "PYTHON_CMD="
for %%p in (
    "D:\Python312\python.exe"
    "C:\Program Files\Python312\python.exe"
    "%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
) do if exist "%%~p" set "PYTHON_CMD=%%~p"

:: ② 若仍未找到，再看 PATH 中是否有 3.12
if not defined PYTHON_CMD (
    python --version >nul 2>&1 && (
        for /f "tokens=2" %%v in ('python --version') do (
            echo %%v | findstr /R "^3\.12\." >nul && (
                for /f "delims=" %%i in ('where python 2^>nul') do (
                    set "PYTHON_CMD=%%~fi"
                    goto :python_found
                )
            )
        )
    )
)
:python_found

if defined PYTHON_CMD (
    echo 【成功】检测到 Python: !PYTHON_CMD!
    goto :skip_python_install
)
echo 【信息】未找到 Python 3.12，准备使用离线包中的安装程序...
if not exist "%PY_INSTALLER%" (
    echo 【错误】离线包缺少 %PYTHON_INSTALLER_NAME% ，无法自动安装 Python
    pause & exit /b 1
)

:: ③ 单分区兼容：直接装到系统盘
set "TARGET_PY_DIR=%SystemDrive%\Python312"

:: ④ 执行安装（系统级+写 PATH）
echo 【信息】安装 Python 到 !TARGET_PY_DIR!
call :install_python_with_spinner "%PY_INSTALLER%" "!TARGET_PY_DIR!"

:: ⑤ 等待安装完成并验证（修复版）
echo 【信息】等待Python安装完成...
for /l %%i in (1,1,60) do (
    if exist "!TARGET_PY_DIR!\python.exe" goto :python_installed
    timeout /t 1 /nobreak >nul
)
echo 【警告】超时，仍未检测到 !TARGET_PY_DIR!\python.exe
exit /b 1
:python_installed

:: ⑥ 刷新PATH并设置解释器路径
set "PATH=!TARGET_PY_DIR!;!TARGET_PY_DIR!\Scripts;%PATH%"
set "PYTHON_CMD=!TARGET_PY_DIR!\python.exe"

:skip_python_install


:: ⑦ 最终校验
if not exist "!PYTHON_CMD!" (
    echo 【警告】Python 安装后仍未找到有效解释器: !PYTHON_CMD!
    echo 【警告】脚本继续，但后续步骤可能失败！
    pause
)
echo.
:step2_done
if !CURRENT_STEP! equ 2 set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 3  准备项目目录
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step3_done
echo 【步骤 3】准备项目目录...
cd /d "%PROJECT_DIR%" || (
    echo 【错误】无法进入项目目录: %PROJECT_DIR%
    pause & exit /b 1
)
echo 【成功】当前目录: !CD!
if exist ".venv" call :clean_with_spinner ".venv"
if exist "%LOCK_FILE%" copy "%LOCK_FILE%" "%PROJECT_DIR%\requirements.lock" >nul
:step3_done
if !CURRENT_STEP! equ 3 set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 4  创建虚拟环境
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step4_done
echo 【步骤 4】创建虚拟环境...
if not exist "%PYTHON_CMD%" (
    echo 【错误】Python 命令未找到: %PYTHON_CMD%
    pause & exit /b 1
)
call :create_venv_with_spinner "%PYTHON_CMD%" "%PROJECT_DIR%"
set "VENV_PY=%PROJECT_DIR%\.venv\Scripts\python.exe"
set "VENV_SITE=%PROJECT_DIR%\.venv\Lib\site-packages"
echo 【成功】虚拟环境已创建
:step4_done
if !CURRENT_STEP! equ 4 set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 5  安装依赖
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step5_done
echo 【步骤 5】安装依赖...

:: 确保在项目目录中
cd /d "%PROJECT_DIR%" 2>nul
if errorlevel 1 (
    echo 【错误】无法进入项目目录: %PROJECT_DIR%
    pause
    exit /b 1
)

:: 复制requirements.lock（如果还不存在）
if not exist "requirements.lock" (
    if exist "%LOCK_FILE%" (
        copy "%LOCK_FILE%" "requirements.lock" >nul
    ) else (
        echo 【错误】未找到 requirements.lock 文件
        echo 源文件: %LOCK_FILE%
        pause
        exit /b 1
    )
)

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
:step5_done
if !CURRENT_STEP! equ 5 set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 6  预置 InsightFace 缓存模型（断网关键）- 优化版
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step6_done
echo 【步骤 6】预置 InsightFace 缓存模型...

set "INSIGHTFACE_HOME=%USERPROFILE%\.insightface"
set "INSIGHTFACE_CACHE=%INSIGHTFACE_HOME%\models\buffalo_l"
set "BUFFALO_ZIP=%BUNDLE_DIR%\models\insightface_models\buffalo_l.zip"

if not exist "%BUFFALO_ZIP%" (
    echo 【警告】离线包未含 buffalo_l.zip，仍可能触发联网下载！
    goto :step6_done
)

if exist "%INSIGHTFACE_CACHE%\buffalo_l.onnx" (
    echo 【成功】缓存模型已存在，跳过解压。
    goto :step6_done
)

:: 确保缓存根目录存在
if not exist "%INSIGHTFACE_HOME%"     mkdir "%INSIGHTFACE_HOME%"
if not exist "%INSIGHTFACE_HOME%\models" mkdir "%INSIGHTFACE_HOME%\models"

:: 解压模型（优先使用tar，速度快10倍以上）
echo 【信息】正在解压 buffalo_l.zip 到 InsightFace 缓存...
tar -xf "%BUFFALO_ZIP%" -C "%INSIGHTFACE_HOME%\models" 2>nul
if errorlevel 1 (
    echo 【信息】tar命令失败，使用PowerShell解压...
    powershell -Command "Expand-Archive -Path '%BUFFALO_ZIP%' -DestinationPath '%INSIGHTFACE_CACHE%' -Force"
    if errorlevel 1 (
        echo 【错误】解压失败，请检查 buffalo_l.zip 是否完整
        pause & exit /b 1
    )
)
echo 【成功】buffalo_l 模型已预置到 %INSIGHTFACE_CACHE%
:step6_done
if !CURRENT_STEP! equ 6 set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 7  部署完成
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step7_done
echo 【步骤 7】部署完成！

:: 创建桌面快捷方式
if not defined START_BAT set "START_BAT=%PROJECT_DIR%\start.bat"
set "DESKTOP=%USERPROFILE%\Desktop"
set "SHORTCUT=%DESKTOP%\FaceImgMat.lnk"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT%'); $Shortcut.TargetPath = '%START_BAT%'; $Shortcut.WorkingDirectory = '%BUNDLE_DIR%\FaceImgMat'; $Shortcut.Save()"
echo 【提示】启动快捷方式已创建到桌面：%SHORTCUT%
:step7_done
if !CURRENT_STEP! equ 7 set /a CURRENT_STEP+=1

:: ##############################################################################
:: 步骤 8  启动服务并打开浏览器
:: ##############################################################################
if !CURRENT_STEP! lss !START_STEP! goto :step8_done
echo 【步骤 8】正在启动 FaceImgMat 服务并打开浏览器...

:: 设置启动脚本路径（如果还未设置）
if not defined START_BAT set "START_BAT=%PROJECT_DIR%\start.bat"

if not exist "%START_BAT%" (
    echo 【错误】未找到 %START_BAT%，无法启动服务！
    pause & exit /b 1
)
start "" "%START_BAT%"
timeout /t 6 /nobreak >nul
start "" "%SERVICE_URL%"
echo 【成功】服务已启动并打开浏览器！
:step8_done

echo.
echo ================================================================
set /a LAST_STEP=!CURRENT_STEP!-1
echo   执行完成！已完成步骤 !START_STEP! 到步骤 !LAST_STEP!
if !CURRENT_STEP! geq 8 (
    echo   部署完成！尽情享受 FaceImgMat 吧！
)
echo ================================================================
echo.
pause
exit /b 0

:: ========================================================================
::  通用子程序
:: ========================================================================
:clean_with_spinner
set "TARGET=%~1"
if not exist "%TARGET%" exit /b
echo | set /p="【清理】 %TARGET% ..."
rmdir /s /q "%TARGET%"
echo done
exit /b

:: ------------------------------------------------------------------------
::  带统一动态进度条的解压
:: ------------------------------------------------------------------------
:unzip_with_retry
set "ARCHIVE=%~1"
set "DEST=%~2"

if not exist "%ARCHIVE%" (
    echo 【解压】 文件不存在: %ARCHIVE%
    exit /b 1
)

echo 【解压】 %ARCHIVE%
<nul set /p="【进度】 "

:: 先尝tar（后台运行）
start /b "" cmd /c "tar -xf "%ARCHIVE%" -C "%DEST%" 2>nul"

:: 显示点点直到tar进程结束
:wait_tar
tasklist 2>nul | find /i "tar.exe" >nul
if errorlevel 1 goto :tar_done
<nul set /p="█"
timeout /t 1 /nobreak >nul 2>&1
goto :wait_tar

:tar_done
timeout /t 1 /nobreak >nul 2>&1
echo.

:: 检查tar是否成功
if exist "%DEST%\*" (
    echo 【成功】tar 解压完成
    exit /b 0
)

:: tar失败用PowerShell，后台运行+显示点点
echo.
echo 【信息】tar不可用，使用PowerShell解压...
<nul set /p="【进度】 "

:: 后台启动PowerShell解压
set "PS_SCRIPT=$ProgressPreference='SilentlyContinue'; Expand-Archive -LiteralPath '%ARCHIVE%' -DestinationPath '%DEST%' -Force"
start /b "" powershell -NoProfile -Command "%PS_SCRIPT%"

:: 显示点点直到PowerShell进程结束
:wait_ps
tasklist 2>nul | find /i "powershell.exe" >nul
if errorlevel 1 goto :ps_done
<nul set /p="█"
timeout /t 2 /nobreak >nul 2>&1
goto :wait_ps

:ps_done
echo.

:: 验证解压结果
if exist "%DEST%\*" (
    echo 【成功】PowerShell 解压完成
    exit /b 0
) else (
    echo 【错误】PowerShell 解压失败
    exit /b 1
)

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
start "" /wait "%INSTALLER%" /quiet InstallAllUsers=1 TargetDir="%~2" AssociateFiles=0 PrependPath=1 /norestart
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
exit /b