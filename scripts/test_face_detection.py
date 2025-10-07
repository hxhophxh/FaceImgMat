"""测试人脸检测功能"""
import cv2
import sys
import numpy as np
from app.face_matcher import face_matcher

def test_image(image_path):
    print(f"\n📷 测试图片: {image_path}")
    print("-" * 50)
    
    # 1. 检查文件读取（支持中文路径）
    img = cv2.imdecode(np.fromfile(image_path, dtype=np.uint8), cv2.IMREAD_COLOR)
    if img is None:
        print("❌ 无法读取图片文件")
        return
    
    print(f"✅ 图片尺寸: {img.shape}")
    
    # 2. 测试人脸检测
    embedding, error = face_matcher.extract_features(image_path)
    
    if error:
        print(f"❌ 检测失败: {error}")
    elif embedding is not None:
        print(f"✅ 检测成功!")
        print(f"   特征向量维度: {len(embedding)}")
        print(f"   特征向量范围: [{embedding.min():.4f}, {embedding.max():.4f}]")
    else:
        print("❌ 未知错误")

if __name__ == '__main__':
    if len(sys.argv) > 1:
        test_image(sys.argv[1])
    else:
        # 测试示例图片
        test_paths = [
            'static/uploads/zxw1.jpg',
            'static/faces/person1.jpg',
            'static/faces/zxw.jpg'
        ]
        for path in test_paths:
            try:
                test_image(path)
            except Exception as e:
                print(f"❌ 异常: {e}")
