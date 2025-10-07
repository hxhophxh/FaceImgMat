# init_demo_data.py
from app import create_app
from app.models import db, Person
from app.face_matcher import face_matcher
import os

app = create_app()

with app.app_context():
    # 清空现有数据
    Person.query.delete()
    db.session.commit()
    
    # 准备演示人脸图片（需要手动准备3-5张人脸图片）
    demo_faces = [
        {'name': '张三', 'image': 'static/faces/person1.jpg'},
        {'name': '李四', 'image': 'static/faces/person2.jpg'},
        {'name': '王五', 'image': 'static/faces/person3.jpg'},
    ]
    
    for face_data in demo_faces:
        if os.path.exists(face_data['image']):
            # 提取特征
            embedding, error = face_matcher.extract_features(face_data['image'])
            
            if embedding is not None:
                person = Person(
                    name=face_data['name'],
                    image_url=face_data['image'],
                    feature_vector=embedding.tolist()
                )
                db.session.add(person)
                print(f"✅ 添加: {face_data['name']}")
            else:
                print(f"❌ 失败: {face_data['name']} - {error}")
        else:
            print(f"⚠️  文件不存在: {face_data['image']}")
    
    db.session.commit()
    
    # 重建FAISS索引
    face_matcher.build_index()
    
    print(f"\n✨ 演示数据初始化完成！共 {Person.query.count()} 个人物")