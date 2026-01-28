class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Validations
  validates :title, presence: true
  validates :subtitle, presence: true

  # At least one of og_url or cover_image_url must be present
  validate :must_have_cover_source

  # Get the cover image URL (prioritize OG URL)
  def cover_url
    og_url.presence || cover_image_url.presence
  end

  private

  def must_have_cover_source
    if og_url.blank? && cover_image_url.blank?
      errors.add(:base, '必须提供 OG 图链接或封面图片链接')
    end
  end
end
