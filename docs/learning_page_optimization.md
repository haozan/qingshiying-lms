# 学习页面布局优化总结

## 优化内容

### 1. 侧边栏默认隐藏
- **问题**: 侧边栏占据固定宽度（320px），限制了学习内容的显示空间
- **解决方案**: 
  - 侧边栏默认隐藏在左侧（`-translate-x-full`）
  - 通过"目录"按钮按需显示
  - 使用遮罩层和平滑动画提升交互体验

### 2. 全屏卡片视图
- **问题**: 页面可以上下滚动，学习卡片需要滚动页面才能看到完整内容
- **解决方案**:
  - 页面容器使用 `fixed inset-0` 固定定位，填满整个视口
  - 卡片容器使用 `w-full h-full` 填满可用空间
  - 内容滚动限制在卡片内部（Markdown 区域使用 `overflow-y-auto`）

### 3. 隐藏导航栏
- **问题**: 导航栏占据头部空间，导致页面需要滚动
- **解决方案**:
  - 在 `LessonsController#show` 中设置 `@full_render = true`
  - 学习页面不显示全局导航栏
  - 侧边栏内有"返回课程列表"链接，不影响导航

## 技术实现

### 布局结构
```
页面容器 (fixed inset-0) ← 固定定位，填满视口
├── 侧边栏 (fixed, 默认隐藏)
└── 主内容区 (flex-1)
    ├── 顶部导航条 (固定高度)
    ├── 遮罩层 (fixed, 默认隐藏)
    └── 卡片容器 (flex-1 p-8)
        └── 卡片 (w-full h-full)
            ├── 视频区域 (aspect-video)
            ├── 内容区域 (flex-1 overflow-y-auto) ⬅️ 滚动在这里
            └── 操作按钮 (固定在底部)
```

**关键点**: 
- 全局导航栏被隐藏（`@full_render = true`）
- 页面使用 `fixed inset-0` 而不是 `h-screen`，避免与 body 的 `min-h-screen` 冲突
- 没有页面级别的滚动条

### 关键 CSS 类

**页面级别**:
- `fixed inset-0` - 固定定位，填满整个视口（top: 0, right: 0, bottom: 0, left: 0）
- `flex` - 使用 Flexbox 布局

**卡片容器**:
- `flex-1` - 占据剩余空间
- `p-8` - 内边距
- `w-full h-full` - 填满父容器

**内容区域**:
- `flex-1` - 占据卡片内剩余空间
- `overflow-y-auto` - 内容过长时显示滚动条

## 用户体验提升

### 之前
- 全局导航栏占据头部空间
- 侧边栏占据固定宽度，内容区域较窄
- 页面可以上下滚动，卡片可能显示不完整
- 需要滚动页面才能看到卡片底部的操作按钮

### 之后
- 导航栏完全隐藏，学习页面专注于内容
- 侧边栏默认隐藏，内容区域最大化
- 页面固定不滚动，卡片始终填满视口
- 卡片内容在内部滚动，操作按钮始终可见
- 整体感觉像一个"应用"而不是"网页"

## 代码改动

### app/controllers/lessons_controller.rb

**改动: 隐藏导航栏**
```diff
 def show
+  @full_render = true  # 隐藏导航栏，让学习页面占据全屏
   @course = @lesson.chapter.course
```

### app/views/lessons/show.html.erb

**改动 1: 页面容器使用固定定位**
```diff
- <div class="h-screen bg-surface flex overflow-hidden"
+ <div class="fixed inset-0 bg-surface flex"
```

**改动 2: 卡片容器移除滚动**
```diff
- <div class="flex-1 p-8 overflow-y-auto"
+ <div class="flex-1 p-8"
```

**改动 3: 卡片尺寸**
```diff
- <div class="max-w-5xl mx-auto h-full"
+ <div class="w-full h-full max-w-5xl mx-auto"
```

### app/javascript/controllers/sidebar_controller.ts

新增侧边栏控制器，处理显示/隐藏逻辑：
- `toggle()` - 切换侧边栏状态
- `updateSidebar()` - 更新 DOM 类名
- 管理遮罩层显示

## 测试验证

✅ 所有 47 个测试通过
- Stimulus 验证器检查通过
- 页面请求测试通过
- HTML 结构验证通过
- 导航栏正确隐藏验证通过

## 相关文档

- [侧边栏切换功能详细说明](./sidebar_toggle.md)
