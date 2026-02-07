FactoryBot.define do
  factory :course_bundle do

    name { "MyString" }
    description { "MyText" }
    original_price { 9.99 }
    current_price { 9.99 }
    early_bird_price { 9.99 }
    status { "MyString" }

  end
end
