FactoryBot.define do
  factory :course do
    sequence(:name) { |n| "Course #{n}" }
    description { "MyText" }
    status { "active" }
    position { 1 }
    annual_price { 999.0 }
  end
end
