@echo off
REM FaceImgMat - 准备超级离线包
REM 在有网络的机器上运行此脚本

echo.
echo === 准备 FaceImgMat 超级离线包 ===
echo.
echo   - 将下载 Python 安装程序和所有依赖包
echo   - 需要网络连接 (20-30 分钟)
echo.
echo ---------------------------------------------------------------
echo.

REM 重新编码 PowerShell 脚本并以静默模式运行
echo [信息] 正在准备 PowerShell 脚本...
powershell -ExecutionPolicy Bypass -NoProfile -Command "Get-Content '%~dp0prepare-super-package.ps1' -Raw -Encoding UTF8 | Set-Content '%~dp0prepare-super-package-temp.ps1' -Encoding UTF8"
if %errorlevel% neq 0 (
    echo [错误] PowerShell 脚本准备失败
    pause
    exit /b 1
)

powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0prepare-super-package-temp.ps1" -Silent
set SCRIPT_EXIT_CODE=%errorlevel%

del "%~dp0prepare-super-package-temp.ps1" >nul 2>&1

if %SCRIPT_EXIT_CODE% neq 0 (
    echo.
    echo [错误] 离线包准备失败
    pause
    exit /b 1
)

echo.
echo [完成] 按任意键退出...
pause >nul
echo.
