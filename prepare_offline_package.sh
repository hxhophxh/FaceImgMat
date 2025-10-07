#!/bin/bash
# 离线部署准备脚本 (Linux/macOS)
# 此脚本帮助您准备完整的离线部署包

set -e

echo "🚀 开始准备离线部署包..."
echo ""

# 1. 检查当前目录
if [ ! -f "requirements.txt" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

PROJECT_ROOT=$(pwd)
echo "📁 项目目录: $PROJECT_ROOT"

# 2. 创建离线包目录
OFFLINE_DIR="$PROJECT_ROOT/offline_deployment_package"
if [ -d "$OFFLINE_DIR" ]; then
    echo "⚠️  离线包目录已存在，将被覆盖"
    rm -rf "$OFFLINE_DIR"
fi
mkdir -p "$OFFLINE_DIR"
echo "✅ 创建离线包目录: $OFFLINE_DIR"

# 3. 下载Python依赖包
echo ""
echo "📦 下载Python依赖包..."
PACKAGES_DIR="$OFFLINE_DIR/python_packages"
mkdir -p "$PACKAGES_DIR"

echo "   正在下载依赖包（这可能需要5-10分钟）..."
pip download -r requirements.txt -d "$PACKAGES_DIR" --no-cache-dir

if [ $? -eq 0 ]; then
    PACKAGE_COUNT=$(ls -1 "$PACKAGES_DIR" | wc -l)
    PACKAGE_SIZE=$(du -sh "$PACKAGES_DIR" | cut -f1)
    echo "✅ 已下载 $PACKAGE_COUNT 个依赖包，总大小: $PACKAGE_SIZE"
else
    echo "❌ 依赖包下载失败"
    exit 1
fi

# 4. 复制InsightFace模型
echo ""
echo "🤖 复制InsightFace模型文件..."
INSIGHTFACE_SRC="$HOME/.insightface/models"
INSIGHTFACE_DST="$OFFLINE_DIR/insightface_models"

if [ -d "$INSIGHTFACE_SRC" ]; then
    cp -r "$INSIGHTFACE_SRC" "$INSIGHTFACE_DST"
    MODEL_SIZE=$(du -sh "$INSIGHTFACE_DST" | cut -f1)
    echo "✅ 模型文件已复制，大小: $MODEL_SIZE"
    
    # 列出模型文件
    echo "   模型文件列表:"
    find "$INSIGHTFACE_DST" -type f -name "*.onnx" | while read file; do
        size=$(du -h "$file" | cut -f1)
        basename=$(basename "$file")
        echo "   - $basename ($size)"
    done
else
    echo "⚠️  未找到InsightFace模型，将在首次运行时自动下载"
    echo "   建议先运行一次应用以下载模型："
    echo "   python -c \"import insightface; insightface.app.FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])\""
    mkdir -p "$INSIGHTFACE_DST"
fi

# 5. 复制项目文件
echo ""
echo "📄 复制项目文件..."
PROJECT_DST="$OFFLINE_DIR/FaceImgMat"

# 使用rsync复制（排除特定目录）
rsync -av --progress \
    --exclude='.venv' \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='offline_deployment_package' \
    "$PROJECT_ROOT/" "$PROJECT_DST/"

if [ $? -eq 0 ]; then
    PROJECT_SIZE=$(du -sh "$PROJECT_DST" | cut -f1)
    echo "✅ 项目文件已复制，大小: $PROJECT_SIZE"
else
    echo "❌ 项目文件复制失败"
    exit 1
fi

# 6. 创建部署脚本
echo ""
echo "📝 创建部署脚本..."

# Windows部署脚本
cat > "$OFFLINE_DIR/deploy_windows.ps1" << 'EOF'
# 离线部署脚本 (Windows)
Write-Host "🚀 开始离线部署..." -ForegroundColor Green

# 检查Python
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 未找到Python，请先安装Python 3.11或3.12" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Python版本: $pythonVersion" -ForegroundColor Green

# 进入项目目录
Set-Location FaceImgMat

# 创建虚拟环境
Write-Host "📦 创建虚拟环境..." -ForegroundColor Cyan
python -m venv .venv

# 激活虚拟环境
& .\.venv\Scripts\Activate.ps1

# 安装依赖
Write-Host "📦 安装依赖包..." -ForegroundColor Cyan
pip install --upgrade pip --no-index --find-links=..\python_packages
pip install -r requirements.txt --no-index --find-links=..\python_packages

# 配置InsightFace模型
Write-Host "🤖 配置InsightFace模型..." -ForegroundColor Cyan
$modelDst = Join-Path $env:USERPROFILE ".insightface\models"
New-Item -ItemType Directory -Path $modelDst -Force | Out-Null
Copy-Item -Path ..\insightface_models\* -Destination $modelDst -Recurse -Force

# 检查数据库
if (-not (Test-Path "instance\face_matching.db")) {
    Write-Host "⚠️  数据库不存在，正在初始化..." -ForegroundColor Yellow
    python scripts\init_demo_data.py
}

Write-Host ""
Write-Host "✅ 部署完成！" -ForegroundColor Green
Write-Host ""
Write-Host "启动服务：python run.py" -ForegroundColor Cyan
Write-Host "访问地址：http://127.0.0.1:5000" -ForegroundColor Cyan
Write-Host "默认账户：admin / Admin@FaceMatch2025!" -ForegroundColor Cyan
EOF

# Linux部署脚本
cat > "$OFFLINE_DIR/deploy_linux.sh" << 'EOF'
#!/bin/bash
# 离线部署脚本 (Linux)
set -e

echo "🚀 开始离线部署..."

# 检查Python
if ! command -v python3.11 &> /dev/null; then
    echo "❌ 未找到Python 3.11，请先安装"
    exit 1
fi

echo "✅ Python版本: $(python3.11 --version)"

# 进入项目目录
cd FaceImgMat

# 创建虚拟环境
echo "📦 创建虚拟环境..."
python3.11 -m venv .venv

# 激活虚拟环境
source .venv/bin/activate

# 安装依赖
echo "📦 安装依赖包..."
python -m pip install --upgrade pip --no-index --find-links=../python_packages
pip install -r requirements.txt --no-index --find-links=../python_packages

# 配置InsightFace模型
echo "🤖 配置InsightFace模型..."
mkdir -p ~/.insightface/models
cp -r ../insightface_models/* ~/.insightface/models/

# 检查数据库
if [ ! -f "instance/face_matching.db" ]; then
    echo "⚠️  数据库不存在，正在初始化..."
    python scripts/init_demo_data.py
fi

echo ""
echo "✅ 部署完成！"
echo ""
echo "启动服务：python run.py"
echo "访问地址：http://127.0.0.1:5000"
echo "默认账户：admin / Admin@FaceMatch2025!"
EOF

chmod +x "$OFFLINE_DIR/deploy_linux.sh"

echo "✅ 部署脚本已创建"

# 7. 创建说明文件
cat > "$OFFLINE_DIR/README.txt" << 'EOF'
# 离线部署包说明

## 📦 包含内容

1. **FaceImgMat/** - 项目源代码
   - 包含数据库文件（已初始化）
   - 包含测试图片
   
2. **python_packages/** - Python依赖包（约500-800MB）
   - 所有requirements.txt中的包
   - 可离线安装

3. **insightface_models/** - AI模型文件（约300MB）
   - buffalo_l模型
   - 人脸检测和识别模型

4. **deploy_windows.ps1** - Windows自动部署脚本
5. **deploy_linux.sh** - Linux自动部署脚本
6. **README.txt** - 本说明文件

## 🚀 快速部署

### Windows环境

1. 确保已安装Python 3.11或3.12
2. 右键点击 deploy_windows.ps1，选择"使用PowerShell运行"
3. 等待部署完成
4. 运行: python run.py

### Linux环境

1. 确保已安装Python 3.11或3.12
2. 运行: chmod +x deploy_linux.sh && ./deploy_linux.sh
3. 运行: python run.py

## 📊 系统要求

- Python 3.11 或 3.12
- 至少 2GB RAM
- 至少 5GB 磁盘空间

## 🔐 默认账户

- 用户名: admin
- 密码: Admin@FaceMatch2025!

⚠️ 首次登录后请立即修改密码！

## 📚 详细文档

查看 FaceImgMat/docs/OFFLINE-DEPLOYMENT.md

## 🆘 问题排查

如果遇到问题，请查看：
- FaceImgMat/docs/OFFLINE-DEPLOYMENT.md
- FaceImgMat/README.md
EOF

echo "✅ 说明文件已创建"

# 8. 创建打包脚本
echo ""
echo "📦 创建打包脚本..."

cat > "$PROJECT_ROOT/create_offline_package.sh" << 'EOF'
#!/bin/bash
# 打包离线部署包

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TAR_FILE="FaceImgMat-offline-$TIMESTAMP.tar.gz"

echo "正在打包到: $TAR_FILE"
tar -czf "$TAR_FILE" -C offline_deployment_package .

TAR_SIZE=$(du -h "$TAR_FILE" | cut -f1)
echo "✅ 打包完成！文件大小: $TAR_SIZE"
echo "文件位置: $(pwd)/$TAR_FILE"
EOF

chmod +x "$PROJECT_ROOT/create_offline_package.sh"

echo "✅ 打包脚本已创建: create_offline_package.sh"

# 9. 统计信息
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 离线部署包统计"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_SIZE=$(du -sh "$OFFLINE_DIR" | cut -f1)

echo "📁 目录: $OFFLINE_DIR"
echo "💾 总大小: $TOTAL_SIZE"
echo ""

for dir in "$OFFLINE_DIR"/*; do
    if [ -d "$dir" ]; then
        DIR_SIZE=$(du -sh "$dir" | cut -f1)
        DIR_NAME=$(basename "$dir")
        echo "  📂 $DIR_NAME: $DIR_SIZE"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 离线部署包准备完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 下一步操作："
echo "   1. 运行 ./create_offline_package.sh 打包成tar.gz文件"
echo "   2. 将tar.gz文件传输到离线环境"
echo "   3. 在离线环境解压并运行部署脚本"
echo ""
echo "📚 详细说明请查看: offline_deployment_package/README.txt"
