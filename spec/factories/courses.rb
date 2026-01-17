FactoryBot.define do
  factory :course do

    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }
    course_type { "subscription" }
    status { "active" }
    position { 1 }
    annual_price { 999.0 }
    buyout_price { 2999.0 }

  end
end
