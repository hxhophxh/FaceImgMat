# 🚀 Git提交到GitHub - 快速参考卡片

## ⚡ 最常用的三连击

```bash
git add .                           # 1. 添加所有文件
git commit -m "说明你做了什么"        # 2. 提交
git push origin main                # 3. 推送到GitHub
```

---

## 📝 完整流程

```bash
# ① 查看当前状态
git status

# ② 查看具体改动（可选）
git diff

# ③ 添加文件到暂存区
git add .                    # 添加所有文件
# 或
git add 文件名.txt            # 添加特定文件

# ④ 提交
git commit -m "添加/修改了什么功能"

# ⑤ 推送到GitHub
git push origin main
```

---

## 🔍 常用命令速查

| 命令 | 说明 |
|------|------|
| `git status` | 查看当前状态 |
| `git diff` | 查看修改内容 |
| `git add .` | 添加所有文件 |
| `git add 文件名` | 添加特定文件 |
| `git commit -m "说明"` | 提交 |
| `git push origin main` | 推送到GitHub |
| `git pull origin main` | 从GitHub拉取 |
| `git log` | 查看提交历史 |

---

## ⚠️ 常见问题

### 问题1：推送被拒绝
```bash
# 错误信息：Updates were rejected...
# 解决：先拉取再推送
git pull origin main
git push origin main
```

### 问题2：忘记写提交信息
```bash
# 会打开编辑器，写完保存退出即可
git commit
```

### 问题3：提交错了想撤销
```bash
# 撤销最后一次提交（保留修改）
git reset --soft HEAD~1

# 修改最后一次提交信息
git commit --amend -m "新的提交信息"
```

### 问题4：不小心add了不该提交的文件
```bash
# 从暂存区移除
git restore --staged 文件名

# 或移除所有
git restore --staged .
```

---

## ✅ 提交信息模板

```bash
# 新功能
git commit -m "feat: 添加离线部署功能"

# 修复bug
git commit -m "fix: 修复数据库连接错误"

# 文档更新
git commit -m "docs: 更新README安装说明"

# 代码优化
git commit -m "refactor: 优化人脸匹配算法"
```

---

## 📋 检查清单

提交前检查：
- [ ] `git status` 查看状态
- [ ] `git diff` 查看改动
- [ ] 确认没有敏感信息（密码、密钥）
- [ ] 确认`.venv`和`__pycache__`未被添加
- [ ] 写清楚的提交信息

---

## 💡 提示

**好的提交信息：**
- ✅ "Add offline deployment scripts"
- ✅ "Fix database initialization error"  
- ✅ "Update README with installation guide"

**不好的提交信息：**
- ❌ "update"
- ❌ "fix"
- ❌ "改了点东西"

---

## 🎓 实例演示

### 场景：添加新文档并推送

```bash
# 1. 创建或修改文件
echo "# New Doc" > new_doc.md

# 2. 查看状态
git status
# 输出：Untracked files: new_doc.md

# 3. 添加文件
git add new_doc.md

# 4. 再次查看状态
git status
# 输出：Changes to be committed: new file: new_doc.md

# 5. 提交
git commit -m "docs: Add new documentation"

# 6. 推送
git push origin main

# ✅ 完成！
```

---

## 📚 详细文档

需要更详细的说明？查看：[Git完整指南](GIT-QUICK-GUIDE.md)

---

**记住这个流程：**
```
修改代码 → git add . → git commit -m "说明" → git push origin main
```

**就这么简单！** 🎉
