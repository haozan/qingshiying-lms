FactoryBot.define do
  factory :course_bundle_item do

    association :course_bundle
    association :course
    position { 1 }

  end
end
