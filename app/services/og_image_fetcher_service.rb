require 'open-uri'
require 'nokogiri'

class OgImageFetcherService < ApplicationService
  def initialize(url)
    @url = url
  end

  def call
    return nil if @url.blank?

    # Validate URL format
    uri = URI.parse(@url)
    return nil unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    # Fetch the HTML content
    html = URI.open(@url, 'User-Agent' => 'Mozilla/5.0', read_timeout: 10).read
    doc = Nokogiri::HTML(html)

    # Try to find OG image meta tag
    og_image = doc.at_css('meta[property="og:image"]')&.[]('content')
    return og_image if og_image.present?

    # Fallback to Twitter image meta tag
    twitter_image = doc.at_css('meta[name="twitter:image"]')&.[]('content')
    return twitter_image if twitter_image.present?

    nil
  rescue => e
    Rails.logger.error("Failed to fetch OG image from #{@url}: #{e.message}")
    nil
  end
end
