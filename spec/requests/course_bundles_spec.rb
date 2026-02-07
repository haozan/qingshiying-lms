require 'rails_helper'

RSpec.describe "Course bundles", type: :request do
  let(:user) { last_or_create(:user) }
  before { sign_in_as(user) }

  describe "GET /course_bundles" do
    it "returns http success" do
      get course_bundles_path
      expect(response).to be_success_with_view_check('index')
    end
  end

  describe "GET /course_bundles/:id" do
    let!(:course_bundle) { CourseBundle.create!(name: 'Test Bundle', description: 'Test', original_price: 1000, status: 'active') }

    it "returns http success" do
      get course_bundle_path(course_bundle)
      expect(response).to be_success_with_view_check('show')
    end
  end

  describe "POST /course_bundles/:id/purchase" do
    let!(:course_bundle) { CourseBundle.create!(name: 'Test Bundle', description: 'Test', original_price: 1000, status: 'active') }
    let!(:course1) { last_or_create(:course) }
    let!(:course2) { create(:course, name: 'Course 2', slug: 'course-2') }

    before do
      course_bundle.course_bundle_items.create!(course: course1, position: 1)
      course_bundle.course_bundle_items.create!(course: course2, position: 2)
    end

    it "creates bundle subscription and redirects to Stripe" do
      expect {
        post purchase_course_bundle_path(course_bundle)
      }.to change { user.bundle_subscriptions.count }.by(1)

      expect(response).to have_http_status(:redirect)
    end
  end
end
