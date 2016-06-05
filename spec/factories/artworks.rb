FactoryGirl.define do
  factory :artwork do
    name 'test_artwork'

    trait :with_merchandise do
      merchandises { [ create(:merchandise) ] }
    end
  end
end