#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
脚本名称: change_admin_password.py
功能描述: 修改管理员密码
创建日期: 2025-10-07
"""

from app import create_app
from app.models import db, Admin
from werkzeug.security import generate_password_hash
import getpass
import re

def validate_password(password):
    """验证密码强度"""
    if len(password) < 12:
        return False, "密码长度至少12位"
    
    if not re.search(r'[A-Z]', password):
        return False, "密码必须包含大写字母"
    
    if not re.search(r'[a-z]', password):
        return False, "密码必须包含小写字母"
    
    if not re.search(r'[0-9]', password):
        return False, "密码必须包含数字"
    
    if not re.search(r'[@#$%&*!]', password):
        return False, "密码必须包含特殊字符 (@#$%&*!)"
    
    return True, "密码强度合格"

def change_admin_password():
    """修改管理员密码"""
    app = create_app()
    
    with app.app_context():
        admin = Admin.query.filter_by(username='admin').first()
        
        if not admin:
            print("❌ 管理员账户不存在！")
            return
        
        print("🔐 修改管理员密码")
        print("=" * 60)
        print("密码要求:")
        print("  - 至少 12 位字符")
        print("  - 包含大写字母 (A-Z)")
        print("  - 包含小写字母 (a-z)")
        print("  - 包含数字 (0-9)")
        print("  - 包含特殊字符 (@#$%&*!)")
        print("=" * 60)
        print()
        
        # 输入新密码（不显示）
        new_password = getpass.getpass("请输入新密码: ")
        
        # 验证密码强度
        is_valid, message = validate_password(new_password)
        if not is_valid:
            print(f"❌ {message}")
            return
        
        # 确认密码
        confirm_password = getpass.getpass("确认新密码: ")
        
        # 验证密码一致性
        if new_password != confirm_password:
            print("❌ 两次密码输入不一致！")
            return
        
        # 更新密码
        admin.password = generate_password_hash(new_password)
        db.session.commit()
        
        print()
        print("✅ 密码修改成功！")
        print("⚠️  请妥善保管新密码")
        print("💡 提示: 建议将密码保存在安全的密码管理器中")

if __name__ == '__main__':
    try:
        change_admin_password()
    except KeyboardInterrupt:
        print("\n\n❌ 操作已取消")
    except Exception as e:
        print(f"\n❌ 发生错误: {e}")
