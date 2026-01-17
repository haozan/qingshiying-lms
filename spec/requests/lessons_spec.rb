require 'rails_helper'

RSpec.describe "Lessons", type: :request do

  let(:user) { last_or_create(:user) }
  before { sign_in_as(user) }

  describe "GET /lessons/:id" do
    let(:lesson_record) { create(:lesson) }

    it "returns http success" do
      get lesson_path(lesson_record)
      expect(response).to be_success_with_view_check('show')
    end
  end
end
