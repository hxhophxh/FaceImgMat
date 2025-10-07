import insightface
import faiss
import numpy as np
import cv2
from app.models import Person, db

class FaceMatcher:
    def __init__(self):
        # 初始化InsightFace
        self.app = insightface.app.FaceAnalysis(providers=['CPUExecutionProvider'])
        self.app.prepare(ctx_id=0, det_size=(640, 640))
        
        # 初始化FAISS索引
        self.dimension = 512
        self.index = faiss.IndexFlatL2(self.dimension)
        self.id_mapping = {}  # FAISS索引 -> Person ID
        
    def extract_features(self, image_path):
        """提取人脸特征"""
        try:
            # 使用支持中文路径的方式读取图片
            img = cv2.imdecode(np.fromfile(image_path, dtype=np.uint8), cv2.IMREAD_COLOR)
            
            # 检查图片是否成功读取
            if img is None:
                return None, f"无法读取图片：{image_path}"
            
            # 检查图片是否为空
            if img.size == 0:
                return None, "图片内容为空"
            
            # 检测人脸
            faces = self.app.get(img)
            
            if len(faces) == 0:
                return None, "未检测到人脸"
            
            # 获取第一个人脸的特征向量
            embedding = faces[0].embedding
            
            # 检查特征向量是否有效
            if embedding is None or len(embedding) == 0:
                return None, "特征提取失败"
            
            # 归一化
            embedding = embedding / np.linalg.norm(embedding)
            return embedding, None
            
        except Exception as e:
            return None, f"特征提取异常：{str(e)}"
    
    def build_index(self):
        """构建FAISS索引"""
        persons = Person.query.all()
        
        for person in persons:
            if person.feature_vector is not None:
                vector = np.array(person.feature_vector).astype('float32')
                self.index.add(vector.reshape(1, -1))
                idx = self.index.ntotal - 1
                self.id_mapping[idx] = person.id
    
    def search(self, query_embedding, k=3, threshold=0.5):
        """搜索最相似的k个人脸
        
        Args:
            query_embedding: 查询人脸特征向量
            k: 返回结果数量
            threshold: 相似度阈值 (0-1)，默认0.5表示50%
        """
        query = np.array(query_embedding).astype('float32').reshape(1, -1)
        distances, indices = self.index.search(query, k)
        
        results = []
        for dist, idx in zip(distances[0], indices[0]):
            if idx in self.id_mapping:
                person_id = self.id_mapping[idx]
                person = Person.query.get(person_id)
                if person:
                    # 改进的相似度计算：使用余弦相似度转换
                    # L2距离转相似度：similarity = 1 - (distance / 2)
                    # 因为归一化向量的L2距离范围是[0, 2]
                    similarity = max(0, 1 - (float(dist) / 2))
                    
                    # 只返回超过阈值的结果
                    if similarity >= threshold:
                        results.append({
                            'person': person,
                            'similarity': similarity,
                            'distance': float(dist)
                        })
        
        return results

# 全局实例
face_matcher = FaceMatcher()