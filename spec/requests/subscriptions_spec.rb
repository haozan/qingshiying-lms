require 'rails_helper'

RSpec.describe "Subscriptions", type: :request do

  let(:user) { last_or_create(:user) }
  let(:course) { create(:course) }
  before { sign_in_as(user) }

  describe "GET /subscriptions/new" do
    it "returns http success" do
      get new_subscription_path(course_id: course.id, payment_type: 'annual')
      expect(response).to be_success_with_view_check('new')
    end
  end

  describe "POST /subscriptions" do
    it "creates a new subscription" do
      post subscriptions_path(course_id: course.id), params: { payment_type: 'annual' }
      expect(response).to be_success_with_view_check
    end
  end
end
