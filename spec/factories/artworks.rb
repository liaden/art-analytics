FactoryGirl.define do
  factory :artwork do
    name 'test_artwork'

    trait :with_merchandise do
      merchandises { [ create(:merchandise) ] }
    end
  end

  factory :unknown_artwork, class: Artwork do
    name "doesn't matter"

    after(:create) do |artwork|
      create(:unknown_merchandise, artwork: artwork)
    end
  end
end
