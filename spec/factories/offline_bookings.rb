FactoryBot.define do
  factory :offline_booking do

    association :user
    association :offline_schedule
    status { "MyString" }
    booked_at { Time.current }

  end
end
