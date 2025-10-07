# PowerShell 启动脚本
# 人脸图像匹配系统

Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   人脸图像匹配系统" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查虚拟环境
if (-not (Test-Path ".venv\Scripts\Activate.ps1")) {
    Write-Host "虚拟环境不存在！" -ForegroundColor Red
    Write-Host "请先运行: python -m venv .venv" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "正在激活虚拟环境..." -ForegroundColor Cyan
& .\.venv\Scripts\Activate.ps1

# 检查是否需要初始化数据
if (-not (Test-Path "instance\face_matching.db")) {
    Write-Host ""
    Write-Host "检测到首次运行，正在初始化演示数据..." -ForegroundColor Yellow
    python scripts\init_demo_data.py
    Write-Host ""
}

# 启动应用
Write-Host ""
Write-Host "系统启动成功！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "访问地址: " -NoNewline -ForegroundColor White
Write-Host "http://127.0.0.1:5000" -ForegroundColor Yellow
Write-Host "默认账号: " -NoNewline -ForegroundColor White
Write-Host "admin" -ForegroundColor Yellow
Write-Host "默认密码: " -NoNewline -ForegroundColor White
Write-Host "Admin@FaceMatch2025!" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "提示: 按 Ctrl+C 停止服务" -ForegroundColor Gray
Write-Host ""

python run.py