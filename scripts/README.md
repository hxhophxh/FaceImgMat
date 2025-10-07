# 脚本使用说明

本目录包含项目的辅助脚本工具。

## 📁 脚本列表

### 1. init_demo_data.py - 演示数据初始化

**功能**: 初始化演示数据，导入预设的人脸照片到数据库。

**使用方法**:
```bash
python scripts/init_demo_data.py
```

**前置条件**:
- 确保 `static/faces/` 目录存在
- 放置测试人脸照片: person1.jpg, person2.jpg, person3.jpg

**输出示例**:
```
✅ 添加: 张三
✅ 添加: 李四
✅ 添加: 王五

✨ 演示数据初始化完成！共 3 个人物
```

---

### 2. change_admin_password.py - 修改管理员密码

**功能**: 安全地修改管理员密码，包含密码强度验证。

**使用方法**:
```bash
python scripts/change_admin_password.py
```

**密码要求**:
- 至少 12 位字符
- 包含大写字母 (A-Z)
- 包含小写字母 (a-z)
- 包含数字 (0-9)
- 包含特殊字符 (@#$%&*!)

**使用场景**:
- 首次部署后修改默认密码
- 定期更换管理员密码
- 密码泄露后紧急修改

**输出示例**:
```
🔐 修改管理员密码
============================================================
密码要求:
  - 至少 12 位字符
  - 包含大写字母 (A-Z)
  - 包含小写字母 (a-z)
  - 包含数字 (0-9)
  - 包含特殊字符 (@#$%&*!)
============================================================

请输入新密码: **********
确认新密码: **********

✅ 密码修改成功！
⚠️  请妥善保管新密码
```

---

### 3. fix_image_paths.py - 图片路径修复

**功能**: 修复数据库中错误的图片路径。

**使用方法**:
```bash
python scripts/fix_image_paths.py
```

**使用场景**:
- 迁移服务器后路径发生变化
- 手动修改了文件夹结构
- 导入数据时路径配置错误

---

### 4. test_face_detection.py - 人脸检测测试

**功能**: 测试 InsightFace 人脸检测功能是否正常。

**使用方法**:
```bash
python scripts/test_face_detection.py
```

**测试内容**:
- InsightFace 模型加载
- 人脸检测功能
- 特征提取能力
- FAISS 索引构建

---

## 🚀 批量导入脚本（待开发）

### import_employees.py - 批量导入员工照片

**计划功能**:
- 从文件夹批量导入员工照片
- 支持 CSV 格式导入人员信息
- 自动提取人脸特征并建立索引

**文件命名格式**:
```
employees/
├── 张三_E001.jpg
├── 李四_E002.jpg
└── 王五_E003.jpg
```

**使用方法** (规划中):
```bash
python scripts/import_employees.py --folder employees --format "name_id"
```

---

## 📝 开发新脚本

如需添加新脚本，请遵循以下规范：

1. **文件命名**: 使用小写字母和下划线，如 `backup_database.py`
2. **添加文档**: 在本文件中补充使用说明
3. **错误处理**: 包含完善的异常捕获和错误提示
4. **日志输出**: 使用 emoji 和清晰的信息提示用户

### 脚本模板

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
脚本名称: xxx.py
功能描述: 简要描述脚本功能
创建日期: YYYY-MM-DD
"""

from app import create_app
from app.models import db

def main():
    """主函数"""
    app = create_app()
    
    with app.app_context():
        try:
            # 脚本逻辑
            print("✅ 操作成功")
        except Exception as e:
            print(f"❌ 操作失败: {e}")

if __name__ == '__main__':
    main()
```

---

## ⚠️ 注意事项

1. **运行前备份**: 执行数据库操作前，请先备份 `instance/face_matching.db`
2. **虚拟环境**: 确保在项目虚拟环境中运行脚本
3. **权限检查**: 确保脚本有文件读写权限
4. **日志记录**: 重要操作会记录到日志文件

---

## 🔧 故障排查

### 脚本无法运行

```bash
# 检查虚拟环境
which python  # Linux/Mac
where python  # Windows

# 重新安装依赖
pip install -r requirements.txt
```

### 数据库锁定

```bash
# 关闭所有使用数据库的进程
# 删除锁文件（如果存在）
rm instance/face_matching.db-journal
```

### 路径错误

```bash
# 确保在项目根目录运行
cd /path/to/FaceImgMat
python scripts/xxx.py
```

---

更多问题请查看 [项目文档](../docs/README.md) 或提交 Issue。
