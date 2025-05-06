# RichTextEditorKit 开发协作指南

## 架构分工方案

基于当前的模块化架构，我们可以将工作分为以下几个核心区域，每个区域可以由不同的开发者负责：

### 1. 核心编辑引擎团队
负责富文本编辑的核心功能实现
- TextView/
- Storage/
- Formatting/
主要职责：
- 实现文本编辑核心逻辑
- 管理文本存储和属性
- 处理格式化逻辑
- 优化编辑性能

### 2. UI组件团队
负责工具栏和按钮等界面组件
- Toolbar/
- Model/ButtonAction
主要职责：
- 开发和优化工具栏组件
- 实现各类格式化按钮
- 处理UI交互逻辑
- 确保组件的可复用性

### 3. 媒体处理团队
负责图片等媒体内容的处理
- Attachments/
主要职责：
- 实现图片插入功能
- 处理图片缓存和优化
- 实现图片排版逻辑
- 未来可能的视频支持

### 4. 数据同步团队
负责数据持久化和同步功能
- Storage/
- Utils/
主要职责：
- 实现数据持久化
- 处理iCloud同步
- 管理版本控制
- 处理冲突解决

## 开发流程

### 分支管理策略

```
main (稳定版本)
  └── develop (开发分支)
      └── feature/* (功能分支)
```

### Git工作流程

1. 日常开发流程
```bash
# 1. 更新开发分支
git checkout develop
git pull origin develop

# 2. 创建功能分支
git checkout -b feature/xxx

# 3. 提交改动
git add .
git commit -m "描述改动"

# 4. 合并回开发分支
git checkout develop
git merge feature/xxx
git push origin develop

# 5. 删除功能分支
git branch -d feature/xxx
```

2. 版本发布流程
```bash
# 1. 确保develop分支稳定
git checkout develop
git pull origin develop

# 2. 合并到main分支
git checkout main
git merge develop
git tag v1.x.x
git push origin main --tags
```

### 提交规范

提交信息格式：
```
[模块]: 改动说明

例如：
[toolbar]: 添加字体选择按钮
[core]: 修复文本删除bug
[docs]: 更新API文档
```


