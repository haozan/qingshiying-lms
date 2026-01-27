FactoryBot.define do
  factory :course do

    name { "MyString" }
    slug { "MyString" }
    description { "MyText" }

    status { "active" }
    position { 1 }
    annual_price { 999.0 }


  end
end
