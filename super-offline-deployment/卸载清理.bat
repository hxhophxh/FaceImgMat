@echo off
REM ====================================================================
REM FaceImgMat 卸载清理脚本
REM 清理已部署的项目和Python环境（可选）
REM ====================================================================
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║     FaceImgMat - 卸载清理工具                                  ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [警告] 本脚本将清理以下内容：
echo.
echo   [√] 项目虚拟环境 (.venv)
echo   [√] 数据库文件 (instance/*.db)
echo   [√] 上传的文件 (static/uploads/*)
echo   [√] 日志文件 (logs/*)
echo   [√] AI模型缓存 (models/*)
echo   [?] Python 安装程序（可选）
echo.
echo [提示] 源代码不会被删除
echo.
echo ════════════════════════════════════════════════════════════════
echo.

set /p CONFIRM="确认要清理吗？(Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo.
    echo [取消] 未执行任何操作
    pause
    exit /b 0
)

set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%02-项目源码\FaceImgMat"

echo.
echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 1/5] 清理项目虚拟环境...
echo.

if exist "%PROJECT_DIR%\.venv" (
    echo [提示] 删除虚拟环境...
    rmdir /s /q "%PROJECT_DIR%\.venv"
    echo [√] 虚拟环境已删除
) else (
    echo [跳过] 未找到虚拟环境
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 2/5] 清理数据库...
echo.

if exist "%PROJECT_DIR%\instance\face_matching.db" (
    echo [提示] 删除数据库文件...
    del /f /q "%PROJECT_DIR%\instance\face_matching.db"
    echo [√] 数据库已删除
) else (
    echo [跳过] 未找到数据库文件
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 3/5] 清理上传文件和缓存...
echo.

if exist "%PROJECT_DIR%\static\uploads" (
    echo [提示] 清空 uploads 目录...
    del /f /q "%PROJECT_DIR%\static\uploads\*.*" 2>nul
    echo [√] 上传文件已清理
) else (
    echo [跳过] 未找到 uploads 目录
)

if exist "%PROJECT_DIR%\logs" (
    echo [提示] 清空 logs 目录...
    del /f /q "%PROJECT_DIR%\logs\*.*" 2>nul
    echo [√] 日志文件已清理
) else (
    echo [跳过] 未找到 logs 目录
)

if exist "%PROJECT_DIR%\models" (
    echo [提示] 清空 models 缓存...
    rmdir /s /q "%PROJECT_DIR%\models" 2>nul
    mkdir "%PROJECT_DIR%\models"
    echo [√] 模型缓存已清理
) else (
    echo [跳过] 未找到 models 目录
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 4/5] 清理 InsightFace 模型...
echo.

set /p CLEAN_MODELS="是否删除 InsightFace 模型文件？(Y/N): "
if /i "%CLEAN_MODELS%"=="Y" (
    if exist "%USERPROFILE%\.insightface" (
        echo [提示] 删除用户目录下的模型...
        rmdir /s /q "%USERPROFILE%\.insightface"
        echo [√] InsightFace 模型已删除
    ) else (
        echo [跳过] 未找到 InsightFace 模型
    )
) else (
    echo [跳过] 保留 InsightFace 模型
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo [步骤 5/5] Python 环境...
echo.

set /p UNINSTALL_PYTHON="是否卸载 Python？(Y/N): "
if /i "%UNINSTALL_PYTHON%"=="Y" (
    echo.
    echo [提示] Python 卸载需要手动操作：
    echo   1. 打开「控制面板」→「程序和功能」
    echo   2. 找到「Python 3.12.7」
    echo   3. 右键 →「卸载」
    echo.
    echo [提示] 或使用 Windows 设置：
    echo   设置 → 应用 → 应用和功能 → Python 3.12.7 → 卸载
    echo.
    echo [提示] 或手动删除安装目录：
    echo   D:\Python312（如果安装在此位置）
    echo.
    set /p OPEN_SETTINGS="是否打开「程序和功能」？(Y/N): "
    if /i "!OPEN_SETTINGS!"=="Y" (
        start appwiz.cpl
    )
) else (
    echo [跳过] 保留 Python 环境
)
echo.

echo ════════════════════════════════════════════════════════════════
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                  ✅ 清理完成！                                 ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo [已清理]
echo   √ 虚拟环境
echo   √ 数据库文件
echo   √ 上传文件和日志

if /i "%CLEAN_MODELS%"=="Y" (
    echo   √ InsightFace 模型
)

echo.
echo [保留]
echo   - 项目源代码
echo   - Python 安装（如未卸载）
echo   - 离线依赖包
echo.
echo [提示] 如需重新部署，再次运行「一键完整部署.bat」即可
echo.
echo ════════════════════════════════════════════════════════════════
echo.
pause
