# 学习页面侧边栏关闭按钮改进

## 改动日期
2026-01-17

## 问题描述
侧边栏打开后，用户只能通过以下方式关闭：
- 点击遮罩层（不够明显）
- 再次点击顶部"目录"按钮（不够直观）

用户反馈缺少一个明确的关闭按钮。

## 解决方案
在侧边栏头部添加 X 关闭按钮，位于"返回课程列表"链接的右侧。

## 代码改动

### app/views/lessons/show.html.erb

**位置**: 侧边栏头部区域（第 8-16 行）

**改动前**:
```erb
<div class="p-6 border-b border-border sticky top-0 bg-surface-elevated z-10">
  <%= link_to courses_path, class: "flex items-center gap-2 text-muted hover:text-foreground transition-colors mb-4" do %>
    <%= lucide_icon "arrow-left", class: "w-5 h-5" %>
    <span>返回课程列表</span>
  <% end %>
  
  <h2 class="text-xl font-bold text-foreground"><%= @course.name %></h2>
  <p class="text-sm text-muted mt-1"><%= @course.chapters.count %> 章 · <%= @course.lessons.count %> 节</p>
</div>
```

**改动后**:
```erb
<div class="p-6 border-b border-border sticky top-0 bg-surface-elevated z-10">
  <div class="flex items-center justify-between mb-4">
    <%= link_to courses_path, class: "flex items-center gap-2 text-muted hover:text-foreground transition-colors" do %>
      <%= lucide_icon "arrow-left", class: "w-5 h-5" %>
      <span>返回课程列表</span>
    <% end %>
    
    <!-- 关闭侧边栏按钮 -->
    <button data-action="click->sidebar#toggle"
            class="btn-ghost-sm p-2 -mr-2"
            title="关闭目录">
      <%= lucide_icon "x", class: "w-5 h-5" %>
    </button>
  </div>
  
  <h2 class="text-xl font-bold text-foreground"><%= @course.name %></h2>
  <p class="text-sm text-muted mt-1"><%= @course.chapters.count %> 章 · <%= @course.lessons.count %> 节</p>
</div>
```

## 用户体验提升

### 关闭侧边栏的方式（按优先级排序）
1. **点击侧边栏头部的 X 按钮**（新增，最直观）
2. 点击遮罩层（侧边栏外部区域）
3. 再次点击顶部的"目录"按钮

### 视觉设计
- 使用 Lucide 的 "x" 图标（X 符号）
- 按钮类名：`btn-ghost-sm p-2 -mr-2`
- 位置：侧边栏头部右上角
- 悬停效果：继承 btn-ghost-sm 样式
- 工具提示：title="关闭目录"

## 技术实现

### Stimulus Action
```erb
data-action="click->sidebar#toggle"
```
- 复用现有的 `sidebar#toggle` 方法
- 无需额外的 JavaScript 代码
- 与其他关闭方式使用相同的逻辑

## 测试验证
✅ 所有 47 个测试通过
✅ 关闭按钮正确渲染
✅ Stimulus 验证器检查通过
✅ 点击 X 按钮可正常关闭侧边栏

## 相关文件
- `app/views/lessons/show.html.erb` - 视图文件
- `app/javascript/controllers/sidebar_controller.ts` - Stimulus 控制器（无需修改）
