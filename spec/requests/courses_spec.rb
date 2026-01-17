require 'rails_helper'

RSpec.describe "Courses", type: :request do

  let(:user) { last_or_create(:user) }
  before { sign_in_as(user) }

  describe "GET /courses" do
    it "returns http success" do
      get courses_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /courses/:id" do
    let(:course_record) { create(:course) }

    it "returns http success" do
      get course_path(course_record)
      expect(response).to be_success_with_view_check('show')
    end
  end
end
