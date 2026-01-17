FactoryBot.define do
  factory :progress do

    association :user
    association :lesson
    completed_at { Time.current }
    status { "MyString" }

  end
end
