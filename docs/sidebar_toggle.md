# 学习页面侧边栏切换功能

## 功能概述

在学习页面（`/lessons/:slug`），侧边栏目录现在默认隐藏，让内容卡片占据更多空间，提供更好的学习体验。

**重要优化**：
- 整个学习页面填满视口（`h-screen`）
- 页面本身不可滚动（`overflow-hidden`）
- 学习卡片作为单一视图，内容在卡片内部滚动
- 无需页面级别的上下滚动

## 实现细节

### 1. 侧边栏状态
- **默认状态**: 隐藏（`-translate-x-full`）
- **切换方式**: 点击顶部导航栏的"目录"按钮
- **动画效果**: 使用 Tailwind 的 `transition-transform duration-300` 实现平滑滑动

### 2. Stimulus Controller

**文件**: `app/javascript/controllers/sidebar_controller.ts`

```typescript
export default class extends Controller<HTMLElement> {
  static targets = ["sidebar", "overlay"]
  static values = { visible: Boolean }

  connect(): void {
    // 默认隐藏侧边栏
    this.visibleValue = false
    this.updateSidebar()
  }

  toggle(): void {
    this.visibleValue = !this.visibleValue
    this.updateSidebar()
  }
}
```

### 3. 视图结构

**文件**: `app/views/lessons/show.html.erb`

```erb
<!-- 页面容器: 填满视口，禁止滚动 -->
<div class="h-screen bg-surface flex overflow-hidden"
     data-controller="sidebar" 
     data-sidebar-visible-value="false">
  
  <!-- 侧边栏: 固定定位，默认隐藏在左侧 -->
  <aside data-sidebar-target="sidebar"
         class="fixed left-0 top-0 bottom-0 -translate-x-full">
    ...
  </aside>

  <!-- 主内容区 -->
  <main class="flex-1">
    <!-- 切换按钮 -->
    <button data-action="click->sidebar#toggle">
      目录
    </button>
    
    <!-- 遮罩层 (点击关闭) -->
    <div data-sidebar-target="overlay"
         data-action="click->sidebar#toggle"
         class="fixed inset-0 bg-foreground/20 z-20 hidden">
    </div>
    
    <!-- 卡片容器: 填满高度 -->
    <div class="flex-1 p-8">
      <div class="w-full h-full max-w-5xl mx-auto">
        <!-- 学习卡片: 内容在卡片内部滚动 -->
        <div class="card-elevated h-full flex flex-col">
          <div class="prose flex-1 overflow-y-auto">
            <!-- Markdown 内容 -->
          </div>
        </div>
      </div>
    </div>
  </main>
</div>
```

## 用户体验

### 优点
1. **全屏卡片视图**: 学习页面填满整个浏览器视口，无页面级别滚动
2. **内容区域最大化**: 侧边栏隐藏后，学习卡片占据全屏宽度
3. **卡片内部滚动**: 课程内容在卡片内滚动，保持页面稳定
4. **按需显示目录**: 需要查看目录时点击"目录"按钮即可打开
5. **快速关闭**: 点击遮罩层或再次点击"目录"按钮可关闭侧边栏
6. **流畅动画**: 使用 CSS 过渡效果，提供平滑的视觉体验

### 交互流程
1. 用户进入学习页面 → 侧边栏默认隐藏，学习卡片填满整个视口
2. 点击"目录"按钮 → 侧边栏从左侧滑入，显示课程目录
3. 点击遮罩层或"目录"按钮 → 侧边栏滑出隐藏
4. 课程内容过长时 → 在卡片内部滚动，页面保持固定

## 测试覆盖

- ✅ Stimulus 验证器检查（targets、values、actions）
- ✅ 页面请求测试（`spec/requests/lessons_spec.rb`）
- ✅ HTML 属性正确性验证

## 相关文件

- `app/javascript/controllers/sidebar_controller.ts` - Stimulus 控制器
- `app/views/lessons/show.html.erb` - 学习页面视图
- `spec/javascript/stimulus_validation_spec.rb` - Stimulus 验证器
