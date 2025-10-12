#!/bin/bash
# ===================================================================
# FaceImgMat 离线部署安装脚本 (Linux/macOS)
# ===================================================================
# 使用说明：
#   1. 将离线部署包解压到任意目录
#   2. 在包含此脚本的目录运行: chmod +x deploy_offline.sh && ./deploy_offline.sh
#   3. 等待自动部署完成
# ===================================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 输出函数
print_step() {
    echo -e "${CYAN}[$(date '+%H:%M:%S')] ===== $1 =====${NC}"
}

print_success() {
    echo -e "${GREEN}  [✓] $1${NC}"
}

print_error() {
    echo -e "${RED}  [✗] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  [!] $1${NC}"
}

print_info() {
    echo -e "  [i] $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 显示欢迎信息
clear
echo -e "${MAGENTA}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║      🎭 FaceImgMat 人脸识别系统 - 离线一键部署            ║
║                   版本: 1.0.0 (Offline)                    ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_info "部署时间: $(date '+%Y-%m-%d %H:%M:%S')"
print_info "工作目录: $(pwd)"
echo ""

# ===================================================================
# 第1步：检查离线包结构
# ===================================================================
print_step "步骤 1/7: 检查离线部署包"

print_info "验证离线包完整性..."

# 检查必要的目录和文件
ALL_ITEMS_PRESENT=true

check_item() {
    if [ -e "$1" ]; then
        print_success "$2: $1"
    else
        print_error "缺失 $2: $1"
        ALL_ITEMS_PRESENT=false
    fi
}

check_item "FaceImgMat" "项目源代码"
check_item "python_packages" "Python依赖包"
check_item "FaceImgMat/requirements.txt" "依赖列表文件"

if [ "$ALL_ITEMS_PRESENT" = false ]; then
    print_error "离线包不完整！请确保解压完整的离线部署包。"
    exit 1
fi

# 检查Python包数量
PACKAGE_COUNT=$(ls python_packages | wc -l)
PACKAGE_SIZE=$(du -sm python_packages | cut -f1)
print_info "Python依赖包: $PACKAGE_COUNT 个文件, ${PACKAGE_SIZE}MB"

# 检查模型文件
if [ -d "insightface_models" ]; then
    MODEL_SIZE=$(du -sm insightface_models | cut -f1)
    print_success "InsightFace模型: ${MODEL_SIZE}MB"
    HAS_MODELS=true
else
    print_warning "未找到InsightFace模型，首次运行时将自动下载（需要网络）"
    HAS_MODELS=false
fi

# ===================================================================
# 第2步：环境检查
# ===================================================================
print_step "步骤 2/7: 环境检查"

# 检查操作系统
print_info "检查操作系统..."
OS_TYPE=$(uname -s)
print_success "操作系统: $OS_TYPE"

# 检查Python
print_info "检查 Python 安装..."
if ! command_exists python3; then
    print_error "未找到 Python3！"
    print_warning "请先安装 Python 3.11 或 3.12"
    case "$OS_TYPE" in
        Linux)
            print_warning "Ubuntu/Debian: sudo apt install python3.11 python3.11-venv python3-pip"
            print_warning "CentOS/RHEL:   sudo yum install python3.11"
            ;;
        Darwin)
            print_warning "macOS: brew install python@3.11"
            ;;
    esac
    exit 1
fi

PYTHON_VERSION=$(python3 --version)
print_success "发现 Python: $PYTHON_VERSION"

# 检查Python版本
PYTHON_MAJOR=$(python3 -c 'import sys; print(sys.version_info.major)')
PYTHON_MINOR=$(python3 -c 'import sys; print(sys.version_info.minor)')

if [ "$PYTHON_MAJOR" -ne 3 ] || [ "$PYTHON_MINOR" -lt 11 ]; then
    print_error "需要 Python 3.11 或更高版本，当前版本: $PYTHON_VERSION"
    print_warning "建议安装 Python 3.11 或 3.12"
    exit 1
fi
print_success "Python 版本检查通过"

# 检查磁盘空间
print_info "检查磁盘空间..."
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 3 ]; then
    print_error "磁盘空间不足！剩余: ${AVAILABLE_SPACE}GB，建议至少 3GB"
    exit 1
fi
print_success "磁盘空间充足: ${AVAILABLE_SPACE}GB 可用"

# ===================================================================
# 第3步：进入项目目录
# ===================================================================
print_step "步骤 3/7: 准备项目目录"

PROJECT_PATH="$(pwd)/FaceImgMat"
print_info "项目路径: $PROJECT_PATH"

cd "$PROJECT_PATH"
print_success "已进入项目目录"

# ===================================================================
# 第4步：创建虚拟环境
# ===================================================================
print_step "步骤 4/7: 创建 Python 虚拟环境"

VENV_PATH=".venv"
if [ -d "$VENV_PATH" ]; then
    print_warning "虚拟环境已存在，将重新创建..."
    rm -rf "$VENV_PATH"
fi

print_info "创建虚拟环境..."
python3 -m venv "$VENV_PATH"
print_success "虚拟环境创建成功"

# 激活虚拟环境
print_info "激活虚拟环境..."
source "$VENV_PATH/bin/activate"
print_success "虚拟环境激活成功"

# 升级 pip（离线模式）
print_info "升级 pip..."
PACKAGES_PATH="$(dirname "$PROJECT_PATH")/python_packages"
python -m pip install --upgrade pip --no-index --find-links="$PACKAGES_PATH" --quiet
print_success "pip 升级完成"

# ===================================================================
# 第5步：安装依赖包（离线）
# ===================================================================
print_step "步骤 5/7: 安装 Python 依赖包（离线模式）"

print_info "从本地包安装依赖..."
print_info "包目录: $PACKAGES_PATH"

pip install -r requirements.txt --no-index --find-links="$PACKAGES_PATH"

print_success "所有依赖包安装完成！"

# 验证关键包
print_info "验证关键依赖..."
KEY_PACKAGES=("flask" "insightface" "faiss-cpu" "opencv-python")
for pkg in "${KEY_PACKAGES[@]}"; do
    if pip show "$pkg" >/dev/null 2>&1; then
        print_success "  ✓ $pkg"
    else
        print_error "  ✗ $pkg 未正确安装"
        exit 1
    fi
done

# ===================================================================
# 第6步：配置InsightFace模型
# ===================================================================
print_step "步骤 6/7: 配置 InsightFace 模型"

if [ "$HAS_MODELS" = true ]; then
    print_info "复制 InsightFace 模型到用户目录..."
    
    MODEL_SRC="$(dirname "$PROJECT_PATH")/insightface_models"
    MODEL_DST="$HOME/.insightface/models"
    
    mkdir -p "$(dirname "$MODEL_DST")"
    
    if [ -d "$MODEL_DST" ]; then
        print_info "目标目录已存在，将覆盖..."
        rm -rf "$MODEL_DST"
    fi
    
    cp -r "$MODEL_SRC" "$MODEL_DST"
    print_success "模型文件已配置到: $MODEL_DST"
    
    # 列出模型文件
    print_info "已安装的模型："
    find "$MODEL_DST" -type f | while read -r file; do
        SIZE_MB=$(du -sm "$file" | cut -f1)
        FILENAME=$(basename "$file")
        print_info "  - $FILENAME (${SIZE_MB}MB)"
    done
else
    print_warning "未提供离线模型，首次运行时需要网络连接下载模型"
fi

# ===================================================================
# 第7步：初始化数据库
# ===================================================================
print_step "步骤 7/7: 初始化数据库"

# 创建必要的目录
DIRECTORIES=("static/faces" "static/uploads" "instance" "logs" "models")
for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "创建目录: $dir"
    fi
done

# 检查数据库是否已存在
DB_PATH="instance/face_matching.db"
if [ ! -f "$DB_PATH" ]; then
    print_info "数据库不存在，正在初始化..."
    
    if [ -f "scripts/init_demo_data.py" ]; then
        if python scripts/init_demo_data.py; then
            print_success "数据库初始化成功，已创建演示数据"
        else
            print_warning "数据库初始化失败，但不影响系统运行"
        fi
    else
        print_warning "未找到初始化脚本"
    fi
else
    print_info "数据库已存在: $DB_PATH"
    DB_SIZE=$(du -k "$DB_PATH" | cut -f1)
    print_info "数据库大小: ${DB_SIZE}KB"
fi

# ===================================================================
# 部署完成
# ===================================================================
echo -e "${GREEN}"
cat << "EOF"

╔════════════════════════════════════════════════════════════╗
║              🎉 离线部署完成！                             ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
print_info "系统信息："
print_success "  项目路径: $PROJECT_PATH"
print_success "  访问地址: http://127.0.0.1:5000"
print_success "  默认账号: admin"
print_success "  默认密码: Admin@FaceMatch2025!"

echo ""
print_warning "安全提醒："
print_info "  1. 首次登录后请立即修改管理员密码"
print_info "  2. 运行命令: python scripts/change_admin_password.py"
print_info "  3. 生产环境请配置 HTTPS 和防火墙"

echo ""
print_info "启动服务："
echo -e "${CYAN}  cd FaceImgMat${NC}"
echo -e "${CYAN}  source .venv/bin/activate${NC}"
echo -e "${CYAN}  python run.py${NC}"

echo ""
print_warning "是否立即启动服务？(y/n)"
read -r RESPONSE
if [ "$RESPONSE" = "y" ] || [ "$RESPONSE" = "Y" ]; then
    print_info "正在启动服务..."
    print_warning "按 Ctrl+C 可停止服务"
    echo ""
    python run.py
fi
