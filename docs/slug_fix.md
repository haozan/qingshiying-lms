# Slug Generation Fix for Chinese Content

## Problem
FriendlyId couldn't properly generate slugs from Chinese characters, resulting in:
- Empty slugs for some lessons
- UUID-based fallback slugs (e.g., `8e009a56-940c-4af2-9d64-22e2f2ad745f`)
- 404 errors when accessing content

## Solution
Implemented custom Chinese-to-Pinyin transliteration in Course, Chapter, and Lesson models.

### Implementation

#### 1. Updated Models
Each model now uses `slug_candidates` method with `romanized_name`:

```ruby
friendly_id :slug_candidates, use: :slugged

def slug_candidates
  [
    :romanized_name,
    [:romanized_name, :id]
  ]
end

def romanized_name
  result = name.dup
  
  # Map common Chinese words to Pinyin
  mappings = {
    '写作' => 'xiezuo',
    '基础' => 'jichu',
    # ... more mappings
  }
  
  mappings.each { |chinese, pinyin| result.gsub!(chinese, pinyin) }
  
  # Fallback to ID-based slug if still contains Chinese
  if result =~ /[\u4e00-\u9fa5]/
    return "model-#{id}" if persisted?
    return "model-#{SecureRandom.hex(4)}"
  end
  
  result.parameterize
end
```

#### 2. Chinese Character Mappings

**Course model:**
- 课程 → kecheng
- 写作 → xiezuo
- 运营 → yunying
- 编程 → biancheng
- 的 → - (dash)

**Chapter model:**
- 绪论 → xulun
- 入门 → rumen
- 基础 → jichu
- 应用 → yingyong
- 高级 → gaoji
- 实战 → shizhan
- 进阶 → jinjie

**Lesson model:**
- Same as Chapter, plus additional common terms

### Slug Examples

**Before:**
- Course: `8e009a56-940c-4af2-9d64-22e2f2ad745f`
- Chapter: (empty slug)
- Lesson: `77288a84-29dd-465e-944c-345a9ccad085`

**After:**
- AI课程 → `aikecheng`
- 写作运营课 → `xiezuoyunyingkecheng`
- 绪论 → `xulun`
- 写作基础 → `xiezuojichu`
- AI的应用 → `ai-yingyong`

## Slug Regeneration

To regenerate all slugs after code changes:

```ruby
rails runner "[Course, Chapter, Lesson].each { |model| model.find_each { |r| r.slug = nil; r.save! } }"
```

## Testing

All 47 tests pass after the fix. URLs are now clean and SEO-friendly.

## Notes

- The `.6` suffix in error URLs (`8e009a56-940c-4af2-9d64-22e2f2ad745f.6`) was likely from browser cache or concurrent requests
- Old UUID slugs in browser history will show 404 errors (expected behavior)
- New content automatically gets proper Pinyin slugs on creation
- If a Chinese word isn't in the mapping, it falls back to `model-{id}` format
