# Open Graph (OG) 图片使用说明

## 概述

网站已经配置了完整的 Open Graph 和 Twitter Card meta 标签，用于在社交媒体平台（微信、微博、Twitter、Facebook 等）上分享时显示漂亮的预览卡片。

## 默认配置

在 `app/views/layouts/application.html.erb` 中，已经配置了以下默认 OG 标签：

- **og:type**: website
- **og:title**: 页面标题（如果有自定义标题，则显示为 "自定义标题 | 青狮营"）
- **og:site_name**: 青狮营
- **og:description**: 默认描述（可以在各个页面自定义）
- **og:image**: OG 分享图片（1200x630）
- **og:url**: 当前页面 URL
- **twitter:card**: summary_large_image
- **twitter:title**: 同 og:title
- **twitter:description**: 同 og:description
- **twitter:image**: 同 og:image

## OG 图片

主要 OG 图片位于 `app/assets/images/og-image.png`，尺寸为 1200x630 像素（符合社交媒体推荐规范）。

## 自定义页面的 OG 信息

### 1. 自定义页面标题

在任何视图文件中使用 `content_for :title`：

```erb
<% content_for :title, "课程列表" %>
```

这将生成：
- **og:title**: "课程列表 | 青狮营"
- **twitter:title**: "课程列表 | 青狮营"

### 2. 自定义页面描述

在 controller 中设置 `@page_description` 实例变量：

```ruby
class CoursesController < ApplicationController
  def index
    @page_description = "探索青狮营的精品课程，从 AI 基础到实战应用，助你掌握 AI 时代的核心技能。"
    @courses = Course.all
  end
end
```

这将生成：
- **og:description**: 你的自定义描述
- **twitter:description**: 你的自定义描述

**注意**：根据项目规范，不允许使用 `content_for :description`，必须使用 `@page_description` 实例变量。

### 3. 完整示例

在 `app/controllers/courses_controller.rb` 中：

```ruby
class CoursesController < ApplicationController
  def index
    @page_description = "探索青狮营的精品课程，从 AI 基础到实战应用，助你掌握 AI 时代的核心技能。"
    @courses = Course.all
  end
  
  def show
    @course = Course.find(params[:id])
    @page_description = @course.description.truncate(150)
  end
end
```

在 `app/views/courses/index.html.erb` 中：

```erb
<% content_for :title, "全部课程" %>

<div class="container">
  <!-- 页面内容 -->
</div>
```

## 测试 OG 标签

### 本地测试

使用 curl 命令查看生成的 OG 标签：

```bash
curl -s http://localhost:3000/ | grep 'og:'
```

### 在线测试工具

1. **Facebook Sharing Debugger**: https://developers.facebook.com/tools/debug/
2. **Twitter Card Validator**: https://cards-dev.twitter.com/validator
3. **LinkedIn Post Inspector**: https://www.linkedin.com/post-inspector/

## 最佳实践

1. **标题长度**: 建议在 60 字符以内
2. **描述长度**: 建议在 150-200 字符之间
3. **图片尺寸**: 1200x630 像素（Facebook 和 Twitter 推荐）
4. **图片格式**: PNG 或 JPG，文件大小建议小于 1MB
5. **必填字段**: 至少包含 title、description、image、url

## 注意事项

1. 社交平台会缓存 OG 信息，修改后可能需要使用上述测试工具强制刷新缓存
2. 微信分享依赖微信开放平台配置，可能需要额外的 JS SDK 配置
3. 确保 OG 图片可以公开访问（不需要登录即可查看）

## 更换 OG 图片

如果需要更换默认的 OG 图片：

1. 将新图片放到 `app/assets/images/` 目录
2. 修改 `app/views/layouts/application.html.erb` 中的 `asset_path('og-image.png')` 为新文件名
3. 重启服务器使更改生效
4. 使用测试工具验证新图片

## 常见问题

**Q: 为什么分享时显示的还是旧图片？**
A: 社交平台会缓存 OG 信息，使用 Facebook Sharing Debugger 或 Twitter Card Validator 可以强制刷新缓存。

**Q: 可以为不同页面使用不同的 OG 图片吗？**
A: 可以。在 `application.html.erb` 中修改图片路径逻辑，支持通过 `content_for :og_image` 自定义。

**Q: OG 标签对 SEO 有帮助吗？**
A: OG 标签主要用于社交分享，但良好的社交分享体验可以间接提升网站流量和品牌曝光。
