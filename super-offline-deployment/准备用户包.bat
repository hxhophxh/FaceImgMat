@echo off
REM ====================================================================
REM 准备用户包 - 清理工具
REM 用于清理已下载的文件，生成轻量级的用户包（方案A）
REM ====================================================================
chcp 65001 >nul

echo.
echo ================================================================
echo.
echo   FaceImgMat 用户包准备工具
echo.
echo   此脚本会清理已下载的文件，生成轻量级部署包
echo   适用于：用户可以联网的场景
echo.
echo ================================================================
echo.

set SCRIPT_DIR=%~dp0

echo [INFO] Current directory: %SCRIPT_DIR%
echo.

REM 检查是否在正确的目录
if not exist "%SCRIPT_DIR%prepare-super-offline.bat" (
    echo [ERROR] Not in the super-offline-deployment directory!
    echo [ERROR] Please run this script from the super-offline-deployment folder.
    pause
    exit /b 1
)

echo [WARNING] This will DELETE the following:
echo   - 01-Python安装包\python-3.12.7-amd64.exe
echo   - 03-Python依赖包\*.whl (all wheel files)
echo   - 04-AI模型文件\insightface_models\ (entire folder)
echo.
echo After cleaning, the package size will be about 10MB.
echo Users will need to run prepare-super-offline.bat to download these files.
echo.

set /p CONFIRM="Are you sure? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo [INFO] Operation cancelled.
    pause
    exit /b 0
)

echo.
echo ================================================================
echo [STEP 1/3] Cleaning Python installer...
echo ================================================================
echo.

if exist "%SCRIPT_DIR%01-Python安装包\python-3.12.7-amd64.exe" (
    del /F /Q "%SCRIPT_DIR%01-Python安装包\python-3.12.7-amd64.exe"
    echo [OK] Python installer deleted
) else (
    echo [INFO] Python installer not found (already clean)
)

echo.
echo ================================================================
echo [STEP 2/3] Cleaning Python packages...
echo ================================================================
echo.

if exist "%SCRIPT_DIR%03-Python依赖包\*.whl" (
    del /F /Q "%SCRIPT_DIR%03-Python依赖包\*.whl"
    echo [OK] Python packages deleted
) else (
    echo [INFO] Python packages not found (already clean)
)

echo.
echo ================================================================
echo [STEP 3/3] Cleaning AI models...
echo ================================================================
echo.

if exist "%SCRIPT_DIR%04-AI模型文件\insightface_models\" (
    rmdir /S /Q "%SCRIPT_DIR%04-AI模型文件\insightface_models\"
    echo [OK] AI models deleted
) else (
    echo [INFO] AI models not found (already clean)
)

echo.
echo ================================================================
echo [SUCCESS] User package is ready!
echo ================================================================
echo.
echo Package location: %SCRIPT_DIR%
echo Estimated size: ~10MB
echo.
echo Next steps:
echo 1. Compress the super-offline-deployment folder to ZIP (optional)
echo 2. Send to users who have internet connection
echo 3. Users will run: prepare-super-offline.bat
echo 4. Then users run: 一键完整部署.bat
echo.
echo Press any key to exit...
pause >nul
