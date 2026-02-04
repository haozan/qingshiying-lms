# 产品 OG 图片更新功能

## 功能概述

在后台管理的产品详情页面，管理员可以手动触发重新抓取产品的 OG 图片。当产品链接的 OG 图片发生更新时，无需手动编辑产品，只需点击"更新 OG 图"按钮即可自动重新抓取。

## 功能位置

**路径**: `/admin/products/:id` （产品详情页）

**按钮位置**: OG Image URL 字段右侧

## 使用方法

### 前提条件
产品必须有 `link_url`（跳转链接）才能显示"更新 OG 图"按钮。

### 操作步骤
1. 进入后台管理 → Products
2. 点击某个产品查看详情
3. 在 "OG Image URL" 字段右侧找到"更新 OG 图"按钮
4. 点击按钮，确认操作
5. 系统会自动：
   - 访问产品的 `link_url`
   - 抓取页面的 OG 图片 URL（`og:image` 或 `twitter:image`）
   - 更新产品的 `og_url` 字段
   - 显示成功或失败消息

## 页面增强功能

### 1. Link URL 显示
- 显示产品的跳转链接
- 可点击链接在新标签页打开
- 带有外部链接图标

### 2. OG Image URL 预览
- 显示完整的 OG 图片 URL
- **实时图片预览**：直接显示 OG 图片
- 图片加载失败时显示错误提示

### 3. Manual Cover Image URL 预览
- 显示手动设置的封面图片 URL
- **实时图片预览**：直接显示封面图片
- 图片加载失败时显示错误提示

### 4. 当前使用的封面图
- 蓝色高亮框显示实际使用的封面图 URL
- 说明优先级规则：`og_url` > `cover_image_url`
- 显示最终在前台页面使用的图片链接

## 技术实现

### Controller Action
```ruby
# app/controllers/admin/products_controller.rb
def refresh_og_image
  if @product.link_url.blank?
    redirect_to admin_product_path(@product), alert: 'Cannot refresh OG image: link_url is blank.'
    return
  end

  fetched_image = OgImageFetcherService.call(@product.link_url)

  if fetched_image.present?
    @product.update(og_url: fetched_image)
    redirect_to admin_product_path(@product), notice: 'OG image was successfully refreshed.'
  else
    redirect_to admin_product_path(@product), alert: 'Failed to fetch OG image from the link URL.'
  end
end
```

### 路由配置
```ruby
# config/routes.rb
namespace :admin do
  resources :products do
    member do
      post :refresh_og_image
    end
  end
end
```

### 服务类
使用现有的 `OgImageFetcherService` 服务：
- 访问目标 URL
- 解析 HTML
- 查找 `og:image` meta 标签
- 回退到 `twitter:image` meta 标签
- 返回图片 URL 或 nil

## 错误处理

### 场景 1: 没有 link_url
- **提示**: "Cannot refresh OG image: link_url is blank."
- **按钮**: 不显示"更新 OG 图"按钮

### 场景 2: 抓取失败
- **提示**: "Failed to fetch OG image from the link URL."
- **可能原因**:
  - URL 无法访问
  - 页面没有 OG image meta 标签
  - 网络超时（10秒超时）
  - HTML 解析失败

### 场景 3: 抓取成功
- **提示**: "OG image was successfully refreshed."
- **结果**: `og_url` 字段被更新为新抓取的图片 URL

## 使用场景

### 场景 1: 产品网站更新了 OG 图片
1. 产品最初创建时自动抓取了 OG 图
2. 后来产品网站更新了 OG 图片设计
3. 管理员点击"更新 OG 图"按钮
4. 系统重新抓取并更新 `og_url`
5. 前台页面显示最新的产品封面图

### 场景 2: 初次创建时抓取失败
1. 创建产品时网络不稳定，抓取失败
2. 使用了 `cover_image_url` 作为临时封面
3. 后续网络恢复后，点击"更新 OG 图"
4. 成功抓取到 OG 图片
5. 前台优先显示 OG 图片

### 场景 3: 验证抓取结果
1. 不确定当前 OG 图是否是最新的
2. 点击"更新 OG 图"重新抓取
3. 查看页面上的图片预览
4. 确认图片是否正确

## 封面图片优先级规则

在 Product 模型中，`cover_url` 方法定义了封面图片的优先级：

```ruby
def cover_url
  og_url.presence || cover_image_url.presence
end
```

**优先级**:
1. **OG Image URL** (`og_url`) - 从产品链接自动抓取的 OG 图片
2. **Manual Cover Image URL** (`cover_image_url`) - 手动设置的备用封面图

**建议**:
- 优先使用 `link_url` + 自动抓取 OG 图
- 只在以下情况使用 `cover_image_url`:
  - 产品没有专属网站
  - 产品网站没有设置 OG 图
  - 需要使用不同于网站 OG 图的封面

## 测试

### 手动测试步骤
1. 访问 `/admin/products`
2. 选择一个有 `link_url` 的产品
3. 点击"更新 OG 图"按钮
4. 确认操作
5. 验证成功消息
6. 检查 OG Image URL 和图片预览是否更新

### 测试用例
```ruby
# 待添加到 spec/requests/admin_products_spec.rb
describe 'POST /admin/products/:id/refresh_og_image' do
  context 'when product has link_url' do
    it 'refreshes the OG image' do
      product = create(:product, link_url: 'https://example.com')
      
      post refresh_og_image_admin_product_path(product)
      
      expect(response).to redirect_to(admin_product_path(product))
      expect(flash[:notice]).to eq('OG image was successfully refreshed.')
    end
  end
  
  context 'when product has no link_url' do
    it 'shows an error' do
      product = create(:product, link_url: nil)
      
      post refresh_og_image_admin_product_path(product)
      
      expect(response).to redirect_to(admin_product_path(product))
      expect(flash[:alert]).to include('link_url is blank')
    end
  end
end
```

## UI 截图说明

### "更新 OG 图" 按钮
- 位置：OG Image URL 字段标签右侧
- 图标：刷新图标（refresh-cw）
- 颜色：次要按钮样式（btn-secondary）
- 只在有 `link_url` 时显示

### 图片预览
- OG Image URL 下方显示实际图片
- Manual Cover Image URL 下方显示实际图片
- 图片最大宽度：`max-w-md`
- 圆角边框：`rounded border`
- 加载失败时显示错误提示

### 当前使用的封面图
- 蓝色背景高亮框
- 显示 `cover_url` 的值
- 说明优先级规则
- 帮助管理员理解哪个图片会在前台显示

## 相关文件

- **Controller**: `app/controllers/admin/products_controller.rb`
- **Model**: `app/models/product.rb`
- **Service**: `app/services/og_image_fetcher_service.rb`
- **View**: `app/views/admin/products/show.html.erb`
- **Route**: `config/routes.rb`

## 注意事项

1. **网络依赖**: 抓取功能依赖外部网站的可访问性
2. **超时设置**: 请求超时时间为 10 秒
3. **User-Agent**: 使用 Mozilla/5.0 作为 User-Agent
4. **错误处理**: 抓取失败不会影响产品其他数据
5. **覆盖确认**: 点击按钮前会弹出确认对话框，防止误操作

## 未来增强

- [ ] 添加批量更新 OG 图功能
- [ ] 在产品列表页显示 OG 图状态（是否已抓取、是否过期）
- [ ] 定时任务自动更新 OG 图
- [ ] 记录 OG 图更新历史
- [ ] 支持手动输入 OG 图 URL（不抓取）
