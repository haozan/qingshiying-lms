class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # Callbacks
  before_validation :fetch_og_image, if: -> { link_url.present? && og_url.blank? }

  # Validations
  validates :title, presence: true
  validates :subtitle, presence: true

  # At least one of og_url or cover_image_url must be present
  validate :must_have_cover_source

  # Get the cover image URL (prioritize fetched OG image, then manual cover)
  def cover_url
    og_url.presence || cover_image_url.presence
  end

  private

  def fetch_og_image
    fetched_image = OgImageFetcherService.call(link_url)
    self.og_url = fetched_image if fetched_image.present?
  end

  def must_have_cover_source
    if og_url.blank? && cover_image_url.blank?
      errors.add(:base, '必须提供跳转链接（自动抓取OG图）或封面图片链接')
    end
  end
end
