FactoryBot.define do
  factory :lesson do

    association :chapter
    name { "MyString" }
    slug { "MyString" }
    content { "MyText" }
    video_url { "MyString" }
    free { false }
    position { 1 }

  end
end
