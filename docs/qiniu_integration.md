# Qiniu Video Player Integration

## 功能说明

青狮营已集成七牛云视频播放器,支持:
- 自动播放/暂停控制
- 视频进度实时跟踪(每10秒同步一次)
- 视频完成状态自动标记
- HTML5 fallback 兼容方案

## 使用步骤

### 1. 配置七牛云账号

前往 [七牛云控制台](https://portal.qiniu.com/) 完成以下配置:

1. 创建视频存储空间(Bucket)
2. 配置CDN加速域名
3. 上传视频文件到存储空间

### 2. 加载 Qiniu Player SDK

编辑 `app/views/layouts/_qiniu_sdk.html.erb`,取消注释并替换为实际SDK地址:

```erb
<script src="https://pili-static.qnsdk.com/player/2.4.0/qiniu-player.js"></script>
```

参考文档: https://developer.qiniu.com/pili/8770/web-player

### 3. 在 Markdown 课程文件中配置视频URL

编辑 `courses/课程名/章节名/课程.md`,在 frontmatter 中添加 `video_url`:

```yaml
---
title: 课程标题
free: true
video_url: https://your-cdn-domain.com/path/to/video.mp4
---

课程内容...
```

### 4. 同步课程数据

运行 rake 任务同步 Markdown 文件到数据库:

```bash
rails courses:sync
```

### 5. 数据库字段(可选)

如需持久化视频观看进度,可为 `progresses` 表添加字段:

```ruby
class AddVideoProgressToProgresses < ActiveRecord::Migration[7.2]
  def change
    add_column :progresses, :video_progress, :integer, default: 0
    add_column :progresses, :video_completed, :boolean, default: false
  end
end
```

## 技术架构

- **前端**: `qiniu_player_controller.ts` (Stimulus)
- **后端**: `lessons_controller.rb` (update_video_progress, mark_video_completed)
- **路由**: PATCH `/lessons/:id/update_video_progress`
- **Fallback**: 自动降级到 HTML5 `<video>` 标签

## 待办事项

当前实现为基础集成,后续可增强:
- [ ] 视频播放统计和分析
- [ ] 视频倍速播放控制
- [ ] 视频质量切换(清晰度)
- [ ] 视频断点续播
- [ ] 视频水印和防盗链

## 注意事项

1. 七牛云 SDK 未加载时自动使用 HTML5 播放器
2. 视频 URL 必须支持 CORS 跨域访问
3. 生产环境建议配置 CDN 加速
4. 视频格式推荐: MP4 (H.264 编码)
