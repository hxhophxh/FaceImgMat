# 项目源码目录

本目录用于存放 FaceImgMat 项目的完整源代码。

## 📁 目录结构

运行 `准备超级离线包.bat` 后，会自动复制项目源码到此目录：

```
FaceImgMat/
├── run.py                # 启动入口
├── requirements.txt      # 依赖列表
├── app/                  # 应用代码
├── scripts/              # 辅助脚本
├── templates/            # HTML模板
├── static/               # 静态资源
└── instance/             # 数据库目录
```

## ⚙️ 自动复制

运行准备脚本时，会自动从项目根目录复制所有必需文件，排除：
- `.git/` (版本控制)
- `.venv/` (虚拟环境)
- `__pycache__/` (Python缓存)
- `super-offline-deployment/` (避免循环)

## 📋 说明

此目录包含完整的应用代码，用户部署时会：
1. 在此目录创建虚拟环境
2. 安装依赖包
3. 初始化数据库
4. 启动服务

---

**来源**: FaceImgMat项目根目录  
**用途**: 离线部署的源代码
