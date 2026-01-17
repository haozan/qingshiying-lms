FactoryBot.define do
  factory :chapter do

    association :course
    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    position { 1 }

  end
end
