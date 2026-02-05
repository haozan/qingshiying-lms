require 'rails_helper'

RSpec.describe OgImageFetcherService, type: :service do
  describe '.call' do
    it 'can be called with a URL' do
      expect { OgImageFetcherService.call('https://example.com') }.not_to raise_error
    end

    it 'returns nil for invalid URL' do
      result = OgImageFetcherService.call('invalid-url')
      expect(result).to be_nil
    end
  end
end
