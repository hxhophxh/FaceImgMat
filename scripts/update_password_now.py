#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
紧急密码更新脚本
直接更新数据库中的管理员密码为新密码
"""

import sys
import os

# 添加项目根目录到路径
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import create_app
from app.models import db, Admin
from werkzeug.security import generate_password_hash

def update_password():
    """更新管理员密码为新密码"""
    app = create_app()
    
    with app.app_context():
        admin = Admin.query.filter_by(username='admin').first()
        
        if not admin:
            print("❌ 管理员账户不存在！")
            return
        
        # 设置新密码
        new_password = 'Admin@FaceMatch2025!'
        admin.password = generate_password_hash(new_password)
        db.session.commit()
        
        print("✅ 密码已更新为: Admin@FaceMatch2025!")
        print("💡 现在可以使用新密码登录了")

if __name__ == '__main__':
    try:
        update_password()
    except Exception as e:
        print(f"❌ 更新失败: {e}")
