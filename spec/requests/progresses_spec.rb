require 'rails_helper'

RSpec.describe "Progresses", type: :request do

  let(:user) { last_or_create(:user) }
  before { sign_in_as(user) }

  describe "GET /progresses/dashboard" do
    it "returns http success" do
      get dashboard_progresses_path
      expect(response).to be_success_with_view_check('dashboard')
    end
  end

end
