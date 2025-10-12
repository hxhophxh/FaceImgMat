@echo off
REM ===================================================================
REM FaceImgMat 离线部署包一键准备脚本 (Windows批处理)
REM ===================================================================
REM 使用说明：双击运行此脚本
REM 功能：自动下载依赖、打包、生成可直接部署的离线包
REM ===================================================================

chcp 65001 >nul
setlocal EnableDelayedExpansion

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║   FaceImgMat 离线部署包一键准备工具                   ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM 检查是否在项目根目录
if not exist "requirements.txt" (
    echo [错误] 请在项目根目录运行此脚本！
    echo.
    pause
    exit /b 1
)

echo [1/7] 检查PowerShell...
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未找到PowerShell！
    pause
    exit /b 1
)
echo [√] PowerShell 已就绪
echo.

echo [2/7] 设置执行策略...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force" >nul 2>&1
echo [√] 执行策略已设置
echo.

echo [3/7] 准备离线部署包（这可能需要10-20分钟）...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0prepare_offline_package.ps1"
if %errorlevel% neq 0 (
    echo.
    echo [错误] 离线包准备失败！
    pause
    exit /b 1
)

echo.
echo [4/7] 创建自动部署脚本...

REM 创建离线部署启动器
set DEPLOY_DIR=%~dp0offline_deployment_package

REM 创建Windows一键部署启动器
echo @echo off > "%DEPLOY_DIR%\一键部署并启动.bat"
echo chcp 65001 ^>nul >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo ════════════════════════════════════════════ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo    FaceImgMat 离线一键部署启动器 >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo ════════════════════════════════════════════ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo [提示] 正在启动部署程序... >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo powershell -ExecutionPolicy Bypass -File "%%~dp0deploy_offline.ps1" -Silent >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo if %%errorlevel%% neq 0 ( >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo     echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo     echo [错误] 部署失败！ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo     pause >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo     exit /b 1 >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo ) >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo ════════════════════════════════════════════ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo    正在启动服务... >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo ════════════════════════════════════════════ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo cd FaceImgMat >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo [提示] 正在启动人脸识别系统... >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo [提示] 服务启动后会自动打开浏览器 >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo start /B .\.venv\Scripts\python.exe run.py >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo timeout /t 5 /nobreak ^>nul >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo [√] 服务已启动！ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo [√] 正在打开浏览器... >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo start http://127.0.0.1:5000 >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo ════════════════════════════════════════════ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo    访问信息 >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo ════════════════════════════════════════════ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo   地址: http://127.0.0.1:5000 >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo   账号: admin >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo   密码: Admin@FaceMatch2025! >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo [提示] 按 Ctrl+C 停止服务 >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo ════════════════════════════════════════════ >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo echo. >> "%DEPLOY_DIR%\一键部署并启动.bat"
echo .\.venv\Scripts\python.exe run.py >> "%DEPLOY_DIR%\一键部署并启动.bat"

echo [√] 自动部署脚本已创建
echo.

echo [5/7] 创建说明文档...
(
echo ╔════════════════════════════════════════════════════════╗
echo ║          FaceImgMat 离线部署包使用说明                ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo 📦 本离线包已准备就绪！
echo.
echo 🚀 快速部署步骤：
echo.
echo 1. 将整个 offline_deployment_package 文件夹
echo    复制到目标机器（无需网络）
echo.
echo 2. 双击运行：一键部署并启动.bat
echo.
echo 3. 等待自动完成（约2-5分钟）
echo.
echo 4. 浏览器会自动打开，即可使用！
echo.
echo ════════════════════════════════════════════════════════
echo.
echo 📋 包含内容：
echo    - FaceImgMat 项目源代码
echo    - Python 依赖包（约500-800MB）
echo    - InsightFace AI模型（约300MB）
echo    - 自动部署脚本
echo.
echo 🔐 默认登录信息：
echo    地址: http://127.0.0.1:5000
echo    账号: admin
echo    密码: Admin@FaceMatch2025!
echo.
echo ⚠️  首次登录后请立即修改密码！
echo.
echo ════════════════════════════════════════════════════════
echo.
echo 📞 如需帮助，查看 FaceImgMat/docs/ONE-CLICK-DEPLOYMENT.md
echo.
) > "%DEPLOY_DIR%\使用说明.txt"

echo [√] 说明文档已创建
echo.

echo [6/7] 打包成ZIP文件...
powershell -Command "Compress-Archive -Path '%DEPLOY_DIR%' -DestinationPath 'FaceImgMat-离线部署包-%date:~0,4%%date:~5,2%%date:~8,2%.zip' -Force"
if %errorlevel% neq 0 (
    echo [警告] 自动打包失败，请手动压缩 offline_deployment_package 文件夹
) else (
    echo [√] 已打包成 ZIP 文件
)
echo.

echo [7/7] 计算文件大小...
for %%A in ("%DEPLOY_DIR%") do set SIZE=%%~zA
set /a SIZE_MB=!SIZE! / 1048576
echo [√] 离线包大小: 约 !SIZE_MB! MB
echo.

echo ════════════════════════════════════════════════════════
echo.
echo ✅ 离线部署包准备完成！
echo.
echo 📁 离线包位置：
echo    %DEPLOY_DIR%
echo.
echo 📦 压缩包位置：
echo    %~dp0FaceImgMat-离线部署包-%date:~0,4%%date:~5,2%%date:~8,2%.zip
echo.
echo 🚀 下一步操作：
echo.
echo    方式1: 复制整个 offline_deployment_package 文件夹到目标机器
echo    方式2: 使用生成的 ZIP 压缩包传输
echo.
echo    然后在目标机器上双击运行：一键部署并启动.bat
echo.
echo ════════════════════════════════════════════════════════
echo.
echo 按任意键打开离线包目录...
pause >nul
explorer "%DEPLOY_DIR%"
