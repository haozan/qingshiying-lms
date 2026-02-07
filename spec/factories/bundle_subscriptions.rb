FactoryBot.define do
  factory :bundle_subscription do

    association :user
    association :course_bundle
    status { "MyString" }
    started_at { Time.current }

  end
end
