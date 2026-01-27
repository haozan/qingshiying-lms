require 'rails_helper'

RSpec.describe "Admin::Courses", type: :request do
  before { admin_sign_in_as(create(:administrator)) }

  describe "GET /admin/courses" do
    it "returns http success" do
      get admin_courses_path
      expect(response).to be_success_with_view_check('index')
    end
  end

end
