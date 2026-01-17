FactoryBot.define do
  factory :homework do

    association :user
    association :lesson
    content { "MyText" }
    status { "MyString" }
    liked_at { Time.current }

  end
end
