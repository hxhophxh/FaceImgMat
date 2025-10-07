# 📦 从GitHub部署到Linux服务器完整指南

本指南介绍如何从GitHub克隆项目并在Linux服务器上部署人脸识别系统。

## 📋 目录

- [前置准备](#前置准备)
- [步骤1：克隆项目](#步骤1克隆项目)
- [步骤2：环境配置](#步骤2环境配置)
- [步骤3：安装依赖](#步骤3安装依赖)
- [步骤4：下载模型](#步骤4下载模型)
- [步骤5：初始化数据](#步骤5初始化数据)
- [步骤6：配置服务](#步骤6配置服务)
- [步骤7：启动服务](#步骤7启动服务)
- [故障排查](#故障排查)

---

## 🔧 前置准备

### 1. 服务器要求

- **操作系统**: Ubuntu 20.04+ / CentOS 7+ / Debian 10+
- **内存**: 至少 2GB RAM
- **存储**: 至少 5GB 可用空间
- **Python**: Python 3.11 或 3.12

### 2. 安装基础工具

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y git python3 python3-pip python3-venv curl

# CentOS/RHEL
sudo yum install -y git python3 python3-pip python3-virtualenv curl
```

### 3. 检查Python版本

```bash
python3 --version
# 应该显示 Python 3.11.x 或 3.12.x
```

如果版本不对，请安装正确版本：

```bash
# Ubuntu 添加 deadsnakes PPA
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.11 python3.11-venv python3.11-dev
```

---

## 📥 步骤1：克隆项目

### 从GitHub克隆

```bash
# 克隆仓库
git clone https://github.com/hxhophxh/FaceImgMat.git

# 进入项目目录
cd FaceImgMat

# 查看项目结构
ls -la
```

### 验证文件完整性

```bash
# 确认关键文件存在
ls -l requirements.txt run.py README.md
ls -l app/ scripts/ templates/ static/
```

---

## ⚙️ 步骤2：环境配置

### 1. 创建虚拟环境

```bash
# 使用 Python 3.11 创建虚拟环境
python3.11 -m venv .venv

# 激活虚拟环境
source .venv/bin/activate

# 验证Python版本
python --version
```

### 2. 升级pip

```bash
pip install --upgrade pip setuptools wheel
```

---

## 📦 步骤3：安装依赖

### 安装系统依赖

```bash
# Ubuntu/Debian
sudo apt install -y \
    build-essential \
    libopenblas-dev \
    liblapack-dev \
    libssl-dev \
    libffi-dev

# CentOS/RHEL
sudo yum groupinstall -y "Development Tools"
sudo yum install -y openblas-devel lapack-devel openssl-devel libffi-devel
```

### 安装Python依赖

```bash
# 安装所有依赖（这可能需要5-10分钟）
pip install -r requirements.txt

# 验证关键包
pip list | grep -E "flask|insightface|faiss|onnxruntime"
```

---

## 🤖 步骤4：下载模型

InsightFace 模型会在首次运行时自动下载，但也可以手动下载。

### 自动下载（推荐）

首次运行时会自动下载：

```bash
python -c "import insightface; insightface.app.FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])"
```

### 手动下载

如果自动下载失败，可以手动下载：

```bash
# 创建模型目录
mkdir -p ~/.insightface/models/buffalo_l

# 从备用源下载（需要根据实际情况调整URL）
# 或从其他机器复制 ~/.insightface/models/ 目录
```

### 验证模型

```bash
# 运行测试脚本
python scripts/test_face_detection.py
```

---

## 🗃️ 步骤5：初始化数据

### 创建必要的目录

```bash
# 创建数据目录
mkdir -p instance logs static/uploads static/faces

# 设置权限
chmod 755 instance logs static/uploads static/faces
```

### 初始化数据库和演示数据

```bash
# 运行初始化脚本
python scripts/init_demo_data.py
```

**输出示例：**
```
✓ 数据库初始化成功
✓ 管理员账户创建成功 (admin / admin123)
✓ 已添加 3 个演示人员
✓ FAISS 索引构建完成
```

### 修改管理员密码（重要！）

```bash
# 使用脚本修改密码
python scripts/change_admin_password.py

# 或者使用快速命令
python -c "from scripts.update_password_now import update_password; update_password('your_new_password')"
```

---

## 🚀 步骤6：配置服务

### 选项A：使用 Systemd（生产环境推荐）

创建服务文件：

```bash
sudo nano /etc/systemd/system/faceimgmat.service
```

添加以下内容（**修改路径为你的实际路径**）：

```ini
[Unit]
Description=Face Image Matching System
After=network.target

[Service]
Type=simple
User=your_username
WorkingDirectory=/home/your_username/FaceImgMat
Environment="PATH=/home/your_username/FaceImgMat/.venv/bin"
ExecStart=/home/your_username/FaceImgMat/.venv/bin/python run.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启用并启动服务：

```bash
# 重载配置
sudo systemctl daemon-reload

# 启用开机自启
sudo systemctl enable faceimgmat

# 启动服务
sudo systemctl start faceimgmat

# 查看状态
sudo systemctl status faceimgmat

# 查看日志
sudo journalctl -u faceimgmat -f
```

### 选项B：使用 screen 或 tmux（测试环境）

```bash
# 使用 screen
screen -S faceimgmat
source .venv/bin/activate
python run.py
# 按 Ctrl+A 然后 D 来分离会话

# 重新连接
screen -r faceimgmat

# 或使用 tmux
tmux new -s faceimgmat
source .venv/bin/activate
python run.py
# 按 Ctrl+B 然后 D 来分离会话

# 重新连接
tmux attach -t faceimgmat
```

---

## 🌐 步骤7：配置反向代理（可选）

### 使用 Nginx

安装 Nginx：

```bash
sudo apt install nginx  # Ubuntu/Debian
# 或
sudo yum install nginx  # CentOS/RHEL
```

创建配置文件：

```bash
sudo nano /etc/nginx/sites-available/faceimgmat
```

添加配置：

```nginx
server {
    listen 80;
    server_name your_domain.com;  # 修改为你的域名或IP

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 增加上传文件大小限制
        client_max_body_size 50M;
    }

    location /static {
        alias /home/your_username/FaceImgMat/static;
        expires 30d;
    }
}
```

启用配置：

```bash
# 创建符号链接
sudo ln -s /etc/nginx/sites-available/faceimgmat /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重载 Nginx
sudo systemctl reload nginx
```

### 配置防火墙

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

---

## ✅ 验证部署

### 1. 检查服务状态

```bash
# 检查进程
ps aux | grep python

# 检查端口
netstat -tlnp | grep 5000
# 或
ss -tlnp | grep 5000
```

### 2. 测试HTTP访问

```bash
# 本地测试
curl http://localhost:5000

# 远程测试（从另一台机器）
curl http://your_server_ip:5000
```

### 3. 访问Web界面

打开浏览器访问：
- 直接访问: `http://your_server_ip:5000`
- 通过Nginx: `http://your_domain.com`

默认登录信息：
- 用户名: `admin`
- 密码: `admin123`（记得修改！）

---

## 🔍 故障排查

### 问题1：无法访问服务

**检查防火墙：**
```bash
sudo ufw status
sudo firewall-cmd --list-all
```

**检查端口绑定：**
```bash
# 修改 run.py 中的 host 参数
# app.run(host='0.0.0.0', port=5000)
```

### 问题2：模型下载失败

**手动下载：**
```bash
# 从有网络的机器下载
# 复制 ~/.insightface/models/ 到服务器相同位置
```

**使用国内镜像：**
```bash
export PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
pip install -r requirements.txt
```

### 问题3：依赖安装失败

**检查Python版本：**
```bash
python --version
# 必须是 3.11 或 3.12
```

**安装编译工具：**
```bash
sudo apt install build-essential python3-dev
```

### 问题4：内存不足

**查看内存使用：**
```bash
free -h
```

**配置交换空间：**
```bash
# 创建 2GB 交换文件
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久生效
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 问题5：权限问题

**修复文件权限：**
```bash
cd /path/to/FaceImgMat
sudo chown -R $USER:$USER .
chmod -R 755 .
chmod 644 instance/*.db
```

### 查看日志

```bash
# 应用日志
tail -f logs/app.log

# Systemd 日志
sudo journalctl -u faceimgmat -n 100 --no-pager

# Nginx 日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## 📊 性能优化

### 1. 使用 Gunicorn（生产环境）

安装：
```bash
pip install gunicorn
```

创建配置文件 `gunicorn_config.py`：
```python
bind = "0.0.0.0:5000"
workers = 2
threads = 2
timeout = 120
accesslog = "logs/gunicorn_access.log"
errorlog = "logs/gunicorn_error.log"
loglevel = "info"
```

修改 systemd 服务：
```ini
ExecStart=/home/your_username/FaceImgMat/.venv/bin/gunicorn -c gunicorn_config.py run:app
```

### 2. 启用 GPU 加速（如果有GPU）

安装 CUDA 版本的 onnxruntime：
```bash
pip uninstall onnxruntime
pip install onnxruntime-gpu
```

### 3. 配置日志轮转

创建 `/etc/logrotate.d/faceimgmat`：
```
/home/your_username/FaceImgMat/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0644 your_username your_username
    sharedscripts
}
```

---

## 🔒 安全建议

1. **修改默认密码**
   ```bash
   python scripts/change_admin_password.py
   ```

2. **启用 HTTPS（使用 Let's Encrypt）**
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d your_domain.com
   ```

3. **限制访问**
   - 在 Nginx 中配置 IP 白名单
   - 使用 VPN 访问

4. **定期更新**
   ```bash
   git pull origin main
   pip install -r requirements.txt --upgrade
   sudo systemctl restart faceimgmat
   ```

5. **备份数据**
   ```bash
   # 备份数据库
   cp instance/face_matching.db instance/face_matching.db.backup
   
   # 备份上传文件
   tar -czf static_backup.tar.gz static/uploads/ static/faces/
   ```

---

## 📝 快速命令参考

```bash
# 启动服务
sudo systemctl start faceimgmat

# 停止服务
sudo systemctl stop faceimgmat

# 重启服务
sudo systemctl restart faceimgmat

# 查看状态
sudo systemctl status faceimgmat

# 查看日志
sudo journalctl -u faceimgmat -f

# 进入项目目录
cd ~/FaceImgMat

# 激活虚拟环境
source .venv/bin/activate

# 更新代码
git pull

# 重启服务
sudo systemctl restart faceimgmat
```

---

## 🎯 完整部署脚本

创建一键部署脚本 `deploy.sh`：

```bash
#!/bin/bash
set -e

echo "🚀 开始部署人脸识别系统..."

# 1. 更新系统
echo "📦 更新系统包..."
sudo apt update

# 2. 安装依赖
echo "📦 安装系统依赖..."
sudo apt install -y git python3.11 python3.11-venv build-essential libopenblas-dev

# 3. 克隆项目
echo "📥 克隆项目..."
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat

# 4. 创建虚拟环境
echo "🔧 创建虚拟环境..."
python3.11 -m venv .venv
source .venv/bin/activate

# 5. 安装Python依赖
echo "📦 安装Python依赖..."
pip install --upgrade pip
pip install -r requirements.txt

# 6. 创建目录
echo "📁 创建必要目录..."
mkdir -p instance logs static/uploads static/faces

# 7. 初始化数据
echo "🗃️ 初始化数据库..."
python scripts/init_demo_data.py

# 8. 配置服务
echo "⚙️ 配置Systemd服务..."
sudo tee /etc/systemd/system/faceimgmat.service > /dev/null <<EOF
[Unit]
Description=Face Image Matching System
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$PWD
Environment="PATH=$PWD/.venv/bin"
ExecStart=$PWD/.venv/bin/python run.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 9. 启动服务
echo "🚀 启动服务..."
sudo systemctl daemon-reload
sudo systemctl enable faceimgmat
sudo systemctl start faceimgmat

echo "✅ 部署完成！"
echo "📝 访问地址: http://$(hostname -I | awk '{print $1}'):5000"
echo "👤 默认账户: admin / admin123"
echo "⚠️  请立即修改密码: python scripts/change_admin_password.py"
```

使用方法：
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## 📚 相关文档

- [Linux部署详细指南](LINUX-DEPLOYMENT.md)
- [部署检查清单](DEPLOYMENT-CHECKLIST.md)
- [项目README](../README.md)
- [安全指南](SECURITY.md)

---

## 🆘 获取帮助

- **GitHub Issues**: https://github.com/hxhophxh/FaceImgMat/issues
- **文档**: 查看 `docs/` 目录下的其他文档

---

**最后更新**: 2025-10-07
