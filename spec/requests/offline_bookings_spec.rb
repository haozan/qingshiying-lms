require 'rails_helper'

RSpec.describe "Offline bookings", type: :request do

  let(:user) { last_or_create(:user) }
  before { sign_in_as(user) }

  describe "GET /offline_bookings" do
    it "returns http success" do
      get offline_bookings_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /offline_bookings/new" do
    it "returns http success" do
      get new_offline_booking_path
      expect(response).to be_success_with_view_check('new')
    end
  end

  describe "POST /offline_bookings" do
    it "creates a new offline_booking" do
      post offline_bookings_path, params: { offline_booking: attributes_for(:offline_booking) }
      expect(response).to be_success_with_view_check
    end
  end
end
