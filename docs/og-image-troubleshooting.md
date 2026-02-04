# OG 图片抓取问题排查指南

## 问题描述
社交媒体平台（Facebook、Twitter、LinkedIn 等）抓取网站的 OG 图片时无法显示。

## 已完成的修复

### 1. 添加 og-image.png 到资产预编译列表
**文件**: `config/initializers/assets.rb`
```ruby
Rails.application.config.assets.precompile += %w[admin.js admin.css og-image.png]
```

### 2. 增强 OG Meta 标签
**文件**: `app/views/layouts/application.html.erb`

添加了以下标签：
- `og:image:type` - 指定图片类型为 `image/png`
- `og:image:alt` - 添加图片替代文本

### 3. 验证图片可访问性
- ✅ 开发环境: `https://3000-2cd2697bf6dc-web.clackypaas.com/dev-assets/og-image-0f621854.png` (200 OK, 753104 bytes)
- ✅ 生产环境: `https://3000-2cd2697bf6dc-web.clackypaas.com/assets/og-image-0f621854.png` (200 OK, 753104 bytes)

## OG 图片规格确认
- ✅ 尺寸: 1200 x 630 像素（符合社交媒体最佳实践）
- ✅ 格式: PNG（8-bit RGBA）
- ✅ 文件大小: 736KB（合理范围）

## 测试方法

### 方法 1: 使用测试页面
访问: `https://3000-2cd2697bf6dc-web.clackypaas.com/og-test.html`

这个测试页面包含：
- 完整的 OG meta 标签
- 直接的图片链接
- 图片预览

### 方法 2: 使用社交媒体调试工具

#### Facebook Sharing Debugger
1. 访问: https://developers.facebook.com/tools/debug/
2. 输入你的页面 URL（例如: `https://3000-2cd2697bf6dc-web.clackypaas.com/products`）
3. 点击"Debug"
4. 如果看到缓存的旧数据，点击"Scrape Again"清除缓存

#### Twitter Card Validator
1. 访问: https://cards-dev.twitter.com/validator
2. 输入你的页面 URL
3. 点击"Preview card"

#### LinkedIn Post Inspector
1. 访问: https://www.linkedin.com/post-inspector/
2. 输入你的页面 URL
3. 点击"Inspect"

### 方法 3: 命令行测试
```bash
# 测试页面 HTML
curl -s 'https://3000-2cd2697bf6dc-web.clackypaas.com/products' | grep 'og:image'

# 测试图片可访问性
curl -I 'https://3000-2cd2697bf6dc-web.clackypaas.com/dev-assets/og-image-0f621854.png'

# 模拟 Facebook 爬虫
curl -A 'facebookexternalhit/1.1' 'https://3000-2cd2697bf6dc-web.clackypaas.com/products'
```

## 常见问题

### 问题 1: 社交平台显示旧的或空白的图片
**原因**: 社交媒体平台会缓存 OG 数据

**解决方案**:
1. 使用上述调试工具手动刷新缓存
2. 等待 24-48 小时让缓存自动过期
3. 修改 OG 图片 URL（添加版本号参数）

### 问题 2: 开发环境和生产环境 URL 不同
**当前配置**:
- 开发环境: `/dev-assets/og-image-xxx.png`
- 生产环境: `/assets/og-image-xxx.png`

这是正常的！Rails 会根据环境自动选择正确的路径。

### 问题 3: 图片在浏览器中能看到，但社交平台抓取失败
**可能原因**:
1. **HTTPS 证书问题**: 开发环境的自签名证书可能不被信任
   - 解决方案: 部署到生产环境使用正式证书
2. **访问权限**: 某些防火墙或 CDN 设置可能阻止爬虫
   - 解决方案: 检查服务器配置，确保允许社交媒体爬虫访问
3. **User-Agent 限制**: 服务器可能屏蔽特定的 User-Agent
   - 解决方案: 确保允许 `facebookexternalhit`、`Twitterbot` 等爬虫

### 问题 4: 在生产环境部署后仍然无法显示
**检查清单**:
1. ✅ 确认 `RAILS_ENV=production rails assets:precompile` 已执行
2. ✅ 确认 `public/assets/og-image-xxx.png` 文件存在
3. ✅ 确认生产环境使用正确的域名（不是 localhost）
4. ✅ 确认 HTTPS 证书有效
5. ✅ 使用社交媒体调试工具清除缓存

## 下一步

如果问题依然存在，请提供以下信息：
1. 你在哪个社交平台遇到问题？（Facebook / Twitter / LinkedIn / 其他）
2. 你使用的是开发环境还是生产环境的 URL？
3. 社交媒体调试工具显示什么错误信息？
4. 截图显示的具体问题是什么？

## 生产环境部署检查清单

部署到生产环境前，确保：
- [ ] 运行 `RAILS_ENV=production rails assets:precompile`
- [ ] 提交并推送所有更改
- [ ] 确认生产环境有有效的 HTTPS 证书
- [ ] 部署后使用社交媒体调试工具测试
- [ ] 如有缓存，清除社交媒体平台的 OG 缓存
