from flask import Flask
from flask_login import LoginManager
from app.models import db, Admin
from app.routes import bp
from app.face_matcher import face_matcher
import os

def create_app():
    # 获取项目根目录
    basedir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    
    app = Flask(__name__, 
                template_folder=os.path.join(basedir, 'templates'),
                static_folder=os.path.join(basedir, 'static'))
    app.config['SECRET_KEY'] = 'your-secret-key-change-in-production'
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///face_matching.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    # 初始化扩展
    db.init_app(app)
    
    # 初始化Flask-Login
    login_manager = LoginManager()
    login_manager.init_app(app)
    login_manager.login_view = 'main.login'
    
    @login_manager.user_loader
    def load_user(user_id):
        return Admin.query.get(int(user_id))
    
    # 注册蓝图
    app.register_blueprint(bp)
    
    # 创建数据库表
    with app.app_context():
        db.create_all()
        
        # 创建默认管理员（如果不存在）
        if not Admin.query.filter_by(username='admin').first():
            from werkzeug.security import generate_password_hash
            admin = Admin(
                username='admin',
                password=generate_password_hash('Admin@FaceMatch2025!')
            )
            db.session.add(admin)
            db.session.commit()
        
        # 构建FAISS索引
        face_matcher.build_index()
    
    return app