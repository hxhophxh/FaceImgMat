from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from flask_login import login_user, logout_user, login_required, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import os
import uuid
from datetime import datetime
from app.models import db, Admin, Person, MatchRecord
from app.face_matcher import face_matcher

bp = Blueprint('main', __name__)

UPLOAD_FOLDER = 'static/uploads'
FACES_FOLDER = 'static/faces'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

# 确保文件夹存在
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(FACES_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@bp.route('/')
def index():
    if current_user.is_authenticated:
        return redirect(url_for('main.match'))
    return redirect(url_for('main.login'))

@bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        admin = Admin.query.filter_by(username=username).first()
        
        if admin and check_password_hash(admin.password, password):
            login_user(admin)
            return redirect(url_for('main.match'))
        
        flash('用户名或密码错误', 'error')
    
    return render_template('login.html')

@bp.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('main.login'))

@bp.route('/match', methods=['GET', 'POST'])
@login_required
def match():
    if request.method == 'POST':
        if 'image' not in request.files:
            return jsonify({'error': '没有上传文件'}), 400
        
        file = request.files['image']
        
        if file.filename == '':
            return jsonify({'error': '没有选择文件'}), 400
        
        if file and allowed_file(file.filename):
            # 保存上传的文件
            filename = secure_filename(file.filename)
            filepath = os.path.join(UPLOAD_FOLDER, filename)
            file.save(filepath)
            
            # 提取特征
            embedding, error = face_matcher.extract_features(filepath)
            
            if error:
                return jsonify({'error': error}), 400
            
            # 搜索匹配（只返回相似度>=60%的结果）
            results = face_matcher.search(embedding, k=5, threshold=0.6)
            
            # 记录匹配历史
            record = MatchRecord(
                admin_id=current_user.id,
                query_image=filename
            )
            db.session.add(record)
            db.session.commit()
            
            # 返回结果
            return jsonify({
                'success': True,
                'results': [
                    {
                        'id': r['person'].id,
                        'name': r['person'].name,
                        'image_url': r['person'].image_url,
                        'similarity': r['similarity'],
                        'similarity_percent': f"{r['similarity']*100:.1f}"
                    }
                    for r in results
                ]
            })
    
    return render_template('match.html')

# ===================== 新增：数据导入功能 =====================

@bp.route('/import', methods=['GET', 'POST'])
@login_required
def import_data():
    """管理员导入人脸数据"""
    if request.method == 'POST':
        # 获取表单数据
        person_name = request.form.get('person_name', '').strip()
        files = request.files.getlist('images')  # 支持批量上传
        
        if not person_name:
            return jsonify({'error': '请输入人物姓名'}), 400
        
        if not files or files[0].filename == '':
            return jsonify({'error': '请选择至少一张图片'}), 400
        
        success_count = 0
        failed_files = []
        
        for file in files:
            if file and allowed_file(file.filename):
                try:
                    # 生成唯一文件名（避免重复）
                    ext = file.filename.rsplit('.', 1)[1].lower()
                    unique_filename = f"{person_name}_{uuid.uuid4().hex[:8]}.{ext}"
                    filepath = os.path.join(FACES_FOLDER, unique_filename)
                    
                    # 保存文件
                    file.save(filepath)
                    
                    # 提取人脸特征
                    embedding, error = face_matcher.extract_features(filepath)
                    
                    if error:
                        failed_files.append({
                            'filename': file.filename,
                            'error': error
                        })
                        os.remove(filepath)  # 删除无效文件
                        continue
                    
                    if embedding is None:
                        failed_files.append({
                            'filename': file.filename,
                            'error': '未检测到人脸'
                        })
                        os.remove(filepath)
                        continue
                    
                    # 添加到数据库
                    person = Person(
                        name=person_name,
                        image_url=f'static/faces/{unique_filename}',
                        feature_vector=embedding.tolist()
                    )
                    db.session.add(person)
                    success_count += 1
                    
                except Exception as e:
                    failed_files.append({
                        'filename': file.filename,
                        'error': str(e)
                    })
        
        # 提交到数据库
        db.session.commit()
        
        # 重建 FAISS 索引
        if success_count > 0:
            face_matcher.build_index()
        
        # 返回结果
        return jsonify({
            'success': True,
            'message': f'成功导入 {success_count} 张图片',
            'success_count': success_count,
            'failed_count': len(failed_files),
            'failed_files': failed_files
        })
    
    # GET 请求：显示导入页面
    # 获取所有已导入的人物，按姓名分组
    persons = Person.query.order_by(Person.name, Person.created_at.desc()).all()
    
    # 按姓名分组
    person_dict = {}
    for p in persons:
        if p.name not in person_dict:
            person_dict[p.name] = {
                'name': p.name,
                'count': 0,
                'images': []
            }
        person_dict[p.name]['count'] += 1
        person_dict[p.name]['images'].append({
            'id': p.id,
            'image_url': p.image_url,
            'created_at': p.created_at.strftime('%Y-%m-%d %H:%M:%S')
        })
    
    # 转换为列表并按照片数量排序
    person_list = sorted(person_dict.values(), key=lambda x: x['count'], reverse=True)
    
    return render_template('import.html', person_list=person_list)

@bp.route('/persons')
@login_required
def list_persons():
    """获取所有人物列表（JSON API）"""
    persons = Person.query.all()
    
    # 按姓名分组
    person_dict = {}
    for p in persons:
        if p.name not in person_dict:
            person_dict[p.name] = []
        person_dict[p.name].append({
            'id': p.id,
            'image_url': p.image_url,
            'created_at': p.created_at.strftime('%Y-%m-%d %H:%M:%S')
        })
    
    return jsonify({
        'success': True,
        'persons': [
            {
                'name': name,
                'count': len(images),
                'images': images
            }
            for name, images in person_dict.items()
        ]
    })

@bp.route('/persons/<int:person_id>', methods=['DELETE'])
@login_required
def delete_person(person_id):
    """删除指定人物的单张照片"""
    person = Person.query.get_or_404(person_id)
    
    # 删除文件（处理可能的路径格式差异）
    if person.image_url.startswith('static/'):
        filepath = person.image_url
    else:
        filepath = os.path.join('static', person.image_url)
    
    if os.path.exists(filepath):
        os.remove(filepath)
    
    # 删除数据库记录
    db.session.delete(person)
    db.session.commit()
    
    # 重建索引
    face_matcher.build_index()
    
    return jsonify({
        'success': True,
        'message': '删除成功'
    })

@bp.route('/persons/<int:person_id>/update_name', methods=['PUT'])
@login_required
def update_person_name(person_id):
    """更新指定人物的姓名"""
    person = Person.query.get_or_404(person_id)
    
    data = request.get_json()
    new_name = data.get('name', '').strip()
    
    if not new_name:
        return jsonify({'error': '姓名不能为空'}), 400
    
    old_name = person.name
    person.name = new_name
    db.session.commit()
    
    # 不需要重建索引，因为只是修改了姓名
    
    return jsonify({
        'success': True,
        'message': f'已将 "{old_name}" 改为 "{new_name}"',
        'old_name': old_name,
        'new_name': new_name
    })

@bp.route('/persons/batch_update_name', methods=['PUT'])
@login_required
def batch_update_name():
    """批量更新同一人物的所有照片姓名"""
    data = request.get_json()
    old_name = data.get('old_name', '').strip()
    new_name = data.get('new_name', '').strip()
    
    if not old_name or not new_name:
        return jsonify({'error': '姓名不能为空'}), 400
    
    if old_name == new_name:
        return jsonify({'error': '新旧姓名相同'}), 400
    
    # 查找所有匹配的记录
    persons = Person.query.filter_by(name=old_name).all()
    
    if not persons:
        return jsonify({'error': f'未找到姓名为 "{old_name}" 的记录'}), 404
    
    # 批量更新
    for person in persons:
        person.name = new_name
    
    db.session.commit()
    
    return jsonify({
        'success': True,
        'message': f'已将 {len(persons)} 条记录从 "{old_name}" 改为 "{new_name}"',
        'count': len(persons)
    })