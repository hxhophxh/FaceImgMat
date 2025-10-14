@echo off
REM ====================================================================
REM 准备超级离线包 - 批处理启动器
REM 在有网络的机器上运行
REM ====================================================================
chcp 65001 >nul

echo.
echo ================================================================
echo.
echo   准备 FaceImgMat 超级离线部署包
echo.
echo   本脚本将下载Python安装程序和所有依赖
echo   需要网络连接，预计耗时 20-30 分钟
echo.
echo ================================================================
echo.

REM 重新编码PowerShell脚本以解决中文乱码问题
echo [提示] 正在准备脚本...
powershell -ExecutionPolicy Bypass -NoProfile -Command "Get-Content '%~dp0prepare-super-package.ps1' -Raw -Encoding UTF8 | Set-Content '%~dp0prepare-super-package-temp.ps1' -Encoding UTF8"

REM 运行重新编码后的脚本（静默模式）
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0prepare-super-package-temp.ps1" -Silent

set SCRIPT_EXIT_CODE=%errorlevel%

REM 清理临时文件
del "%~dp0prepare-super-package-temp.ps1" >nul 2>&1

if %SCRIPT_EXIT_CODE% neq 0 (
    echo.
    echo [错误] 离线包准备失败！
    pause
    exit /b 1
)

echo.
echo [完成] 按任意键退出...
pause >nul