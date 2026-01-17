require 'rails_helper'

RSpec.describe "Admin::Homeworks", type: :request do
  before { admin_sign_in_as(create(:administrator)) }

  describe "GET /admin/homeworks" do
    it "returns http success" do
      get admin_homeworks_path
      expect(response).to be_success_with_view_check('index')
    end
  end

end
