require 'rails_helper'

RSpec.describe "Admin::OfflineSchedules", type: :request do
  before { admin_sign_in_as(create(:administrator)) }

  describe "GET /admin/offline_schedules" do
    it "returns http success" do
      get admin_offline_schedules_path
      expect(response).to be_success_with_view_check('index')
    end
  end

end
