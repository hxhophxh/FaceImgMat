# 🔐 密码安全说明

## 默认管理员账户

- **用户名**: `admin`
- **默认密码**: `Admin@FaceMatch2025!`

⚠️ **安全警告**: 
- 首次部署后，**必须立即修改默认密码**！
- 默认密码仅供初始化使用，不可在生产环境中使用。

---

## 密码复杂度要求

### 生产环境密码标准

✅ **推荐密码格式**:
- 至少 **12 位字符**
- 包含 **大写字母** (A-Z)
- 包含 **小写字母** (a-z)
- 包含 **数字** (0-9)
- 包含 **特殊字符** (@, #, $, %, &, *, !)
- 避免使用常见词汇或个人信息

### 密码示例 ✅

```
Good@Pass2025!Secure
FaceMatch#2025$Admin
MySecure@System2025!
```

### 弱密码示例 ❌

```
admin123          # 太简单
12345678          # 纯数字
password          # 常见词汇
admin2025         # 无特殊字符
```

---

## 修改管理员密码

### 方法 1: 通过代码修改（推荐）

创建脚本 `scripts/change_admin_password.py`:

```python
from app import create_app
from app.models import db, Admin
from werkzeug.security import generate_password_hash
import getpass

def change_admin_password():
    """修改管理员密码"""
    app = create_app()
    
    with app.app_context():
        admin = Admin.query.filter_by(username='admin').first()
        
        if not admin:
            print("❌ 管理员账户不存在！")
            return
        
        print("🔐 修改管理员密码")
        print("-" * 50)
        
        # 输入新密码（不显示）
        new_password = getpass.getpass("请输入新密码: ")
        confirm_password = getpass.getpass("确认新密码: ")
        
        # 验证密码
        if new_password != confirm_password:
            print("❌ 两次密码输入不一致！")
            return
        
        if len(new_password) < 12:
            print("❌ 密码长度至少12位！")
            return
        
        # 更新密码
        admin.password = generate_password_hash(new_password)
        db.session.commit()
        
        print("✅ 密码修改成功！")
        print("⚠️  请妥善保管新密码")

if __name__ == '__main__':
    change_admin_password()
```

**使用方法**:

```bash
python scripts/change_admin_password.py
```

---

### 方法 2: 直接修改数据库初始化代码

编辑 `app/__init__.py`，修改第 40-45 行：

```python
# 创建默认管理员（如果不存在）
if not Admin.query.filter_by(username='admin').first():
    from werkzeug.security import generate_password_hash
    admin = Admin(
        username='admin',
        password=generate_password_hash('YOUR_NEW_STRONG_PASSWORD')  # 修改这里
    )
    db.session.add(admin)
    db.session.commit()
```

**注意**: 修改后需要删除数据库重新初始化：

```bash
# 1. 删除旧数据库
Remove-Item instance\face_matching.db

# 2. 重新启动应用（自动创建数据库）
python run.py
```

---

### 方法 3: 使用 Flask Shell 修改

```bash
# 进入 Flask Shell
python
>>> from app import create_app
>>> from app.models import db, Admin
>>> from werkzeug.security import generate_password_hash
>>> 
>>> app = create_app()
>>> with app.app_context():
...     admin = Admin.query.filter_by(username='admin').first()
...     admin.password = generate_password_hash('YOUR_NEW_PASSWORD')
...     db.session.commit()
...     print("✅ 密码已更新")
>>> 
>>> exit()
```

---

## 密码存储机制

系统使用 **Werkzeug 的 PBKDF2** 哈希算法存储密码：

```python
from werkzeug.security import generate_password_hash, check_password_hash

# 加密密码
hashed = generate_password_hash('Admin@FaceMatch2025!')
# 结果: pbkdf2:sha256:600000$...

# 验证密码
is_valid = check_password_hash(hashed, 'Admin@FaceMatch2025!')
# 结果: True
```

### 安全特性

- ✅ **加盐哈希**: 每个密码使用随机盐值
- ✅ **多次迭代**: 默认 600,000 次迭代
- ✅ **防止彩虹表攻击**: 即使相同密码，哈希值也不同
- ✅ **单向加密**: 无法反向解密

---

## 密码重置流程

### 如果忘记管理员密码

**方法 1: 重置数据库** (会丢失所有数据)

```bash
# 删除数据库
Remove-Item instance\face_matching.db

# 重启应用（自动创建新管理员）
python run.py
```

**方法 2: 直接修改数据库** (保留数据)

```bash
# 使用 SQLite 工具连接数据库
sqlite3 instance\face_matching.db

# 更新密码（已哈希）
UPDATE admin SET password = 'pbkdf2:sha256:600000$新哈希值' WHERE username = 'admin';
```

**方法 3: 创建新管理员** (推荐)

```python
from app import create_app
from app.models import db, Admin
from werkzeug.security import generate_password_hash

app = create_app()
with app.app_context():
    # 创建新管理员
    new_admin = Admin(
        username='admin2',
        password=generate_password_hash('NewSecurePassword@2025')
    )
    db.session.add(new_admin)
    db.session.commit()
    print("✅ 新管理员创建成功: admin2")
```

---

## 多管理员管理

### 添加新管理员

```python
from app import create_app
from app.models import db, Admin
from werkzeug.security import generate_password_hash

app = create_app()
with app.app_context():
    # 添加新管理员
    new_admin = Admin(
        username='张三',
        password=generate_password_hash('StrongPass@2025')
    )
    db.session.add(new_admin)
    db.session.commit()
```

### 删除管理员

```python
from app import create_app
from app.models import db, Admin

app = create_app()
with app.app_context():
    admin = Admin.query.filter_by(username='张三').first()
    if admin:
        db.session.delete(admin)
        db.session.commit()
        print("✅ 管理员已删除")
```

### 列出所有管理员

```python
from app import create_app
from app.models import Admin

app = create_app()
with app.app_context():
    admins = Admin.query.all()
    for admin in admins:
        print(f"👤 ID: {admin.id}, 用户名: {admin.username}")
```

---

## 安全建议

### ✅ 生产环境必做

1. **立即修改默认密码**
2. **启用 HTTPS** (防止密码传输被截获)
3. **限制登录失败次数** (防止暴力破解)
4. **记录登录日志** (审计追踪)
5. **定期更换密码** (建议 90 天)
6. **使用强密码策略**
7. **启用双因素认证** (如 Google Authenticator)

### ⚠️ 不要做

1. ❌ 使用默认密码 `Admin@FaceMatch2025!`
2. ❌ 在代码中硬编码密码
3. ❌ 将密码明文存储在配置文件
4. ❌ 使用简单密码（如 123456）
5. ❌ 多个系统使用相同密码
6. ❌ 在不安全的网络环境登录

---

## 密码泄露应急响应

如果密码泄露：

1. **立即修改密码**
   ```bash
   python scripts/change_admin_password.py
   ```

2. **检查登录日志**
   查看是否有异常登录记录

3. **检查匹配记录**
   确认是否有未授权的人脸匹配操作

4. **通知相关人员**
   告知可能受影响的用户

5. **加强安全措施**
   - 启用 IP 白名单
   - 添加登录验证码
   - 启用双因素认证

---

## 相关文档

- [部署指南](DEPLOYMENT.md)
- [快速入门](quick-start-guide.md)
- [项目结构](PROJECT-STRUCTURE.md)

---

最后更新: 2025-10-07
