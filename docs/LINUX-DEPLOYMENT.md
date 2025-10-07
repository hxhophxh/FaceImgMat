# 🐧 Linux 服务器完整部署指南

完整的 Linux 生产环境部署步骤（Ubuntu/CentOS）

---

## 📋 目录

1. [服务器准备](#1-服务器准备)
2. [系统依赖安装](#2-系统依赖安装)
3. [项目部署](#3-项目部署)
4. [Gunicorn 配置](#4-gunicorn-配置)
5. [Nginx 反向代理](#5-nginx-反向代理)
6. [Systemd 服务配置](#6-systemd-服务配置)
7. [SSL 证书配置](#7-ssl-证书配置)
8. [防火墙配置](#8-防火墙配置)
9. [监控与日志](#9-监控与日志)
10. [故障排查](#10-故障排查)

---

## 1. 服务器准备

### 1.1 服务器要求

- **操作系统**: Ubuntu 20.04/22.04 或 CentOS 7/8
- **CPU**: 2 核心以上
- **内存**: 4GB 以上（推荐 8GB）
- **磁盘**: 20GB 以上
- **网络**: 公网 IP 或域名

### 1.2 连接服务器

```bash
# SSH 连接
ssh root@your-server-ip

# 或使用密钥
ssh -i ~/.ssh/id_rsa user@your-server-ip
```

### 1.3 更新系统

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

---

## 2. 系统依赖安装

### 2.1 安装 Python 3.11/3.12

#### Ubuntu 22.04

```bash
# 安装 Python 3.11
sudo apt install -y python3.11 python3.11-venv python3.11-dev

# 设置默认 Python
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# 安装 pip
sudo apt install -y python3-pip
```

#### CentOS 8

```bash
# 启用 EPEL 仓库
sudo yum install -y epel-release

# 安装 Python 3.11
sudo yum install -y python311 python311-devel

# 安装 pip
sudo yum install -y python311-pip
```

### 2.2 安装系统库

```bash
# Ubuntu/Debian
sudo apt install -y \
    build-essential \
    libopencv-dev \
    libssl-dev \
    libffi-dev \
    libjpeg-dev \
    libpng-dev \
    pkg-config \
    nginx \
    supervisor

# CentOS/RHEL
sudo yum install -y \
    gcc \
    gcc-c++ \
    make \
    opencv-devel \
    openssl-devel \
    libffi-devel \
    libjpeg-devel \
    libpng-devel \
    nginx \
    supervisor
```

### 2.3 验证安装

```bash
# 检查 Python 版本
python3 --version
# 预期输出: Python 3.11.x 或 3.12.x

# 检查 pip
pip3 --version

# 检查 Nginx
nginx -v
```

---

## 3. 项目部署

### 3.1 创建应用用户

```bash
# 创建专用用户（安全）
sudo useradd -m -s /bin/bash faceapp
sudo passwd faceapp

# 或使用现有用户
sudo usermod -aG sudo faceapp
```

### 3.2 上传项目文件

#### 方式 1: 使用 Git（推荐）

```bash
# 切换到应用用户
su - faceapp

# 克隆项目
cd /home/faceapp
git clone https://github.com/your-repo/FaceImgMat.git
cd FaceImgMat
```

#### 方式 2: 使用 SCP

```bash
# 在本地 Windows 机器上压缩项目
# 排除不需要的文件
tar -czf FaceImgMat.tar.gz \
    --exclude='.venv' \
    --exclude='instance' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    FaceImgMat/

# 上传到服务器
scp FaceImgMat.tar.gz faceapp@your-server-ip:/home/faceapp/

# 在服务器上解压
ssh faceapp@your-server-ip
cd /home/faceapp
tar -xzf FaceImgMat.tar.gz
cd FaceImgMat
```

#### 方式 3: 使用 SFTP/FileZilla

1. 使用 FileZilla 连接服务器
2. 上传整个项目目录到 `/home/faceapp/FaceImgMat`
3. 确保文件权限正确

### 3.3 设置文件权限

```bash
# 设置所有者
sudo chown -R faceapp:faceapp /home/faceapp/FaceImgMat

# 设置目录权限
sudo chmod 755 /home/faceapp/FaceImgMat
sudo chmod 755 /home/faceapp/FaceImgMat/static
sudo chmod 755 /home/faceapp/FaceImgMat/instance

# 设置脚本执行权限
chmod +x /home/faceapp/FaceImgMat/start.sh
chmod +x /home/faceapp/FaceImgMat/scripts/*.py
```

### 3.4 创建虚拟环境

```bash
# 切换到项目目录
cd /home/faceapp/FaceImgMat

# 创建虚拟环境
python3 -m venv .venv

# 激活虚拟环境
source .venv/bin/activate

# 升级 pip
pip install --upgrade pip
```

### 3.5 安装 Python 依赖

```bash
# 确保虚拟环境已激活
source .venv/bin/activate

# 安装依赖
pip install -r requirements.txt

# 安装生产环境额外依赖
pip install gunicorn gevent

# 验证安装
pip list | grep -E "flask|gunicorn|insightface|faiss"
```

### 3.6 初始化数据库

```bash
# 创建实例目录
mkdir -p instance

# 初始化演示数据
python scripts/init_demo_data.py

# 验证数据库
ls -lh instance/face_matching.db
```

### 3.7 测试运行

```bash
# 临时测试（开发模式）
python run.py

# 在浏览器访问
http://your-server-ip:5000

# 如果可以访问，按 Ctrl+C 停止
```

---

## 4. Gunicorn 配置

### 4.1 创建 Gunicorn 配置文件

```bash
# 创建配置文件
cat > /home/faceapp/FaceImgMat/gunicorn_config.py << 'EOF'
# Gunicorn 配置文件

# 绑定地址
bind = "127.0.0.1:8000"

# 工作进程数（推荐: CPU 核心数 * 2 + 1）
workers = 5

# 工作类型（使用 gevent 提高并发）
worker_class = "gevent"

# 每个工作进程的线程数
threads = 2

# 超时时间（秒）
timeout = 120

# 保持连接时间
keepalive = 5

# 最大请求数（防止内存泄漏）
max_requests = 1000
max_requests_jitter = 50

# 日志级别
loglevel = "info"

# 访问日志
accesslog = "/home/faceapp/FaceImgMat/logs/access.log"

# 错误日志
errorlog = "/home/faceapp/FaceImgMat/logs/error.log"

# 进程名称
proc_name = "faceimgmat"

# Daemon 模式
daemon = False

# PID 文件
pidfile = "/home/faceapp/FaceImgMat/logs/gunicorn.pid"
EOF
```

### 4.2 创建日志目录

```bash
mkdir -p /home/faceapp/FaceImgMat/logs
touch /home/faceapp/FaceImgMat/logs/access.log
touch /home/faceapp/FaceImgMat/logs/error.log
```

### 4.3 测试 Gunicorn

```bash
# 切换到项目目录
cd /home/faceapp/FaceImgMat

# 激活虚拟环境
source .venv/bin/activate

# 启动 Gunicorn
gunicorn -c gunicorn_config.py run:app

# 测试访问
curl http://127.0.0.1:8000

# 如果成功，按 Ctrl+C 停止
```

---

## 5. Nginx 反向代理

### 5.1 创建 Nginx 配置

```bash
# 创建配置文件
sudo nano /etc/nginx/sites-available/faceimgmat

# 粘贴以下内容
```

```nginx
# Nginx 配置 - 人脸匹配系统

upstream faceimgmat {
    server 127.0.0.1:8000 fail_timeout=0;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;  # 修改为您的域名

    # 重定向到 HTTPS（如果配置了 SSL）
    # return 301 https://$server_name$request_uri;

    # 客户端最大上传大小
    client_max_body_size 10M;

    # 日志
    access_log /var/log/nginx/faceimgmat_access.log;
    error_log /var/log/nginx/faceimgmat_error.log;

    # 静态文件
    location /static {
        alias /home/faceapp/FaceImgMat/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # 上传文件（禁止直接访问）
    location /uploads {
        alias /home/faceapp/FaceImgMat/static/uploads;
        internal;
    }

    # 应用代理
    location / {
        proxy_pass http://faceimgmat;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 超时设置
        proxy_connect_timeout 120s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
        
        # WebSocket 支持（如果需要）
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 健康检查
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### 5.2 启用配置

```bash
# 创建软链接
sudo ln -s /etc/nginx/sites-available/faceimgmat /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
```

### 5.3 验证 Nginx

```bash
# 检查 Nginx 状态
sudo systemctl status nginx

# 测试访问
curl http://localhost
curl http://your-domain.com
```

---

## 6. Systemd 服务配置

### 6.1 创建 Systemd 服务文件

```bash
# 创建服务文件
sudo nano /etc/systemd/system/faceimgmat.service
```

```ini
[Unit]
Description=Face Image Matching System
After=network.target

[Service]
Type=notify
User=faceapp
Group=faceapp
WorkingDirectory=/home/faceapp/FaceImgMat
Environment="PATH=/home/faceapp/FaceImgMat/.venv/bin"
ExecStart=/home/faceapp/FaceImgMat/.venv/bin/gunicorn \
    -c /home/faceapp/FaceImgMat/gunicorn_config.py \
    run:app
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 6.2 启用并启动服务

```bash
# 重新加载 systemd
sudo systemctl daemon-reload

# 启用服务（开机自启）
sudo systemctl enable faceimgmat

# 启动服务
sudo systemctl start faceimgmat

# 检查状态
sudo systemctl status faceimgmat
```

### 6.3 服务管理命令

```bash
# 启动
sudo systemctl start faceimgmat

# 停止
sudo systemctl stop faceimgmat

# 重启
sudo systemctl restart faceimgmat

# 重载配置
sudo systemctl reload faceimgmat

# 查看日志
sudo journalctl -u faceimgmat -f

# 查看最近 100 行日志
sudo journalctl -u faceimgmat -n 100
```

---

## 7. SSL 证书配置

### 7.1 使用 Let's Encrypt（免费）

```bash
# 安装 Certbot
# Ubuntu
sudo apt install -y certbot python3-certbot-nginx

# CentOS
sudo yum install -y certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 自动续期
sudo certbot renew --dry-run
```

### 7.2 更新 Nginx 配置（HTTPS）

Certbot 会自动更新 Nginx 配置，或手动添加：

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    # SSL 证书
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # SSL 配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # ... 其他配置同上
}

# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 8. 防火墙配置

### 8.1 UFW (Ubuntu)

```bash
# 启用防火墙
sudo ufw enable

# 允许 SSH
sudo ufw allow 22/tcp

# 允许 HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 查看状态
sudo ufw status
```

### 8.2 Firewalld (CentOS)

```bash
# 启动防火墙
sudo systemctl start firewalld
sudo systemctl enable firewalld

# 允许服务
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh

# 重载配置
sudo firewall-cmd --reload

# 查看状态
sudo firewall-cmd --list-all
```

---

## 9. 监控与日志

### 9.1 日志位置

```bash
# 应用日志
/home/faceapp/FaceImgMat/logs/access.log
/home/faceapp/FaceImgMat/logs/error.log

# Nginx 日志
/var/log/nginx/faceimgmat_access.log
/var/log/nginx/faceimgmat_error.log

# Systemd 日志
sudo journalctl -u faceimgmat
```

### 9.2 查看日志命令

```bash
# 实时查看应用日志
tail -f /home/faceapp/FaceImgMat/logs/error.log

# 实时查看 Nginx 日志
sudo tail -f /var/log/nginx/faceimgmat_error.log

# 查看系统服务日志
sudo journalctl -u faceimgmat -f

# 查看最近的错误
sudo journalctl -u faceimgmat --since "1 hour ago" | grep ERROR
```

### 9.3 日志轮转

```bash
# 创建日志轮转配置
sudo nano /etc/logrotate.d/faceimgmat
```

```
/home/faceapp/FaceImgMat/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 faceapp faceapp
    sharedscripts
    postrotate
        systemctl reload faceimgmat > /dev/null 2>&1 || true
    endscript
}
```

---

## 10. 故障排查

### 10.1 服务无法启动

```bash
# 检查服务状态
sudo systemctl status faceimgmat

# 查看错误日志
sudo journalctl -u faceimgmat -n 50

# 检查配置文件
python /home/faceapp/FaceImgMat/run.py

# 检查端口占用
sudo netstat -tulpn | grep 8000
```

### 10.2 502 Bad Gateway

```bash
# 检查 Gunicorn 是否运行
sudo systemctl status faceimgmat

# 检查端口监听
sudo netstat -tulpn | grep 8000

# 重启服务
sudo systemctl restart faceimgmat
```

### 10.3 Permission Denied

```bash
# 修复文件权限
sudo chown -R faceapp:faceapp /home/faceapp/FaceImgMat
sudo chmod -R 755 /home/faceapp/FaceImgMat

# 修复日志目录
sudo chmod 755 /home/faceapp/FaceImgMat/logs
```

### 10.4 数据库错误

```bash
# 重新初始化数据库
cd /home/faceapp/FaceImgMat
source .venv/bin/activate
rm instance/face_matching.db
python scripts/init_demo_data.py
```

---

## 📋 快速部署清单

```bash
# 1. 系统更新
sudo apt update && sudo apt upgrade -y

# 2. 安装依赖
sudo apt install -y python3.11 python3.11-venv python3-pip nginx supervisor

# 3. 创建用户
sudo useradd -m -s /bin/bash faceapp

# 4. 上传项目
scp -r FaceImgMat faceapp@server:/home/faceapp/

# 5. 设置权限
sudo chown -R faceapp:faceapp /home/faceapp/FaceImgMat

# 6. 安装依赖
cd /home/faceapp/FaceImgMat
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip install gunicorn gevent

# 7. 初始化数据
python scripts/init_demo_data.py

# 8. 配置 Gunicorn
# (创建 gunicorn_config.py)

# 9. 配置 Nginx
sudo nano /etc/nginx/sites-available/faceimgmat
sudo ln -s /etc/nginx/sites-available/faceimgmat /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 10. 配置 Systemd
sudo nano /etc/systemd/system/faceimgmat.service
sudo systemctl daemon-reload
sudo systemctl enable faceimgmat
sudo systemctl start faceimgmat

# 11. 验证
sudo systemctl status faceimgmat
curl http://localhost
```

---

## 🔗 相关文档

- [项目 README](../README.md)
- [快速开始](quick-start-guide.md)
- [安全配置](SECURITY.md)
- [故障排查](complete-fix-summary.md)

---

**部署成功后访问**: https://your-domain.com

最后更新: 2025-10-07
