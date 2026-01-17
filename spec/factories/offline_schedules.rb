FactoryBot.define do
  factory :offline_schedule do

    association :course
    schedule_date { Date.today }
    max_attendees { 1 }
    status { "MyString" }

  end
end
