# Git 分支开发指南

## 创建新分支开发新特性的步骤

### 1. 查看当前分支状态
```bash
# 查看当前所在分支
git branch

# 查看所有分支（包括远程分支）
git branch -a

# 查看当前状态
git status
```

### 2. 创建并切换到新分支
```bash
# 创建新分支并立即切换到该分支
git switch -c feature/your-feature-name

# 或者使用传统命令
git checkout -b feature/your-feature-name
```

### 3. 分支命名规范建议
- `feature/` - 新功能开发 (如: `feature/user-authentication`)
- `bugfix/` - Bug修复 (如: `bugfix/login-error`)
- `hotfix/` - 紧急修复 (如: `hotfix/security-patch`)
- `release/` - 发布准备 (如: `release/v1.2.0`)
- `experimental/` - 实验性功能 (如: `experimental/new-ui`)

### 4. 开发新特性
```bash
# 在新分支上进行开发工作
# 编辑文件...

# 添加更改到暂存区
git add .

# 提交更改
git commit -m "feat: Add new feature description"

# 继续开发和提交...
```

### 5. 保持分支同步（可选但推荐）
```bash
# 定期将主分支的更改合并到特性分支
git switch main
git pull origin main
git switch feature/your-feature-name
git merge main
```

### 6. 推送分支到远程仓库
```bash
# 首次推送新分支
git push -u origin feature/your-feature-name

# 后续推送
git push
```

### 7. 完成开发后的操作

#### 选项A: 合并到主分支
```bash
# 切换到主分支
git switch main

# 拉取最新更改
git pull origin main

# 合并特性分支
git merge feature/your-feature-name

# 推送到远程仓库
git push origin main

# 删除本地特性分支（可选）
git branch -d feature/your-feature-name

# 删除远程特性分支（可选）
git push origin --delete feature/your-feature-name
```

#### 选项B: 创建Pull Request/Merge Request
```bash
# 推送分支到远程仓库
git push origin feature/your-feature-name

# 在GitHub/GitLab等平台上创建Pull Request
# 通过Web界面完成代码审查和合并
```

## 实际操作示例

假设我们要为Zig CLI库添加一个新特性"文件树显示"：

```bash
# 1. 确保在主分支上
git switch main

# 2. 拉取最新更改
git pull origin main

# 3. 创建新特性分支
git switch -c feature/file-tree-display

# 4. 开始开发工作
# 创建新文件、编辑代码等...

# 5. 提交更改
git add src/lib/tree.zig
git commit -m "feat: Add file tree display component"

# 6. 继续开发并提交更多更改
git add src/main.zig
git commit -m "feat: Integrate tree display into main application"

# 7. 推送分支到远程仓库
git push -u origin feature/file-tree-display

# 8. 在GitHub上创建Pull Request进行代码审查
```

## 最佳实践

1. **保持分支专注**：每个分支应该只关注一个特性或修复
2. **频繁提交**：小的、逻辑相关的更改应该及时提交
3. **有意义的提交信息**：使用清晰、描述性的提交信息
4. **定期同步**：定期将主分支的更改合并到特性分支
5. **及时清理**：特性开发完成后及时删除已合并的分支

## 常用命令总结

```bash
# 创建并切换到新分支
git switch -c feature/new-feature

# 查看分支状态
git branch

# 切换分支
git switch branch-name

# 合并分支
git merge branch-name

# 删除本地分支
git branch -d branch-name

# 删除远程分支
git push origin --delete branch-name
```