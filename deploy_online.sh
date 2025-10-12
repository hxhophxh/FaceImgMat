#!/bin/bash
# ===================================================================
# FaceImgMat 在线一键部署脚本 (Linux/macOS)
# ===================================================================
# 适用场景：全新Linux/macOS机器，有网络连接
# 功能：自动检查环境、创建虚拟环境、安装依赖、初始化数据、启动服务
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
║        🎭 FaceImgMat 人脸识别系统 - 在线一键部署          ║
║                     版本: 1.0.0                            ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_info "部署时间: $(date '+%Y-%m-%d %H:%M:%S')"
print_info "工作目录: $(pwd)"
echo ""

# ===================================================================
# 第1步：环境检查
# ===================================================================
print_step "步骤 1/6: 环境检查"

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

# 检查pip
print_info "检查 pip 安装..."
if ! command_exists pip3; then
    print_error "未找到 pip3！"
    print_warning "请安装 pip: python3 -m ensurepip --upgrade"
    exit 1
fi
print_success "发现 pip: $(pip3 --version)"

# 检查网络连接
print_info "检查网络连接..."
if ping -c 1 pypi.org >/dev/null 2>&1; then
    print_success "网络连接正常"
else
    print_warning "无法连接到 pypi.org，可能会影响包下载"
    print_warning "如果部署失败，请检查网络或使用离线部署方式"
fi

# 检查磁盘空间
print_info "检查磁盘空间..."
AVAILABLE_SPACE=$(df -BG . | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$AVAILABLE_SPACE" -lt 5 ]; then
    print_error "磁盘空间不足！剩余: ${AVAILABLE_SPACE}GB，建议至少 5GB"
    exit 1
fi
print_success "磁盘空间充足: ${AVAILABLE_SPACE}GB 可用"

# ===================================================================
# 第2步：创建虚拟环境
# ===================================================================
print_step "步骤 2/6: 创建 Python 虚拟环境"

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

# 升级 pip
print_info "升级 pip 到最新版本..."
pip install --upgrade pip --quiet
print_success "pip 升级完成"

# ===================================================================
# 第3步：安装依赖包
# ===================================================================
print_step "步骤 3/6: 安装 Python 依赖包"

if [ ! -f "requirements.txt" ]; then
    print_error "未找到 requirements.txt 文件！"
    exit 1
fi

print_info "开始安装依赖包（这可能需要 5-15 分钟，请耐心等待）..."
print_warning "正在下载和安装: Flask, InsightFace, FAISS, OpenCV 等..."

# 使用重试机制
MAX_RETRIES=3
RETRY_COUNT=0
INSTALL_SUCCESS=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$INSTALL_SUCCESS" = false ]; do
    if [ $RETRY_COUNT -gt 0 ]; then
        print_warning "第 $((RETRY_COUNT + 1)) 次尝试安装..."
    fi
    
    if pip install -r requirements.txt --timeout 300; then
        INSTALL_SUCCESS=true
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
    fi
done

if [ "$INSTALL_SUCCESS" = false ]; then
    print_error "依赖包安装失败！"
    print_warning "可能的原因："
    print_warning "  1. 网络连接不稳定"
    print_warning "  2. PyPI 服务器响应慢"
    print_warning "建议："
    print_warning "  1. 检查网络连接"
    print_warning "  2. 使用国内镜像: pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple"
    print_warning "  3. 使用离线部署方式"
    exit 1
fi

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
# 第4步：创建必要的目录
# ===================================================================
print_step "步骤 4/6: 创建项目目录结构"

DIRECTORIES=(
    "static/faces"
    "static/uploads"
    "instance"
    "logs"
    "models"
)

for dir in "${DIRECTORIES[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "创建目录: $dir"
    else
        print_info "目录已存在: $dir"
    fi
done

# ===================================================================
# 第5步：初始化数据库和演示数据
# ===================================================================
print_step "步骤 5/6: 初始化数据库和演示数据"

if [ -f "scripts/init_demo_data.py" ]; then
    print_info "运行数据初始化脚本..."
    if python scripts/init_demo_data.py; then
        print_success "数据库和演示数据初始化成功"
        print_info "已创建 3 个测试人员（张三、李四、王五）"
    else
        print_warning "数据初始化失败，但不影响系统启动"
    fi
else
    print_warning "未找到初始化脚本，跳过数据初始化"
fi

# ===================================================================
# 第6步：启动服务
# ===================================================================
print_step "步骤 6/6: 启动 FaceImgMat 服务"

echo -e "${GREEN}"
cat << "EOF"

╔════════════════════════════════════════════════════════════╗
║                    🎉 部署完成！                           ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_info "系统信息："
print_success "  访问地址: http://127.0.0.1:5000"
print_success "  默认账号: admin"
print_success "  默认密码: Admin@FaceMatch2025!"

echo ""
print_warning "安全提醒："
print_info "  1. 首次登录后请立即修改管理员密码"
print_info "  2. 运行命令: python scripts/change_admin_password.py"
print_info "  3. 生产环境请配置 HTTPS 和防火墙"

echo ""
print_info "正在启动服务..."
print_warning "按 Ctrl+C 可停止服务"
echo ""

# 启动服务
python run.py
