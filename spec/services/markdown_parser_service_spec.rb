require 'rails_helper'

RSpec.describe MarkdownParserService, type: :service do
  describe '#sync_all_courses' do
    it 'can be initialized and called' do
      service = MarkdownParserService.new
      expect { service.sync_all_courses }.not_to raise_error
    end
  end
end
