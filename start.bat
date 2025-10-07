@echo off
chcp 65001 >nul
cls
echo ========================================
echo    🎭 人脸图像匹配系统
echo ========================================
echo.

REM 检查虚拟环境
if not exist ".venv\Scripts\activate.bat" (
    echo ❌ 虚拟环境不存在！
    echo 💡 请先运行: python -m venv .venv
    echo.
    pause
    exit /b 1
)

echo 🔧 激活虚拟环境...
call .venv\Scripts\activate.bat

REM 检查是否需要初始化数据
if not exist "instance\face_matching.db" (
    echo.
    echo 📊 检测到首次运行，正在初始化演示数据...
    python scripts\init_demo_data.py
    echo.
)

REM 启动应用
echo.
echo ✨ 系统启动成功！
echo ========================================
echo 📍 访问地址: http://127.0.0.1:5000
echo 👤 默认账号: admin
echo 🔐 默认密码: Admin@FaceMatch2025!
echo ========================================
echo.
echo 💡 提示: 按 Ctrl+C 停止服务
echo.

python run.py