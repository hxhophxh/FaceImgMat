@echo off
REM ====================================================================
REM Prepare Super Offline Package
REM Run this on a machine with internet connection
REM ====================================================================
chcp 65001 >nul

echo.
echo ================================================================
echo.
echo   FaceImgMat Super Offline Bundle Builder
echo.
echo   This will snapshot the validated .venv, models, and installer
echo   Estimated time: 3-8 minutes (no large downloads)
echo   Advanced: use prepare-super-package.ps1 -SkipZip / -ZipTool SevenZip
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

REM Detect preferred compression tool so BAT 调用也能触发进度条
set "ZIP_TOOL_PARAM="
where 7z.exe >nul 2>&1
if %errorlevel%==0 set "ZIP_TOOL_PARAM=-ZipTool SevenZip"
if not defined ZIP_TOOL_PARAM if exist "C:\Program Files\7-Zip\7z.exe" set "ZIP_TOOL_PARAM=-ZipTool SevenZip"
if not defined ZIP_TOOL_PARAM if exist "C:\Program Files (x86)\7-Zip\7z.exe" set "ZIP_TOOL_PARAM=-ZipTool SevenZip"
if defined ZIP_TOOL_PARAM (
    echo [INFO] Detected 7-Zip, enabling zip progress UI...
) else (
    echo [INFO] 7-Zip not found, falling back to auto tool selection.
)

REM Run the re-encoded script in silent mode
echo [INFO] Collecting local environment and building bundle...
echo.
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0prepare-super-package-temp.ps1" -Silent %ZIP_TOOL_PARAM%

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
echo 1. Verify offline_bundle.zip or offline_bundle/ folder is generated
echo 2. Upload the ZIP (or manually compressed archive) to GitHub Release / targets
echo 3. Distribute together with updated deployment scripts
echo.
pause
