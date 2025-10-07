"""
修复数据库中的图片路径问题
将 'faces/xxx.jpg' 格式统一改为 'static/faces/xxx.jpg'
"""
from app import create_app
from app.models import db, Person

app = create_app()

with app.app_context():
    # 查找所有路径不正确的记录
    persons = Person.query.all()
    fixed_count = 0
    
    for person in persons:
        # 如果路径不是以 static/ 开头，则修复
        if not person.image_url.startswith('static/'):
            old_url = person.image_url
            
            # 处理不同情况
            if person.image_url.startswith('faces/'):
                person.image_url = 'static/' + person.image_url
            else:
                person.image_url = 'static/faces/' + person.image_url
            
            print(f"✅ 修复 ID={person.id}, Name={person.name}")
            print(f"   旧路径: {old_url}")
            print(f"   新路径: {person.image_url}")
            fixed_count += 1
    
    if fixed_count > 0:
        db.session.commit()
        print(f"\n✨ 成功修复 {fixed_count} 条记录！")
        
        # 重建 FAISS 索引
        from app.face_matcher import face_matcher
        face_matcher.build_index()
        print("✅ FAISS 索引已重建")
    else:
        print("✅ 所有路径都是正确的，无需修复")
    
    # 显示修复后的结果
    print("\n📊 当前数据库中的所有记录：")
    for p in Person.query.all():
        print(f"ID: {p.id}, Name: {p.name}, URL: {p.image_url}")
