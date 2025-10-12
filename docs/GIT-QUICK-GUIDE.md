# 📝 Git提交到GitHub快速指南

## 🎯 基本流程（三步走）

### 1️⃣ 添加文件到暂存区
```bash
# 添加所有修改的文件
git add .

# 或者添加特定文件
git add README.md
git add docs/NEW_FILE.md

# 添加特定目录
git add docs/
```

### 2️⃣ 提交更改
```bash
# 提交并添加说明信息
git commit -m "添加新功能/修复bug的描述"

# 示例
git commit -m "Add offline deployment scripts and documentation"
git commit -m "Update README with new features"
git commit -m "Fix database initialization issue"
```

### 3️⃣ 推送到GitHub
```bash
# 推送到远程仓库
git push origin main

# 首次推送可以使用
git push -u origin main
```

---

## 📋 完整示例

```bash
# 1. 查看当前状态
git status

# 2. 查看具体修改内容
git diff

# 3. 添加所有文件
git add .

# 4. 再次确认
git status

# 5. 提交（记得写清楚说明）
git commit -m "Add deployment scripts and update documentation"

# 6. 推送到GitHub
git push origin main
```

---

## 🔍 常用Git命令

### 查看状态
```bash
# 查看当前状态
git status

# 查看简短状态
git status -s

# 查看被忽略的文件
git status --ignored
```

### 查看差异
```bash
# 查看未暂存的修改
git diff

# 查看已暂存的修改
git diff --staged

# 查看特定文件的修改
git diff README.md
```

### 添加文件
```bash
# 添加所有文件
git add .

# 添加所有修改和删除（不包括新文件）
git add -u

# 添加所有（包括新文件、修改、删除）
git add -A

# 添加特定文件
git add file1.txt file2.py

# 交互式添加
git add -i
```

### 提交
```bash
# 提交并添加消息
git commit -m "提交说明"

# 提交并打开编辑器写详细说明
git commit

# 修改上次提交（未push前）
git commit --amend

# 跳过暂存直接提交已跟踪文件
git commit -a -m "提交说明"
```

### 推送
```bash
# 推送到远程main分支
git push origin main

# 首次推送并设置上游
git push -u origin main

# 强制推送（谨慎使用）
git push -f origin main
```

### 撤销操作
```bash
# 撤销工作区的修改
git restore <file>

# 撤销暂存区的修改（保留工作区）
git restore --staged <file>

# 撤销所有未暂存的修改
git restore .

# 查看提交历史
git log

# 回退到上一个提交
git reset --soft HEAD~1  # 保留修改
git reset --hard HEAD~1  # 丢弃修改（危险）
```

---

## 📊 文件状态说明

```
Untracked files:    未跟踪的新文件（红色）
Changes not staged: 已修改但未暂存（红色）
Changes to be committed: 已暂存待提交（绿色）
```

### 状态转换
```
新文件 → git add → 已暂存 → git commit → 已提交 → git push → GitHub
修改文件 → git add → 已暂存 → git commit → 已提交 → git push → GitHub
```

---

## ✅ 提交规范（推荐）

### 提交信息格式
```
<类型>: <简短描述>

<详细描述>（可选）

<相关Issue>（可选）
```

### 常用类型
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 重构代码
- `test`: 测试相关
- `chore`: 构建/工具相关

### 示例
```bash
git commit -m "feat: Add offline deployment support"
git commit -m "fix: Fix database initialization error"
git commit -m "docs: Update README with installation guide"
git commit -m "refactor: Optimize face matching algorithm"
```

---

## 🚨 注意事项

### ⚠️ 提交前检查
```bash
# 1. 查看将要提交的文件
git status

# 2. 查看具体修改内容
git diff

# 3. 确保.gitignore正确
git status --ignored

# 4. 检查是否包含敏感信息
grep -r "password\|secret\|token" .
```

### ❌ 不要提交的文件
- `.venv/` - 虚拟环境
- `__pycache__/` - Python缓存
- `.env` - 环境变量（包含密码）
- `*.log` - 日志文件
- 大文件（>100MB）
- 二进制文件（除非必要）

### ✅ 应该提交的文件
- 源代码（`.py`, `.js`, `.html`等）
- 配置文件（`requirements.txt`, `.gitignore`）
- 文档（`.md`）
- 小的资源文件（图片、图标）
- 脚本文件（`.sh`, `.ps1`, `.bat`）

---

## 🔧 常见问题解决

### 问题1：推送被拒绝
```bash
# 错误：Updates were rejected because the remote contains work
# 解决：先拉取再推送
git pull origin main
git push origin main
```

### 问题2：合并冲突
```bash
# 1. 拉取时发生冲突
git pull origin main

# 2. 手动解决冲突文件（编辑器打开）
# 找到 <<<<<<< HEAD ... ======= ... >>>>>>> 标记

# 3. 解决后添加并提交
git add .
git commit -m "Resolve merge conflicts"
git push origin main
```

### 问题3：误提交敏感文件
```bash
# 从暂存区移除（未commit）
git restore --staged <file>

# 已提交但未push
git reset --soft HEAD~1

# 已push（需要强制推送，谨慎）
git rm --cached <file>
git commit -m "Remove sensitive file"
git push -f origin main
```

### 问题4：提交信息写错了
```bash
# 修改最后一次提交信息（未push）
git commit --amend -m "正确的提交信息"

# 已经push了需要强制推送（谨慎）
git commit --amend -m "正确的提交信息"
git push -f origin main
```

---

## 📚 分支操作

### 创建和切换分支
```bash
# 创建新分支
git branch feature-new

# 切换分支
git checkout feature-new

# 创建并切换（推荐）
git checkout -b feature-new

# 查看所有分支
git branch -a
```

### 合并分支
```bash
# 切换到main分支
git checkout main

# 合并feature分支
git merge feature-new

# 删除已合并的分支
git branch -d feature-new
```

---

## 🎓 实战演练

### 场景1：添加新文件
```bash
# 创建新文件
echo "# New Feature" > new_feature.md

# 查看状态（Untracked）
git status

# 添加到暂存区
git add new_feature.md

# 查看状态（Changes to be committed）
git status

# 提交
git commit -m "Add new feature documentation"

# 推送
git push origin main
```

### 场景2：修改现有文件
```bash
# 修改文件
echo "更新内容" >> README.md

# 查看修改
git diff README.md

# 添加到暂存区
git add README.md

# 提交
git commit -m "Update README with new information"

# 推送
git push origin main
```

### 场景3：批量提交多个文件
```bash
# 查看所有修改
git status

# 添加所有文件
git add .

# 查看将要提交的内容
git diff --staged

# 提交
git commit -m "Add multiple features and update documentation"

# 推送
git push origin main
```

---

## 🔍 查看历史

```bash
# 查看提交历史
git log

# 简洁显示
git log --oneline

# 图形化显示
git log --graph --oneline

# 查看最近3次提交
git log -3

# 查看某个文件的历史
git log README.md

# 查看某个人的提交
git log --author="Your Name"
```

---

## 💡 提示

### 好习惯
1. ✅ 经常提交，小步快跑
2. ✅ 写清楚的提交信息
3. ✅ 提交前检查状态和差异
4. ✅ 一次提交只做一件事
5. ✅ 提交前运行测试

### 坏习惯
1. ❌ 长时间不提交
2. ❌ 提交信息写"update"、"fix"等无意义内容
3. ❌ 不检查就提交
4. ❌ 提交大量无关文件
5. ❌ 提交敏感信息

---

## 📞 获取帮助

```bash
# Git命令帮助
git help
git help <command>

# 示例
git help commit
git help push
```

---

**快速记忆口诀：**
```
状态看清楚 → status
添加到暂存 → add
提交写说明 → commit
推送到远程 → push
```

**最常用的三连击：**
```bash
git add .
git commit -m "说明"
git push origin main
```
