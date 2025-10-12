@echo off
REM ====================================================================
REM Prepare Super Offline Package
REM Run this on a machine with internet connection
REM ====================================================================
chcp 65001 >nul

echo.
echo ================================================================
echo.
echo   FaceImgMat Super Offline Package Preparation
echo.
echo   This will download Python installer and all dependencies
echo   Estimated time: 20-30 minutes
echo.
echo ================================================================
echo.

REM Re-encode PowerShell script to fix UTF-8 encoding issues
echo [INFO] Preparing script...
powershell -ExecutionPolicy Bypass -NoProfile -Command "Get-Content '%~dp0prepare-super-package.ps1' -Raw -Encoding UTF8 | Set-Content '%~dp0prepare-super-package-temp.ps1' -Encoding UTF8"

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to prepare script!
    pause
    exit /b 1
)

REM Run the re-encoded script in silent mode
echo [INFO] Starting download and preparation...
echo.
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0prepare-super-package-temp.ps1" -Silent

set SCRIPT_EXIT_CODE=%errorlevel%

REM Clean up temporary file
del "%~dp0prepare-super-package-temp.ps1" >nul 2>&1

if %SCRIPT_EXIT_CODE% neq 0 (
    echo.
    echo ================================================================
    echo [ERROR] Offline package preparation FAILED!
    echo ================================================================
    echo.
    pause
    exit /b 1
)

echo.
echo ================================================================
echo [SUCCESS] Super offline package preparation completed!
echo ================================================================
echo.
echo Next steps:
echo 1. Compress the entire super-offline-deployment folder
echo 2. Transfer to target machine
echo 3. Run the deployment script
echo.
pause
