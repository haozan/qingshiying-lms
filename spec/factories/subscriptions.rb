FactoryBot.define do
  factory :subscription do

    association :user
    association :course
    started_at { Time.current }
    expires_at { Time.current }
    status { "MyString" }
    payment_type { "MyString" }

  end
end
