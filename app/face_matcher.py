"""人脸特征提取与搜索封装。

通过惰性（lazy）初始化，避免在应用启动阶段因 insightface/模型 缺失而直接崩溃，
同时为离线部署提供更清晰的错误反馈。
"""

import os
import traceback
import numpy as np
import cv2
import faiss
import insightface
from app.models import Person


class FaceMatcher:
    def __init__(self):
        self._ready = False
        self.error = None
        self.dimension = 512
        self.index = faiss.IndexFlatL2(self.dimension)
        self.id_mapping = {}
        # 延迟加载 insightface 模型

    def _ensure_ready(self):
        if self._ready:
            return True
        try:
            # 检查模型目录（离线部署提前复制）
            user_home = os.path.expanduser('~')
            model_dir = os.path.join(user_home, '.insightface', 'models', 'buffalo_l')
            missing_files = []
            for f in ['det_10g.onnx', 'w600k_r50.onnx', 'glintr100.onnx']:
                if not os.path.exists(os.path.join(model_dir, f)):
                    missing_files.append(f)
            if missing_files:
                # 不阻塞初始化，insightface 会尝试下载，但离线环境给出明显提示
                self.error = f"模型文件缺失: {', '.join(missing_files)} (目录: {model_dir})"
            self.app = insightface.app.FaceAnalysis(
                name='buffalo_l',
                providers=['CPUExecutionProvider']
            )
            self.app.prepare(ctx_id=-1, det_size=(640, 640))
            self._ready = True
            return True
        except Exception as e:
            self.error = f"初始化失败: {e}"
            traceback.print_exc()
            return False

    def extract_features(self, image_path):
        if not self._ensure_ready():
            return None, f"引擎未就绪: {self.error}"
        try:
            img = cv2.imdecode(np.fromfile(image_path, dtype=np.uint8), cv2.IMREAD_COLOR)
            if img is None or img.size == 0:
                return None, f"无法读取图片/为空: {image_path}"
            faces = self.app.get(img)
            if not faces:
                return None, "未检测到人脸"
            embedding = faces[0].embedding
            if embedding is None or len(embedding) == 0:
                return None, "特征提取失败"
            embedding = embedding / np.linalg.norm(embedding)
            return embedding, None
        except Exception as e:
            return None, f"特征提取异常: {e}"

    def build_index(self):
        # 重建索引前清空
        self.index = faiss.IndexFlatL2(self.dimension)
        self.id_mapping = {}
        persons = Person.query.all()
        for person in persons:
            if person.feature_vector:
                vector = np.array(person.feature_vector, dtype='float32')
                if vector.shape[0] == self.dimension:
                    self.index.add(vector.reshape(1, -1))
                    self.id_mapping[self.index.ntotal - 1] = person.id

    def search(self, query_embedding, k=3, threshold=0.5):
        if self.index.ntotal == 0:
            return []
        query = np.array(query_embedding, dtype='float32').reshape(1, -1)
        distances, indices = self.index.search(query, k)
        results = []
        for dist, idx in zip(distances[0], indices[0]):
            if idx in self.id_mapping:
                person = Person.query.get(self.id_mapping[idx])
                if person:
                    similarity = max(0.0, 1 - (float(dist) / 2))
                    if similarity >= threshold:
                        results.append({
                            'person': person,
                            'similarity': similarity,
                            'distance': float(dist)
                        })
        return results


# 单例惰性实例
face_matcher = FaceMatcher()
