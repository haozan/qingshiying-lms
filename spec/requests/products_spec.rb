require 'rails_helper'

RSpec.describe "Products", type: :request do

  # Uncomment this if controller need authentication
  # let(:user) { last_or_create(:user) }
  # before { sign_in_as(user) }

  describe "GET /products" do
    it "returns http success" do
      get products_path
      expect(response).to be_success_with_view_check('index')
    end
  end
end
