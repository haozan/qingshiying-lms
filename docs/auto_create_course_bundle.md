# 后台一键创建课程套餐功能

## 功能说明

在后台管理界面添加了"一键创建标准套餐"按钮，管理员可以通过点击按钮自动创建包含所有课程的标准套餐，无需手动配置。

## 使用方法

### 方式一：通过后台界面（推荐）

1. 登录后台管理系统：`/admin/login`
2. 进入"Course bundles Management"页面：`/admin/course_bundles`
3. 点击页面右上角的 **"⚡ 一键创建标准套餐"** 按钮
4. 确认弹窗提示的套餐信息
5. 系统自动创建套餐并关联所有课程

**界面位置：**
```
Course bundles Management
┌───────────────────────────────────────────────┐
│  [⚡ 一键创建标准套餐]  [+ New Course bundle]  │
└───────────────────────────────────────────────┘
```

**确认提示内容：**
```
确认创建标准套餐？

套餐名称：3 课联报特惠
包含课程：AI课程、写作运营课、AI编程课
原价：￥30,000 元
现价：￥15,000 元
早鸟价：￥9,000 元
```

### 方式二：通过命令行

如果需要在服务器命令行直接执行：

```bash
rails runner tmp/create_course_bundle.rb
```

## 创建的套餐内容

| 字段 | 值 |
|------|-----|
| 名称 | 3 课联报特惠 |
| 描述 | 一次性购买所有课程，享受超值优惠！包含：AI课程、写作运营课、AI编程课 |
| 原价 | ¥30,000.00 |
| 现价 | ¥15,000.00 |
| 早鸟价 | ¥9,000.00 |
| 状态 | active |
| 包含课程 | AI课程、写作运营课、AI编程课（按顺序） |

## 功能特性

✅ **智能检测：** 自动检测课程是否存在，缺少课程时给出明确提示  
✅ **幂等操作：** 套餐已存在时自动更新，不会重复创建  
✅ **自动关联：** 自动将3门课程按顺序关联到套餐  
✅ **友好提示：** 操作成功/失败都有清晰的中文提示信息  
✅ **确认机制：** 点击按钮前需要确认，防止误操作

## 错误处理

### 错误1：缺少课程

**提示：** `❌ 缺少课程：AI课程。请先创建这些课程。`

**解决：** 先在后台创建缺少的课程，或运行 `rails db:seed` 创建基础数据

### 错误2：套餐保存失败

**提示：** `❌ 套餐保存失败：[具体错误信息]`

**解决：** 检查数据库连接和字段验证规则

## 技术实现

### 新增文件

1. **Service 类**
   - 文件：`app/services/auto_create_course_bundle_service.rb`
   - 作用：封装套餐创建逻辑，包括课程查找、套餐创建、课程关联

2. **测试文件**
   - 文件：`spec/services/auto_create_course_bundle_service_spec.rb`
   - 覆盖：成功创建、更新已存在、缺少课程等场景

3. **脚本文件**
   - 文件：`tmp/create_course_bundle.rb`
   - 作用：命令行直接执行的备用方案

### 修改文件

1. **控制器** (`app/controllers/admin/course_bundles_controller.rb`)
   ```ruby
   def auto_create
     result = AutoCreateCourseBundleService.new.call
     if result[:success]
       redirect_to admin_course_bundles_path, notice: result[:message]
     else
       redirect_to admin_course_bundles_path, alert: result[:message]
     end
   end
   ```

2. **路由** (`config/routes.rb`)
   ```ruby
   resources :course_bundles do
     post :auto_create, on: :collection
   end
   ```

3. **视图** (`app/views/admin/course_bundles/index.html.erb`)
   - 添加"一键创建标准套餐"按钮（绿色，带闪电图标）

4. **Factory** (`spec/factories/courses.rb`)
   - 修复 slug 冲突问题，使用 sequence 生成唯一名称

## 验证方法

### 1. 后台验证

访问 `/admin/course_bundles`，确认套餐列表中显示：
- 套餐名称：3 课联报特惠
- 原价/现价/早鸟价正确
- 状态为 active

### 2. 前台验证

访问 `/courses` 页面，确认显示套餐优惠板块：
```
┌─────────────────────────────────────────┐
│ 🎁 3 课联报特惠                          │
│                                         │
│ 原价: ￥30,000 元                        │
│ 现价: ￥15,000 元                        │
│ 早鸟价: ￥9,000 元 [立减￥6,000]          │
│                                         │
│ [立即报名] 或 [登录后购买]                │
└─────────────────────────────────────────┘
```

### 3. 测试验证

运行测试确认功能正常：
```bash
bundle exec rspec spec/services/auto_create_course_bundle_service_spec.rb
```

预期输出：`4 examples, 0 failures`

## 常见问题

**Q: 点击按钮后没有反应？**  
A: 检查浏览器控制台是否有 JavaScript 错误，确认表单提交正常

**Q: 提示"缺少课程"但课程明明存在？**  
A: 检查课程名称是否完全一致（注意空格），必须是"AI课程"、"写作运营课"、"AI编程课"

**Q: 套餐创建成功但前台不显示？**  
A: 确认套餐状态为 `active`，且 `@course_bundle` 在控制器中正确加载

**Q: 可以修改套餐内容吗？**  
A: 可以。创建后可以在后台编辑页面修改价格、描述等字段。但课程关联需要通过数据库或重新执行创建

## 相关文档

- [生产环境套餐创建指南](./production_course_bundle_setup.md)
- [Seeds 数据修复说明](./seeds_fix.md)
- [课程套餐购买流程文档](./load-failed-fix.md)
