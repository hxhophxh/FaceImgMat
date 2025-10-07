# 🔌 离线环境部署指南

本指南专门针对**无网络连接的离线环境**部署人脸识别系统。

## 📋 目录

- [部署准备](#部署准备)
- [在线环境准备](#在线环境准备)
- [离线环境部署](#离线环境部署)
- [验证部署](#验证部署)
- [故障排查](#故障排查)

---

## 🎯 部署策略

由于离线环境无法直接从GitHub克隆或通过pip安装依赖，我们采用以下策略：

1. **在线环境**：准备所有必要的文件和依赖包
2. **传输**：将打包的文件传输到离线环境
3. **离线环境**：安装和配置系统

---

## 📦 在线环境准备

### 步骤1：克隆项目

```bash
# 克隆完整项目（包含数据库和测试数据）
git clone https://github.com/hxhophxh/FaceImgMat.git
cd FaceImgMat
```

### 步骤2：下载Python依赖包

为离线环境下载所有Python依赖包：

```bash
# 创建依赖包目录
mkdir offline_packages

# 下载所有依赖包到本地（包括依赖的依赖）
pip download -r requirements.txt -d offline_packages

# 查看下载的包
ls offline_packages
```

**预计大小**：约 500-800MB

### 步骤3：下载InsightFace模型

InsightFace模型需要单独下载：

```bash
# 方法1：运行测试脚本自动下载
python -c "import insightface; app = insightface.app.FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])"

# 模型会下载到用户目录
# Windows: C:\Users\<用户名>\.insightface\models\
# Linux: ~/.insightface/models/

# 复制模型文件到项目
mkdir -p models/insightface_models
cp -r ~/.insightface/models/* models/insightface_models/
```

**模型大小**：约 180MB

### 步骤4：准备Python离线安装包

如果离线环境没有Python 3.11/3.12，需要下载：

**Windows**：
```bash
# 下载 Python 3.11 或 3.12 离线安装包
# 访问 https://www.python.org/downloads/
# 下载 Windows installer (64-bit)
```

**Linux**：
```bash
# 下载 Python 源代码或预编译包
wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz

# 或使用系统包管理器下载包到本地
# Ubuntu/Debian
apt-get download python3.11 python3.11-venv python3.11-dev

# CentOS/RHEL
yumdownloader python311 python311-devel
```

### 步骤5：打包所有文件

```bash
# 返回上级目录
cd ..

# 创建压缩包（排除.venv）
tar -czf FaceImgMat-offline.tar.gz \
    --exclude='.venv' \
    --exclude='.git' \
    --exclude='__pycache__' \
    FaceImgMat/

# 或使用zip（Windows推荐）
# 在Windows PowerShell中：
Compress-Archive -Path FaceImgMat -DestinationPath FaceImgMat-offline.zip -Force

# 验证压缩包大小
ls -lh FaceImgMat-offline.*
```

### 步骤6：准备传输清单

创建文件清单，确保所有文件都已准备：

```bash
# 检查文件完整性
cd FaceImgMat
find . -type f | wc -l
du -sh .
```

**需要传输的文件**：
- ✅ `FaceImgMat-offline.tar.gz` (项目代码和数据)
- ✅ `offline_packages/` (Python依赖包，500-800MB)
- ✅ `models/insightface_models/` (AI模型，约180MB)
- ✅ `Python-3.11.x` 安装包（如果需要）

**总大小估算**：约 1-1.5GB

---

## 🚚 传输到离线环境

使用U盘、移动硬盘或内网文件传输：

```bash
# 将以下文件复制到移动存储设备
1. FaceImgMat-offline.tar.gz
2. offline_packages/ 文件夹
3. models/insightface_models/ 文件夹
4. Python安装包（如果需要）
```

---

## 💻 离线环境部署

### 步骤1：安装Python（如果需要）

**Windows**：
```powershell
# 运行Python安装程序
.\python-3.11.9-amd64.exe

# 确保勾选：
# ✅ Add Python to PATH
# ✅ Install pip
```

**Linux**：
```bash
# 使用系统包管理器
# Ubuntu/Debian
sudo dpkg -i python3.11*.deb
sudo apt-get install -f

# 或从源码编译
tar -xzf Python-3.11.9.tgz
cd Python-3.11.9
./configure --prefix=/usr/local
make
sudo make install
```

### 步骤2：解压项目

```bash
# Linux
tar -xzf FaceImgMat-offline.tar.gz
cd FaceImgMat

# Windows PowerShell
Expand-Archive -Path FaceImgMat-offline.zip -DestinationPath .
cd FaceImgMat
```

### 步骤3：创建虚拟环境

```bash
# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# Linux/macOS
source .venv/bin/activate

# 升级pip（离线模式）
python -m pip install --upgrade pip --no-index --find-links=../offline_packages
```

### 步骤4：离线安装依赖

```bash
# 从本地包安装所有依赖
pip install -r requirements.txt \
    --no-index \
    --find-links=../offline_packages

# 验证安装
pip list
```

### 步骤5：配置InsightFace模型

```bash
# 创建InsightFace模型目录
mkdir -p ~/.insightface/models

# 复制模型文件
cp -r ../models/insightface_models/* ~/.insightface/models/

# Windows PowerShell
mkdir $env:USERPROFILE\.insightface\models -Force
Copy-Item -Path ..\models\insightface_models\* -Destination $env:USERPROFILE\.insightface\models\ -Recurse -Force
```

### 步骤6：初始化数据库

项目已经包含了初始化的数据库文件 `instance/face_matching.db`，包含：
- 管理员账户（admin / Admin@FaceMatch2025!）
- 3个测试人员
- 人脸特征索引

**如果需要重新初始化**：
```bash
# 删除现有数据库
rm instance/face_matching.db

# 重新初始化
python scripts/init_demo_data.py
```

### 步骤7：启动服务

```bash
# Windows
.\start.ps1

# Linux/macOS
./start.sh

# 或直接运行
python run.py
```

---

## ✅ 验证部署

### 1. 检查服务状态

```bash
# 查看进程
# Windows
Get-Process | Where-Object {$_.ProcessName -like "*python*"}

# Linux
ps aux | grep python

# 检查端口
# Windows
netstat -ano | findstr :5000

# Linux
netstat -tlnp | grep 5000
```

### 2. 访问Web界面

打开浏览器访问：
- **本地访问**：http://127.0.0.1:5000
- **局域网访问**：http://[服务器IP]:5000

### 3. 登录测试

- 用户名：`admin`
- 密码：`Admin@FaceMatch2025!`

### 4. 人脸匹配测试

使用项目中的测试图片进行匹配：
- `static/faces/person1.jpg`
- `static/faces/person2.jpg`
- `static/faces/person3.jpg`

---

## 📊 离线部署清单

使用以下清单确保部署完整：

- [ ] Python 3.11/3.12 已安装
- [ ] 项目文件已解压
- [ ] 虚拟环境已创建
- [ ] 所有依赖包已安装（检查 `pip list`）
- [ ] InsightFace模型已配置（检查 `~/.insightface/models/`）
- [ ] 数据库文件存在（`instance/face_matching.db`）
- [ ] 服务可以启动（`python run.py`）
- [ ] Web界面可以访问
- [ ] 能够登录系统
- [ ] 人脸匹配功能正常

---

## 🔧 故障排查

### 问题1：依赖包安装失败

**错误**：`ERROR: Could not find a version that satisfies the requirement`

**解决方案**：
```bash
# 检查offline_packages目录是否完整
ls -lh ../offline_packages

# 手动安装核心包
pip install ../offline_packages/Flask-*.whl --no-index
pip install ../offline_packages/insightface-*.whl --no-index
```

### 问题2：InsightFace模型加载失败

**错误**：`ModelNotFoundError` 或 `Model file not found`

**解决方案**：
```bash
# 检查模型文件
ls -la ~/.insightface/models/buffalo_l/

# 应该包含以下文件：
# - det_10g.onnx
# - w600k_r50.onnx
# - glintr100.onnx

# 如果缺失，重新复制
cp -r ../models/insightface_models/* ~/.insightface/models/
```

### 问题3：数据库文件损坏

**错误**：`sqlite3.DatabaseError: database disk image is malformed`

**解决方案**：
```bash
# 删除损坏的数据库
rm instance/face_matching.db

# 重新初始化
python scripts/init_demo_data.py
```

### 问题4：端口已被占用

**错误**：`Address already in use` 或 `OSError: [Errno 98]`

**解决方案**：
```bash
# 查找占用5000端口的进程
# Windows
netstat -ano | findstr :5000

# Linux
lsof -i :5000

# 杀掉进程或修改端口
# 编辑 run.py，修改端口号
```

### 问题5：权限问题（Linux）

**错误**：`Permission denied`

**解决方案**：
```bash
# 修改文件权限
chmod +x start.sh
chmod -R 755 .

# 确保数据库目录可写
chmod 755 instance
chmod 644 instance/face_matching.db
```

---

## 🔒 安全配置

### 修改默认密码

**重要**：首次部署后立即修改密码！

```bash
python scripts/change_admin_password.py
```

### 限制访问IP（可选）

编辑 `run.py`：

```python
# 仅本机访问
app.run(host='127.0.0.1', port=5000)

# 局域网访问
app.run(host='0.0.0.0', port=5000)

# 指定IP访问（需配置防火墙）
```

---

## 📈 性能优化

### 使用Gunicorn（生产环境）

如果在离线包中包含了gunicorn：

```bash
# 检查是否已安装
pip list | grep gunicorn

# 使用gunicorn启动
gunicorn -c gunicorn_config.py run:app
```

### 配置日志轮转

创建 `/etc/logrotate.d/faceimgmat`（Linux）：

```
/path/to/FaceImgMat/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0644 user user
}
```

---

## 📦 更新部署

如果需要更新系统：

1. **在线环境**：
   ```bash
   git pull origin main
   pip download -r requirements.txt -d offline_packages_update
   ```

2. **打包更新文件**：
   ```bash
   tar -czf FaceImgMat-update.tar.gz \
       --exclude='.venv' \
       --exclude='instance' \
       FaceImgMat/
   ```

3. **离线环境**：
   ```bash
   # 备份数据库
   cp instance/face_matching.db instance/face_matching.db.backup
   
   # 解压更新
   tar -xzf FaceImgMat-update.tar.gz
   
   # 安装新依赖
   pip install -r requirements.txt --no-index --find-links=../offline_packages_update
   
   # 重启服务
   ```

---

## 📚 离线部署文件结构

```
离线部署包/
├── FaceImgMat-offline.tar.gz          # 项目代码（约10MB）
│   ├── app/                            # 应用代码
│   ├── instance/face_matching.db      # 初始数据库
│   ├── static/faces/                  # 测试图片
│   ├── requirements.txt               # 依赖清单
│   └── ...
│
├── offline_packages/                   # Python依赖包（500-800MB）
│   ├── Flask-3.0.0-py3-none-any.whl
│   ├── insightface-0.7.3-*.whl
│   ├── faiss_cpu-1.11.0-*.whl
│   └── ... (100+个包)
│
├── models/insightface_models/          # AI模型（约180MB）
│   └── buffalo_l/
│       ├── det_10g.onnx
│       ├── w600k_r50.onnx
│       └── glintr100.onnx
│
├── Python-3.11.9-amd64.exe            # Python安装包（可选）
│
└── 部署说明.txt                        # 简要说明
```

---

## 🎯 快速部署脚本

创建 `offline_deploy.sh`（Linux）：

```bash
#!/bin/bash
set -e

echo "🚀 开始离线部署..."

# 1. 解压项目
tar -xzf FaceImgMat-offline.tar.gz
cd FaceImgMat

# 2. 创建虚拟环境
python3.11 -m venv .venv
source .venv/bin/activate

# 3. 安装依赖
pip install -r requirements.txt --no-index --find-links=../offline_packages

# 4. 配置模型
mkdir -p ~/.insightface/models
cp -r ../models/insightface_models/* ~/.insightface/models/

# 5. 验证数据库
if [ ! -f "instance/face_matching.db" ]; then
    echo "⚠️  数据库文件不存在，正在初始化..."
    python scripts/init_demo_data.py
fi

echo "✅ 部署完成！"
echo "运行 'python run.py' 启动服务"
```

Windows PowerShell 版本 `offline_deploy.ps1`：

```powershell
Write-Host "🚀 开始离线部署..." -ForegroundColor Green

# 1. 解压项目
Expand-Archive -Path FaceImgMat-offline.zip -DestinationPath .
Set-Location FaceImgMat

# 2. 创建虚拟环境
python -m venv .venv
& .\.venv\Scripts\Activate.ps1

# 3. 安装依赖
pip install -r requirements.txt --no-index --find-links=..\offline_packages

# 4. 配置模型
$modelPath = "$env:USERPROFILE\.insightface\models"
New-Item -ItemType Directory -Path $modelPath -Force
Copy-Item -Path ..\models\insightface_models\* -Destination $modelPath -Recurse -Force

# 5. 验证数据库
if (-not (Test-Path "instance\face_matching.db")) {
    Write-Host "⚠️  数据库文件不存在，正在初始化..." -ForegroundColor Yellow
    python scripts\init_demo_data.py
}

Write-Host "✅ 部署完成！" -ForegroundColor Green
Write-Host "运行 'python run.py' 启动服务"
```

---

## 📞 支持

如有问题，请参考：
- [项目README](../README.md)
- [完整文档索引](INDEX.md)
- [故障排查指南](DEPLOYMENT.md)

---

**最后更新**：2025-10-08  
**适用版本**：v1.0+
