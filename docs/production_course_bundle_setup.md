# 生产环境课程套餐创建指南

## 问题背景

测试环境有"3课联报特惠"套餐，但生产环境没有，导致 `/courses` 页面缺少套餐优惠板块。

## 解决方案

### 方案一：运行脚本（推荐✅）

**优点：** 快速、准确、包含所有课程关联

在生产环境执行：

```bash
rails runner tmp/create_course_bundle.rb
```

**重要：** 脚本已包含在代码仓库的 `tmp/create_course_bundle.rb`，部署后即可直接运行。

脚本会自动：
1. 查找3门课程（AI课程、写作运营课、AI编程课）**注意：没有空格**
2. 创建套餐记录（如已存在则更新）
3. 关联所有课程到套餐
4. 输出详细的创建日志

**预期输出：**
```
Creating course bundle...
✅ Course bundle created/updated: 3 课联报特惠 (ID: 1)
  - Cleared old course associations
  - Added course: AI课程 (position: 1)
  - Added course: 写作运营课 (position: 2)
  - Added course: AI编程课 (position: 3)

✅ Success! Course bundle is ready.
  - Bundle ID: 1
  - Status: active
  - Includes 3 courses
  - Courses: AI课程, 写作运营课, AI编程课
```

---

### 方案二：运行 seeds（如果数据库为空）

如果生产环境数据库是新的或需要完全初始化：

```bash
rails db:seed
```

**注意：** 这会创建所有基础数据（课程、章节、课时、套餐等）

---

### 方案三：通过后台管理界面

**⚠️ 限制：** 当前后台界面**不支持**选择课程，只能创建套餐基本信息。

如需使用后台界面，需要先增强功能（参见下方"后续优化"）。

---

## 验证

创建成功后，访问 `/courses` 页面应该能看到：

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

---

## 套餐数据结构

```ruby
CourseBundle
  - name: "3 课联报特惠"
  - description: "一次性购买所有课程，享受超值优惠！包含：AI课程、写作运营课、AI编程课"
  - original_price: 30000.00
  - current_price: 15000.00
  - early_bird_price: 9000.00
  - status: 'active'
  
CourseBundleItem (关联表)
  - course_id: [AI课程ID]     position: 1
  - course_id: [写作运营课ID]  position: 2
  - course_id: [AI编程课ID]    position: 3
```

---

## 故障排查

### 错误1: "Not all courses found"

**原因：** 生产环境缺少课程数据

**解决：** 先运行 `rails db:seed` 创建课程数据

### 错误2: 页面依然不显示套餐

**检查步骤：**

1. 确认套餐存在且状态为 active：
   ```bash
   rails runner "puts CourseBundle.active.first.inspect"
   ```

2. 确认套餐包含课程：
   ```bash
   rails runner "bundle = CourseBundle.first; puts bundle.courses.pluck(:name)"
   ```

3. 检查控制器代码：
   ```ruby
   # app/controllers/courses_controller.rb line 15
   @course_bundle = CourseBundle.active.first
   ```

4. 重启应用加载新数据

---

## 后续优化（可选）

### 增强后台管理界面

当前后台套餐表单缺少课程选择功能，可以添加：

**需要修改的文件：**

1. `app/controllers/admin/course_bundles_controller.rb`
   - 在 `new` 和 `edit` 方法中加载所有课程
   - 在 `course_bundle_params` 中允许 `course_ids` 参数

2. `app/views/admin/course_bundles/_form.html.erb`（需创建）
   - 添加多选课程下拉框（使用 tom-select）

3. `app/models/course_bundle.rb`
   - 添加 `accepts_nested_attributes_for :course_bundle_items`

**示例代码：**

```ruby
# Controller
def course_bundle_params
  params.require(:course_bundle).permit(
    :name, :description, :original_price, :current_price, 
    :early_bird_price, :status, course_ids: []
  )
end

# View (使用 tom-select)
<div class="form-group">
  <%= form.label :course_ids, "选择课程" %>
  <%= form.select :course_ids, 
      Course.all.map { |c| [c.name, c.id] }, 
      {}, 
      { multiple: true, data: { controller: "tom-select" } } %>
</div>
```

---

## 相关文件

- 脚本文件: `tmp/create_course_bundle.rb`
- Seeds 文件: `db/seeds.rb` (line 252-276)
- 控制器: `app/controllers/admin/course_bundles_controller.rb`
- 模型: `app/models/course_bundle.rb`
- 前端视图: `app/views/courses/index.html.erb` (line 187-287)

---

## 总结

**推荐方案：** 在生产环境执行 `rails runner tmp/create_course_bundle.rb`

这是最快速、最可靠的方法，无需修改任何代码，且包含完整的课程关联。
